

declare @startDate datetime
declare @endDate datetime
declare @manifest nvarchar(25)

set @startDate = '4/16/2011'
set @endDate = '4/20/2011'

set @manifest = 'mfst1'
;with cteAccountsByManifest
as (
	select @startDate as dt
		, m.MfstCode, a.AcctCode, p.PubShortName
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where m.MfstCode = @manifest
	and m.ManifestDate = @startDate
	union all
	select dt + 1
		, m.MfstCode, a.AcctCode, p.PubShortName
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	join cteAccountsByManifest cte
		on cte.MfstCode = m.MfstCode
		and cte.AcctCode = a.AcctCode
		and cte.PubShortName = p.PubShortName
	where m.MfstCode = @manifest
	and m.ManifestDate = dt + 1
	and dt + 1 <= @endDate
)
select distinct AcctCode, PubShortName
from cteAccountsByManifest
--option (maxrecursion 7)

--select MfstCode, ManifestDate
--from scManifests
--order by ManifestDate desc