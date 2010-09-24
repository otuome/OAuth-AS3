/**
 * Parameter
 * 
 * A simple class to handle the key/value pairs of a single parameter
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
	public class Parameter
	{
		public function Parameter( k:String, v:String )
		{
			if (k == null || k.length == 0)
			{
				throw new ArgumentError( "Empty key given, a valid key must be at least one character" );
			}

			key = k;
			value = v;
		}

		public function set key( k:String ):void
		{
			if (k == null || k.length == 0)
			{
				throw new ArgumentError( "Empty key given, a valid key must be at least one character" );
			}

			_key = k;
		}
		public function get key():String
		{
			return _key;
		}

		public function set value( v:String ):void
		{
			_value = v;
			_valueEncoded = encodeURIComponent( v );
		}
		public function get value():String
		{
			return _value;
		}

		public function get valueEncoded():String
		{
			return _valueEncoded;
		}

		private var _key:String = "";
		private var _value:String = "";
		private var _valueEncoded:String = "";
	}
}