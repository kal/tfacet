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
	
	import flash.utils.Dictionary;
	
	import model.owl.OwlClass;
	import model.owl.OwlOntology;
	import model.sparql.QueryVariable;
	import model.sparql.SimpleQueryPattern;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.rpc.events.FaultEvent;
	
	import parser.SPARQLResult;

	/**
	 * Tree structure storing the taxonomy of classes.
	 * Because it implements ITreeDataDescriptor, it can be used
	 * in a tree widget.
	 */
	public class ClassSelectionModel implements ITreeDataDescriptor
	{
		public var ontology:OwlOntology = OwlOntology.getInstance();
		public var rootNode:Object;
		[Bindable]
		public var selectedClass:OwlClass;
		// instance counts for each class
		[Bindable]
		public var instanceCounts:Dictionary = new Dictionary();
		public function ClassSelectionModel()
		{}

		public function selectClass(owlClass:OwlClass):void {
			// create filter from selected class
			selectedClass = owlClass;
			var classFilter:SimpleQueryPattern = new SimpleQueryPattern(
				Constants.INSTANCE_VAR,
				Constants.RDF_TYPE,
				owlClass.resource);
			FilterManager.getInstance().updateFilter(this, classFilter);
		}
				
		// Implementation of ITreeDataDescriptor
		
		public function getChildren(node:Object, model:Object = null):ICollectionView
		{
			if (hasChildren(node)) {
				return (node as OwlClass).subClasses;
			}
			else {
				return null;
			}
		}
		
		public function hasChildren(node:Object, model:Object = null):Boolean
		{
			return (node as OwlClass).subClasses.length != 0;
		}
		
		public function isBranch(node:Object, model:Object = null):Boolean
		{
			return (node as OwlClass).subClasses.length != 0;
		}
		
		public function getData(node:Object, model:Object = null):Object
		{
			return (node as OwlClass);
		}
		
		public function addChildAt(parent:Object, newChild:Object,
								   index:int, model:Object = null):Boolean
		{
			return false;
		}
		
		public function removeChildAt(parent:Object, child:Object,
									  index:int, model:Object = null):Boolean
		{
			return false;
		}
	}
}
