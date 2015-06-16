begin tran
set nocount on 
	declare @sourceManifestTypeId int
	declare @targetManifestTypeId int

	set @sourceManifestTypeId = 1
	set @targetManifestTypeId = 2

	select 
		  null as [ManifestTemplateId]
		, replace( MTCode, '_D', '_C') as [MTCode]
		, replace( MTName, '_D', '_C') as [MTName]
		, MTOwner, MTDescription, MTNotes, MTImported, MTCustom1, MTCustom2, MTCustom3, MTDeleted, DeviceId
		, ManifestTemplateId as [SourceManifestTemplateId]
	into #mfstsToCopy
	from scManifestTemplates
	where ManifestTypeId = @sourceManifestTypeId

	--select *
	--from #mfstsToCopy

	--select MTCode, MTName, MTOwner, MTDescription, MTNotes, MTImported, MTCustom1, MTCustom2, MTCustom3, MTDeleted, DeviceId
	--from scManifestTemplates
	--where ManifestTypeId = 1

	select MTCode, mst.Code, count(msi.AccountPubId)
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	left join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mt.ManifestTypeId in ( 1, 2 )
	group by MTCode, mst.Code
	order by mtcode

	insert into scManifestTemplates (MTCode, MTName, MTOwner, MTDescription, MTNotes, MTImported, MTCustom1, MTCustom2, MTCustom3, MTDeleted, DeviceId, ManifestTypeId)
	select 
		MTCode
		, MTName, MTOwner, MTDescription, MTNotes, MTImported, MTCustom1, MTCustom2, MTCustom3, MTDeleted, DeviceId, @targetManifestTypeId
	from #mfstsToCopy
	print 'inserted ' + cast(@@rowcount as varchar) + ' Manifest Templates'

	update #mfstsToCopy
	set ManifestTemplateId = mt.ManifestTemplateId
	from #mfstsToCopy tmp
	join scManifestTemplates mt
		on tmp.MTCode = mt.MTCode

	insert into scManifestSequenceTemplates 
	(
		ManifestTemplateId, Code, Description, Frequency
	)
	select tmp.ManifestTemplateId,  replace( mst.Code, '_D', '_C' ), replace( mst.Description, '_D', '_C' ), mst.Frequency
	from #mfstsToCopy tmp
	join scManifestSequenceTemplates mst
		on tmp.SourceManifestTemplateId = mst.ManifestTemplateId
	print 'inserted ' + cast(@@rowcount as varchar) + ' Manifest Sequence Templates'


	;with cteSourceSequenceItems as (  
		select tmp.ManifestTemplateId, msi.AccountPubId, msi.Sequence
		from #mfstsToCopy tmp
		join scManifestSequenceTemplates mst
			on tmp.SourceManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	)
	insert into scManifestSequenceItems 
	(
		ManifestSequenceTemplateId, AccountPubId, Sequence
	)
	select distinct mst.ManifestSequenceTemplateId, cte.AccountPubId, cte.Sequence
	from cteSourceSequenceItems cte
	join scManifestSequenceTemplates mst
		on cte.ManifestTemplateId = mst.ManifestTemplateId
	left join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	print 'inserted ' + cast(@@rowcount as varchar) + ' Manifest Sequence Items'

	select MTCode, mst.Code, count(msi.AccountPubId)
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	left join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mt.ManifestTypeId in ( 1, 2 )
	group by MTCode, mst.Code
	order by mtcode
	
	select MTCode, MTName, mst.Code, mst.Frequency, msi.AccountPubId, msi.Sequence
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	left join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mt.ManifestTypeId = 2
	order by MTCode, Sequence

commit tran