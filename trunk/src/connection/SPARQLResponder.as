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

package connection
{
	import mx.rpc.AsyncResponder;
	import mx.rpc.events.ResultEvent;
	
	import parser.ResultParser;
	import parser.SPARQLResult;
	
	/**
	 * Extends AsyncResponder to parse the XML Result into a SPARQLResult
	 */
	public class SPARQLResponder extends AsyncResponder
	{
		public function SPARQLResponder(result:Function, fault:Function, token:Object = null)
		{
			super(result, fault, token);
		}
		public override function result(data:Object):void
		{
			var parsedResult:SPARQLResult = parseResult(data);
			super.result(parsedResult);
		}
		
		private function parseResult(result:Object):SPARQLResult
		{
			return ResultParser.parseResult(XML((result as ResultEvent).result));
		}
	}
}
