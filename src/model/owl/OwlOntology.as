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

package model.owl
{
	import model.Constants;
	import model.rdf.LanguageLiteral;
	import model.rdf.Resource;
	import model.rdf.ResourceSet;
	
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	public class OwlOntology
	{
		public var owlThing:OwlClass = new OwlClass(ResourceSet.insertOrGetResourceByUri(Constants.owl + "Thing"));
		private var _classSet:Object = {};
		private var _propertySet:Object = {};
		private static var instance:OwlOntology;
		
		// TODO enforce singleton
		public function OwlOntology() {
			init();
		}
		
		public static function getInstance():OwlOntology
		{
			if (instance == null) {
				instance = new OwlOntology();
			}
			return instance;
		}
		
		private function init():void
		{
			_classSet[owlThing.resource.uri] = owlThing;
			owlThing.resource.label = new LanguageLiteral("Thing", "en");	
		}
		
		public function clear():void
		{
			_classSet = {};
			_propertySet = {};
			owlThing = new OwlClass(ResourceSet.insertOrGetResourceByUri(Constants.owl + "Thing"));
			init();
		}
		
		public function get classList():Array {
			var tmpList:Array = [];
			for each (var owlClass:OwlClass in _classSet) {
				tmpList.push(owlClass);				
			}
			tmpList.sortOn("label");
			return tmpList;
		}
		
		public function addClass(owlClass:OwlClass):void {
			_classSet[owlClass.resource.uri] = owlClass;
		}
		
		public function getClass(uri:String):OwlClass {
			return _classSet[uri];	
		}
		
		public function addProperty(property:IProperty):void {
			_propertySet[property.resource.uri] = property;
		}
		
		/**
		 * try to get the property from a given uri.
		 * Returns null if no such property is found in the ontology.
		 */
		public function getProperty(uri:String):IProperty {
			return _propertySet[uri];	
		}
		
		public function get propertyList():Array {
			var tmpList:Array = [];
			for each (var property:IProperty in _propertySet) {
				tmpList.push(property);
				tmpList.sort();				
			}
			return tmpList;
		}
		
		public function get rootClass():OwlClass {
			return owlThing;
		}
		public function sort():void {
			classList.sort();
			propertyList.sort();
		}		
	}
}
