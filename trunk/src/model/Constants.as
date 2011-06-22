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

package model
{
	import model.rdf.Resource;
	import model.sparql.QueryVariable;
	
	import mx.collections.ArrayList;
	
	public class Constants
	{
		public function Constants()
		{
		}
		
		public static const TOOL_PAGE:String = "http://tfacet.visualdataweb.org";
		public static const TOOL_VERSION:String = "0.7";
		
		// URLs
		// empty string: no proxy
		//public static const PROXY_URL:String = "http://relfinder.semanticweb.org/Proxy3.php?";
		public static const PROXY_URL:String = "";
		
		//public static const DEFAULT_SPARQL_ENDPOINT:String = "http://dbpedia.org/sparql";
		public static const DEFAULT_SPARQL_ENDPOINT:String = "http://lod.openlinksw.com/sparql";
		
		public static const SPARQL_ENDPOINTS:ArrayList = new ArrayList([
			"http://lod.openlinksw.com/sparql",
			"http://dbpedia.org/sparql",
			"http://dbpedia-live.openlinksw.com/sparql"
		]);
		
		
		/**
		 * SPARQL Variables
		 */
		public static const INSTANCE_VAR:QueryVariable = new QueryVariable("instance");
		public static const OWL_CLASS_VAR:QueryVariable = new QueryVariable("owl_class");
		
		/**
		 * Namespaces
		 */
		public static const dbpedia_owl:Namespace = new Namespace("http://dbpedia.org/ontology/>");
		public static const owl:Namespace = new Namespace("http://www.w3.org/2002/07/owl#");
		public static const rdfs:Namespace = new Namespace("http://www.w3.org/2000/01/rdf-schema#");
		public static const rdf:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		public static const xsd:Namespace = new Namespace("http://www.w3.org/2001/XMLSchema#");
		
		/**
		 * Resources
		 */
		public static const RDFS_LABEL:Resource = new Resource(rdfs + "label");
		public static const RDF_TYPE:Resource = new Resource(rdf + "type");
		public static const RDFS_DOMAIN:Resource = new Resource(rdfs + "domain");
		public static const RDFS_RANGE:Resource = new Resource(rdfs + "range");
		public static const RDFS_SUBCLASS_OF:Resource = new Resource(rdfs + "subClassOf");
		public static const OWL_CLASS:Resource = new Resource(owl + "Class");
		public static const RDFS_PROPERTY:Resource = new Resource(rdfs + "Property");
		public static const OWL_DATATYPE_PROPERTY:Resource = new Resource(owl + "DatatypeProperty");
		public static const OWL_OBJECT_PROPERTY:Resource = new Resource(owl + "ObjectProperty");
		
		// xsd datatypes
		public static const XSD_STRING:Resource = new Resource(xsd + "string");
		public static const XSD_INT:Resource = new Resource(xsd + "integer");
		public static const XSD_DECIMAL:Resource = new Resource(xsd + "decimal");
		public static const XSD_FLOAT:Resource = new Resource(xsd + "float");
		public static const XSD_DOUBLE:Resource = new Resource(xsd + "double");
		public static const XSD_DATE:Resource = new Resource(xsd + "date");
		
		// Events
		public static const filterUpdatedEvent:String = "filterUpdated";
		
	}
}
