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
	public class ComplexQueryPattern implements IQueryPattern
	{
		public var _isOptional:Boolean = false;
		private var _filters:Array = [];
		private var _subPatterns:Array = [];
		private var _rawSubPatterns:Array = [];
		public var subPatternsAreUnion:Boolean = false;
		public function ComplexQueryPattern()
		{
		}
		
		public function addSubPattern(pattern:IQueryPattern):void {
			_subPatterns.push(pattern);
		}
		public function addFilter(filter:String):void {
			_filters.push(filter);
		}
		public function get isOptional():Boolean {
			return _isOptional;
		}
		public function clear():void {
			_subPatterns = [];
			_filters = [];
			_rawSubPatterns = [];
		}
		
		public function addRawSubPattern(pattern:String):void
		{
			_rawSubPatterns.push(pattern);
		}
		
		public function toString():String
		{
			if (_subPatterns.length == 0) {
				return '';
			} 
			var patternString:String = '';
			if (_isOptional) {
				patternString += 'OPTIONAL ';
			}
			patternString += '{\n';
			for (var i:String in _subPatterns) {
				patternString += _subPatterns[i].toString();
				// add union between subpatterns but not after the last one.
				if (subPatternsAreUnion && int(i) < _subPatterns.length - 1) {
					patternString += 'UNION\n'; 
				}
			}
			patternString += _rawSubPatterns.join('\n');
			patternString += ' ';
			if (_filters.length > 0) {
				patternString += 'FILTER ('
				patternString += _filters.join(' && ') + ')';	
			}
			patternString += '}';
			return patternString;
		}
	}
}
