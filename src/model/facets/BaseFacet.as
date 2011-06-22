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

package model.facets
{
	import connection.SPARQLService;
	
	import events.FilterUpdatedEvent;
	
	import flash.events.EventDispatcher;
	
	import model.Constants;
	import model.FilterManager;
	import model.facettree.FacetTreeNode;
	import model.owl.IProperty;
	import model.sparql.ComplexQueryPattern;
	import model.sparql.QueryVariable;
	
	import mx.rpc.events.FaultEvent;
	
	[Event(name="filterUpdatedEvent", type="events.FilterUpdatedEvent")]
	[Event(name="facetInstancesLoaded", type="Event")]
	
	/**
	 * Base facet class that contains things common to all facet types.
	 */
	public class BaseFacet extends EventDispatcher implements IFacet
	{
		public static const FACET_INSTANCES_LOADED:String = "facetInstancesLoaded";
		private var _node:FacetTreeNode;
		protected var _filterPattern:ComplexQueryPattern = new ComplexQueryPattern();
		[Bindable]
		public var currentPage:uint = 1;
		
		public function BaseFacet(node:FacetTreeNode) {
			_node = node;
		}
		
		public function get node():FacetTreeNode
		{
			return _node;
		}

		protected function faultHandler(event:FaultEvent, service:SPARQLService):void {
			trace(event);
		}
		/**
		 * Clear local query filter and notify all listeners about the change.
		 */		
		public function removeFilter():void {
			_filterPattern.clear();
			FilterManager.getInstance().updateFilter(this, null);
		}
	}
}
