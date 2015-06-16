declare @mfstcode nvarchar(25)
declare @startDate datetime
declare @endDate datetime

set @mfstcode = '8301'
set @startDate = '11/07/2011'
set @endDate = '11/13/2011'

;with cteManifests 
as (
	select distinct MfstCode, AccountId
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID			
	where MfstCode = @mfstcode
	and ManifestDate between @startDate and @endDate
)
--,
--cteManifestTempaltes
--as (
--	select distinct MTCode, ap.AccountId
--	from scManifestTemplates mt
--	join scManifestSequenceTemplates mst
--		on mt.ManifestTemplateId = mst.ManifestTemplateId
--	join scManifestSequenceItems msi
--		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
--	join scAccountsPubs ap
--		on msi.AccountPubId = ap.AccountPubID	
--	where mt.MTCode = @mfstcode	
--)
, cteDraws
as (
	select DrawID, MfstCode, d.AccountID, PublicationID, DrawDate, DrawAmount, AdjAmount, AdjAdminAmount, RetAmount
	from scDraws d
	join cteManifests m
		on d.AccountID = m.AccountId
	where DrawDate between @startDate and @endDate
	)
select a.AcctCode, cte.*
from cteDraws cte
join scAccounts a
	on cte.AccountID = a.AccountID
where RetAmount > 0

		