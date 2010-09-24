/**
 * OAuthManager
 * 
 * An ActionScript 3 implementation of OAUTH, An open protocol to allow secure API authorization
 * Visit www.oauth.net for further information.
 * Copyright (c) 2009 Dan Petitt (http://coderanger.com). All rights reserved.
 * 
 * Requires as3corelib from http://code.google.com/p/as3corelib/. Copyright Henri Torgemane
 * 
 * Please read USAGE.txt for instructions and examples
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
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class OAuthManager extends EventDispatcher
	{
		public function OAuthManager()
		{
			reset();
		}
		

		//
		// The following properties are used for initialising a request for authorisation

		// The authorisation root domain URI (e.g. 'twitter.com')
		public function set oauthDomain( value:String ):void
		{
			_oauthDomain = value;
		}
		// The token URI fragment for requesting a token
		public function set requestTokenFragment( value:String ):void
		{
			_requestTokenFragment = value;
		}
		// The token URI fragment for authorising given a request token
		public function set authorizeFragment( value:String ):void
		{
			_authorizeFragment = value;
		}
		// The token URI fragment for requesting an access token after a pin has been given
		public function set accessTokenFragment( value:String ):void
		{
			_accessTokenFragment = value;
		}

		// The Twitter-assigned consumer key for OAuth signing.
		public function set consumerKey( value:String ):void
		{
			_consumerKey = value;
		}
		public function get consumerKey():String
		{
			return _consumerKey;
		}
		
		// The Twitter-assigned consumer secret for OAuth signing.
		public function set consumerSecret( value:String ):void
		{
			_consumerSecret = value;
		}
		public function get consumerSecret():String
		{
			return _consumerSecret;
		}

		// Sets whether to use pin based desktop workflow (true by default) 
		public function set usePinWorkflow( b:Boolean ):void
		{
			_usePinWorkflow = b;
		}



		//
		// The following properties are used once authorised, for setting up for further secured requests

		// The authorization PIN ... to be persisted for future requests
		public function set accessPin( value:Number ):void
		{
			_accessPin = value;
		}
		public function get accessPin():Number
		{
			return _accessPin;
		}

		// The authorization access token ... to be persisted for future requests
		public function set accessToken( value:String ):void
		{
			_accessToken = value;
		}
		public function get accessToken():String
		{
			return _accessToken;
		}

		// The authorization access token secret ... to be persisted for future requests
		public function set accessTokenSecret( value:String ):void
		{
			_accessTokenSecret = value;
		}
		public function get accessTokenSecret():String
		{
			return _accessTokenSecret;
		}

		// The current user's user name retrieved from authorisation
		public function get currentUserName():String
		{
			return _currentUserName;
		}
		
		// The current user's user ID retrieved from authorisation
		public function get currentUserID():Number
		{
			return _currentUserID;
		}


		// Returns whether this request has full authorisation
		public function isAuthorised():Boolean
		{
			return ( _accessPin && _accessToken.length );
		}



		// Resets all values to ensure multiple-requests do not get messed up
		public function reset():void
		{
			_oauthDomain = "";
			_currentUserName = "";
			_currentUserID = 0;
			_consumerKey = "";
			_consumerSecret = "";
			_authorizationToken = "";
			_accessToken = "";
			_accessTokenSecret = "";
		}


		// Given a url and post data, return a signed url for secured requests
		public function getSignedURI( method:String, url:String, postData:String = "" ):String
		{
			//	oauth_consumer_key:
			//		The Consumer Key. 
			//	oauth_signature_method:
			//		The signature method the Consumer used to sign the request. 
			//	oauth_signature:
			//		The signature as defined in Signing Requests (Signing Requests). 
			//	oauth_timestamp:
			//		As defined in Nonce and Timestamp (Nonce and Timestamp). 
			//	oauth_nonce:
			//		As defined in Nonce and Timestamp (Nonce and Timestamp). 
			//	oauth_version:
			//		OPTIONAL. If present, value MUST be 1.0 . Service Providers MUST assume the protocol version to be 1.0 if this parameter is not present. Service Providers’ response to non-1.0 value is left undefined. 
			//	Additional parameters:
			//		Any additional parameters, as defined by the Service Provider. 
			
			if (method.toUpperCase() != "GET" && method.toUpperCase() != "POST")
			{
				throw new ArgumentError( "Invalid method passed. Only GET and POST supported");
			}
			if (url.length == 0)
			{
				throw new ArgumentError( "Empty url passed" );
			}
			if (consumerKey.length == 0)
			{
				throw new ArgumentError( "consumerKey property not set" );
			}
			if (_consumerSecret.length == 0)
			{
				throw new ArgumentError( "consumerSecret property not set" );
			}


			var timeStamp:String = Math.round( new Date().getTime() / 1000 ).toString();
			var nonce:String = Math.round( Math.random() * 10000 ).toString();


			// Setup the standard parameters
			var newQueryString:QueryString = new QueryString();
				newQueryString.add( new Parameter("oauth_version", "1.0") );
				newQueryString.add( new Parameter("oauth_signature_method", "HMAC-SHA1") );
				newQueryString.add( new Parameter("oauth_nonce", nonce) );
				newQueryString.add( new Parameter("oauth_timestamp", timeStamp) );
				newQueryString.add( new Parameter("oauth_consumer_key", consumerKey) );
				
			if (_usePinWorkflow)
			{
				newQueryString.add( new Parameter("oauth_callback", "oob") );
			}
			if (_accessToken.length)
			{
				newQueryString.add( new Parameter( "oauth_token", _accessToken ) );
			}
			else if (_authorizationToken.length)
			{
				newQueryString.add( new Parameter("oauth_token", _authorizationToken) );
			}
			if (_accessPin )
			{
				newQueryString.add( new Parameter("oauth_verifier", _accessPin.toString()) );
			}

			// Add any post data if available
			if (method.toUpperCase() == "POST" && postData.length)
			{
				var qs:QueryString = new QueryString( postData );
				if (qs.length)
				{
					for (var p:uint = 0; p < qs.length; p++)
					{
						newQueryString.add( qs.getParam(p) );
					}
				}
			}

			newQueryString.sort();	// Oauth requires parameters to be sorted


			var signedURI:String = newQueryString.toString();
//			trace( "signedURI: " + signedURI );

			var sigBase:String = method.toUpperCase() + "&" + encodeURIComponent( url ) + "&" + encodeURIComponent( signedURI );
//			trace( "sigBase: " + sigBase );

			var hmac:HMAC = Crypto.getHMAC( "sha1" );	// Must be lower case crypto type
			var key:ByteArray = Hex.toArray( Hex.fromString(encodeURIComponent(_consumerSecret) + "&" + encodeURIComponent(_accessTokenSecret)) );
			var data:ByteArray = Hex.toArray( Hex.fromString(sigBase) );

			var sha:String = Base64.encodeByteArray( hmac.compute(key, data) );

			signedURI += "&oauth_signature=" + encodeURIComponent( sha );
//			trace( "signedURI: " + signedURI );

			return signedURI;
		}




		//
		// STEP 1: Request an authorisation token...

		public function requestToken():void
		{
			if (_oauthDomain.length == 0)
			{
				throw new ArgumentError( "oauthDomain property not set" );
			}


			try
			{
				var reqURI:String = "http://" + _oauthDomain + _requestTokenFragment;
					reqURI += "?" + getSignedURI( "GET", reqURI );

				var req:URLRequest = new URLRequest( reqURI );
					req.method = "GET";

				var httpService:HTTPService = new HTTPService;
					httpService.url = reqURI;
					httpService.useProxy = false;
					httpService.method = "GET";
					httpService.addEventListener( "result", httpRequestTokenResult );
					httpService.addEventListener( "fault", httpRequestTokenFault );
					httpService.send();
			}
			catch( error:Error )
			{
				var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_REQUEST_TOKEN_FAILED );
				evt.data = "Unable to request token from " + _oauthDomain + " because: " + error.toString();
				this.dispatchEvent( evt );
				trace( evt.data );

				reset();
			}
		}

		private function httpRequestTokenResult( event:ResultEvent ):void
		{
			var result:String = event.result.toString();
			trace( "httpResult: " + result );

			var qs:QueryString = new QueryString( result );
			if (qs.length)
			{
				_authorizationToken = qs.getValue( "oauth_token" );
			}
			
			if (_authorizationToken != null && _authorizationToken.length)
			{
				this.dispatchEvent( new OAuthEvent(OAuthEvent.ON_REQUEST_TOKEN_RECEIVED) );
			}
			else
			{
				var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_REQUEST_TOKEN_FAILED );
				evt.data = "Unable to receive request token from " + _oauthDomain + " because no valid response received. We got: " + result;
				this.dispatchEvent( evt );
				trace( evt.data );

				reset();
			}
		}
		
		private function httpRequestTokenFault( event:FaultEvent ):void
		{
			var faultstring:String = event.fault.faultString;

			var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_REQUEST_TOKEN_FAILED );
			evt.data = "Unable to request token from " + _oauthDomain + " because: " + faultstring;
			this.dispatchEvent( evt );
			trace( evt.data );

			reset();
		}



		//
		// STEP 2: Redirect to website for authorisation...

		public function requestAuthorisation():void
		{
			if (_oauthDomain.length == 0)
			{
				throw new ArgumentError( "oauthDomain property not set" );
			}
			if (_authorizationToken.length == 0)
			{
				throw new Error( "requestToken not called successfully yet" );
			}


			try
			{
				var reqURI:String = "http://" + _oauthDomain + _authorizeFragment;
				reqURI += "?oauth_token=" + encodeURIComponent( _authorizationToken );					
				trace( "reqURI: " + reqURI );

				var urlRequest:URLRequest = new URLRequest( reqURI );
				navigateToURL( urlRequest );
			}
			catch (error:Error)
			{
				var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_REQUEST_TOKEN_FAILED );
				evt.data = "Unable to authorise request from " + _oauthDomain + " because: " + error.toString();
				this.dispatchEvent( evt );
				trace( evt.data );

				reset();
			}
		}



		//
		// STEP 3: Request an access token...

		public function requestAccessToken( pin:Number ):void
		{
			if (_oauthDomain.length == 0)
			{
				throw new ArgumentError( "oauthDomain property not set" );
			}
			if (_authorizationToken.length == 0)
			{
				throw new Error( "requestToken not called successfully yet" );
			}


			_accessPin = pin;

			try
			{
				var reqURI:String = "http://" + _oauthDomain + _accessTokenFragment
				reqURI += "?" + getSignedURI( "GET", reqURI );
				trace( "reqURI: " + reqURI );

				var req:URLRequest = new URLRequest( reqURI );
				req.method = "GET";

				var httpService:HTTPService = new HTTPService;
					httpService.url = reqURI;
					httpService.useProxy = false;
					httpService.method = "GET";
					httpService.addEventListener( "result", httpAccessTokenResult );
					httpService.addEventListener( "fault", httpAccessTokenFault );
					httpService.send();
			}
			catch (error:Error)
			{
				var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_ACCESS_TOKEN_FAILED );
				evt.data = "Unable to request access token from " + _oauthDomain + " because: " + error.toString();
				this.dispatchEvent( evt );
				trace( evt.data );

				reset();
			}
		}

		private function httpAccessTokenResult( event:ResultEvent ):void
		{
			var result:String = event.result.toString();
			trace( "httpResult: " + result );

			var qs:QueryString = new QueryString( result );
			if (qs.length)
			{
				_accessToken = qs.getValue( "oauth_token" );
				_accessTokenSecret = qs.getValue( "oauth_token_secret" );
				_currentUserID = Number( qs.getValue( "user_id" ) );
				_currentUserName = qs.getValue( "screen_name" );
			}
			
			if (_accessToken != null && _accessToken.length && _accessTokenSecret != null && _accessTokenSecret.length)
			{
				this.dispatchEvent( new OAuthEvent(OAuthEvent.ON_ACCESS_TOKEN_RECEIVED) );
			}
			else
			{
				var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_ACCESS_TOKEN_FAILED );
				evt.data = "Unable to receive access token from " + _oauthDomain + " because no valid response received. We got: " + result;
				this.dispatchEvent( evt );
				trace( evt.data );

				reset();
			}
		}
		
		private function httpAccessTokenFault( event:FaultEvent ):void
		{
			var faultstring:String = event.fault.faultString;

			var evt:OAuthEvent = new OAuthEvent( OAuthEvent.ON_ACCESS_TOKEN_FAILED );
			evt.data = "Unable to request access token from " + _oauthDomain + " because: " + faultstring;
			this.dispatchEvent( evt );
			trace( evt.data );

			reset();
		}



		// Validate a Luhn number which is used for client authentication PIN numbers
		public function validatePin( pin:String ):Boolean
		{
			var clen:Array = [];
			var n:Number = 0;
			for (n = 0; n < pin.length; ++n)
			{
				clen[n] = Number( pin.charAt(n) );
			}

			for (n = clen.length - 2; n >= 0; n -= 2)
			{
				clen[n] *= 2;

				if (clen[n] > 9)
					clen[n] -= 9;
			}

			var sum:Number = 0;
			for (n = 0; n < clen.length; ++n)
			{
				sum += clen[ n ];
			}

			return ( sum % 10 ) == 0 ? true : false;
		}


		// Private internal variables
		private var _requestTokenFragment:String = "/oauth/request_token";		
		private var _authorizeFragment:String = "/oauth/authorize";		
		private var _accessTokenFragment:String = "/oauth/access_token";
		
		private var _oauthDomain:String = "";
		private var _consumerKey:String = "";
		private var _consumerSecret:String = "";
		private var _usePinWorkflow:Boolean = true;

		// Variables filled out during authorisation
		private var _currentUserName:String = "";
		private var _currentUserID:Number = 0;

		private var _authorizationToken:String = "";

		// Access variables which need to be persisted for future requests
		private var _accessToken:String = "";
		private var _accessTokenSecret:String = "";		
		private var _accessPin:Number = 0;
	}
}
