
declare @acctCode nvarchar(25)

set @acctCode = '40000084'

select m.ManifestDate, m.MfstCode, typ.ManifestTypeName
	, a.AcctCode, p.PubShortName
from scManifests m
join dd_scManifestTypes typ
	on m.ManifestTypeId = typ.ManifestTypeId
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where a.AcctCode = @acctCode
--and DATEPART(dw, m.ManifestDate) in (1,7)
--and datediff(d, m.ManifestDate, GETDATE()) < 21
--and DATEPART(dw, m.ManifestDate) = 7
and m.ManifestTypeId = 1
and p.PubShortName = 'stee'
order by m.ManifestDate desc, m.MfstCode, p.PubShortName