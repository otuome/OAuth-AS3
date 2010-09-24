package org.iotashan.oauth
{
	import org.iotashan.utils.URLEncoding;
	
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	/**
	 * Used to sign requests using HMAC-SHA1.
	 * @author Shannon Hicks
	 */
	public class OAuthSignatureMethod_HMAC_SHA1 implements IOAuthSignatureMethod
	{
		///////////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE PROPERTIES
		///////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC PROPERTIES
		///////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		///////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * Constructor 
		 */		
		public function OAuthSignatureMethod_HMAC_SHA1()
		{
		}
		/**
		 * Returns the name of the signature method. 
		 * @return String
		 */	
		public function get name():String
		{
			return "HMAC-SHA1";
		}
		/**
		 * Signs the specified request. 
		 * @param request
		 * @return String
		 */
		public function signRequest( request:OAuthRequest ):String
		{
			// get the signable string
			var toBeSigned:String = request.getSignableString();
			
			// get the secrets to encrypt with
			var sSec:String = URLEncoding.encode( request.consumer.secret ) + "&"
			
			if (request.token)
				sSec += URLEncoding.encode( request.token.secret );
			
			// hash them
			var hmac:HMAC = Crypto.getHMAC( "sha1" );
			var key:ByteArray = Hex.toArray( Hex.fromString(sSec) );
			var message:ByteArray = Hex.toArray( Hex.fromString(toBeSigned) );
			
			var result:ByteArray = hmac.compute( key,message );
			var ret:String = Base64.encodeByteArray( result );
			
			return ret;
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////
		// OVERRIDES
		///////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		///////////////////////////////////////////////////////////////////////////////////////////////
	}
}