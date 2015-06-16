declare @manifest nvarchar(25)
set @manifest = '501'


declare @day int
set @day = 0

;with cte
as (
	select @day as dt 
		, MTCode, mst.Frequency, AcctCode, PubShortName, msi.Sequence
		, CASE when mst.Frequency & 1 = 1 then msi.Sequence 
			else null end as [SEQ1]
		, CASE when mst.Frequency & 2 = 2 then msi.Sequence 
			else null end as [SEQ2]
		, CASE when mst.Frequency & 4 = 4 then msi.Sequence 
			else null end as [SEQ3]	
		, CASE when mst.Frequency & 8 = 8 then msi.Sequence 
			else null end as [SEQ4]
		, CASE when mst.Frequency & 16 = 16 then msi.Sequence 
			else null end as [SEQ5]
		, CASE when mst.Frequency & 32 = 32 then msi.Sequence 
			else null end as [SEQ6]
		, CASE when mst.Frequency & 64 =64 then msi.Sequence 
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
	and mst.Frequency & power(2, @day ) = 1
	union all
	select  dt + 1
		, mt.MTCode, mst.Frequency, a.AcctCode, p.PubShortName, msi.Sequence
		, CASE when mst.Frequency & 1 = 1 then msi.Sequence 
			else null end as [SEQ1]
		, CASE when mst.Frequency & 2 = 2 then msi.Sequence 
			else null end as [SEQ2]
		, CASE when mst.Frequency & 4 = 4 then msi.Sequence 
			else null end as [SEQ3]	
		, CASE when mst.Frequency & 8 = 8 then msi.Sequence 
			else null end as [SEQ4]
		, CASE when mst.Frequency & 16 = 16 then msi.Sequence 
			else null end as [SEQ5]
		, CASE when mst.Frequency & 32 = 32 then msi.Sequence 
			else null end as [SEQ6]
		, CASE when mst.Frequency & 64 = 64 then msi.Sequence 
			else null end as [SEQ7]		from scManifestTemplates mt
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
	and mst.Frequency & power(2, dt + 1 ) = power(2, dt + 1 )
	and power(2, dt + 1 ) <= 127
)
select MTCode, AcctCode, PubShortName
		, MAX(SEQ1) as [SUN]
		, MAX(SEQ2) as [MON]
		, MAX(SEQ3) as [TUE]
		, MAX(SEQ4) as [WED]
		, MAX(SEQ5) as [THU]
		, MAX(SEQ6) as [FRI]
		, MAX(SEQ7) as [SAT]
from cte
group by MTCode, AcctCode, PubShortName
order by AcctCode
