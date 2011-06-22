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

package parser
{
	public class SPARQLResult
	{
		private var _varList:Array;
		private var _resultList:Array;
		public function SPARQLResult(varList:Array, resultList:Array)
		{
			_varList = varList;
			_resultList = resultList;
		}
		
		public function get varList():Array
		{
			return _varList;
		}
		
		public function get resultList():Array
		{
			return _resultList;	
		}
		public function toString():String
		{
			var out:String = "";
			out += varList.join(" ") + "\n";
			for each (var result:Object in resultList)
			{
				for each (var variable:String in varList)
				{
					out += result[variable] + " ";
				}
				out += "\n";
			}
			return out;
		}
	}
}
