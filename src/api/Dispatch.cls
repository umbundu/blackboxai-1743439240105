Class api.Dispatch Extends %CSP.REST
{

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
    if (pUrl = "/auth/login") {
        return $$$OK
    }
    
    set token = $piece(%request.GetCgiEnv("HTTP_AUTHORIZATION"), " ", 2)
    if (token = "") {
        return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP401UNAUTHORIZED)
    }
    
    set payload = ##class(infrastructure.security.JWTService).ValidateToken(token)
    if '$isobject(payload) {
        return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP401UNAUTHORIZED)
    }
    
    set %session.Data("username") = payload.sub
    set %session.Data("roles") = payload.roles
    
    return $$$OK
}

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/auth" Prefix="1" Forward="api.AuthAPI"/>
    <Route Url="/problem" Prefix="1" Forward="api.ProblemAPI"/>
    <Route Url="/comment" Prefix="1" Forward="api.CommentAPI"/>
</Routes>
}
}