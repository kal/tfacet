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
	import flash.events.EventDispatcher;
	
	import model.rdf.Resource;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	/**
	 * An owl class.
	 */
	public class OwlClass extends EventDispatcher
	{
		private var _domainOfList: ArrayCollection = new ArrayCollection();
		private var _rangeOfList: ArrayCollection = new ArrayCollection();
		private var _superClasses: ArrayCollection = new ArrayCollection();
		private var _subClasses: ArrayCollection = new ArrayCollection();
		private var _resource:Resource;
		[Bindable]
		public var instanceCount:Object = null;
		public function OwlClass(resource:Resource = null) {
			_resource = resource;
			_subClasses.sort = new Sort();
			_subClasses.sort.fields = [new SortField("label",true)];
			_subClasses.refresh();
		}

		public function get resource():Resource
		{
			return _resource;
		}

		public function set resource(value:Resource):void
		{
			_resource = value;
		}

		public function get subClasses():ArrayCollection
		{
			return _subClasses;
		}

		public function set subClasses(value:ArrayCollection):void
		{
			_subClasses = value;
		}
		
		public function getSubClassesTransitive():ArrayCollection
		{
			var subClassesTransitive:ArrayCollection = new ArrayCollection();
			subClassesTransitive.addAll(subClasses);
			for each (var subClass:OwlClass in subClasses)
			{
				subClassesTransitive.addAll(subClass.getSubClassesTransitive());
			}
			return subClassesTransitive;
		}
		
		public function get superClasses():ArrayCollection
		{
			return _superClasses;
		}
		
		public function set superClasses(superClasses:ArrayCollection):void
		{
			_superClasses = superClasses;
		}
		
		public function getSuperClassesTransitive():ArrayCollection
		{
			var superClassesTransitive:ArrayCollection = new ArrayCollection();
			superClassesTransitive.addAll(superClasses);
			for each (var superClass:OwlClass in superClasses)
			{
				superClassesTransitive.addAll(superClass.getSuperClassesTransitive());
			}
			return superClasses;
		}

		/**
		 * Returns a list of properties that have this class as domain. 
		 */
		public function get domainOfList():ArrayCollection
		{
			return _domainOfList;
		}
		
		public function set domainOfList(value:ArrayCollection):void
		{
			_domainOfList = value;
		}
		
		/**
		 * Returns a list of properties that have this class as range. 
		 */
		public function get rangeOfList():ArrayCollection
		{
			return _rangeOfList;
		}

		public function set rangeOfList(value:ArrayCollection):void
		{
			_rangeOfList = value;
		}
		public override function toString():String {
			if (resource != null)
			{
				return _resource.uri;	
			} else
			{
				return "anonymous class";
			}
		}
		public function get label():String {
			if (resource != null)
			{
				return _resource.label.toString();	
			} else
			{
				return "anonymous class";
			}
		}
	}
}
