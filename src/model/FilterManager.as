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

package model
{
	import events.FilterUpdatedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import model.sparql.ComplexQueryPattern;
	import model.sparql.IQueryPattern;
	
	/**
	 * This class is responsible for the handling of filters for result and facets.
	 * It dispatches a FilterUpdatedEvent on each filter update.
	 */
	[Event(name="filterUpdated", type="events.FilterUpdatedEvent")]
	public class FilterManager extends EventDispatcher
	{
		private static var _instance:FilterManager;
		private var _filterList:Dictionary = new Dictionary();
		public function FilterManager()
		{
			// TODO prevent other classes from calling the constructor
		}
		
		// singleton
		public static function getInstance():FilterManager
		{
			if (_instance == null)
			{
				_instance = new FilterManager();
			}
			return _instance;
		}
		
		public function updateFilter(source:Object, filter:IQueryPattern):void {
			_filterList[source] = filter;
			dispatchEvent(new FilterUpdatedEvent(FilterUpdatedEvent.FILTER_UPDATED, filter, source));
		}
		
		public function getFilterPattern(exclude:Object = null):IQueryPattern {
			var filterPattern:ComplexQueryPattern = new ComplexQueryPattern();
			for each (var filter:IQueryPattern in _filterList) {
				if (_filterList[exclude] != filter) {
					filterPattern.addSubPattern(filter);					
				}
			}
			return filterPattern;
		}
	}
}
