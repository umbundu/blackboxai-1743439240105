Class infrastructure.security.JWTService
{

/// Generate JWT token
ClassMethod GenerateToken(pUsername As %String, pRoles As %String) As %String
{
    set payload = {
        "sub": (pUsername),
        "exp": ($zdt($ztimestamp + (60*60*24),3)), // 24h expiration
        "roles": (pRoles)
    }
    set secret = "your-secret-key-here"
    return ##class(%OAuth2.Utils).GenerateJWT(secret, "HS256", , payload)
}

/// Validate JWT token
ClassMethod ValidateToken(pToken As %String) As %DynamicObject
{
    set secret = "your-secret-key-here"
    return ##class(%OAuth2.Utils).ValidateJWT(secret, pToken)
}
}