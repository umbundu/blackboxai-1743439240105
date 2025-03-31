Class domain.problem.Problem Extends %Persistent
{
Property Patient As domain.patient.Patient;
Property Name As %String;
Property Status As %String(VALUELIST = ",Active,Resolved");
Property OnsetDate As %Date;
Property Updated As %TimeStamp;
Property Comments As list Of domain.comment.Comment;

Index PatientIndex On Patient;
}