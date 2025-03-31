Class domain.problem.ProblemService
{

ClassMethod GetProblems(patientId As %String) As %DynamicArray
{
    set result = []
    &sql(
        DECLARE C1 CURSOR FOR
        SELECT ID INTO :id
        FROM domain_problem.Problem
        WHERE Patient = :patientId
    )
    &sql(OPEN C1)
    for {
        &sql(FETCH C1)
        quit:(SQLCODE '= 0)
        set problem = ##class(domain.problem.Problem).%OpenId(id)
        set json = ..ProblemToJSON(problem)
        do result.%Push(json)
    }
    &sql(CLOSE C1)
    return result
}

ClassMethod ProblemToJSON(problem As domain.problem.Problem) As %DynamicObject
{
    set json = {
        "id": (problem.%Id()),
        "name": (problem.Name),
        "status": (problem.Status),
        "onsetDate": ($zdate(problem.OnsetDate, 3)),
        "updated": (problem.Updated),
        "comments": []
    }
    
    for i=1:1:problem.Comments.Count() {
        set comment = problem.Comments.GetAt(i)
        do json.comments.%Push({
            "id": (comment.%Id()),
            "text": (comment.Text),
            "enteredBy": (comment.EnteredBy),
            "date": (comment.Date)
        })
    }
    return json
}

ClassMethod CreateProblem(patientId As %String, problemData As %DynamicObject) As %Status
{
    set problem = ##class(domain.problem.Problem).%New()
    set problem.Patient = ##class(domain.patient.Patient).%OpenId(patientId)
    set problem.Name = problemData.name
    set problem.Status = problemData.status
    set problem.OnsetDate = $zdateh(problemData.onsetDate, 3)
    set problem.Updated = $zdt($now(), 3)
    return problem.%Save()
}
}