Class api.AuthAPI Extends %CSP.REST
{

Parameter UseSession = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/login" Method="POST" Call="Login"/>
    <Route Url="/logout" Method="POST" Call="Logout"/>
</Routes>
}

ClassMethod Login() As %Status
{
    set data = %request.Content
    set username = data.username
    set password = data.password
    
    if (username = "admin" && (password = "admin")) {
        set token = ##class(infrastructure.security.JWTService).GenerateToken(username, "admin")
        set response = {
            "token": (token)
        }
        return ..%WriteResponse(response)
    }
    
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP401UNAUTHORIZED)
}

ClassMethod Logout() As %Status
{
    kill %session.Data("username")
    kill %session.Data("roles")
    return ..%WriteResponse({"status":"success"})
}
}