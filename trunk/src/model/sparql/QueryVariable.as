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

package model.sparql
{
	import model.rdf.INode;

	public class QueryVariable implements IQueryVariable
	{
		private var _name:String;
		public function QueryVariable(name:String) {
			_name = name;
		}
		public function get name():String {
			return _name
		}
		public function toString():String {
			return name;
		}
		public function get countName():String {
			return _name + "_count";
		}
	}
}
