<cfinclude template = "./includes/header.cfm">


<cfscript>
	// Get date and Time
	datetime = dateConvert("Local2UTC", now())
	amzDate=	dateFormat( datetime, "yyyymmdd" ) &	"T" & timeFormat( datetime, "HHmmss" ) &	"Z"
	dateStamp=	dateFormat( datetime, "yyyymmdd" )

	// Define a struct for arguments
	args={requestParams={MarketplaceIds='ATVPDKIKX0DER',CreatedAfter='2020-10-10',MaxResultPerPage=2}}
	// Input fields
	args.requestMethod='GET'
	args.hostName='sellingpartnerapi-na.amazon.com'
	args.requestURI='/orders/v0/orders'
	args.requestBody=""
	args.requestHeaders={}
	
	args.signedPayload=true
	args.excludeHeaders=[]
	args.amzDate=#amzDate#
	args.dateStamp=dateStamp

	// create objects
	oauth = createObject("component","src.components.oauth");
	externalFulfillment = createObject("component","src.components.externalFulfillment");
	orders = createObject("component","src.components.orders");
	generateData = createObject("component","src.components.generateData");

	filepath="data/orders.json";
	// Get Signatured Data
	signatureData=externalFulfillment.generateSignatureData(argumentCollection=args)

	args.updateTargetUrl='https://sellingpartnerapi-na.amazon.com/orders/v0/orders?MarketplaceIds=ATVPDKIKX0DER&CreatedAfter=2020-10-10&MaxResultPerPage=2'
	// Get Access and Refresh Data
	args.tokens=oauth.getToken(amzDate)
	orders=orders.getOrders(args.updateTargetUrl,args.tokens.access_token,amzDate,signatureData.authHeader)
	Writedump(var=orders)
	fileName = "orders.json"
	filePath = ExpandPath("data/" & fileName)
	//generateData.createJsonFile(orders,filePath)
</cfscript>
	<cfoutput>
		<div class="container-fluid">
		<h2 class='w-100 text-center'>Display Orders</h2>
		<h3 class='w-100 text-center mt-3'>Response</h3>
		</div>
	</cfoutput>
<cfinclude template = "./includes/footer.cfm">
    
