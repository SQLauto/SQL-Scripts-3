/*
delivery start date by acctcode
*/
declare @acctcode nvarchar(20)
set @acctcode = '20057605'

select a.AcctCode, p.PubShortName, MIN(d.DrawDate) as [MinDrawDate]
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID
left join scDraws d
	on ap.AccountId = d.AccountID
	and ap.PublicationId = d.PublicationID
where ( ( @acctcode is null and a.AccountID > 0 )
	or a.AcctCode = @acctcode )
group by a.AcctCode, p.PubShortName	
	
