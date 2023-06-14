<cfcomponent name="oauth">
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

	//GET TOKEN
	public function getToken(required any amzDate)
	{
		cfhttp(method="post", url=apiEndPoint, result="result") {
		cfhttpparam(name="X-Amz-Date", type="header", value=arguments.amzDate);
		cfhttpparam(name="content-type", type="header", value="application/x-www-form-urlencoded");
		cfhttpparam(name="grant_type", type="formfield", value=grant_type);
		cfhttpparam(name="refresh_token", type="formfield", value=refresh_token);
		cfhttpparam(name="client_id", type="formfield", value=client_id);
		cfhttpparam(name="client_secret", type="formfield", value=client_secret);
		}
		token=result.filecontent;
		return deSerializeJSON(token)
	}
    
	</cfscript>


</cfcomponent>