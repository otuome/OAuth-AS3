/**
 * QueryString
 * 
 * A simple class to decode parameters of a query string
 * Copyright (c) 2009 Dan Petitt (http://coderanger.com). All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list 
 * of conditions and the following disclaimer. Redistributions in binary form must 
 * reproduce the above copyright notice, this list of conditions and the following 
 * disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the author nor the names of its contributors may be used to endorse
 * or promote products derived from this software without specific prior written permission.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND, 
 * EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY 
 * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  
 *
 * IN NO EVENT SHALL TOM WU BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER
 * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT ADVISED OF
 * THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF LIABILITY, ARISING OUT
 * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */


package com.coderanger
{
	public class QueryString
	{
		public function QueryString( queryString:String = "" )
		{
			if (queryString.length)
			{
				var pairs:Array = queryString.split( "&" );
				for (var n:int = 0; n < pairs.length; n++)
				{
					var pair:String = pairs[ n ];
	
					var values:Array = pair.split( "=" );
					if (values.length == 2)
					{
						add( new Parameter(values[ 0 ], decodeURIComponent(values[1])) );
					}
					else
					{
						throw new Error( "Invalid parameter found. There was not a valid key/value pair, instead we got '" + pair + "'" );
					}
				}
			}
		}
		
		public function add( param:Parameter ):void
		{
			params.push( param );
			paramsAssociative[ param.key ] = param.value;
		}
		

		public function get length():uint
		{
			return params.length;
		}
		
		public function getValue( key:String ):String
		{
			var ret:String = paramsAssociative[ key ];
			return ret != null ? ret : "";
		}
		
		public function getParam( index:uint ):Parameter
		{
			return params[ index ];
		}

		
		public function sort():void
		{
			function paramsCompareFunction( a:Parameter, b:Parameter ):Number
				{
					// Sort on key and then value...
					if (a.key == b.key)
					{
						if (a.value == b.value)
						{
							return 0;
						}

						return ( a.value < b.value ) ? -1 : 1;
					}
					
					return ( a.key < b.key ) ? -1 : 1;
				};
			params.sort( paramsCompareFunction );
		}
		

		public function toString():String
		{
			var ret:String = "";
			for (var n:int = 0; n < params.length; n++)
			{
				var param:Parameter = params[ n ];

				if (ret.length) ret += "&";
				ret += param.key + "=" + param.valueEncoded;
			}
			return ret;
		}
		
		public function toPostObject():Object
		{
			var ret:Object = new Object();
			for (var n:int = 0; n < params.length; n++)
			{
				var param:Parameter = params[ n ];
				ret[param.key] = param.value;
			}
			return ret;
		}
		
		
		
		private var params:Array = new Array;
		private var paramsAssociative:Object = new Object;
	}
}