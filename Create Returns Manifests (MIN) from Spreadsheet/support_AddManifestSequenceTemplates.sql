IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_AddManifestSequenceTemplates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_AddManifestSequenceTemplates]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_AddManifestSequenceTemplates]
	@consolidated int = 1
AS
BEGIN
	set nocount on

	declare @msg nvarchar(256)
	declare @count int

	create table #tempManifests (
		mfstcode varchar(20)
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


	insert into #tempManifests (mfstcode, frequency)
	select mt.MTCode, 127
	from scManifestTemplates mt
	left join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	where 
		mt.ManifestTypeId = ( select ManifestTypeId from dd_scManifestTypes where ManifestTypeDescription = 'Returns' )
		and mt.MTDeleted <> 1
	group by mt.ManifestTemplateId, mt.MTCode, mt.MTDeleted
	having COUNT(mst.ManifestSequenceTemplateId) = 0	
	set @count = @@ROWCOUNT
	
	
	if @count > 0
	begin
		set @msg = 'Found ' + CAST(@count as varchar) + ' Returns Manifests with no Manifest Sequence Templates.  '
		print @msg
		
		if @consolidated = 1
		begin
			insert scManifestSequenceTemplates (
				 ManifestTemplateId
				,Code
				,Description
				,Frequency
			)
			select 
				 mt.ManifestTemplateId
				, MTCode
				, MTCode + '_WEEKLY Sequence'
				, 127 as [Frequency]
			from #tempManifests tmp
			--join #tmpDaysOfWeek dow
			--	on ( tmp.frequency & dow.frequency ) > 0
			join scManifestTemplates mt on tmp.mfstcode = mt.MTCode
			left join scManifestSequenceTemplates mst on
				mst.ManifestTemplateId = mt.ManifestTemplateId and
				( mst.Frequency & tmp.frequency ) > 0
			where mst.ManifestSequenceTemplateId is null
			order by 1
			
			set @msg = @msg + 'Inserted ' + cast(@@rowcount as varchar) + ' records into scManifestSequenceTemplates.'
			exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
			print @msg		
		end
		else 
		begin

			--|individual sequences	
			insert scManifestSequenceTemplates (
				 ManifestTemplateId
				,Code
				,Description
				,Frequency
			)
			select 
				 mt.ManifestTemplateId
				, left(MTCode + '_' + [DayName], 20)
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
			set @msg = @msg + 'Inserted ' + cast(@@rowcount as varchar) + ' records into scManifestSequenceTemplates.'
			exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
			print @msg
		end
	end
	else
		begin
			set @msg = 'Found ' + CAST(@count as varchar) + ' Returns Manifests with no Manifest Sequence Templates.  '
			print @msg
		end	
	drop table #tempManifests
	drop table #tmpDaysOfWeek
END
GO	

GRANT EXECUTE ON [dbo].[support_AddManifestSequenceTemplates] TO [nsUser]
GO