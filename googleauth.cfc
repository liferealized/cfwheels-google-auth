<cfcomponent mixin="model" output="false">

  <cffunction name="init" access="public" output="false">
    <cfscript>
      this.version = "1.1.7,1.1.8"; 
    </cfscript>
    <cfreturn this />
  </cffunction>
  
  <cffunction name="googleAuth" access="public" output="false" returntype="void">
    <cfargument name="secretKeyProperty" type="string" required="true" />
    <cfargument name="usernameProperty" type="string" required="true" />
    <cfscript>
      var loc = {};

      // make sure we have space to save our property info
      if (!structKeyExists(variables.wheels.class, "googleauth"))
        variables.wheels.class.googleauth = {};

      if (!structKeyExists(variables.wheels.class, "googleauthObj"))
        variables.wheels.class.googleauthObj = _createGoogleAuthJavaLoader().create("com.warrenstrange.googleauth.GoogleAuthenticator").init();

      variables.wheels.class.googleauth = duplicate(arguments);
    </cfscript>
    <cfreturn />
  </cffunction>

  <cffunction name="generateSecretKey" access="public" output="false" returntype="string">
    <cfset _verifyGoogleAuthInited() />
    <cfset this[variables.wheels.class.googleauth.secretKeyProperty] = variables.wheels.class.googleauthObj.generateSecretKey() />
    <cfreturn this[variables.wheels.class.googleauth.secretKeyProperty] />
  </cffunction>

  <cffunction name="clearSecretKey" access="public" output="false" returntype="void">
    <cfset _verifyGoogleAuthInited() />
    <cfset this[variables.wheels.class.googleauth.secretKeyProperty] = "" />
  </cffunction>

  <cffunction name="getQrBarcodeUrl" access="public" output="false" returntype="string">
    <cfargument name="host" type="string" required="false" default="#cgi.http_host#" />
    <cfargument name="user" type="string" required="false" default="#this[variables.wheels.class.googleauth.usernameProperty]#" />
    <cfargument name="secret" type="string" required="false" default="#this[variables.wheels.class.googleauth.secretKeyProperty]#" />
    <cfset _verifyGoogleAuthInited() />
    <cfreturn variables.wheels.class.googleauthObj.getQRBarcodeURL(arguments.user, arguments.host, arguments.secret) />
  </cffunction>

  <cffunction name="checkCode" access="public" output="false" returntype="string">
    <cfargument name="code" type="string" required="true" />
    <cfargument name="secret" type="string" required="false" default="#this[variables.wheels.class.googleauth.secretKeyProperty]#" />
    <cfargument name="ms" type="numeric" required="false" default="#getTickCount()#" />
    <cfset _verifyGoogleAuthInited() />
    <cfreturn variables.wheels.class.googleauthObj.check_code(arguments.secret, arguments.code, arguments.ms) />
  </cffunction>

  <cffunction name="_verifyGoogleAuthInited" access="public" output="false" returntype="void">
    <cfscript>
      if (!structKeyExists(variables.wheels.class, "googleauth"))
        $throw(type="Wheels", message="Not Inited", extendedInfo="You must call `googleAuth()` in this model object's `init()` before using the google auth plugin methods.");
    </cfscript>
  </cffunction>

  <cffunction name="_createGoogleAuthJavaLoader" access="public" output="false" returntype="any">
    <cfscript>
      var loc = {};
      
      if (!StructKeyExists(server, "javaloader") || !IsStruct(server.javaloader))
        server.javaloader = {};
      
      if (StructKeyExists(server.javaloader, "googleauth"))
        return server.javaloader.googleauth;
      
      loc.relativePluginPath = application.wheels.webPath & application.wheels.pluginPath & "/googleauth/";
      loc.classPath = Replace(Replace(loc.relativePluginPath, "/", ".", "all") & "javaloader", ".", "", "one");
      
      loc.paths = ArrayNew(1);
      loc.paths[1] = ExpandPath(loc.relativePluginPath & "lib/googleauth-0.0.1.jar");
      
      // set the javaLoader to the request in case we use it again
      server.javaloader.googleauth = $createObjectFromRoot(path=loc.classPath, fileName="JavaLoader", method="init", loadPaths=loc.paths, loadColdFusionClassPath=false);
    </cfscript>
    <cfreturn server.javaloader.googleauth />
  </cffunction>
  
</cfcomponent>