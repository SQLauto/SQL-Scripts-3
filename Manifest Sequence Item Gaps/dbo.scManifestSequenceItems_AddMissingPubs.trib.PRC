if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scManifestSequenceItems_AddMissingPubs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scManifestSequenceItems_AddMissingPubs]
GO

create  procedure [dbo].[scManifestSequenceItems_AddMissingPubs]
as
/*=========================================================
	
	scManifestSequenceItems_AddMissingPubs	

	$History:  $

==========================================================*/
begin
	set nocount on

	declare @counter int
	declare @msg nvarchar(1028)
	declare @debug int --| [0|1]
	set @debug = 0
	
	set @msg = 'scManifestSequenceItems_AddMissingPubs:  Procedure Starting...'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg


	/*
		Get the assigned pub count per account, per manifest type
	*/
		select AccountID, AcctCode, ManifestTypeId, Frequency, SUM([assignedPubCount]) as [assignedPubCountTotal]
		into #assignedPubCount
		from (
			select a.AccountID, a.AcctCode, mt.ManifestTypeId, mst.Frequency, COUNT(*) as [assignedPubCount]
			from scManifestTemplates mt
			join scManifestSequenceTemplates mst
				on mt.ManifestTemplateId = mst.ManifestTemplateId
			join scManifestSequenceItems msi
				on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
			join scAccountsPubs ap
				on msi.AccountPubId = ap.AccountPubID
			join scAccounts a
				on ap.AccountId = a.AccountID
			where a.AcctCode <> ''
			group by a.AccountID, a.AcctCode, mt.ManifestTypeId, mst.Frequency	
		) as [assignedPubCountTotal]
		group by AccountID, AcctCode, ManifestTypeId, Frequency
		order by AccountID, ManifestTypeId, Frequency

	/*
		Compare the assigned pub count with the total pub count to get a preliminary 
		list of Accounts before we eliminate splits and weekend boxes  
	*/
		select tmp.AccountId, tmp.AcctCode, tmp.ManifestTypeId, tmp.Frequency
			, tmp.assignedPubCountTotal, pubCount.totalPubCount
		into #prelimAccts
		from #assignedPubCount tmp
		join (
			select a.AccountID, a.AcctCode, COUNT(*) as [totalPubCount]
			from scAccounts a
			join scAccountsPubs ap
				on a.AccountID = ap.AccountId
			group by a.AccountID, a.AcctCode
			--order by a.AccountID	
			) as [pubCount]
			on tmp.AccountID = pubCount.AccountID	
		where tmp.[assignedPubCountTotal] < pubCount.totalPubCount	
		
	/*
		Find accounts that are split between two manifests.  These are ineligible for 
		correction by this procedure.
	*/
		select tmp1.AccountID, tmp1.ManifestTypeId, tmp1.Frequency
		into #splitAccts --|  Accounts split between manifests
		from (	
			select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency
			from scAccounts a
			join #prelimAccts pre
				on a.AccountId = pre.AccountId
			join scAccountsPubs ap
				on a.AccountID = ap.AccountId
			join scManifestSequenceItems msi
				on ap.AccountPubID = msi.AccountPubId
			join scManifestSequenceTemplates mst
				on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
			join scManifestTemplates mt
				on mst.ManifestTemplateId = mt.ManifestTemplateId
			join dd_scManifestTypes typ
				on mt.ManifestTypeId = typ.ManifestTypeId	
			group by a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency	
			) as [tmp1]
		join (
			select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency
			from scAccounts a
			join #prelimAccts pre
				on a.AccountId = pre.AccountId
			join scAccountsPubs ap
				on a.AccountID = ap.AccountId
			join scManifestSequenceItems msi
				on ap.AccountPubID = msi.AccountPubId
			join scManifestSequenceTemplates mst
				on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
			join scManifestTemplates mt
				on mst.ManifestTemplateId = mt.ManifestTemplateId
			join dd_scManifestTypes typ
				on mt.ManifestTypeId = typ.ManifestTypeId	
			group by a.AccountID, a.AcctCode, mt.ManifestTemplateId ,MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency	
			) as [tmp2]
			on tmp1.AcctCode = tmp2.AcctCode
			and tmp1.ManifestTypeDescription = tmp2.ManifestTypeDescription
		where tmp1.Frequency & tmp2.Frequency > 0
		and tmp1.MTCode <> tmp2.MTCode
		and tmp1.ManifestTemplateId > tmp2.ManifestTemplateId
		order by tmp1.AcctCode
		
	/*
		eligibleAccts (Prelim Accounts with splits and wknd boxes eliminated)
	*/	
		select prelim.AccountId, prelim.ManifestTypeId, prelim.Frequency
			, prelim.[assignedPubCountTotal], prelim.[totalPubCount]
		into #eligibleAccts
		from #prelimAccts prelim
		left join (
			select a.AccountId
			from scAccounts a
			join dd_scAccountTypes typ
				on a.AccountTypeID = typ.AccountTypeID
			join scAccountsPubs ap
				on a.AccountID = ap.AccountId	
			join nsPublications	p
				on ap.PublicationId = p.PublicationID
			join scDefaultDraws dd
				on ap.AccountId = dd.AccountID
				and ap.PublicationId = dd.PublicationID
			where typ.ATName = 'OBOX'
			and PubShortName in ('RED1','HOY')
			and dd.DrawWeekday in (1,7)
			) as wkndBoxes
			on prelim.AccountId = wkndBoxes.AccountId
		left join #splitAccts split
			on prelim.AccountId = split.AccountId
			and prelim.ManifestTypeId = split.ManifestTypeId
			and prelim.Frequency = split.Frequency
		where split.AccountId is null
		and wkndBoxes.AccountID is null
		
		set @msg = 'scManifestSequenceItems_AddMissingPubs:  Found ' + cast(@@rowcount as varchar) + ' eligible accounts with '

		select @counter = sum([totalPubCount] - [assignedPubCountTotal])
		from #eligibleAccts e	
		
		set @msg = @msg + 'with ' + CAST(@counter as varchar) + ' AcctPubs.'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg

	/*
		Keep an audit trail of items added
	*/
		if not exists (
			select id
			from sysobjects
			where id = object_id('scManifestSequenceItems_ItemsToAdd')
		)
		begin
			create table scManifestSequenceItems_ItemsToAdd (
				  ManifestSequenceTemplateId int
				, AccountPubID int
				, Sequence int
				, DateAdded datetime
			)
		end
		
		declare @date datetime
		set @date = GETDATE()
		
		insert into scManifestSequenceItems_ItemsToAdd (ManifestSequenceTemplateId, AccountPubID, Sequence, DateAdded)
		select mfsts.ManifestSequenceTemplateId, ap.AccountPubID, mfsts.Sequence, @date as [DateAdded]
		from #eligibleAccts	e
		join (
			--By definition, the eligible Accounts have to be on a single manifest
			select a.AccountID, mt.ManifestTemplateId, mt.ManifestTypeId
				, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
			from scAccounts a
			join scAccountsPubs ap
				on a.AccountID = ap.AccountId
			join scManifestSequenceItems msi
				on ap.AccountPubID = msi.AccountPubId
			join scManifestSequenceTemplates mst
				on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
			join scManifestTemplates mt
				on mst.ManifestTemplateId = mt.ManifestTemplateId
			join dd_scManifestTypes typ
				on mt.ManifestTypeId = typ.ManifestTypeId	
			group by a.AccountID, mt.ManifestTemplateId, mt.ManifestTypeId
				, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
			) as [mfsts]
			on e.AccountId = mfsts.AccountID
			and e.ManifestTypeId = mfsts.ManifestTypeId
			and e.Frequency = mfsts.Frequency
		join scAccountsPubs ap
			on e.AccountId = ap.AccountId
		left join scManifestSequenceItems msi
			on ap.AccountPubID = msi.AccountPubId
			and mfsts.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
		where msi.AccountPubId is null			
		order by 1


		insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
		select ManifestSequenceTemplateId, AccountPubId, Sequence
		from scManifestSequenceItems_ItemsToAdd
		where DateAdded = @date

		set @msg = 'scManifestSequenceItems_AddMissingPubs:  Inserted ' + cast(@@rowcount as varchar) + ' Manifest Sequence Items.'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg

	drop table #assignedPubCount
	drop table #splitAccts
	drop table #prelimAccts	
	drop table #eligibleAccts

	set @msg = 'scManifestSequenceItems_AddMissingPubs:  Procedure Completed.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg

	if @debug = 1
		select a.AcctCode, p.PubShortName, mt.MTCode, mtyp.ManifestTypeDescription, mst.Code, mst.Frequency, tmp.Sequence
		from scManifestSequenceItems_ItemsToAdd tmp
		join scAccountsPubs ap
			on tmp.AccountPubID = ap.AccountPubID
		join scAccounts a
			on ap.AccountId = a.AccountID
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		join scManifestSequenceTemplates mst
			on tmp.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		join scManifestTemplates mt
			on mst.ManifestTemplateId = mt.ManifestTemplateId
		join dd_scManifestTypes mtyp
			on mt.ManifestTypeId = mtyp.ManifestTypeId
		where DateAdded = @date
		order by a.AcctCode, p.PubShortName, tmp.Sequence
end
