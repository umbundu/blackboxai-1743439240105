Class domain.comment.Comment Extends %Persistent
{
Property Text As %String(MAXLEN = 500);
Property EnteredBy As %String;
Property Date As %TimeStamp [ InitialExpression = {$zdt($now(), 3)} ];
}