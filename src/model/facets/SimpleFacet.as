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
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import model.Constants;
	import model.FilterManager;
	import model.facettree.FacetTreeNode;
	import model.rdf.ILiteral;
	import model.sparql.IQueryPattern;
	import model.sparql.QueryVariable;
	import model.sparql.SimpleQueryPattern;
	
	import mx.collections.ArrayCollection;
	import mx.collections.AsyncListView;
	import mx.collections.IList;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import parser.ResultParser;
	import parser.SPARQLResult;
	
	[Event(name="facetInstancesLoaded", type="Event")]
	/**
	 * represents a simple facet whose content are literals
	 */
	public class SimpleFacet extends BaseFacet implements IFacet
	{
		private var _loader:SimpleFacetLoader;
		[Bindable]
		public var instanceCount:uint=0;
		[Bindable]
		public var instances:ArrayCollection = new ArrayCollection();
		public var selectedInstances:Vector.<ILiteral> = new Vector.<ILiteral>;
		public static const ITEMS_PER_PAGE:uint = 200;
		public var searchString:String = "";
		
		public function SimpleFacet(node:FacetTreeNode) {
			super(node);
			_loader = new SimpleFacetLoader(this);
			FilterManager.getInstance().addEventListener(FilterUpdatedEvent.FILTER_UPDATED, filterUpdatedHandler);
		}
		
		public function requestInstanceCount():void
		{
			_loader.requestInstanceCount();
		}
		
		public function requestInstances(offset:uint=0, limit:uint=ITEMS_PER_PAGE):void
		{
			instances.removeAll();
			_loader.requestInstances(offset, limit, searchString);
		}

		//			this.dispatchEvent(new Event(FACET_INSTANCES_LOADED));
		
		/**
		 * Update local query filter and notify all listeners about the change.
		 */
		public function updateFilter(items:Vector.<Object>):void {
			_filterPattern.clear();
			_filterPattern.subPatternsAreUnion = true;
			var parentInstanceVar:QueryVariable;
			var pattern:IQueryPattern;
			if (node.isRoot())
			{
				parentInstanceVar = Constants.INSTANCE_VAR;
			} else
			{
				parentInstanceVar = new QueryVariable(node.parent.loader.FACET_INSTANCE_VAR);
				// we need all variables on the way to its parent
				_filterPattern.addRawSubPattern(node.loader.createPreFilterPattern());
			}
			for each (var item:Object in items) {
				if (node.reversedProperty) {
					pattern = new SimpleQueryPattern(item.instance, node.property.resource, parentInstanceVar);	
				} else {
					pattern = new SimpleQueryPattern(parentInstanceVar, node.property.resource, item.instance);
				}
				_filterPattern.addSubPattern(pattern);
			}
			FilterManager.getInstance().updateFilter(this, _filterPattern);
//			dispatchEvent(new FilterUpdatedEvent(Constants.filterUpdatedEvent, _filterPattern, this));
		}
		
		/**
		 * Update data on filter changes of other facets.
		 */
		public function filterUpdatedHandler(e:FilterUpdatedEvent):void {
			// don't update on local filtering
			if (e.filterSource != this) {
				requestInstanceCount();
				_loader.countLoaded = false;
//				requestInstances();	
			}
		}
	}
}
