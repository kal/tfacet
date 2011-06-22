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

package parser
{
	import model.Constants;
	import model.rdf.DecimalLiteral;
	import model.rdf.IntegerLiteral;
	import model.rdf.LanguageLiteral;
	import model.rdf.Resource;
	import model.rdf.ResourceSet;
	import model.rdf.StringLiteral;
	import model.rdf.TypedLiteral;

	/**
	 * Parses a SPARQL result into an ActionScript datastructure for further processing.
	 * TODO discover filetypes in xml an cast accordingly
	 * 
	 * @author brunksn
	 * 
	 */	
	public class ResultParser
	{
		public function ResultParser() {
		}

		private static var rdf:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		private static var sparqlResults:Namespace = new Namespace("http://www.w3.org/2005/sparql-results#");
		private static var xml:Namespace = new Namespace("xml", "http://www.w3.org/XML/1998/namespace");
		
		/**
		 * Parses a SPARQL XML result into an array of results.
		 */
		public static function parseResult(xmlResults:XML):SPARQLResult {
			default xml namespace = sparqlResults; //"http://www.w3.org/2005/sparql-results#";
			xmlResults.addNamespace(xml); // prevent flex from adding an inline namespace (aaa)
			// TODO fehlerbehandlung
			var varList:Array = [];
			var resultList:Array = [];
			for each (var varName:String in (xmlResults.*::head.*::variable.@name)) {
				varList.push(varName);
			}
			for each (var xmlResult:XML in xmlResults.*::results.*::result) {
				var result:Object = new Object();
				for each (var binding:XML in (xmlResult.*::binding)) {
					// case resource
					if (binding.hasOwnProperty("uri")) {
						var resource:Resource = ResourceSet.insertOrGetResourceByUri(binding.*::uri.text());
						result[binding.@name] = resource;
					}
					// case literal
					else if (binding.hasOwnProperty("literal")) {
						// case typed literal
						// TODO more clean implementation
						if (binding.*::literal.hasOwnProperty("@datatype")) {
							switch (binding.*::literal.@datatype.toString()) {
								case Constants.XSD_STRING.uri:
									result[binding.@name] = new StringLiteral(binding.*::literal.text());
									break;
								case Constants.XSD_INT.uri:
									result[binding.@name] = new IntegerLiteral(binding.*::literal.text());
									break;
								case Constants.XSD_DECIMAL.uri:
									result[binding.@name] = new DecimalLiteral(binding.*::literal.text());
									break;
								// case unknown type
								default:
									result[binding.@name] = new TypedLiteral(binding.*::literal.text(), binding.*::literal.@datatype);
							}
						// case lang literal
						} else if (binding.*::literal.hasOwnProperty(new QName(xml, "@lang"))) {
							result[binding.@name] = new LanguageLiteral(binding.*::literal.text(), binding.*::literal.@xml::lang);
						} else {
							// case untyped literal without language
							result[binding.@name] = new StringLiteral(binding.*::literal.text());
						}
					}
					// case bnode TODO
					else if (binding.hasOwnProperty("bnode")) {
						result[binding.@name] = binding.*::bnode.text();
					}
//					trace(result[binding.@name] + " " + getQualifiedClassName(result[binding.@name]));
				}
				resultList.push(result);
			}
			return new SPARQLResult(varList, resultList);
		}
	}
}
