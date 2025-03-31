Class api.ProblemAPI Extends %CSP.REST
{

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/patient/:patientId/problem" Method="GET" Call="GetProblems"/>
    <Route Url="/patient/:patientId/problem" Method="POST" Call="CreateProblem"/>
    <Route Url="/patient/:patientId/problem/:id" Method="GET" Call="GetProblem"/>
    <Route Url="/patient/:patientId/problem/:id" Method="PUT" Call="UpdateProblem"/>
    <Route Url="/patient/:patientId/problem/:id" Method="DELETE" Call="DeleteProblem"/>
</Routes>
}

ClassMethod GetProblems(patientId As %String) As %Status
{
    set problems = ##class(domain.problem.ProblemService).GetProblems(patientId)
    return ..%WriteResponse(problems)
}

ClassMethod CreateProblem(patientId As %String) As %Status
{
    set data = %request.Content
    set sc = ##class(domain.problem.ProblemService).CreateProblem(patientId, data)
    if $$$ISOK(sc) {
        return ..%WriteResponse({"status":"success"})
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP500INTERNALSERVERERROR)
}

ClassMethod GetProblem(patientId As %String, id As %String) As %Status
{
    set problem = ##class(domain.problem.Problem).%OpenId(id)
    if $isobject(problem) && (problem.Patient.%Id() = patientId) {
        return ..%WriteResponse(##class(domain.problem.ProblemService).ProblemToJSON(problem))
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP404NOTFOUND)
}

ClassMethod UpdateProblem(patientId As %String, id As %String) As %Status
{
    set problem = ##class(domain.problem.Problem).%OpenId(id)
    if '$isobject(problem) || (problem.Patient.%Id() '= patientId) {
        return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP404NOTFOUND)
    }
    
    set data = %request.Content
    set problem.Name = data.name
    set problem.Status = data.status
    set problem.OnsetDate = $zdateh(data.onsetDate, 3)
    set problem.Updated = $zdt($now(), 3)
    set sc = problem.%Save()
    
    if $$$ISOK(sc) {
        return ..%WriteResponse({"status":"success"})
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP500INTERNALSERVERERROR)
}

ClassMethod DeleteProblem(patientId As %String, id As %String) As %Status
{
    set problem = ##class(domain.problem.Problem).%OpenId(id)
    if '$isobject(problem) || (problem.Patient.%Id() '= patientId) {
        return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP404NOTFOUND)
    }
    
    set sc = ##class(domain.problem.Problem).%DeleteId(id)
    if $$$ISOK(sc) {
        return ..%WriteResponse({"status":"success"})
    }
    return ..ReportHttpStatusCode(##class(%CSP.REST).#HTTP500INTERNALSERVERERROR)
}
}