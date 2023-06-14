<cfcomponent name="config">
	<cfscript>
		//APP Settings
		this.accessKeyId = application.accessKeyId;
		this.secretAccessKey = application.secretAccessKey;

		this.refresh_token = application.refresh_token;
		this.grant_type='refresh_token'

		this.client_id = application.client_id;
		this.client_secret = application.client_secret;


        this.apiEndPoint="https://api.amazon.com/auth/o2/token"


		this.defaultRegionName = "us-east-1";
		this.defaultServiceName = "execute-api";

		this.hashAlorithm = "SHA256";
		this.grant_type = "refresh_token";
		this.client_id = application.client_id;
		this.client_secret = application.client_secret;

		this.signatureAlgorithm	 = "AWS4-HMAC-SHA256";
		this.hashAlorithm = "SHA256";
		this.apiVersion = "aws4_request";




	</cfscript>

</cfcomponent>