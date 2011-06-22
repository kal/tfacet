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
	public class Loader
	{
		public static const NOT_LOADED:String = "not_loaded";
		public static const LOADING:String = "loading";
		public static const FAILED:String = "failed";
		public static const FINISHED:String = "finished";
		
		public var state:String = NOT_LOADED;
		
		public function Loader()
		{
		}
		
		public function reload()
		{
			
		}
	}
}
