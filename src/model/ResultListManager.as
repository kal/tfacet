/*******************************************************************************
 * Copyright (c) 2011 Sören Brunk.
 * This file is part of tFacet.
 * 
 * tFacet is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * tFacet is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with tFacet.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/

package model
{
	import connection.SPARQLService;
	
	import events.FilterUpdatedEvent;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import model.facettree.FacetTreeLoader;
	import model.facettree.FacetTreeNode;
	import model.owl.OwlObjectProperty;
	import model.rdf.IntegerLiteral;
	import model.rdf.Resource;
	import model.sparql.RawQuery;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.CollectionEvent;
	import mx.rpc.events.FaultEvent;
	
	import parser.SPARQLResult;
	
	import ui.ResultListComponent;

	public class ResultListManager
	{
		private var facetManager:FacetManager = FacetManager.getInstance();
		public var component:ResultListComponent;
		[Bindable]
		public var instances:ArrayCollection = new ArrayCollection();
		private var _instanceMap:Object = {};
		[Bindable]
		public var instanceCount:uint;
		[Bindable]
		public var currentPage:uint = 1;
		public static const ITEMS_PER_PAGE:uint = 50;
		[Bindable]
		public var possibleColumns:ArrayCollection;
		private var instanceService:SPARQLService = new SPARQLService();
		private var instanceCountService:SPARQLService = new SPARQLService();
		[Bindable]
		public var sort:FacetTreeNode;
		public var sortDescending:Boolean = true;

		public function ResultListManager(component:ResultListComponent)
		{
			this.component = component;
			
			instances.sort = new Sort();
			instances.sort.fields = [new SortField("label", true, false)];
			instances.refresh();
			
			FilterManager.getInstance().addEventListener(FilterUpdatedEvent.FILTER_UPDATED, filterUpdatedHandler);
			facetManager.facetTree.loader.addEventListener(FacetTreeLoader.LOADING_FINISHED, treeNodesLoadedHandler);
			requestInstanceCount();
			requestInstances();
		}
		
		private function treeNodesLoadedHandler(e:Event):void
		{
			possibleColumns = new ArrayCollection(facetManager.facetTree.children.source);
			possibleColumns.filterFunction = filter;
			var sort:Sort = new Sort();
			sort.fields = [new SortField("instanceCount", false, true, true)];
			possibleColumns.sort = sort;
			possibleColumns.refresh();
			component.changeColumnsButton.enabled = true;
			
			function filter(item:Object):Boolean
			{
				var node:FacetTreeNode = item as FacetTreeNode;
				if (node.instanceCount <= 3) {return false};
//				if (node.propertyURI == "http://dbpedia.org/ontology/abstract") {return false};
//				if (node.propertyURI == "http://dbpedia.org/ontology/thumbnail") {return false};
				return true;
			}
		}
		
		private function filterUpdatedHandler(e:FilterUpdatedEvent):void
		{
			currentPage = 1;
			requestInstanceCount(component.textFilter.text);
			requestInstances(0, ITEMS_PER_PAGE, component.textFilter.text);
		}
		
		public function requestInstanceCount(filterString:String=""):void
		{
			var q:RawQuery = new RawQuery();
			q.append('SELECT COUNT(DISTINCT ?instance) as ?instance_count FROM <http://dbpedia.org> WHERE {');
			if (filterString != "") {
				q.append('{?instance rdfs:label ?instance_label ' +
					'FILTER(lang(?instance_label)="en" || lang(?instance_label)="") ' +
					'?instance_label bif:contains "'+filterString+'"}');
			} else {
				q.append('{?instance rdfs:label ?instance_label FILTER(lang(?instance_label)="en" || lang(?instance_label)="") }');
			}
			q.append('{SELECT DISTINCT ?instance WHERE {');
			q.append(FilterManager.getInstance().getFilterPattern().toString());
			q.append('}}}');
			instanceCountService.query = q.createQueryString();
			trace(instanceCountService.query + "\n");
			instanceCountService.doRequest(instanceCountResult, faultHandler);
		}
		
		private function instanceCountResult(results:SPARQLResult, service:SPARQLService):void {
			for each (var result:Object in results.resultList) {
				if (result["instance_count"] is IntegerLiteral) {
					instanceCount = (result["instance_count"] as IntegerLiteral).value;
				} else {
					// TODO fehler abfangen
				}
			}
		}
		
		public function requestInstances(offset:uint=0, limit:uint=ITEMS_PER_PAGE, filterString:String=""):void {
//			// cancel pending request, if required

			instances.removeAll();
			_instanceMap = [];
			
			var q:RawQuery = new RawQuery();
			q.append('SELECT ?instance ?instance_label FROM <http://dbpedia.org> WHERE {');
			if (filterString != "") {
				q.append('{?instance rdfs:label ?instance_label ' +
					'FILTER(lang(?instance_label)="en" || lang(?instance_label)="") ' +
					'?instance_label bif:contains "'+filterString+'"}');
			} else {
				q.append('{?instance rdfs:label ?instance_label FILTER(lang(?instance_label)="en" || lang(?instance_label)="") }');
			}
			
			if (sort != null) {
				if (sort.reversedProperty) {
					q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
					q.append('{?column <'+sort.propertyURI+'> ?instance}');				
				} else {
					if (sort.property is OwlObjectProperty) {
						q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
						q.append('{?instance <'+sort.propertyURI+'> ?column}');
					} else {
						q.append('{?instance <'+sort.propertyURI+'> ?column_label');
						q.append('FILTER(lang(?column_label)="en" || lang(?column_label)="")}');			
					}
				}				
			}
			
			q.append('{SELECT DISTINCT ?instance WHERE {');
			q.append(FilterManager.getInstance().getFilterPattern().toString());
			q.append('}}');
			
			// TODO sort desc/asc bei flex andersrum als bei sparql?
			if (sort != null) {
				if (sortDescending == false) {
					q.append('} ORDER BY DESC(?column_label) LIMIT '+limit+' OFFSET ' + offset);
				} else {
					q.append('} ORDER BY ?column_label LIMIT '+limit+' OFFSET ' + offset);	
				}
			} else {
				if (sortDescending == false) {
					q.append('} ORDER BY DESC(?instance_label) LIMIT '+limit+' OFFSET ' + offset);
				} else {
					q.append('} ORDER BY ?instance_label LIMIT '+limit+' OFFSET ' + offset);
				}
			}
			
			instanceService.query = q.createQueryString();
			trace(instanceService.query + "\n");
			instanceService.doRequest(instancesResult, faultHandler);
		}

		private function instancesResult(results:SPARQLResult, service:SPARQLService):void
		{
			for each (var result:Object in results.resultList) {
				if (result[Constants.INSTANCE_VAR] is Resource) {
					var instance:ResultListItem = new ResultListItem();
					instance.resource = result[Constants.INSTANCE_VAR];
					instance.resource.label = result["instance_label"];
					instance.label = instance.resource.label.toString();
					instances.addItem(instance);
					_instanceMap[instance.resource.uri] = instance;
				}
			}
			if (component.selectionWindow.columnsSelection != null) {
				for each (var node:FacetTreeNode in component.selectionWindow.columnsSelection.selectedItems) {
					requestExtraColumns(node);
				}				
			}
		}
		
		public function getInstance(uri:String):ResultListItem
		{
			return _instanceMap[uri];
		}
		
		public function requestExtraColumns(node:FacetTreeNode, offset:uint=0):void {
			if (instanceCount == 0) {
				return;
			}
			var q:RawQuery = new RawQuery();
			var instanceURIs:Array = [];
			var instanceString:String = ''; //'<'+instances.source.join(">, <")+'>';
			for each (var instance:ResultListItem in instances) {
				instanceURIs.push('<'+instance.resource.uri+'>');
			}
			instanceString = instanceURIs.join(", \n");
			if (node.reversedProperty) {
				q.append('SELECT ?instance ?column_label FROM <http://dbpedia.org> WHERE {');
				q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
				q.append('{?column <'+node.propertyURI+'> ?instance');
				q.append('FILTER (?instance IN ('+instanceString+'))}');
				q.append('} ORDER BY ?column_label LIMIT 1000 OFFSET ' + offset);					
			} else {
				if (node.property is OwlObjectProperty) {
					q.append('SELECT ?instance ?column_label FROM <http://dbpedia.org> WHERE {');
					q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
					q.append('{?instance <'+node.propertyURI+'> ?column');
					q.append('FILTER (?instance IN ('+instanceString+'))}');
					q.append('} ORDER BY ?column_label LIMIT 1000 OFFSET ' + offset);	
				} else {
					q.append('SELECT ?instance ?column_label FROM <http://dbpedia.org> WHERE {');
					q.append('{?instance <'+node.propertyURI+'> ?column_label');
					q.append('FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
					q.append('FILTER (?instance IN ('+instanceString+'))');
					q.append('} ORDER BY ?column_label LIMIT 1000 OFFSET ' + offset);				
				}
			}
			
			var service:SPARQLService = new SPARQLService();
			//  temporarily use LOD endpoint for this request due to
			// problems with standard sparql endpoint
			//service.endpoint = Constants.LOD_ENDPOINT;
			service.query = q.createQueryString();
			service.doRequest(extraColumnsResult, faultHandler);
			service.customData.node = node;
//			}
		}
		
		private function extraColumnsResult(results:SPARQLResult, service:SPARQLService):void
		{
			for each (var result:Object in results.resultList) {
				if (result[Constants.INSTANCE_VAR] is Resource) {
					var resource:Resource = result[Constants.INSTANCE_VAR];
					var instance:ResultListItem = getInstance(resource.uri);
					if (instance.columns[service.customData.node] == null)
					{
						instance.columns[service.customData.node] = [result["column_label"]];
					} else
					{
						instance.columns[service.customData.node].push(result["column_label"]);
					}
				}
			}
			instances.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
		}
	
		private function faultHandler(event:FaultEvent, service:SPARQLService):void {
			//requestToken = null;
			trace(event.fault.content);
		}
	}
}
