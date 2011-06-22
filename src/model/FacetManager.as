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
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import model.facets.IFacet;
	import model.facets.ObjectFacet;
	import model.facets.SimpleFacet;
	import model.facettree.FacetTree;
	import model.facettree.FacetTreeNode;
	import model.owl.IProperty;
	import model.owl.OwlClass;
	import model.owl.OwlDatatypeProperty;
	import model.owl.OwlObjectProperty;
	
	import mx.core.IVisualElementContainer;
	
	import ui.ObjectFacetComponent;
	import ui.SimpleFacetComponent;
	import ui.supportClasses.IFacetComponent;

	/**
	 * Responsible for creating facet components and models, respectively.
	 */
	public class FacetManager
	{
		private static var _instance:FacetManager;
		private var _facetComponentMap:Dictionary = new Dictionary();
		private var _visibleComponents:Dictionary = new Dictionary();
		public var facetContainer:IVisualElementContainer;
		[Bindable]
		public var facetTree:FacetTree;
		public function FacetManager()
		{
		// TODO prevent other classes from calling the constructor
		}
		
		/**
		 * Singleton
		 */
		public static function getInstance():FacetManager
		{
			if (_instance == null)
			{
				_instance = new FacetManager();
			}
			return _instance;
		}
		
		public function getComponent(facet:IFacet):IFacetComponent
		{
			return _facetComponentMap[facet];
		}
		private function addComponent(facet:IFacet, facetComponent:IFacetComponent):void
		{
			_facetComponentMap[facet] = facetComponent;
		}
		public function isVisible(component:IFacetComponent):Boolean
		{
			return _visibleComponents[component] != null;
		}
		/**
		 * creates a facet component depending on the facet type
		 */
		private function createFacetComponent(facet:IFacet):IFacetComponent
		{
			var facetComponent:IFacetComponent;
			// TODO clean implementation
			if (facet is ObjectFacet)
			{
				facetComponent = new ObjectFacetComponent();
				(facetComponent as ObjectFacetComponent).setModel(facet);
			} else if (facet is SimpleFacet)
			{
				facetComponent = new SimpleFacetComponent();
				(facetComponent as SimpleFacetComponent).setModel(facet);
			}
			addComponent(facet, facetComponent);
			return facetComponent;
		}
		private function showFacetComponent(facetComponent:IFacetComponent):void
		{
			facetContainer.addElement(facetComponent);
			_visibleComponents[facetComponent] = facetComponent;
			facetComponent.getModel().node.facetDetailsVisible = true;
		}
		
		public function hideFacetComponent(facetComponent:IFacetComponent):void
		{
			facetContainer.removeElement(facetComponent);
			delete _visibleComponents[facetComponent];
			facetComponent.getModel().node.facetDetailsVisible = false;
		}
		
		public function setFacetDetailsVisible(facetTreeNode:FacetTreeNode, visible:Boolean):void
		{
			if (visible != isVisible(getComponent(facetTreeNode.facetModel)))
				{
					toggleFacetDetails(facetTreeNode);
				}
		}
		
		public function toggleFacetDetails(facetTreeNode:FacetTreeNode):void
		{
			var facetComponent:IFacetComponent = getComponent(facetTreeNode.facetModel); 
			// show details (create if necessary)
			if (!isVisible(facetComponent))
			{
				if (facetTreeNode.facetModel == null)
				{
					facetTreeNode.createFacetModel();
					facetComponent =
						createFacetComponent(facetTreeNode.facetModel);
				}
				showFacetComponent(facetComponent);
			} else // hide details
			{
				hideFacetComponent(facetComponent);
			}
		}
	}
}
