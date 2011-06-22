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

package model.rdf
{
	public class ResourceSet
	{
		private static var _resourceSet:Object = [];
		public function ResourceSet()
		{
		}
		
		/**
		 * Returns the resource object for the given URI or null if the resource is not known
		 */
		public static function getResourceByUri(uri:String):Resource {
			// TODO an factory delegieren
			return _resourceSet[uri]; 
		}
		/**
		 * Returns the resource for a given uri if known, otherwise creates a new resource and returns it.
		 */
		public static function insertOrGetResourceByUri(uri:String):Resource {
			var resource:Resource = getResourceByUri(uri); 
			if ( resource == null) {
				resource = new Resource(uri);
				_resourceSet[uri] = resource;	
			}
			return resource;
		}
		
		public static function insertResource(resource:Resource):void {
			_resourceSet[resource.uri] = resource;
		}
	}
}
