<cfcomponent name="externalFulfillment">
	<cfscript>
		// create object of Configuration CFC
		app = createObject("component","config");
		// set default values
		defaultRegionName=app.defaultRegionName
		defaultServiceName=app.defaultServiceName
		// get app values
		secretAccessKey=app.secretAccessKey
		accessKeyId=app.accessKeyId
		refresh_token=app.refresh_token
		grant_type=app.grant_type
		client_id=app.client_id
		client_secret=app.client_secret
		apiEndPoint=app.apiEndPoint

		signatureAlgorithm=app.signatureAlgorithm
		hashAlorithm=app.hashAlorithm
		apiVersion=app.apiVersion
	</cfscript>

<cfscript> 


	public  function generateSignatureData(
		required string requestMethod
		, required string hostName
		, required string requestURI
		, required any requestBody
		, required struct requestHeaders
		, required struct requestParams
		, boolean signedPayload = true
		, array excludeHeaders = []
		, string regionName
		, string serviceName
		, string amzDate 
		, string dateStamp 
	) {

		var result={}
		canonicalRequest = "";
		var hasQueryParams = structCount(arguments.requestParams) > 0;
		result.canonicalURI = buildCanonicalURI(requestURI);


					

		result.canonicalQueryString = buildCanonicalQueryString(arguments.requestParams);
		


		requestHeaders = { 
				"host" = hostName
				, "x-amz-date" = amzDate
			};
		cleanedHeaders = cleanHeaders(requestHeaders);
		cleanedPairs  = cleanHeaderNames(cleanedHeaders);




		//canonicalHeaderString
		result.canonicalHeaderString =buildCanonicalHeaders(cleanedPairs)

		// signedHeaderString 
		result.signedHeaderString = buildSignedHeaders(sortedHeaderNames);




		requestPayload = requestBody;

		if(isStruct(requestPayload))
		{
			//payloadChecksum
			result.payloadChecksum = lcase( hash( serializejson(requestPayload) , "SHA256" ) );
		}
		else{
			//payloadChecksum
			result.payloadChecksum = lcase( hash( requestPayload , "SHA256" ) );
		}

		//hashOfCanonicalRequest
		result.canonicalRequest = buildCanonicalRequest( requestMethod, result.canonicalURI, result.canonicalQueryString,result.canonicalHeaderString, result.signedHeaderString, result.payloadChecksum)

		result.hashOfCanonicalRequest=buildHashCanonicalRequest(result.canonicalRequest)

		//algorithm
		result.algorithm = signatureAlgorithm & chr(10);

		//credentialScope
		result.credentialScope=buildCredentialScope(dateStamp
		,defaultRegionName
		,defaultServiceName
		,apiVersion);

		result.stringToSign=generateStringToSign(result.algorithm
		,amzDate
		,result.credentialScope
		,result.hashOfCanonicalRequest
		)

		result.signature=generateSignatureKey(result.stringToSign,dateStamp)

		result.authHeader = buildAuthorizationHeader( 
		result.credentialScope
		,result.signedHeaderString
		,result.signature 
		)
		return result;
	}

	/**
	*  Generates request string to sign
	*/
	private string function generateStringToSign(
		required string algorithm
		,required string amzDate
		, required string credentialScope 
		, required string canonicalRequest
	) {
		stringToSign='';
		stringToSign = algorithm & amzDate & chr(10 ) & credentialScope & canonicalRequest;
		return stringToSign;
	}
	
	/**
	*  Generate canonical request string
	*/
	private  function buildCanonicalRequest(
		required string requestMethod
		, required string canonicalURI
		, required string canonicalQueryString
		, required string canonicalHeaderString
		, required string signedHeaderString
		, required string payloadChecksum ){
		canonicalRequest = requestMethod & chr(10) & canonicalURI & chr(10)	& canonicalQueryString & chr(10) & canonicalHeaderString & chr(10) & signedHeaderString & chr(10) & payloadChecksum ;
		return canonicalRequest;
	}

		/**
	*  Generate Hash canonical request string
	*/
	private  function buildHashCanonicalRequest(
		required string canonicalRequest
 ){
		hashOfCanonicalRequest = lcase( hash( canonicalRequest , "SHA256" ) );
		return hashOfCanonicalRequest
	}

	
	/**
	 * Generates canonical query string
	 * @returns canonical query string 
	 */
	private string function buildCanonicalQueryString(required struct queryParams) {
		canonicalQueryString=''	
		encodedPairs  = [];

		structEach( queryParams, function(key, value) {
		encodedParams[ encodeRFC3986(arguments.key) ] = encodeRFC3986( arguments.value);
		});

try{
		encodedKeyNames = structKeyArray( encodedParams );
		arraySort( encodedKeyNames, "text" );
		for (key in encodedKeyNames) {
		arrayAppend( encodedPairs, key &"="& encodedParams[ key ] ); 
		}

		// canonicalQueryString
		canonicalQueryString = arrayToList( encodedPairs, "&");
		} catch(any s){}

		return canonicalQueryString
	}
	
	
	/**
	 * Generates a list of signed header names. 
	 * @returns Sorted list of signed header names, delimited by semi-colon ";"
	 */

	private string function buildSignedHeaders(required any sortedHeaderNames ) {
	    signedHeaderString = arrayToList( sortedHeaderNames, ";" );
		return signedHeaderString
	}
	
	/**
	 * Generates a list of canonical headers, returns Sorted list of header pairs, delimited by new lines
	 */
	private string function buildCanonicalHeaders(required any cleanedPairs ) {
		canonicalHeaderString = arrayToList( cleanedPairs, chr(10) ) & chr(10) ;
		return canonicalHeaderString;
	}
	

	/**
	 * Generates canonical URI. Encoded, absolute path component of the URI, 
	 * @returns URL encoded path
	 */
	private string function buildCanonicalURI(required string requestURI) {
		originalURI  = len(trim(requestURI)) ? requestURI : "/"& requestURI;
		canonicalURI = replace( encodeRFC3986( originalURI ), "%2F", "/", "all");
		return canonicalURI;
	}
	
	
	/**
	 * Generates signing key for AWS Signature V4
	*/
	private  function generateSignatureKey(
		required string stringToSign
		,required any dateStamp

	){
		//Generate initial key 
		kSecret = charsetDecode("AWS4" & secretAccessKey, "UTF-8");
		//Generate HMAC of date 
		kDate     = binaryDecode( HMAC( lcase(dateStamp), kSecret, "HMACSHA256", "UTF-8"), "hex" );
		//Generate HMAC of region name
		kRegion     = binaryDecode( HMAC( lcase(defaultRegionName), kDate, "HMACSHA256", "UTF-8"), "hex" );
		//Generate HMAC of service name 
		kService     = binaryDecode( HMAC( lcase(defaultServiceName), kRegion, "HMACSHA256", "UTF-8"), "hex" );
		//generate kSigning
		kSigning = binaryDecode( HMAC("aws4_request", kService, "HMACSHA256", "UTF-8"), "hex" );
		//signature
		signature = lcase( HMAC( stringToSign, kSigning, "HMACSHA256", "UTF-8" ) );
		return signature;
	}	
	

	/**
	*  Generates string indicating the scope for which the signature is valid.
	*dateStamp / regionName / serviceName / terminationString
	*/
	private string function buildCredentialScope(
		required string dateStamp
		, required string regionName 
		, required string serviceName 
		, required string apiVersion 
	) {
		 return   credentialScope = dateStamp &'/' & regionName &'/' & serviceName &'/' & apiVersion & chr(10);
	}
	
	/**
	*  Generates Authorization header string. 
	*/
	private string function buildAuthorizationHeader( 
		required string credentialScope
		,required string signedHeaderString
		, required string signature 
	) {
		 authorizationHeader = ""
		authorizationHeader = signatureAlgorithm &" " & "Credential=" & accessKeyId &"/"& credentialScope & ", " & "SignedHeaders=" & signedHeaderString & ", " & "Signature="& signature;
		return authorizationHeader;
	}
	
	
	/**
	 * A method Generates a (binary) HMAC code for the specified message
	*/
	private binary function hmacBinary (
		required string message 
		, required binary key 
		, string algorithm = "HMACSHA256"
		, string encoding = "UTF-8"
	){
		// Generate HMAC and decode result into binary
		return binaryDecode( HMAC( arguments.message, arguments.key, arguments.algorithm, arguments.encoding), "hex" );
	}	

	
	/**
	 * A method that hashes the supplied value, with SHA256
	 * returns hashed value, in lower case
	 */
	private string function hash256 ( required any text ){
		return lcase( hash(arguments.text, "SHA256") );
	}	
	
	
	/**
	 * URL encode query parameters and names
	 * returns new structure with all parameter names and values encoded
	 */
	private struct function encodeQueryParams(required struct queryParams) {
		// First encode parameter names and values 
		var encodedParams = {};
		structEach( arguments.queryParams, function(string key, string value) {
			encodedParams[ urlEncode(arguments.key) ] = urlEncode( arguments.value );
		});	
		return encodedParams;
	}
	
	/**
	 * Scrubs header names and values:
	 */
	private struct function cleanHeaders(required struct requestHeaders) {
		cleanedHeaders = {};
		structEach( requestHeaders, function(key, value) {
		headerName = reReplace( trim(arguments.key), "\s+", " ", "all");
		headerValue = reReplace( trim(arguments.value), "\s+", " ", "all");
		cleanedHeaders[ lcase(headerName) ] = headerValue;
	});
    return cleanedHeaders;
	}

	/**
	 * Scrubs header names and values:
	 */
	private array function cleanHeaderNames(required any names) {
		cleanedPairs=[]
		sortedHeaderNames = structKeyArray( cleanedHeaders );
		arraySort( sortedHeaderNames, "text" );
		
		for (key in sortedHeaderNames) {
			arrayAppend( cleanedPairs, key &":"& cleanedHeaders[ key ] ); 
		}

		return cleanedPairs;
	}
	

		// encode url
		private function encodeRFC3986(required string text) {
		// Requires CF10+
		Local.encoded = encodeForURL(arguments.text);
		
		// Undo encoding of tilde "~"
		Local.encoded = replace( Local.encoded, "%7E", "~", "all" );
		// Change space encoding from "+" to "%20"
		Local.encoded = replace( Local.encoded, "+", "%20", "all" );
		// URL encode asterisk "*" 
		Local.encoded = replace( Local.encoded, "*", "%2A", "all" );
		return Local.encoded;
	}

	
	/**
	 * URL encodes the supplied string per RFC 3986, which defines the following as 
	 */
	private string function urlEncode( string value ) {
		var encodedValue = encodeForURL(arguments.value);
		// Reverse encoding of tilde "~"
		encodedValue = replace( encodedValue, encodeForURL("~"), "~", "all" );
		// Fix encoding of spaces, ie replace '+' into "%20"
		encodedValue = replace( encodedValue, "+", "%20", "all" );
		// Asterisk "*" should be encoded
		encodedValue = replace( encodedValue, "*", "%2A", "all" );
		
		return encodedValue;
	}





	</cfscript>
 </cfcomponent>