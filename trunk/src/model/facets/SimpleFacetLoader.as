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
	
	import flash.events.Event;
	
	import model.FilterManager;
	import model.rdf.ILiteral;
	import model.rdf.Resource;
	import model.sparql.RawQuery;
	
	import mx.rpc.events.FaultEvent;
	
	import parser.SPARQLResult;

	/**
	 * Logic to load data from SPARQL queries into a simple literal facet
	 */
	public class SimpleFacetLoader
	{
		public var facet:SimpleFacet;
		public var countLoaded:Boolean;
		private var FACET_INSTANCE_VAR:String;
		public function SimpleFacetLoader(facet:SimpleFacet)
		{
			this.facet = facet;
			FACET_INSTANCE_VAR = facet.node.loader.FACET_INSTANCE_VAR;
			
		}
		public function requestInstanceCount(searchString:String=""):void
		{
			var q:RawQuery = new RawQuery();
			q.append('SELECT COUNT (DISTINCT ?'+FACET_INSTANCE_VAR+') as ?instance_count FROM <http://dbpedia.org> WHERE {');
			q.append(facet.node.loader.createPreFilterPattern(searchString));
			q.append(FilterManager.getInstance().getFilterPattern(facet).toString());
			q.append('FILTER(lang(?'+FACET_INSTANCE_VAR+') = "en" || lang(?'+FACET_INSTANCE_VAR+')="")');
			q.append('}');
			var service:SPARQLService = new SPARQLService();
			service.query = q.createQueryString();
			service.doRequest(instancesCountResult, faultHandler);
			trace(service.query + "\n");
		}
		private function instancesCountResult(result:SPARQLResult, service:SPARQLService):void
		{
			var facetInstance:Resource;
			var resultRow:Object = result.resultList[0];
			facet.instanceCount = resultRow["instance_count"];
			countLoaded = true;
			requestInstances(0, SimpleFacet.ITEMS_PER_PAGE, facet.searchString);
		}
		protected function faultHandler(event:FaultEvent, service:SPARQLService):void
		{
			trace(event);
		}
		
		public function requestInstances(offset:uint, limit:uint, searchString:String):void
		{
			if (!countLoaded) {
				requestInstanceCount();
			} else {
				var q:RawQuery = new RawQuery();
				q.append('SELECT ?'+FACET_INSTANCE_VAR+' ?instance_count');
				q.append('FROM <http://dbpedia.org> WHERE {');
				// nested query to speed up language filters
				q.append('{SELECT DISTINCT ?'+FACET_INSTANCE_VAR+' COUNT(?instance) as ?instance_count WHERE {');
				q.append(facet.node.loader.createPreFilterPattern(searchString));
				// add filters from other facets
				q.append(FilterManager.getInstance().getFilterPattern(facet).toString());
				q.append("}}");
				q.append('FILTER(lang(?'+FACET_INSTANCE_VAR+') = "en" || lang(?'+FACET_INSTANCE_VAR+')="")');
				q.append('} ORDER BY ?'+FACET_INSTANCE_VAR+' LIMIT '+limit+' OFFSET '+offset);
				var service:SPARQLService = new SPARQLService();				
				service.query = q.createQueryString();
				service.doRequest(instancesResult, faultHandler);
				service.customData.offset = offset;
				trace(service.query + "\n");
			}
		}
		
		private function instancesResult(result:SPARQLResult, service:SPARQLService):void
		{
			facet.instances.removeAll();
			var index:uint=service.customData.offset;
			for each (var resultRow:Object in result.resultList) {
				var row:SimpleFacetItem = new SimpleFacetItem();
				row.instanceCount = resultRow["instance_count"];
				var selected:ILiteral = equalsSelected(resultRow[FACET_INSTANCE_VAR]);
				if (selected != null) {
					row.instance = selected;
					row.selected = true;
				} else {
					row.instance = resultRow[FACET_INSTANCE_VAR];
				}
//				facet.instances.setItemAt(row, index);
				facet.instances.addItem(row);
				index++;
			}
			facet.dispatchEvent(new Event(BaseFacet.FACET_INSTANCES_LOADED));

			// comparison function
			function equalsSelected(resultLiteral:ILiteral):ILiteral
			{
				for each (var literal:ILiteral in facet.selectedInstances) {
					if (literal.equals(resultLiteral)) {
						return literal;
					}
				}
				return null;
			}
		}
		
	}
}
