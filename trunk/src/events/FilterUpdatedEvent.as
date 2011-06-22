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

package events
{
	import flash.events.Event;
	
	import model.sparql.IQueryPattern;

	/**
	 * Fired on any update of the query filter.
	 */
	public class FilterUpdatedEvent extends Event
	{
		public static const FILTER_UPDATED:String = "filterUpdated";
		public var filter:IQueryPattern;
		public var filterSource:Object
		public function FilterUpdatedEvent(type:String, filter:IQueryPattern, filterSource:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.filter = filter;
			this.filterSource = filterSource;
		}
		
		/**
		 * We need to pass filter and filterSource through the chain.
		 */
		public override function clone():Event {
			return new FilterUpdatedEvent(type, filter, filterSource, bubbles, cancelable);
		}
	}
}
