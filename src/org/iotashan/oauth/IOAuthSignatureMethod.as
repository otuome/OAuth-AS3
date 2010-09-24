package org.iotashan.oauth
{
	public interface IOAuthSignatureMethod
	{
		function get name():String
		
		function signRequest( request:OAuthRequest ):String
	}
}