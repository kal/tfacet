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
	public class DecimalLiteral implements ILiteral
	{
		private var _valueString:String;
		private var _value:Number;
		public function DecimalLiteral(value:String) {
			_valueString = value;
			_value = Number(value);
		}
		public function set value(value:Number):void {
			_value = value;
		}
		public function get label():Number {
			return _value;
		}
		public function toString():String {
			return _value.toString();
		}
		public function get type():Class {
			return Number;
		}
		public function toTurtleString():String {
			return _valueString;
		}
		public function equals(literal:ILiteral):Boolean
		{
			//TODO
			throw Error("not implemented");
		}
	}
}
