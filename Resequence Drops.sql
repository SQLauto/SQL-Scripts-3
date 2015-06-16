begin tran

declare @start int
declare @increment int

set @start = 0
set @increment = 7

--|  "preview" using a select statement
;with cteMTAccounts 
as (
	select distinct mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID	
	)	
select mst.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, ap.PublicationId, msi.Sequence
	, seq.NewSequence
from scManifestSequenceTemplates mst
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID	
join (
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId
		, isnull(@start,0) + row_number() over (partition by ManifestTemplateId, ManifestSequenceTemplateId order by Sequence) 
			* @increment
		as [NewSequence]
	from cteMTAccounts
	) as seq
	on ap.AccountId = seq.AccountId
	and mst.ManifestTemplateId = seq.ManifestTemplateId
	and mst.ManifestSequenceTemplateId = seq.ManifestSequenceTemplateId
order by ManifestTemplateId

--|  actual update statement that you would use in the stored procedure 
;with cteMTAccounts 
as (
	--| get the current sequence order, by Account
	select distinct mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID	
	)	
update scManifestSequenceItems 
set Sequence = seq.NewSequence
from scManifestSequenceTemplates mst
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID	
join (
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId
		, isnull(@start,0) + row_number() over (partition by ManifestTemplateId, ManifestSequenceTemplateId order by Sequence) 
			* @increment
		as [NewSequence]
	from cteMTAccounts
	) as seq
	on ap.AccountId = seq.AccountId
	and mst.ManifestTemplateId = seq.ManifestTemplateId
	and mst.ManifestSequenceTemplateId = seq.ManifestSequenceTemplateId



rollback tran