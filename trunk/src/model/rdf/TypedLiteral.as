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
	public class TypedLiteral implements ILiteral
	{
		private var _value:String;
		private var _type:String;
		public function TypedLiteral(value:String, type:String) {
			_value = value;
			_type = type;
		}
		public function set value(value:String):void {
			_value = value;
		}
		public function get value():String {
			return _value;
		}
		public function get label():String {
			return _value;
		}
		public function toTurtleString():String {
			return '"' + value + '"^^<' + _type + '>';
		}
		public function toString():String {
			return _value;
		}
		public function get type():String {
			return _type;
		}
		public function set type(type:String):void {
			_type = type;
		}
		public function equals(literal:ILiteral):Boolean
		{
			return (literal is TypedLiteral
				&& value == (literal as TypedLiteral).value
				&& type == (literal as TypedLiteral).type);
		}
	}
}
