

--|Trace AcctPub through manifest history

declare @acctcode nvarchar(20)
declare @pub nvarchar(5)

set @acctcode = '10045001'
set @pub = null

select m.ManifestDate, m.MfstCode, a.AcctCode, p.PubShortName
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
left join scManifestSequences ms
	on ap.AccountPubID = ms.AccountPubId
left join scManifests m
	on ms.ManifestId = m.ManifestID
where a.AcctCode = @acctcode
and (
	( @pub is null and p.PublicationId > 0 )
	or ( @pub is not null and p.PubShortName = @pub )
	)
order by m.ManifestDate desc