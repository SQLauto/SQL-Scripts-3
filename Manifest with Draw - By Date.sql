declare @date datetime
set @date = convert( nvarchar, getdate(), 1)



;with cteManifests 
as (
select MfstCode, ap.AccountId, ap.PublicationId
from scManifests m
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubID	
where m.ManifestDate = @date
), cteDraws
as (
select DrawID, DrawDate, AccountID, PublicationID, DrawAmount
from scDraws d
where d.DrawDate = @date
)
select m.MfstCode, @date as [DrawDate], sum(d.DrawAmount) as [DrawTotal]
from cteManifests m
join cteDraws d
	on m.AccountId = d.AccountID
	and m.PublicationId = d.PublicationID
group by m.MfstCode