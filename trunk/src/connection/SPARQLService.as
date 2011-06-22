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
	import flash.display.DisplayObject;
	
	import model.Constants;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import parser.ResultParser;
	import parser.SPARQLResult;
	
	import ui.RequestFailedWindow;
	
	/**
	 * The SPARQLService is responsible for requesting a SPARQL endpoint.
	 * It has an integrated error/retry handling to handle timeouts.
	 * The default endpoint url can be changed by setting the endpoint attribute.
	 */
	public class SPARQLService
	{
		[Bindable]
		public var state:String = NOT_LOADED;
		public static const NOT_LOADED:String = "not_loaded";
		public static const LOADING:String = "loading";
		public static const FAILED:String = "failed";
		public static const FINISHED:String = "finished";
		
		// container for custom data that needs to be passed to callback handler
		public var customData:Object = {};
		public static var defaultEndpoint:String = Constants.DEFAULT_SPARQL_ENDPOINT;
		public var endpoint:String;
		public var proxy:String = Constants.PROXY_URL;
		public var showRetryPopup:Boolean = true;
		
		private var _query:String;
		private var _service:HTTPService = new HTTPService();
		private var _token:AsyncToken = null;
		private var _retries:int = 0;
		private var _resultHandler:Function = null;
		private var _faultHandler:Function = null;
		
		public function SPARQLService()
		{
			_service.requestTimeout = 10;
			_service.concurrency = "last";
			_service.method = "GET";
			_service.resultFormat = HTTPService.RESULT_FORMAT_E4X;
			_service.request = {
				"format": "application/sparql-results+xml",
				"default-graph-uri": "http://dbpedia.org"};
			_service.showBusyCursor = true;
			
			_service.addEventListener(ResultEvent.RESULT, internalResultHandler);
			_service.addEventListener(FaultEvent.FAULT, internalFaultHandler);
		}
		
		public function set query(query:String):void
		{ _query = query; }
		
		public function get query():String
		{ return _query; }
		
		public function get httpService():HTTPService
		{ return _service; }
		
		/**
		 * Sends a request to an endpoint.
		 * On Success, the answer is parsed into a SPARQLResult Object and passed
		 * to the result callback function.
		 * 
		 * A result function must have the following signature:
		 * resultHandler(sparqlResult:SPARQLResult, service:SPARQLService):void
		 * 
		 * An error is passed as FaultEvent, so an error handling function must have
		 * the following signature:
		 * faultHandler(event:FaultEvent, service:SPARQLService):void
		 */
		public function doRequest(result:Function, fault:Function, retries:int=2):void
		{
			_retries = retries;
			_resultHandler = result;
			_faultHandler = fault;
			var queryString:String = query.toString();
			if (endpoint != null) {
				_service.url = proxy + endpoint;
			} else {
				_service.url = proxy + defaultEndpoint;
			}
			// send long queries as post
			if (_service.url.length + queryString.length + 1 >= 1024) {
				_service.method = "POST";
			}
			else {
				// separator for parameters for get requests
				_service.url += "?";
			}
			_service.request.query = queryString;
			_token = _service.send();
			//_token.addResponder(new SPARQLResponder(internalResultHandler, internalFaultHandler, _token));
		}
		
		/**
		 * internal result handler, just delegates callback
		 */
		private function internalResultHandler(result:ResultEvent, token:AsyncToken=null):void
		{
			trace("Request sucessful");
			var sparqlResult:SPARQLResult =  ResultParser.parseResult(XML(result.result));
			_resultHandler(sparqlResult, this);
		}
		
		/**
		 * Internal fault handler, necessary for retry handling
		 */
		private function internalFaultHandler(event:FaultEvent, token:AsyncToken=null):void
		{
			trace("internal fault handler called");
			// try another request
			if (_retries > 0) {
				_retries--;
				_token = _service.send();
				//_token.addResponder(new SPARQLResponder(internalResultHandler, internalFaultHandler, _token));
				trace ("Request Retry");
			} else {
				trace("Request failed");
				// TODO externalize GUI stuff
				if (showRetryPopup == true) {
					var failPopup:RequestFailedWindow = new RequestFailedWindow();
					failPopup.errorMessage = event.fault.faultString;
					// TODO eventbased
					failPopup.retryFunction = fullRetry;
					PopUpManager.addPopUp(failPopup, FlexGlobals.topLevelApplication as DisplayObject, true);
					PopUpManager.centerPopUp(failPopup);					
				}
				// pass fault event to service caller
				else if (_faultHandler != null) {
					_faultHandler(event, this);
				}
			}
		}
		
		private function fullRetry():void
		{
			// TODO retry count
			doRequest(_resultHandler, _faultHandler);
		}
		
		/**
		 * Cancels a running request.
		 */
		public function cancelRequest():void
		{
			// cancel last request
			_service.cancel();
		}
		
	}
}
