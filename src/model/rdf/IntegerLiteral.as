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
	public class IntegerLiteral implements ILiteral
	{
		private var _value:int;
		public function IntegerLiteral(value:String) {
			_value = int(value); 
		}
		public function get value():int {
			return _value;
		}
		public function set value(value:int):void {
			_value = value;
		}
		public function get label():int {
			return _value;
		}
		public function toString():String {
			return _value.toString();
		}
		public function toTurtleString():String {
			return value.toString();
		}
		public function equals(literal:ILiteral):Boolean
		{
			return literal is IntegerLiteral && value == (literal as IntegerLiteral).value;
		}
	}
}
