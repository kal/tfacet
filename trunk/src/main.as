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

import connection.OntologyLoader;
import connection.SPARQLService;

import events.OntologyLoadedEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.LoaderContext;
import flash.system.Security;

import model.Constants;
import model.FacetManager;
import model.ResultListManager;
import model.facettree.FacetTree;
import model.facettree.FacetTreeLoader;
import model.owl.OwlClass;
import model.owl.OwlOntology;

import mx.rpc.events.FaultEvent;

import parser.SPARQLResult;

import ui.FacetViewComponent;

[Bindable]
public var selectedClass:OwlClass;
public var facetTree:FacetTree = new FacetTree();

private var ontLoader:connection.OntologyLoader = new connection.OntologyLoader();

private function init():void
{
	// download ontology
	ontLoader.requestOntology();
	ontLoader.addEventListener(OntologyLoadedEvent.ONTOLOGY_LOADED, ontologyLoadedHandler);
	ontLoader.addEventListener(connection.OntologyLoader.ONTOLOGY_LOADING_FAILED, loadingFailedHandler);
	//requestFailedWindow.retryButton.addEventListener(MouseEvent.CLICK, reloadHandler);
	requestFailedWindow.retryFunction = reloadHandler;
}

public function reloadHandler():void
{
	requestFailedWindow.visible = false;
	classSelection.classTree.dataProvider = null;
	ontLoader.requestOntology();
}

private function ontologyLoadedHandler(event:OntologyLoadedEvent):void
{
	classSelection.classTree.dataProvider = OwlOntology.getInstance().rootClass;
	var preselectedClass:OwlClass = OwlOntology.getInstance().getClass("http://dbpedia.org/ontology/MusicGenre");
	if (preselectedClass != null) {
		classSelection.classTree.selectedItem = preselectedClass;
	}
}

private function loadingFailedHandler(event:FaultEvent):void
{
	var errMsg:String = event.fault.faultString;
//	var errMsg:String = event.fault.content.toString();
//	var index:int = errMsg.search("\n");
//	if (index > 0) {
//		requestFailedWindow.errorMessage = errMsg.substr(0, index); 
//	} else {
//	requestFailedWindow.errorMessage = errMsg;
//	}
	requestFailedWindow.visible = true;
}

/**
 * initializes the main view.
 */
private function createFacetView(owlClass:OwlClass):void {
	selectedClass = owlClass;
	FacetManager.getInstance().facetTree = facetTree;
	facetTree.owlClass = owlClass;
	contentContainer.resultListComponent.manager = new ResultListManager(contentContainer.resultListComponent);
	facetTree.loader.requestChildren();
	contentContainer.facetTree.dataProvider = facetTree.children;
	mainViewStack.selectedIndex = 1;
}

