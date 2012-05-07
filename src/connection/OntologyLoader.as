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

package connection
{
	import events.OntologyLoadedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import model.owl.OwlClass;
	import model.owl.OwlDatatypeProperty;
	import model.owl.OwlObjectProperty;
	import model.owl.OwlOntology;
	import model.rdf.LanguageLiteral;
	import model.rdf.Resource;
	import model.rdf.ResourceSet;
	import model.sparql.RawQuery;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	
	import parser.SPARQLResult;

	[Event(name="ontologyLoaded", type="events.OntologyLoadedEvent")]
	[Event(name="ontologyLoadingFailed", type="FaultEvent")]
	
	/**
	 * Loads the DBPedia ontology (owl classes and properties) using SPARQL.
	 */
	public class OntologyLoader extends EventDispatcher
	{
		public static const ONTOLOGY_LOADING_FAILED:String = "ontologyLoadingFailed";
		public var ontology:OwlOntology = OwlOntology.getInstance();
		
		private var services:Array = [];
		// keeps state of sent queries
		private var activeQueries:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var loadingState:String = NOT_LOADED;
		public static const NOT_LOADED:String = "not_loaded";
		public static const LOADING:String = "loading";
		public static const FAILED:String = "failed";
		public static const FINISHED:String = "finished";
		
		private var classesLoaded:Boolean = false;
		
		private var pendingResultsQueue:Array = [];
		
		public function OntologyLoader()
		{
			// create services
			var i:int;
			for (i=0; i<=2; i++) {
				var service:SPARQLService = new SPARQLService();
				service.showRetryPopup = false;
				services.push(service);
			}
		}
		
		public function requestOntology():void
		{
			if (loadingState == LOADING) { return; }
			
			ontology.clear();
			
			var q:RawQuery = new RawQuery();
			
			loadingState = LOADING;
			
			// query class structure
			q.append('SELECT DISTINCT ?class ?superclass ?label ?count WHERE {');
			q.append('	{?class rdfs:label ?label} FILTER (lang(?label) = "en" || lang(?label) = "")');
			q.append('	{SELECT ?class ?superclass count(?instance) as ?count {');
			q.append('		{?class rdf:type owl:Class}');
			q.append('		{?class rdfs:subClassOf ?superclass}');
			q.append('		OPTIONAL {?instance rdf:type ?class}');
			q.append('	}}} LIMIT 1000');
			services[0].query = q.createQueryString();
			
			// query properties
			// TODO count results, query accordingly
			// objectProperties
			q = new RawQuery();
			q.append('SELECT DISTINCT ?property ?domain ?range ?label');
			q.append('FROM <http://dbpedia.org> WHERE {');
			q.append('	?property rdf:type owl:ObjectProperty .');
			q.append('  OPTIONAL {?property rdfs:domain ?domain}');
			q.append('	OPTIONAL {?property rdfs:range ?range .');
			// TODO allow other ranges
			q.append('	?range rdf:type owl:Class.}');
			q.append('	?property rdfs:label ?label . FILTER (lang(?label) = "en" || lang(?label) = "")');
			q.append('} LIMIT 1000');
		
			services[1].query = q.createQueryString();
			//trace(services[1].query);
			
			// datatypeProperties
			q = new RawQuery();
			q.append('SELECT DISTINCT ?property ?domain ?range ?label');
			q.append('FROM <http://dbpedia.org> WHERE {');
			q.append('	?property rdf:type owl:DatatypeProperty .');
			q.append('  OPTIONAL {?property rdfs:domain ?domain}');
			q.append('	?property rdfs:range ?range .');
			q.append('	?property rdfs:label ?label . FILTER (lang(?label) = "en" || lang(?label) = "")');
			q.append('} LIMIT 1000');
			services[2].query = q.createQueryString();
			
			// keep state of running query
			activeQueries.addItem(services[1]);
			services[1].doRequest(objectPropertyResultHandler, faultHandler);
			
			// keep state of running query
			activeQueries.addItem(services[0]);
			services[0].doRequest(classResultHandler, faultHandler);
			
			// keep state of running query
			activeQueries.addItem(services[2]);
			services[2].doRequest(datatypePropertyResultHandler, faultHandler);
		}

		
		private function classResultHandler(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			activeQueries.removeItemAt(activeQueries.getItemIndex(service));
			if (loadingState != LOADING) {return;}

			//  trace(sparqlResult.toString());
			// create classes and add them to ontology
			for each(var result:Object in sparqlResult.resultList)
			{
				// fow now only add class, if it has instances:
				if (result["count"] == 0) {continue;}
				var resource:Resource = ResourceSet.insertOrGetResourceByUri(result["class"]);
				var owlClass:OwlClass = new OwlClass(resource);
				owlClass.resource.label = new LanguageLiteral(result["label"], "en");
				owlClass.instanceCount = result["count"];
				ontology.addClass(owlClass);
				//trace("Class:" + owlClass);
			}
			// second pass for superclasses
			for each(result in sparqlResult.resultList)
			{
				owlClass = ontology.getClass(result["class"]);
				if (owlClass == null) {continue;}
				var superClass:OwlClass = ontology.getClass(result["superclass"]);
				if (superClass == null) {continue;} // ignore external classes
				owlClass.superClasses.addItem(superClass);
				superClass.subClasses.addItem(owlClass);
			}
			
			classesLoaded = true;
			checkPendingResults();
			// each single queries has finished
			if (activeQueries.length == 0)
			{
				loadingState = FINISHED;
				//dispatchEvent(new Event(LOADING_FINISHED));
				dispatchEvent(new OntologyLoadedEvent("ontologyLoaded", ontology));
			}
		}
		
		/** 
		 * Make sure that properties are added after classes
		 */
		private function checkPendingResults():void
		{
			if (classesLoaded) {
				for each (var pendingCall:Object in pendingResultsQueue)
				{
					pendingCall.func(pendingCall.arg0, pendingCall.arg1);
				}
				pendingResultsQueue = [];
			}
		}
		
		private function objectPropertyResultHandler(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			if (classesLoaded) {
				addObjectProperties(sparqlResult, service);
			} else {
				pendingResultsQueue.push({"func":addObjectProperties, "arg0":sparqlResult, "arg1":service});
			}
		}
		
		private function addObjectProperties(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			activeQueries.removeItemAt(activeQueries.getItemIndex(service));
			if (loadingState != LOADING) {return;}
			
			// create properties and add them to ontology
			for each(var result:Object in sparqlResult.resultList)
			{
				var resource:Resource = ResourceSet.insertOrGetResourceByUri(result["property"]);
				var property:OwlObjectProperty = new OwlObjectProperty(resource);
				var domainClass:OwlClass = ontology.getClass(result["domain"]);
				if (domainClass != null) {
					property.domain.addItem(domainClass);
					domainClass.domainOfList.addItem(property);
					
				} else {
					property.domain.addItem(ontology.rootClass);
					ontology.rootClass.domainOfList.addItem(property);
//					trace(result["domain"]);
				}
				var rangeClass:OwlClass = ontology.getClass(result["range"]);
				if (rangeClass != null) {
					property.range.addItem(rangeClass);
					rangeClass.rangeOfList.addItem(property);						
				} else {
					property.range.addItem(ontology.rootClass);
					ontology.rootClass.rangeOfList.addItem(property)
//					trace(result["range"]);
				}
				
				property.resource.label = new LanguageLiteral(result["label"], "en");
				ontology.addProperty(property);
			}

			// each single queries has finished
			if (activeQueries.length == 0)
			{
				loadingState = FINISHED;
				dispatchEvent(new OntologyLoadedEvent("ontologyLoaded", ontology));
			}
		}
		
		private function datatypePropertyResultHandler(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			if (classesLoaded) {
				addDatatypeProperties(sparqlResult, service);
			} else {
				//var pendingCall:Function = addDatatypeProperties(sparqlResult, token);
				pendingResultsQueue.push({"func":addDatatypeProperties, "arg0":sparqlResult, "arg1":service});
			}
		}
		
		private function addDatatypeProperties(sparqlResult:SPARQLResult, service:SPARQLService):void
		{
			activeQueries.removeItemAt(activeQueries.getItemIndex(service));
			if (loadingState != LOADING) {return;}
			
			// create properties and add them to ontology
			for each(var result:Object in sparqlResult.resultList)
			{
				var resource:Resource = ResourceSet.insertOrGetResourceByUri(result["property"]);
				var property:OwlDatatypeProperty = new OwlDatatypeProperty(resource);
				property.resource.label = new LanguageLiteral(result["label"], "en");
				var domainClass:OwlClass = ontology.getClass(result["domain"]);
				if (domainClass != null) {
					property.domain.addItem(domainClass);
					domainClass.domainOfList.addItem(property);
					
				} else {
					property.domain.addItem(ontology.rootClass);
					ontology.rootClass.domainOfList.addItem(property);
//					trace(result["domain"]);
				}
				var rangeUri:String = result["range"];
				property.range.addItem(rangeUri);
				ontology.addProperty(property);
//				trace(property);
			}
			
			// each single queries has finished
			if (activeQueries.length == 0)
			{
				loadingState = FINISHED;
				dispatchEvent(new OntologyLoadedEvent("ontologyLoaded", ontology));
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
			pendingResultsQueue = [];
			loadingState = FAILED;
			trace(event.fault.content);
			trace("ontology loading failed");
			dispatchEvent(new FaultEvent(ONTOLOGY_LOADING_FAILED, false, true, event.fault));
		}
		
	}
}
