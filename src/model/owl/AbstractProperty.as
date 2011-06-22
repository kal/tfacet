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
	import model.rdf.Resource;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	public class AbstractProperty implements IProperty
	{
		protected var _resource:Resource;
		protected var _domain:ArrayCollection = new ArrayCollection();
		protected var _range:ArrayCollection = new ArrayCollection();
		public function AbstractProperty(resource:Resource=null)
		{
			_resource = resource;
		}
		
		public function get resource():Resource
		{
			return _resource;
		}
		
		public function set resource(resource:Resource):void
		{
			_resource = resource;
		}
		
		public function get domain():ArrayCollection
		{
			return _domain;
		}
		
		public function set domain(domain:ArrayCollection):void
		{
			_domain = domain;
		}
		
		public function get range():ArrayCollection
		{
			return _range;
		}
		
		public function set range(range:ArrayCollection):void
		{
			_range = range;
		}
		public function toString():String
		{
			return resource.label.toString();
		}
	}
}
