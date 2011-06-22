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
	
	import model.owl.OwlClass;
	
	/**
	 * Fired when the user selects the initial owl class.
	 */
	public class ClassSelectedEvent extends Event
	{
		public static const CLASS_SELECTED:String = "classSelected";
		public var selectedClass:OwlClass;
		public function ClassSelectedEvent(type:String, selectedClass:OwlClass, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.selectedClass = selectedClass;
		}
		public override function clone():Event
		{
			return new ClassSelectedEvent(type, selectedClass, bubbles, cancelable);
		}
	}
}
