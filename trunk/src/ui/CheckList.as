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

package ui
{
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElement;
	
	import spark.components.List;
	
	/**
	 * Extends List to allow multiple selection without pressing ctrl.
	 */
	public class CheckList extends List
	{
		public function CheckList()
		{
			allowMultipleSelection = true;
			super();
		}
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
//			var newIndex:Number = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			// always assume the Ctrl key is pressed by setting the third parameter of
			// calculateSelectedIndices() to true
//			selectedIndices = calculateSelectedIndices(newIndex, event.shiftKey, true);
			var e:MouseEvent = event as MouseEvent;
			e.ctrlKey = true;
			super.item_mouseDownHandler(e);
		}
		
//		override protected function item_clickHandler(event:MouseEvent) : void
//		{
//			var e:MouseEvent = event as MouseEvent;
//			e.ctrlKey = true;
//			super.item_clickHandler(e);
//		}

	}
}
