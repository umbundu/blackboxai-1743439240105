Class api.CommentAPI Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/problem/:problemId/comment" Method="POST" Call="AddComment"/>
    <Route Url="/problem/:problemId/comment/:id" Method="DELETE" Call="DeleteComment"/>
</Routes>
}

ClassMethod AddComment(problemId As %String) As %Status
{
    set data = %request.Content
    set problem = ##class(domain.problem.Problem).%OpenId(problemId)
    set comment = ##class(domain.comment.Comment).%New()
    set comment.Text = data.text
    set comment.EnteredBy = data.enteredBy
    do problem.Comments.Insert(comment)
    set sc = problem.%Save()
    
    if $$$ISOK(sc) {
        return ..%WriteResponse({"status":"success"})
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP500INTERNALSERVERERROR)
}

ClassMethod DeleteComment(problemId As %String, id As %String) As %Status
{
    set problem = ##class(domain.problem.Problem).%OpenId(problemId)
    set comment = ##class(domain.comment.Comment).%OpenId(id)
    if '$isobject(problem) || '$isobject(comment) {
        return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP404NOTFOUND)
    }
    
    set sc = problem.Comments.RemoveAt(id)
    if $$$ISOK(sc) {
        set sc = problem.%Save()
        return ..%WriteResponse({"status":"success"})
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP500INTERNALSERVERERROR)
}
}