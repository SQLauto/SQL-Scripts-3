

declare @startDate datetime
declare @endDate datetime
declare @manifest nvarchar(25)

set @startDate = '11/11/2012'
set @endDate = '11/17/2012'
set @manifest = 'R05971'
;with cte
as (
	select 0 as dt
		--, mt.MfstCode, m.ManifestDate
		, mt.MTCode, mst.Frequency
		, a.AcctCode, p.PubShortName, msi.Sequence
		, CASE when mst.Frequency & 1 > 0 then msi.Sequence 
			else null end as [SEQ1]
		, CASE when mst.Frequency & 2 > 0 then msi.Sequence 
			else null end as [SEQ2]
		, CASE when mst.Frequency & 4 > 0 then msi.Sequence 
			else null end as [SEQ3]	
		, CASE when mst.Frequency & 8 > 0 then msi.Sequence 
			else null end as [SEQ4]
		, CASE when mst.Frequency & 16 > 0 then msi.Sequence 
			else null end as [SEQ5]
		, CASE when mst.Frequency & 32 > 0 then msi.Sequence 
			else null end as [SEQ6]
		, CASE when mst.Frequency & 64 > 0 then msi.Sequence 
			else null end as [SEQ7]				
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where mt.MTCode = @manifest
	--and m.ManifestDate = @startDate
	union all
	select dt + 1
		, mt.MTCode, mst.Frequency
		, a.AcctCode, p.PubShortName, msi.Sequence
		, CASE when mst.Frequency & 1 > 0 then msi.Sequence 
			else null end as [SEQ1]
		, CASE when mst.Frequency & 2 > 0 then msi.Sequence 
			else null end as [SEQ2]
		, CASE when mst.Frequency & 4 > 0 then msi.Sequence 
			else null end as [SEQ3]	
		, CASE when mst.Frequency & 8 > 0 then msi.Sequence 
			else null end as [SEQ4]
		, CASE when mst.Frequency & 16 > 0 then msi.Sequence 
			else null end as [SEQ5]
		, CASE when mst.Frequency & 32 > 0 then msi.Sequence 
			else null end as [SEQ6]
		, CASE when mst.Frequency & 64 > 0 then msi.Sequence 
			else null end as [SEQ7]				
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	join cte
		on cte.MTCode = mt.MTCode
		and cte.AcctCode = a.AcctCode
		and cte.PubShortName = p.PubShortName
	where mt.MTCode = @manifest
	and mst.Frequency & power(2, dt + 1) > 0
	--and dt + 1 <= @endDate
)
select MTCode, AcctCode, PubShortName
		, MAX(SEQ1) as [SEQ1]
		, MAX(SEQ2) as [SEQ2]
		, MAX(SEQ3) as [SEQ3]
		, MAX(SEQ4) as [SEQ4]
		, MAX(SEQ5) as [SEQ5]
		, MAX(SEQ6) as [SEQ6]
		, MAX(SEQ7) as [SEQ7]
from cte
group by MTCode, AcctCode, PubShortName
order by [SEQ1]
