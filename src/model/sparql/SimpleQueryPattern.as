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
	import model.rdf.ILiteral;
	import model.rdf.INode;
	import model.rdf.IntegerLiteral;
	import model.rdf.LanguageLiteral;
	import model.rdf.Resource;
	
	public class SimpleQueryPattern implements IQueryPattern
	{
		private var _subject:INode;
		private var _predicate:INode;
		private var _object:INode;
		public var _isOptional:Boolean = false;
		private var _filters:Array = [];
		public function SimpleQueryPattern(
				subject:INode = null,
				predicate:INode=null,
				object:INode=null,
				isOptional:Boolean = false) {
			_subject = subject;
			_predicate = predicate;
			_object = object;
			_isOptional = isOptional;
		}
		
		public function get isOptional():Boolean {
			return _isOptional;
		}
		public function addFilter(filter:String):void {
			_filters.push(filter);
		}

		public function toString():String {
			var patternString:String = '';
			if (_isOptional) {
				patternString += 'OPTIONAL '
			}
			patternString += '{ ';
			for each (var node:INode in [_subject, _predicate, _object]) {
				if (node is Resource) {
					patternString += '<' + (node as Resource).uri + '>';
				} else if (node is QueryVariable) {
					patternString += '?' + (node as QueryVariable).toString();
				} else if (node is ILiteral) {
					patternString += (node as ILiteral).toTurtleString();
				}
				patternString += ' ';
			}
			
			if (_filters.length > 0) {
				patternString += 'FILTER ('
				patternString += _filters.join(' && ') + ')';	
			}
			patternString += ' }\n';
			return patternString;
		}
		
	}
}
