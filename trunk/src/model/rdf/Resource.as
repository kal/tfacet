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
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * Represents an RDF Resource of any type
	 */
	public dynamic class Resource implements INode
	{
		private var _label:ILiteral;
		private var _uri:String;
		public var namespace:Namespace;
		public var localName:String;
		
		public function Resource(uri:String)
		{
			_uri = uri;
		}
		public function get uri():String
		{
			return _uri;
		}
		public function set label(label:ILiteral):void
		{
			_label = label;
		}
		public function get label():ILiteral
		{
			return _label;
		}
		public function toString():String
		{
			return uri;
		}

		/**
		 * Splits uri into namespace and localname
		 */
		private function splitUri():void {
			// TODO implementation
		}
	}
}
