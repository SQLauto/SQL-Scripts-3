
begin tran
/*
	Move finalized sequence items from old manifest to new manifest
*/
declare @oldMfst nvarchar(25)
declare @newMfst nvarchar(25)
declare @manifestDate datetime
declare @MTCode nvarchar(25)

declare @newMfstId int
declare @newMfstSeqTemplateId int

set @manifestDate = '12/24/2010'
set @oldMfst = '8347-1'
set @newMfst = '8347'

--| Create the new manifest
	insert scManifests (
		 CompanyID
		,DistributionCenterId
		,MfstCode
		,MfstName
		,MfstDescription
		,MfstNotes
		,MfstImported
		,MfstCustom1
		,MfstCustom2
		,MfstCustom3
		,MfstActive
		,DeviceId
		,ManifestTypeId
		,ManifestOwner
		,ManifestDate
		,ManifestTemplateId
	)
	select
		 1
		,1
		,mt.MTCode
		,mt.MTName
		,mt.MTDescription
		,mt.MTNotes
		,mt.MTImported
		,mt.MTCustom1
		,mt.MTCustom2
		,mt.MTCustom3
		,1
		,mt.DeviceId
		,mt.ManifestTypeId
		,mt.MTOwner
		,@manifestDate
		,mt.ManifestTemplateId
	from
		scManifestTemplates mt
	where
		mt.MTCode = @newMfst


--|  Get the Manifest Sequences to update
select ms.ManifestSequenceId, ms.AccountPubId
	, ms.ManifestId, ms.ManifestSequenceTemplateId
into #toUpdate
from scManifestSequences ms
join scManifests m
	on ms.ManifestId = m.ManifestID
where m.MfstCode = @oldMfst
and m.ManifestDate = @manifestDate

--select *
--from #toUpdate

--|  Get the ManifestId of the destination manifest
select @newMfstId = m.ManifestID
from scManifests m
where MfstCode = @newMfst
and ManifestDate = @manifestDate

--|  Get the ManifestSequenceTemplateId of the destination Sequence
select @newMfstSeqTemplateId = ManifestSequenceTemplateId 
	--MTCode, mst.Code, mst.Frequency
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
where mt.MTCode = @newMfst
and mst.Frequency & case DATEPART(dw, @manifestDate) 
		when 1 then 1
		when 2 then 2
		when 3 then 4
		when 4 then 8
		when 5 then 16
		when 6 then 32
		when 7 then 64
		end
		> 0

update scManifestSequences 
set ManifestId = @newMfstId
	, ManifestSequenceTemplateId = @newMfstSeqTemplateId
from scManifestSequences ms
join #toUpdate tmp
	on ms.ManifestSequenceId = tmp.ManifestSequenceId

select tmp.ManifestSequenceId, tmp.AccountPubId, tmp.ManifestId, tmp.ManifestSequenceTemplateId
	, ms.ManifestId as [New ManifestId]
	, ms.ManifestSequenceTemplateId as [New ManifestSequenceTemplateId]
from #toUpdate tmp
join scManifestSequences ms
	on tmp.ManifestSequenceId = ms.ManifestSequenceId

drop table #toUpdate

commit tran