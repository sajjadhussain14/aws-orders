<cfcomponent displayname="AWS Orders 2" output="true" hint="Handle the application.">

    <!--- Set up the application. --->
    <cfset THIS.Name = "AWS Orders 2" />
    <cfset THIS.ApplicationTimeout = CreateTimeSpan( 1, 0, 0, 0 ) />
    <cfset THIS.SessionTimeout = CreateTimeSpan( 0, 3, 0, 0 ) />
    <cfset THIS.SessionManagement = true />
    <cfset THIS.SetClientCookies = true />

<cfscript>
	this.serialization = {
		preserveCaseForStructKey: true,
		preserveCaseForQueryColumn: true
	};
</cfscript>

    <!--- Define the page request properties. --->
    <cfsetting requesttimeout="999999999999" showdebugoutput="true" enablecfoutputonly="false" />

    <cffunction name="OnApplicationStart" access="public"  output="false" hint="Fires when the application is first created.">

        <cfscript>

            // Configure application
            currentDirectory='/aws-orders/'
            host = structKeyExists(cgi,'http_host') ? cgi.http_host  : '';
            req_url = 'http://' & host;
            application.baseUrl = req_url & currentDirectory;
            application.homeurl = req_url & currentDirectory;
            application.secureurl=req_url & currentDirectory  


            // AWS API CREDENTIALS 
            
            application.accessKeyId = ""; 
            application.secretAccessKey = "";

            application.refresh_token=''

            application.client_id = ""; 
            application.client_secret = ""; 


        </cfscript>
    </cffunction>

    <cffunction name="OnRequest" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete.">

        <!--- Define arguments. --->
        <cfargument name="TargetPage" type="string" required="true" />
        
        <!--- maximum items to display for pagination --->
        <cfset application.pagingMaxItems = 10>

<cfscript>
	this.serialization = {
		preserveCaseForStructKey: false,
		preserveCaseForQueryColumn: false
	};
</cfscript>

        <!--- Include the requested page. --->
        <cfinclude template="#ARGUMENTS.TargetPage#" />

        <!--- Return out. --->
        <cfreturn />
    </cffunction>


    <cffunction name="OnRequestEnd" access="public" returntype="void" output="true" hint="Fires after the page processing is complete.">
        <!--- Return out. --->
   
        <cfreturn />
    </cffunction>


    <cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
        <!--- Define arguments. --->
        <cfargument name="SessionScope" type="struct" required="true" />
        <cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

        <!--- Return out. --->
        <cfreturn />
    </cffunction>


    <cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Fires when the application is terminated.">
        <!--- Define arguments. --->
        <cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

        <!--- Return out. --->
        <cfreturn />
    </cffunction>


    <cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
        <!--- Define arguments. --->
        <cfargument name="Exception" type="any" required="true" />
        <cfargument name="EventName" type="string" required="false" default="" />

        <cfdump var="#arguments#" abort>
        <!--- Return out. --->
        <cfreturn />
    </cffunction>

</cfcomponent>