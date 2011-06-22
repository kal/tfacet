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
	import flash.events.Event;
	
	import model.owl.OwlClass;
	import model.owl.OwlOntology;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	/**
	 * Holds the tree structure for selection of facets.
	 * Each facet in the tree is represented by a FacetTreeNode object.
	 */
	public class FacetTree
	{
		[Bindable]
		public var owlClass:OwlClass;
		[Bindable]
		public var children:ArrayCollection = new ArrayCollection();
		public var loader:FacetTreeLoader = new FacetTreeLoader();
		public function FacetTree()
		{
			loader.tree = this;
			children.filterFunction = filter;
			var sort:Sort = new Sort();
			sort.fields = [new SortField("instanceCount", false, true, true)];
			children.sort = sort;
			children.refresh();
		}

		public static function filter(item:Object):Boolean
		{
			// TODO make this configurable
			var node:FacetTreeNode = item as FacetTreeNode;
			if (node.instanceCount <= 3) {return false};
			if (node.propertyURI == "http://dbpedia.org/ontology/abstract") {return false};
			if (node.propertyURI == "http://dbpedia.org/ontology/thumbnail") {return false};
			return true;
		}
	}
}
