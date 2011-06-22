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

package model.facets
{
	import connection.SPARQLService;
	
	import flash.events.Event;
	
	import model.Constants;
	import model.FilterManager;
	import model.facettree.FacetTreeNode;
	import model.owl.OwlObjectProperty;
	import model.rdf.Resource;
	import model.sparql.RawQuery;
	
	import mx.events.CollectionEvent;
	import mx.rpc.events.FaultEvent;
	
	import parser.SPARQLResult;

	/**
	 * SPARQL logic for loading data into an object facet.
	 */
	public class ObjectFacetLoader
	{
		public var facet:ObjectFacet;
		private var FACET_INSTANCE_VAR:String;
		private var FACET_INSTANCE_LABEL_VAR:String;
		private var _instanceMap:Object = [];
		public function ObjectFacetLoader(facet:ObjectFacet)
		{
			this.facet = facet;
			FACET_INSTANCE_VAR = facet.node.loader.FACET_INSTANCE_VAR;
			FACET_INSTANCE_LABEL_VAR = FACET_INSTANCE_VAR + "_label";
		}
		/**
		 * Request the number of facet entries with filters from other facets applied
		 */
		public function requestInstanceCount(filtering:Boolean=true):void
		{			
			var q:RawQuery = new RawQuery();
			q.append('SELECT COUNT(DISTINCT ?'+FACET_INSTANCE_VAR+') as ?facet_instance_count');
			q.append('FROM <http://dbpedia.org> WHERE {');
			q.append('{SELECT DISTINCT ?'+FACET_INSTANCE_VAR+' WHERE {');
			q.append(facet.node.loader.createPreFilterPattern());
			// add filters from other facets
			q.append(FilterManager.getInstance().getFilterPattern(facet).toString());
			q.append("}}");
			
			if (facet.filterString != "") {
				q.append('{?'+FACET_INSTANCE_VAR+' rdfs:label ?'+FACET_INSTANCE_LABEL_VAR+
					' FILTER(lang(?'+FACET_INSTANCE_LABEL_VAR+') = "en" || lang(?'+FACET_INSTANCE_LABEL_VAR+')="")'+
					' ?'+FACET_INSTANCE_LABEL_VAR+' bif:contains "'+facet.filterString+'"}');
			} else {
				q.append('{?'+FACET_INSTANCE_VAR+' rdfs:label ?'+FACET_INSTANCE_LABEL_VAR+' ');
				q.append('FILTER(lang(?'+FACET_INSTANCE_LABEL_VAR+') = "en" || lang(?'+FACET_INSTANCE_LABEL_VAR+')="")}');
			}
			q.append('}');
			
			var service:SPARQLService = new SPARQLService()
			service.query = q.createQueryString();
			service.doRequest(instancesCountResult, faultHandler);
			trace(service.query, "\n");
		}
		private function instancesCountResult(result:SPARQLResult, service:SPARQLService):void
		{
			var facetInstance:Resource;
			var resultRow:Object = result.resultList[0];
			facet.instanceCount = resultRow["facet_instance_count"];
//			facet.instances.source.length = facet.instanceCount;
		}
		protected function faultHandler(event:FaultEvent, service:SPARQLService):void
		{
			trace(event.fault.content);
		}
		
		public function requestInstances(offset:uint, limit:uint):void
		{
			_instanceMap = [];
			
			var q:RawQuery = new RawQuery();
			q.append('SELECT ?'+FACET_INSTANCE_VAR+' ?'+FACET_INSTANCE_LABEL_VAR + ' ?instance_count');
			q.append('FROM <http://dbpedia.org> WHERE {');
			q.append('{SELECT DISTINCT ?'+FACET_INSTANCE_VAR+' COUNT(?instance) as ?instance_count WHERE {');
			q.append(facet.node.loader.createPreFilterPattern());
			// add filters from other facets
			q.append(FilterManager.getInstance().getFilterPattern(facet).toString());
			q.append("}}");
			
			if (facet.filterString != "") {
				q.append('{?'+FACET_INSTANCE_VAR+' rdfs:label ?'+FACET_INSTANCE_LABEL_VAR+
					' FILTER(lang(?'+FACET_INSTANCE_LABEL_VAR+') = "en" || lang(?'+FACET_INSTANCE_LABEL_VAR+')="")'+
					' ?'+FACET_INSTANCE_LABEL_VAR+' bif:contains "'+facet.filterString+'"}');
			} else {
				q.append('{?'+FACET_INSTANCE_VAR+' rdfs:label ?'+FACET_INSTANCE_LABEL_VAR+' ');
				q.append('FILTER(lang(?'+FACET_INSTANCE_LABEL_VAR+') = "en" || lang(?'+FACET_INSTANCE_LABEL_VAR+')="")}');
			}
			
			if (facet.sort != null && facet.countSort == false) {
				if (facet.sort.reversedProperty) {
					q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
					q.append('{?column <'+facet.sort.propertyURI+'> ?'+FACET_INSTANCE_VAR+'}');				
				} else {
					if (facet.sort.property is OwlObjectProperty) {
						q.append('{?column rdfs:label ?column_label FILTER(lang(?column_label)="en" || lang(?column_label)="")}');
						q.append('{?'+FACET_INSTANCE_VAR+' <'+facet.sort.propertyURI+'> ?column}');
					} else {
						q.append('{?'+FACET_INSTANCE_VAR+' <'+facet.sort.propertyURI+'> ?column_label');
						q.append('FILTER(lang(?column_label)="en" || lang(?column_label)="")}');			
					}
				}				
			}
			
			// TODO sort desc/asc bei flex andersrum als bei sparql?
			if (facet.countSort == false) {
				if (facet.sort != null) {
					if (facet.sortDescending == false) {
						q.append('} ORDER BY DESC(?column_label) LIMIT '+limit+' OFFSET ' + offset);
					} else {
						q.append('} ORDER BY ?column_label LIMIT '+limit+' OFFSET ' + offset);	
					}
				} else {
					if (facet.sortDescending == false) {
						q.append('} ORDER BY DESC(?'+FACET_INSTANCE_LABEL_VAR+') LIMIT '+limit+' OFFSET ' + offset);
					} else {
						q.append('} ORDER BY ?'+FACET_INSTANCE_LABEL_VAR+' LIMIT '+limit+' OFFSET ' + offset);
					}
				}
			} else { // sort by count
				if (facet.sortDescending == false) {
					q.append('} ORDER BY DESC(?instance_count) LIMIT '+limit+' OFFSET ' + offset);
				} else {
					q.append('} ORDER BY ?instance_count LIMIT '+limit+' OFFSET ' + offset);	
				}
			}
			
			var service:SPARQLService = new SPARQLService();
			service.query = q.createQueryString();
			service.doRequest(instancesResult, faultHandler);
			trace(service.query, "\n");
		}
		
		/**
		 * Parses results into the model.
		 */
		private function instancesResult(result:SPARQLResult, service:SPARQLService):void
		{
			var index:uint=0;
			for each (var resultRow:Object in result.resultList) {
				var row:ObjectFacetItem = new ObjectFacetItem();
				// TODO use different datatypes
				// var literal:Literal = result[FACET_INSTANCE.name].value;
				row.resource = resultRow[FACET_INSTANCE_VAR];
				row.instanceURI = row.resource.uri;
				row.label = resultRow[FACET_INSTANCE_LABEL_VAR];
				row.instanceCount = resultRow["instance_count"];
				//facet.instances.setItemAt(row, index);
				facet.instances.addItem(row);
				_instanceMap[row.resource.uri] = row;
				index++;
			}
			facet.dispatchEvent(new Event(BaseFacet.FACET_INSTANCES_LOADED));
			if (facet.instanceCount > 0) {
				requestExtraColumns(facet.node);
			}
		}
		
		
		public function requestExtraColumns(node:FacetTreeNode, offset:uint=0):void
		{
			var q:RawQuery = new RawQuery();
			var instanceURIs:Array = [];
			var instanceString:String = ''; //'<'+instances.source.join(">, <")+'>';
			for each (var instance:ObjectFacetItem in facet.instances)
			{
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
				if (node.property is OwlObjectProperty)
				{
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
			service.query = q.createQueryString();
			trace(service.query + "\n");
			service.doRequest(extraColumnsResult, faultHandler);
			service.customData.node = node;
		}
		
		private function extraColumnsResult(results:SPARQLResult, service:SPARQLService):void
		{
			for each (var result:Object in results.resultList) {
				if (result[Constants.INSTANCE_VAR] is Resource) {
					var resource:Resource = result[Constants.INSTANCE_VAR];
					var instance:ObjectFacetItem = _instanceMap[resource.uri];
					if (instance.columns[service.customData.node] == null) {
						instance.columns[service.customData.node] = [result["column_label"]];
					} else {
						instance.columns[service.customData.node].push(result["column_label"]);
					}
				}
			}
			facet.instances.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
		}
	}
}
