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
	import model.FacetManager;
	import model.facets.IFacet;
	import model.facets.ObjectFacet;
	import model.facets.SimpleFacet;
	import model.owl.IProperty;
	import model.owl.OwlClass;
	import model.owl.OwlDatatypeProperty;
	import model.owl.OwlObjectProperty;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	/**
	 * Represents a facet in the selection tree.
	 */
	public class FacetTreeNode
	{
		public static var largestId:uint = 0;
		// simple incremental id to distinguish facets in queries
		public const ID:int = largestId + 1;
		
		private var _tree:FacetTree;
		public var parent:FacetTreeNode;
		[Bindable]
		public var children:ArrayCollection = new ArrayCollection();
		public var propertyURI:String;
		public var property:IProperty;
		/**
		 * If true, this indicates that instances of this facet are connected to the parent
		 * in the way that they are subject of the relation (child property parent).
		 * If false, they are object (parent property child). 
		 */
		public var reversedProperty:Boolean;
		[Bindable]
		public var instanceCount:uint;
		[Bindable]
		public var label:String;
		public var loader:FacetTreeLoader;
		public var facetModel:IFacet;
		[Bindable]
		public var facetDetailsVisible:Boolean;
		public function FacetTreeNode()
		{
			loader = new FacetTreeLoader(this);
			largestId = ID;
			children.filterFunction = FacetTree.filter;
			var sort:Sort = new Sort();
			sort.fields = [new SortField("instanceCount", false, true, true)];
			children.sort = sort;
			children.refresh();
		}
		public function isRoot():Boolean
		{
			return parent == null;
		}
		public function get tree():FacetTree
		{
			return _tree;
		}
		public function set tree(tree:FacetTree):void
		{
			_tree = tree;
			loader.tree = tree;
		}
		
		public function createPropertyPath():String
		{
			var currentNode:FacetTreeNode = this;
			var path:String = "";
			if (property is OwlDatatypeProperty)
			{
				if (currentNode.reversedProperty)
				{
					path = " > is " + currentNode.property.resource.label + ' of ' + path;
				} else
				{
					path = " > " + currentNode.property.resource.label + ' '  + path;	
				}
				currentNode = currentNode.parent;
			}
			while (currentNode != null)
			{
					if (currentNode.reversedProperty)
					{
						path = " > is " + currentNode.property.resource.label + ' of: ' + currentNode.property.domain[0].resource.label + path;
					} else
					{
						path = " > " + currentNode.property.resource.label + ': ' + currentNode.property.range[0].resource.label + path;	
					}
				currentNode = currentNode.parent;
			}
			path = tree.owlClass.label + path;
			return path;	
		}
		
		public function createFacetModel():void
		{
			if (facetModel != null) {return;}
			if (property.range[0] is OwlClass)
			{
				facetModel = new ObjectFacet(this);
			// TODO other facet types
			} else
			{
				facetModel = new SimpleFacet(this);
			}
		}
		
//		[Bindable]
//		public function set facetDetailsVisible(visible:Boolean):void
//		{
//			
//		}
//		
//		public function get facetDetailsVisible():Boolean
//		{
//			
//		}
		
//		public function facetDetailsVisible():Boolean
//		{
//			
//			return FacetManager.getInstance().isVisible(
//				FacetManager.getInstance().getComponent(facetModel));
//		}

		public function get reverseAwareLabel():String
		{
			if (reversedProperty) { return "is "+label+" of"; }
			else { return label; }
		}
	}
}
