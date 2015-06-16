IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'support_BulkFinalizeForDateRange' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.support_BulkFinalizeForDateRange
GO

CREATE PROCEDURE dbo.support_BulkFinalizeForDateRange
	@startdate datetime
	, @enddate datetime
	, @refinalize int = 0
AS
	set nocount on
	
	declare @msg nvarchar(200)

	if @refinalize = 1
	begin

		--exec support_BackupTable 'scManifests', 1, null
		--exec support_BackupTable 'scManifestSequences', 1, null
		--exec support_BackupTable 'scManifestHistory', 1, null

		delete scManifestSequences
		from scManifests m
		join scManifestSequences ms
			on m.ManifestID = ms.ManifestId
		where m.ManifestDate between @startdate and @enddate
		set @msg = 'Deleted ' + cast(@@rowcount as varchar) + ' manifest sequence records.'
		print @msg
		
		delete scManifestHistory
		from scManifests m
		join scManifestHistory mh
			on m.ManifestID = mh.ManifestId
		where m.ManifestDate between @startdate and @enddate
		set @msg = 'Deleted ' + cast(@@rowcount as varchar) + ' manifest history records.'
		print @msg
		
		delete scManifests
		from scManifests m
		where m.ManifestDate between @startdate and @enddate
		set @msg = 'Deleted ' + cast(@@rowcount as varchar) + ' manifest records for manifests between ' 
			+ convert(varchar, @startdate, 1) + ' and ' + convert(varchar, @enddate, 1)
		print @msg
	end

	create table #manifestsToInsert (ManifestTemplateId int, ManifestDate datetime )
	
	;with cteDateRange(Date)
		AS
		(
			SELECT
				@StartDate [Date]
			UNION ALL
			SELECT
				DATEADD(day, 1, Date) Date
			FROM
				cteDateRange
			WHERE
				Date < @EndDate
		)
		
	insert into #manifestsToInsert( ManifestTemplateId, ManifestDate )
	select mt.ManifestTemplateId, [Date]--, m.ManifestID
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join cteDateRange dt
		on 1 = 1
	left join scManifests m
		on mt.ManifestTemplateId = m.ManifestTemplateId
		and dt.Date = m.ManifestDate
	where dbo.scGetDayFrequency([Date]) & mst.Frequency > 0
	and mt.MTDeleted = 0
	and m.ManifestID is null
	option (maxrecursion 365)
	
	--select *
	--from #manifestsToInsert
	--order by 1, 2

	-- Insert the manifests if they do not exist
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
		,tmp.ManifestDate
		,mt.ManifestTemplateId
	from #manifestsToInsert tmp
	join scManifestTemplates mt
		on tmp.ManifestTemplateId = mt.ManifestTemplateId
	set @msg = 'Inserted ' + cast(@@rowcount as varchar) + ' historical manifest records.'
	print @msg
	--exec syncSystemLog_Insert 2, 0, 1, @msg

/*
	select
		 mt.MTCode
		,mt.MTName
		, u.UserName as [MTOwner]
		, d.DeviceCode
		, convert(varchar, tmp.ManifestDate, 1) as [ManifestDate]
	from #manifestsToInsert tmp
	join scManifestTemplates mt
		on tmp.ManifestTemplateId = mt.ManifestTemplateId
	left join Users u
		on mt.MTOwner = u.UserID
	left join nsDevices d
		on mt.DeviceId = d.DeviceId
*/		

	;with cteDateRange(Date)
		AS
		(
			SELECT
				@StartDate [Date]
			UNION ALL
			SELECT
				DATEADD(day, 1, Date) Date
			FROM
				cteDateRange
			WHERE
				Date < @EndDate
	),
	cteAlreadyOnManifest
	as (
		select m.ManifestID, ms.ManifestSequenceTemplateId, ms.AccountPubId, ms.Sequence
		from scManifests m
		join cteDateRange dt
			on m.ManifestDate = dt.Date
		join scManifestSequences ms
			on m.ManifestID = ms.ManifestId	
		)
	select m.ManifestID, mst.ManifestSequenceTemplateId, msi.AccountPubId, msi.Sequence
	into #manifestSequencesToInsert
	from scManifests m
	join cteDateRange dt
		on m.ManifestDate = dt.Date
	join scManifestTemplates mt
		on m.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
		and dbo.scGetDayFrequency(m.ManifestDate) & mst.Frequency > 0
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID	
	left join cteAlreadyOnManifest cte
		on msi.ManifestSequenceTemplateId = cte.ManifestSequenceTemplateId
		and msi.AccountPubId = cte.AccountPubId
	where cte.AccountPubId is null
	and a.AcctActive = 1
	and ap.Active = 1
	option (maxrecursion 365)

	insert scManifestSequences ( ManifestId, ManifestSequenceTemplateId, AccountPubId, Sequence )
	select *
	from #manifestSequencesToInsert
	set @msg = 'Inserted ' + cast(@@rowcount as varchar) + ' manifest sequence records.'
	print @msg

	--select m.MfstCode, convert(varchar, m.ManifestDate, 1) as [ManifestDate], COUNT(*) as [# of AcctPubs Added]
	--from #manifestSequencesToInsert tmp
	--join scManifests m
	--	on tmp.ManifestID = m.ManifestID
	--group by m.MfstCode, m.ManifestDate
	--order by m.MfstCode, m.ManifestDate

	--select m.MfstCode, convert(varchar, m.ManifestDate, 1) as [ManifestDate], a.AcctCode, p.PubShortName, tmp.Sequence
	--from #manifestSequencesToInsert tmp
	--join scManifests m
	--	on tmp.ManifestID = m.ManifestID
	--join scAccountsPubs ap
	--	on tmp.AccountPubId = ap.AccountPubID
	--join scAccounts a
	--	on a.AccountID = ap.AccountId
	--join nsPublications p
	--	on ap.PublicationId = p.PublicationID
	--order by m.MfstCode, m.ManifestDate, tmp.Sequence

	drop table #manifestsToInsert
	drop table #manifestSequencesToInsert
GO