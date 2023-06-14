<cfinclude template = "./includes/header.cfm">

<cfscript>
	// CREATE CFC OBJECTS
    ordersObj = createObject("component","src.components.orders");
	
	// REQUEST URL  
    ordersUrl="https://sellingpartnerapi-na.amazon.com/orders/v0/orders?MarketplaceIds=ATVPDKIKX0DER&CreatedAfter=2020-10-10&MaxResultPerPage=1"
    requestMethod="GET"

	// GET ORDERS DATA FROM AMAZON
    orderResponse=ordersObj.getOrders(ordersUrl,requestMethod)
	
	// GET ORDER OLD FORMAT PROPERTIES 
	compatibleOrderData=ordersObj.getOrderOldFormat()

	// CHECK ORDERS DATA EXISTS ON AMAZON
	ordersData=[]
	if (structKeyExists(variables, "orderResponse") && structKeyExists(orderResponse, "payload")) 
	{
		ordersData=orderResponse.payload.orders
	}

	// GENERATE ORDERS DATA ACCORDING TO OLD FORMAT AND SAVES ON JSON FILES
	ordersObj.genOldFormatOrderRecods(ordersData,compatibleOrderData)

</cfscript>
	<cfoutput>
		<div class="container-fluid">
		<h2 class='w-100 text-center'>Create orders filesOrders</h2>
		</div>
	</cfoutput>
<cfinclude template = "./includes/footer.cfm">
    
