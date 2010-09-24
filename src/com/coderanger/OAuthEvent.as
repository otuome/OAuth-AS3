/**
 * OAuthEvent
 * 
 * A simple wrapper for some events dispatched by the OAuthManager class
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
	import flash.events.Event;

	public class OAuthEvent extends Event
	{
		public static const ON_REQUEST_TOKEN_RECEIVED: String = "onRequestTokenReceived";		
		public static const ON_REQUEST_TOKEN_FAILED: String = "onRequestTokenFailed";		
		
		public static const ON_ACCESS_TOKEN_RECEIVED: String = "onAccessTokenReceived";		
		public static const ON_ACCESS_TOKEN_FAILED: String = "onAccessTokenFailed";		


		public var data:Object = new Object ();

		public function OAuthEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
		}
		
	}
}