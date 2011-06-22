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

package model.facettree
{
	import connection.SPARQLService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import model.owl.OwlClass;
	import model.owl.OwlDatatypeProperty;
	import model.owl.OwlOntology;
	import model.sparql.QueryVariable;
	import model.sparql.RawQuery;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.errors.ItemPendingError;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	
	import parser.SPARQLResult;

	[Event(name="loadingFinished")]
	
	/**
	 * Responsible for filling the tree with facets for selection.
	 */
	public class FacetTreeLoader extends EventDispatcher
	{
		// keeps state of sent queries
		private var activeQueries:ArrayCollection = new ArrayCollection();
		private var services:Array = [];
		//private var service:SPARQLService = new SPARQLService();
		public var node:FacetTreeNode;
		public var tree:FacetTree;
	
		public static const LOADING_FINISHED:String = "loadingFinished";
		private static const INSTANCE_VAR:String = "instance";
		private static const INSTANCE_COUNT_VAR:String = "instance_count";
		private static const PROPERTY_VAR:String = "property";
		public var FACET_PROPERTY_VAR:String;
		public var FACET_INSTANCE_VAR:String;
		
		[Bindable]
		public var loadingState:String = NOT_LOADED;
		public static const NOT_LOADED:String = "not_loaded";
		public static const LOADING:String = "loading";
		public static const FAILED:String = "failed";
		public static const FINISHED:String = "finished";
		
		public function FacetTreeLoader(node:FacetTreeNode = null)
		{
			this.node = node;
			if (node != null) {
				FACET_INSTANCE_VAR = ("facet_" + node.ID + "_instance");
				tree = node.tree;
			}
			// create services
			var i:int;
			for (i=0; i<=2; i++) {
				services.push(new SPARQLService());
			}
		}
		
		public function requestChildren():void
		{
			if (loadingState == LOADING || loadingState == FINISHED) { return; }
			// query for properties whose range are (owl) objects that are connected to instances
			// as object in a statemant: (instance property object)
			var q:RawQuery = new RawQuery();
			q.append('SELECT DISTINCT COUNT(DISTINCT ?child_facet_instance) as ?instance_count ?property');
			q.append('FROM <http://dbpedia.org> WHERE {');
			// extraction of nested facets
			if (node != null)
			{
				q.append('{?'+node.loader.FACET_INSTANCE_VAR+' ?property ?child_facet_instance}');
				q.append(createPreFilterPattern());
			// case top Level children	
			} else {
				q.append('{?instance ?property ?child_facet_instance}');
			}
			q.append('{?instance rdf:type <'+tree.owlClass.resource.uri+'>}');
			q.append('{?property rdf:type owl:ObjectProperty}');
			q.append('} ORDER BY desc(?instance_count) LIMIT 1000');
			services[0].query = q.createQueryString();
			services[0].doRequest(resultHandler, faultHandler);
			// keep state of running query
			activeQueries.addItem(services[0]);
			trace(services[0].query);
			
			// query for properties whose range are literals (instance property literal)
			q = new RawQuery();
			q.append('SELECT DISTINCT COUNT(DISTINCT ?child_facet_instance) as ?instance_count ?property');
			q.append('FROM <http://dbpedia.org> WHERE {');
			// extraction of nested facets
			if (node != null)
			{
				q.append('{?'+node.loader.FACET_INSTANCE_VAR+' ?property ?child_facet_instance}');
				q.append(createPreFilterPattern());
				// case top Level children	
			} else {
				q.append('{?instance ?property ?child_facet_instance}');
			}
			q.append('{?instance rdf:type <'+tree.owlClass.resource.uri+'>}');
			q.append('{?property rdf:type owl:DatatypeProperty}');
//			q.append('FILTER(lang(?child_facet_instance)="en" || lang(?child_facet_instance)="")');
			q.append('} ORDER BY desc(?instance_count) LIMIT 1000');
			services[1].query = q.createQueryString();
			services[1].doRequest(resultHandler, faultHandler);
			//			// keep state of running query
			activeQueries.addItem(services[1]);
			trace(services[1].query);
			
			// query for properties whose domain are (owl) objects that are connected
			// to the instance as subject (child property instance)
			q = new RawQuery();
			q.append('SELECT DISTINCT COUNT(DISTINCT ?child_facet_instance) as ?instance_count ?property');
			q.append('FROM <http://dbpedia.org> WHERE {');
			// extraction of nested facets
			if (node != null)
			{
				q.append('{?child_facet_instance ?property ?'+node.loader.FACET_INSTANCE_VAR+'}');
				q.append(createPreFilterPattern());
				// case top Level children	
			} else {
				q.append('{?child_facet_instance ?property ?instance}');
			}
			q.append('{?instance rdf:type <'+tree.owlClass.resource.uri+'>}');
			q.append('{?property rdf:type owl:ObjectProperty}');
			q.append('} ORDER BY desc(?instance_count) LIMIT 1000');
			services[2].query = q.createQueryString();
			services[2].doRequest(resultHandler, faultHandler);
			// set reversedProperty for resultHandler
			//token.reversedProperty = true;
			//	keep state of running query
			activeQueries.addItem(services[2]);
			trace(services[2].query);
			
			loadingState = LOADING;
		}
		
		/**
		 * returns a sparql pattern that filter instances of the current facet
		 * due to the facet hierarchy
		 */
		public function createPreFilterPattern(searchString:String=""):String
		{
			var q:RawQuery = new RawQuery();
			var currentNode:FacetTreeNode = node;
			while (!currentNode.isRoot())
			{
				// case (child property parent)
				if (currentNode.reversedProperty)
				{
					q.append('{?'
						+currentNode.loader.FACET_INSTANCE_VAR+
						' <'+currentNode.property.resource.uri+'> ?'
						+currentNode.parent.loader.FACET_INSTANCE_VAR+'.');

				} else
				// case (parent property child)
				{
					q.append('{?'
						+currentNode.parent.loader.FACET_INSTANCE_VAR+
						' <'+currentNode.property.resource.uri+'> ?'
						+currentNode.loader.FACET_INSTANCE_VAR+'.');
				}
				if (node==currentNode && searchString!="")
				{
					q.append('?' +currentNode.loader.FACET_INSTANCE_VAR+ ' bif:contains "'+searchString+'"');
				}
				q.append('}');
				currentNode = currentNode.parent;	
			}
			if (currentNode.reversedProperty)
			{
				q.append('{?'+currentNode.loader.FACET_INSTANCE_VAR+' <'
					+currentNode.property.resource.uri+'> '
					+'?instance .');	
			} else
			{				
				q.append('{?instance <'
					+currentNode.property.resource.uri+'> ?'
					+currentNode.loader.FACET_INSTANCE_VAR+' .');
			}
			if (node==currentNode && searchString!="")
			{
				q.append('?' +currentNode.loader.FACET_INSTANCE_VAR+ ' bif:contains "'+searchString+'"');
			}
			q.append('}');
//			q.append('	{?instance rdf:type <'+tree.owlClass.resource.uri+'>}');
			return q.createQueryString();
		}
		
		/**
		 * creates child nodes based on the result list
		 */
		private function resultHandler(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			activeQueries.removeItemAt(activeQueries.getItemIndex(service));
			if (loadingState == LOADING)
			{
//				trace(sparqlResult.toString());
				for each(var result:Object in sparqlResult.resultList)
				{
					var childNode:FacetTreeNode = new FacetTreeNode();
					childNode.tree = tree;
					childNode.parent = node;
					childNode.instanceCount = result[INSTANCE_COUNT_VAR];
					childNode.propertyURI = result["property"];
					childNode.property = OwlOntology.getInstance().getProperty(childNode.propertyURI);
					
					// set reversedProperty for results of last query
					if (service == services[2]) {
						childNode.reversedProperty = true;
					}
					if (childNode.property) {
						childNode.label = childNode.property.resource.label.toString();
					}						
					if (node != null) {
						node.children.addItem(childNode);	
					}
					else {
						tree.children.addItem(childNode)
					}
				}
//				node.tree.rootNode.children.itemUpdated(node.tree.rootNode.children[0]);
				// all queries have finished
				if (activeQueries.length == 0)
				{
					loadingState = FINISHED;
					dispatchEvent(new Event(LOADING_FINISHED));
					trace("finished!!!");
				}
			}
		}
		
		private function faultHandler(event:FaultEvent, service:SPARQLService):void
		{
			activeQueries.removeItemAt(activeQueries.getItemIndex(service));
			for each (var s:SPARQLService in activeQueries)
			{
				s.cancelRequest();
			}
			activeQueries.removeAll();
			loadingState = FAILED;
			trace("failed!!!");
		}
	}
}
