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
	/**
	 * Represents a raw SPARQL query string
	 */
	public class RawQuery
	{
		private var queryParts:Array = [];
		public function RawQuery()
		{
		}
		public function append(queryPart:String):void
		{
			queryParts.push(queryPart);
		}
		public function createQueryString():String
		{
			return queryParts.join("\n");
		}
		public function toString():String
		{
			return createQueryString();
		}
	}
}
