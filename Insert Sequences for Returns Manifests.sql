begin tran

set nocount on

	--|  Import Manifests
	create table #tempManifests (
		mfstcode varchar(20)
		, mfstname varchar(50)
		, mfsttype varchar(80)
		, mfstowner varchar(50)
		, frequency int
	)


	create table #tmpDaysOfWeek ( 
		  DayNumber int
		, DayName nvarchar(3)
		, Frequency int
		)

	insert into #tmpDaysOfWeek 
	select 1, 'SUN', 1
	union all select 2, 'MON', 2
	union all select 3, 'TUE', 4
	union all select 4, 'WED', 8
	union all select 5, 'THU', 16
	union all select 6, 'FRI', 32
	union all select 7, 'SAT', 64


	insert into #tempManifests (mfstcode, mfstname, mfsttype, mfstowner, frequency)
	 select mtcode, mtcode, ManifestTypeId, MTOwner, 127
	 from scManifestTemplates mt
	where ManifestTypeId = 1

	-- Insert the new manifests.
	insert dbo.scManifestTemplates (
		 MTCode
		,MTName
		,MTOwner
		,ManifestTypeId
	--	,MTDescription
		,MTNotes
		,MTImported
	--	,MTCustom1
	--	,MTCustom2
	--	,MTCustom3
		,MTDeleted

	)
	select mfstcode
		, mfstname
		, tmp.mfstowner as [MTOwner]
		, tmp.mfsttype as [ManifestTypeId]
		, 'Adhoc Import ' + convert(varchar, getdate(), 1)
		, 0 as [MTImported]
		, 0 as [MTDeleted]
	from #tempManifests tmp
	left join scManifestTemplates mt on ( tmp.mfstcode = mt.MTCode )
	where MTCode is null
	order by mfsttype, mfstcode
	print 'Inserted ' + cast(@@rowcount as varchar) + ' into scManifestTemplates.'

	insert scManifestSequenceTemplates (
		 ManifestTemplateId
		,Code
		,Description
		,Frequency
	)
	select 
		 mt.ManifestTemplateId
		, MTCode + '_' + [DayName]
		, MTCode + '_' + [DayName] + ' Sequence'
		, case [DayNumber]
			when 1 then 1
			when 2 then 2
			when 3 then 4
			when 4 then 8
			when 5 then 16
			when 6 then 32
			when 7 then 64
			end as [Frequency]
	from #tempManifests tmp
	join #tmpDaysOfWeek dow
		on ( tmp.frequency & dow.frequency ) > 0
	join scManifestTemplates mt on tmp.mfstcode = mt.MTCode
	left join scManifestSequenceTemplates mst on
		mst.ManifestTemplateId = mt.ManifestTemplateId and
		( mst.Frequency & tmp.frequency ) > 0
	where mst.ManifestSequenceTemplateId is null
	order by 1
	print 'Inserted ' + cast(@@rowcount as varchar) + ' into scManifestSequenceTemplates.'

	drop table #tempManifests
	drop table #tmpDaysOfWeek

rollback tran