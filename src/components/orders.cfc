<cfcomponent name="orders">
	<cfscript> 
	// Get date and Time
	datetime = dateConvert("Local2UTC", now())
	amzDate=	dateFormat( datetime, "yyyymmdd" ) &	"T" & timeFormat( datetime, "HHmmss" ) &	"Z"
	dateStamp=	dateFormat( datetime, "yyyymmdd" )

	// GET AUTH DATA
	public function getAuthData(
		required any requestParams
		,required any requestMethod
		,required any hostName
		,required any requestURI
	)
	{
		authContent={}
		// Define a struct for arguments
		args={requestParams=arguments.requestParams}
		// Input fields
		args.requestMethod=arguments.requestMethod
		args.hostName=arguments.hostName
		args.requestURI=
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
		// Get Signatured Data
		signatureData=externalFulfillment.generateSignatureData(argumentCollection=args)
		args.updateTargetUrl='https://sellingpartnerapi-na.amazon.com/orders/v0/orders/112-6882465-4525054/orderItems'
		// Get Access and Refresh Data
		args.tokens=oauth.getToken(amzDate)
	}


	// GET GQUERY PARAMS FROM URL STRING
	public  function getQueryString(
		required string urlString
	)
	{
		queryParams = {}
		if (FindNoCase("=",arguments.urlString) and Find("?", arguments.urlString))
		{
			queryString = ListRest(arguments.urlString, "?")
			if( len(queryString))
			{
				queryArray = listToArray(listLast(arguments.urlString, "?"), "&")
				for ( param in queryArray) {
					paramName = listFirst(param, "=")
					paramValue = listLast(param, "=")
					queryParams[paramName] = paramValue
				}
			}
		}
		return queryParams;
	}


	// GET HOSTNAME FROM URL STRING
	public  function getHostname(
		required string urlString
	)
	{
		urlDomain = reReplace(
			urlString,
			"^\w+://([^\/:]+)[\w\W]*$",
			"\1",
			"one"
			);
		urlDomain=urlDomain
		return urlDomain
	}


	// GET URI FROM URL STRING
	public  function getURI(
		required string urlString
	)
	{
		uriString = Replace(urlString, "https://", "") 
		uriString = ListRest(uriString, "/")
		uriString = ListFirst(uriString, "?")
		return uriString
	}

	// GET ORDERS DATA
	public function getOrders(
		required any urlString
		,required any requestMethod
	)
	{
		requestParams=getQueryString(arguments.urlString)
		hostName=getHostname(arguments.urlString)
		requestURI=getURI(arguments.urlString)
		// Define a struct for arguments
		args={requestParams=requestParams}
		// Input fields
		args.requestMethod=arguments.requestMethod
		args.hostName=hostName
		args.requestURI=requestURI
		args.requestBody=""
		args.requestHeaders={}
		args.signedPayload=true
		args.excludeHeaders=[]
		args.amzDate=#amzDate#
		args.dateStamp=dateStamp
		oauth = createObject("component","oauth");
		externalFulfillment = createObject("component","externalFulfillment");
		// Get Signatured Data
		signatureData=externalFulfillment.generateSignatureData(argumentCollection=args)
		// Get Access and Refresh Data
		tokens=oauth.getToken(amzDate)
		cfhttp(method=arguments.requestMethod, url=urlString, result="result" , charset = "utf-8") {
			cfhttpparam(name="x-amz-access-token", type="header", value=tokens.access_token);
			cfhttpparam(name="X-Amz-Date", type="header", value=amzDate);
			cfhttpparam(name="Authorization", type="header", value=signatureData.authHeader);
		}
		res=result.filecontent;
		return deSerializeJSON(res)
	}

	// GET ORDERS ITEMS
	private function getOrdersItems(
		required any urlString
		,required any requestMethod
	)
	{
		requestParams=getQueryString(arguments.urlString)
		hostName=getHostname(arguments.urlString)
		requestURI=getURI(arguments.urlString)
		// Define a struct for arguments
		args={requestParams=requestParams}
		// Input fields
		args.requestMethod=arguments.requestMethod
		args.hostName=hostName
		args.requestURI=requestURI
		args.requestBody=""
		args.requestHeaders={}
		args.signedPayload=true
		args.excludeHeaders=[]
		args.amzDate=#amzDate#
		args.dateStamp=dateStamp
		oauth = createObject("component","oauth");
		externalFulfillment = createObject("component","externalFulfillment");
		// Get Signatured Data
		signatureData=externalFulfillment.generateSignatureData(argumentCollection=args)
		// Get Access and Refresh Data
		tokens=oauth.getToken(amzDate)
		cfhttp(method=arguments.requestMethod, url=urlString, result="result" , charset = "utf-8") {
			cfhttpparam(name="x-amz-access-token", type="header", value=tokens.access_token);
			cfhttpparam(name="X-Amz-Date", type="header", value=amzDate);
			cfhttpparam(name="Authorization", type="header", value=signatureData.authHeader);
		}
		res=result.filecontent;
		return deSerializeJSON(res)
	}

	// GET ORDERS OLD FORMAT
	public function getOrderOldFormat()
	{
		orderoldFormat={
			"OrderShippingTaxTotal": 0.0,
			"OrderStateId": 1,
			"MinusPromotionsOrderTotal": 0.0,
			"ShipAddressFieldThree": "",
			"TenderId": 1,
			"BuyerName": "",
			"insertClosed": "false",
			"InventoryStoreIds": 1,
			"MachineId": 100,
			"OrderLineTaxRate": 0.0,
			"ShipAddressFieldOne": "",
			"ShipPostalCode": "",
			"OrderTotal": 0,
			"OrderDate": "",
			"OrderSubtotal": 0,
			"OrderLineShipTaxRate": 0.0,
			"ShipName": "",
			"WeightedReceiptShipTaxRate": "0",
			"ShipCountryCode": "US",
			"CombinedOrderTaxAndShippingTaxTotal":0,
			"Promotions": [],
			"FulfillmentServiceLevel": "",
			"ShipAddressFieldTwo": "",
			"ShipPhoneNumber": "",
			"PromotionTotal": 0.0,
			"EmployeeId": 1,
			"AmazonSessionId": "",
			"StoreId": 1,
			"OrderShippingTotal": 0.0,
			"GiftMessageText": "",
			"OrderGiftNotes": "",
			"AmazonOrderId": "",
			"FulfillmentMethod": "",
			"OrderTypId": 1,
			"OrderTaxTotal": 0.0, 
			"OrderPostedDate": "",
			"AmazonChannel": "",
			"BuyerEmailAddress": "",
			"CombinedOrderPrincipalAndShippingCharge": 0.0,
			"LineItems": [
				{
				"Quantity": "1",
				"GiftWrapPrice": 0,
				"Tax": 0,
				"GiftMessageText": "",
				"OrderLineTaxRate": 0,
				"GiftWrapTax": 0,
				"Shipping": 0,
				"ShippingPromo": 0,
				"AmazonOrderItemCode": "",
				"OrderLineShipTaxRate": 0,
				"Principal": 0, 
				"Title": "",
				"Sku": "",
				"Weight": 1,
				"ProductTaxCode": "null",
				"Promotions": 0,
				"ShippingTax": 0,
				"FeeTotal": 0
				}
			],
			"ShipCity": "",
			"ShipStateOrRegion": "",
			"BuyerPhoneNumber": "" 
			}

		return orderoldFormat		
	}

		// START GENERATE ORDER DATA IN OLD FORMAT IN JASON FILES
		public function genOldFormatOrderRecods(
			required any ordersData
			,required any compatibleOrderData
		)
		{
			// SET VARIABLES 
			ordersData=arguments.ordersData
			compatibleOrderData=arguments.compatibleOrderData

				// LOOP THROUGH OLDERS ARRAY ordersData
				for ( i=1; i<=2;i++)// for ( i=1; i<=arrayLen(ordersData);i++)
				{
					orderID=ordersData[i].AmazonOrderId

					// REQUEST DATA FOR LINE ITEMS USING ORDER ID
					itemsUrl="https://sellingpartnerapi-na.amazon.com/orders/v0/orders/#orderID#/orderItems"
					requestMethod="GET"
					
					// GET ORDER LINE ITEMS
					resp=getOrdersItems(itemsUrl,requestMethod)
					ordertAllItems=resp.payload.orderItems

					// GET ORDERS OLD FORMAT
					compatibleOrderData=copyOrdersData(ordersData,ordertAllItems,compatibleOrderData)
					
					// START WRITING ORDERS IN OLD FORMAT IN JSON FILES
					fileName = orderID&".json"
					filePath = ExpandPath("data/" & fileName)
					saveOrdersData(compatibleOrderData,filePath)
					// END WRITING ORDERS IN OLD FORMAT IN JSON FILES
				}
				writeDump('orders saved in old formats Successfully!')
		}
		// END GENERATE ORDER DATA IN OLD FORMAT IN JASON FILES


		// START COPY ORDERS DATA FROM AWS TO FILE ACCORDING TO OLD FORMAT
		private function copyOrdersData(
		required any ordersData
		,required any ordertAllItems
		,required any compatibleOrderData
		)
		{
			// SET VARIABLES
			ordersData=arguments.ordersData			
			ordertAllItems=arguments.ordertAllItems			
			compatibleOrderData=arguments.compatibleOrderData
			shippingTaxTotalItems=0
			shippingPriceTotalItems=0
			totalPriceItems=0
			ordertaxTotal=0

			// START COPING LINE ITEMS
			arrayEach(ordertAllItems, function(orderItem, index) 
			{
				if(isdefined("orderItem.ItemTax.amount"))
				{
					shippingTaxTotalItems+=orderItem.ItemTax.amount
				}
				if(isdefined("orderItem.ShippingPrice.Amount"))
				{
					shippingPriceTotalItems+=orderItem.ShippingPrice.Amount
				}
				if(isdefined("orderItem.ItemPrice.amount"))
				{
					totalPriceItems+=orderItem.ItemPrice.amount
				}
				if(isdefined("orderItem.ItemTax.amount"))
				{
					ordertaxTotal+=orderItem.ItemTax.amount
				}
				if(isdefined("orderItem.QuantityOrdered"))
				{
					compatibleOrderData.LineItems[index].Quantity=orderItem.QuantityOrdered
				}
				compatibleOrderData.LineItems[index].GiftWrapPrice=0
				if(isdefined("orderItem.QuantityOrdered"))
				{
					compatibleOrderData.LineItems[index].Tax=orderItem.ItemTax.amount
				}
				compatibleOrderData.LineItems[index].GiftMessageText=""
				if(isdefined("orderItem.ItemTax.amount") && isdefined("orderItem.ItemPrice.amount") && isdefined("orderItem.QuantityOrdered"))
				{
					compatibleOrderData.LineItems[index].OrderLineTaxRate=NumberFormat((orderItem.ItemTax.amount/(orderItem.ItemPrice.amount*orderItem.QuantityOrdered))*100,"0.00")
				}
				compatibleOrderData.LineItems[index].GiftWrapTax=""
				if(isdefined("orderItem.ShippingPrice.amount"))
				{
					compatibleOrderData.LineItems[index].Shipping=orderItem.ShippingPrice.amount
				}	
				compatibleOrderData.LineItems[index].ShippingPromo=0
				compatibleOrderData.LineItems[index].AmazonOrderItemCode=orderID
				if(isdefined("orderItem.ShippingTax.amount") && isdefined("orderItem.ShippingPrice.amount"))
				{
					compatibleOrderData.LineItems[index].OrderLineShipTaxRate=NumberFormat((orderItem.ShippingTax.amount/orderItem.ShippingPrice.amount)*100,"0.00")
				}
				if(isdefined("orderItem.ItemPrice.amount"))
				{
					compatibleOrderData.LineItems[index].Principal=orderItem.ItemPrice.amount
				}
				if(isdefined("orderItem.Title"))
				{
					compatibleOrderData.LineItems[index].Title=orderItem.Title
				}
				if(isdefined("orderItem.SellerSKU"))
				{
					compatibleOrderData.LineItems[index].Sku=orderItem.SellerSKU
				}
				compatibleOrderData.LineItems[index].Weight=1
				compatibleOrderData.LineItems[index].ProductTaxCode="null"
				compatibleOrderData.LineItems[index].Promotions=0
				if(isdefined("orderItem.ShippingTax.amount"))
				{
					compatibleOrderData.LineItems[index].ShippingTax=orderItem.ShippingTax.amount
				}
				compatibleOrderData.LineItems[index].FeeTotal=0
			});
			// END COPING LINE ITEMS

			// Start Renaming values according to Old Format
			compatibleOrderData.OrderShippingTaxTotal=shippingTaxTotalItems
			compatibleOrderData.OrderStateId=1
			compatibleOrderData.MinusPromotionsOrderTotal=0.0
			compatibleOrderData.ShipAddressFieldThree=""
			compatibleOrderData.TenderId=1
			compatibleOrderData.BuyerName=""
			compatibleOrderData.insertClosed=false
			compatibleOrderData.InventoryStoreIds=1
			compatibleOrderData.MachineId=100
			compatibleOrderData.OrderLineTaxRate=0.0
			compatibleOrderData.ShipAddressFieldOne=""
			compatibleOrderData.ShipPostalCode=ordersData[i].ShippingAddress.PostalCode
			compatibleOrderData.OrderTotal=ordersData[i].OrderTotal.Amount
			compatibleOrderData.OrderDate=ordersData[i].PurchaseDate
			compatibleOrderData.OrderSubtotal=ordersData[i].OrderTotal.Amount-(shippingPriceTotalItems+shippingTaxTotalItems)
			compatibleOrderData.OrderLineShipTaxRate=0.0
			compatibleOrderData.ShipName=""
			compatibleOrderData.WeightedReceiptShipTaxRate="0"
			compatibleOrderData.ShipCountryCode="US"
			compatibleOrderData.CombinedOrderTaxAndShippingTaxTotal=shippingPriceTotalItems+shippingTaxTotalItems
			compatibleOrderData.Promotions=[]
			compatibleOrderData.FulfillmentServiceLevel=ordersData[i].ShipServiceLevel
			compatibleOrderData.ShipAddressFieldTwo=""
			compatibleOrderData.ShipPhoneNumber=""
			compatibleOrderData.PromotionTotal=0.0
			compatibleOrderData.AmazonSessionId=ordersData[i].AmazonOrderId
			compatibleOrderData.OrderShippingTotal=shippingPriceTotalItems
			compatibleOrderData.GiftMessageText=""
			compatibleOrderData.OrderGiftNotes=""
			compatibleOrderData.AmazonOrderId=ordersData[i].AmazonOrderId
			compatibleOrderData.FulfillmentMethod=ordersData[i].FulfillmentChannel
			compatibleOrderData.OrderTypId=1
			compatibleOrderData.OrderTaxTotal=ordertaxTotal
			compatibleOrderData.OrderPostedDate=ordersData[i].PurchaseDate
			compatibleOrderData.AmazonChannel=ordersData[i].FulfillmentChannel
			compatibleOrderData.BuyerEmailAddress=ordersData[i].BuyerInfo.BuyerEmail
			compatibleOrderData.CombinedOrderPrincipalAndShippingCharge=totalPriceItems+shippingPriceTotalItems
			compatibleOrderData.ShipCity=ordersData[i].ShippingAddress.City
			compatibleOrderData.ShipStateOrRegion=ordersData[i].ShippingAddress.StateOrRegion
			compatibleOrderData.BuyerPhoneNumber=""
			// End Renaming values according to Old Format
			return compatibleOrderData;			
		}
		// END COPY ORDERS DATA FROM AWS TO FILE ACCORDING TO OLD FORMAT

		// WRITE ORDERS DATA IN JSON FILES
		private function saveOrdersData(
			required any data
			,required any filePath
		)
		{
            // Convert struct to JSON string
            jsonData = SerializeJSON(data);
            // Write JSON string to file
            cffile(action="write", file=filePath, output=jsonData);
            return '';
		}

	</cfscript>
</cfcomponent>