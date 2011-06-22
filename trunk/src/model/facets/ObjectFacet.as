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
	import model.facettree.FacetTreeLoader;
	import model.facettree.FacetTreeNode;
	import model.sparql.IQueryPattern;
	import model.sparql.QueryVariable;
	import model.sparql.SimpleQueryPattern;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import parser.SPARQLResult;

	/**
	 * Represents a facet whose content are resources
	 */
	public class ObjectFacet extends BaseFacet implements IFacet
	{
		private var _loader:ObjectFacetLoader;
		[Bindable]
		public var instances:ArrayCollection = new ArrayCollection();
		public var selectedInstances:Dictionary = new Dictionary();
		[Bindable]
		public var instanceCount:uint = 0;
		[Bindable]
		public var possibleColumns:ArrayCollection;
		[Bindable]
		public var childrenLoaded:Boolean;
		public static const ITEMS_PER_PAGE:uint = 50;
		[Bindable]
		public var filterString:String = "";
		public var sort:FacetTreeNode;
		public var sortDescending:Boolean = true;
		public var countSort:Boolean = false;

		public function ObjectFacet(node:FacetTreeNode)
		{
			super(node);
			
			instances.sort = new Sort();
			instances.sort.fields = [new SortField("label", true, false)];
			instances.refresh();
			
			_loader = new ObjectFacetLoader(this);
			if (node.loader.loadingState != FacetTreeLoader.FINISHED)
			{
				node.loader.requestChildren();
				node.loader.addEventListener(FacetTreeLoader.LOADING_FINISHED, treeNodesLoadedHandler);
			} else
			{
				treeNodesLoadedHandler();
			}
			
			FilterManager.getInstance().addEventListener(FilterUpdatedEvent.FILTER_UPDATED, filterUpdatedHandler);
		}
		
		private function treeNodesLoadedHandler(e:Event=null):void
		{
			possibleColumns = new ArrayCollection(node.children.source);
			possibleColumns.filterFunction = filter;
			var sort:Sort = new Sort();
			sort.fields = [new SortField("instanceCount", false, true, true)];
			possibleColumns.sort = sort;
			possibleColumns.refresh();
			childrenLoaded = true;
			
			function filter(item:Object):Boolean
			{
				var node:FacetTreeNode = item as FacetTreeNode;
				if (node.instanceCount <= 5) {return false};
				return true;
			}
		}
		
		public function requestInstanceCount():void
		{
			_loader.requestInstanceCount();
		}
		
		public function requestInstances(offset:uint=0, limit:uint=ITEMS_PER_PAGE):void
		{
			instances.removeAll();
			_loader.requestInstances(offset, limit);
		}
		
		public function requestExtraColumns(node:FacetTreeNode):void
		{
			_loader.requestExtraColumns(node);
		}
		
		/**
		 * Update local query filter and notify all listeners about the change.
		 */
		public function updateFilter(items:Array):void {
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
				_filterPattern.addRawSubPattern(node.parent.loader.createPreFilterPattern());
			}
			for each (var item:Object in items) {
				if (node.reversedProperty) {
					pattern = new SimpleQueryPattern(item.resource, node.property.resource, parentInstanceVar);	
				} else {
					pattern = new SimpleQueryPattern(parentInstanceVar, node.property.resource, item.resource);
				}
				_filterPattern.addSubPattern(pattern);
			}
			FilterManager.getInstance().updateFilter(this, _filterPattern);
		}
		
		/**
		 * Update data on filter changes of other facets.
		 */
		public function filterUpdatedHandler(e:FilterUpdatedEvent):void {
			// don't update on local filtering
			if (e.filterSource != this) {
				requestInstanceCount();
				requestInstances();	
			}
		}
	}
}
