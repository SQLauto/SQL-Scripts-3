begin tran

/*
	Fill in gaps

	Validate:
	1)  Get a list of accounts with unassigned pubs.  This is a preliminary list of accounts where we
		can fill in the gaps.
	2)  make sure account isn't split between manifests
	
	Insert:
	1)  Take list of eligible Accounts, find the Manifest that the account belongs to
	
*/
set nocount on

declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)

set @bkp_name = 'tmpBackup_scManifestSequenceItems_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)

set @sql = 'select *
			into ' + @bkp_name + '
			from scManifestSequenceItems'
exec(@sql)			

--set @sql = 'select *
--			from ' + @bkp_name
--exec(@sql)			


	select AccountID, AcctCode, ManifestTypeId, Frequency, SUM(PubCount) as [PubCount (Assigned)]
	into #seqPubCount
	from (
		select a.AccountID, a.AcctCode, mt.ManifestTypeId, mst.Frequency, COUNT(*) as [PubCount]
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
	) as [seqPubCount]
	group by AccountID, AcctCode, ManifestTypeId, Frequency
	order by AccountID, ManifestTypeId, Frequency

	select seq.*, pubCount.PubCount as [PubCount (Total)]
	into #prelimAccts
	from #seqPubCount seq
	join (
		select a.AccountID, a.AcctCode, COUNT(*) as [PubCount]
		from scAccounts a
		join scAccountsPubs ap
			on a.AccountID = ap.AccountId
		group by a.AccountID, a.AcctCode
		--order by a.AccountID	
		) as [pubCount]
		on seq.AccountID = pubCount.AccountID	
	where seq.[PubCount (Assigned)] < pubCount.PubCount	
	print cast(@@rowcount as varchar) + ' Accounts where not all Pubs are assigned to a Sequence on a given day'

--select *
--from #prelimAccts

	select tmp1.AccountID, tmp1.ManifestTypeId, tmp1.Frequency
	into #splitAccts --|  Accounts split between manifests
	from (	
		select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency
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
		group by a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency	
		) as [tmp1]
	join (
		select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency
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
		group by a.AccountID, a.AcctCode, mt.ManifestTemplateId ,MTCode, mt.ManifestTypeId, typ.ManifestTypeDescription, mst.Frequency	
		) as [tmp2]
		on tmp1.AcctCode = tmp2.AcctCode
		and tmp1.ManifestTypeDescription = tmp2.ManifestTypeDescription
	where tmp1.Frequency & tmp2.Frequency > 0
	and tmp1.MTCode <> tmp2.MTCode
	and tmp1.ManifestTemplateId > tmp2.ManifestTemplateId
	order by tmp1.AcctCode
	print cast(@@rowcount as varchar) + ' Accounts that are split between Manifests.  These are ineligible to "fill in the gaps" on a single manifest.'
	
--|eligibleAccts
	select prelim.AccountId, prelim.ManifestTypeId, prelim.Frequency, prelim.[PubCount (Assigned)], prelim.[PubCount (Total)]
	into #eligibleAccts
	from #prelimAccts prelim
	left join #splitAccts split
		on prelim.AccountId = split.AccountId
		and prelim.ManifestTypeId = split.ManifestTypeId
		and prelim.Frequency = split.Frequency
	where split.AccountId is null
	
	print 'Found ' + cast(@@rowcount as varchar) + ' eligible accounts.  (The number of inserted manifest sequence items will be higher due to the pubs)'	

/*
select a.AcctCode, e.AccountId, e.ManifestTypeId, e.Frequency, e.[PubCount (Assigned)], e.[PubCount (Total)]
from #eligibleAccts e
join scAccounts a
	on e.AccountId = a.AccountID
where e.AccountID not in (
		select a.AccountId
			--, AcctCode, AcctName, PubShortName, dd.DrawAmount, dd.DrawWeekday
			--	, case dd.DrawWeekday
			--		when 1 then 1
			--		when 2 then 2
			--		when 3 then 4
			--		when 4 then 8
			--		when 5 then 16
			--		when 6 then 32
			--		when 7 then 64
			--		end as [Freq]
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
		)
order by a.AcctCode
*/

select sum([PubCount (Total)] - [PubCount (Assigned)]) as [Missing AcctPub count]
from #eligibleAccts e
where e.AccountID not in (
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
		)	
		
--/*
	select mfsts.ManifestSequenceTemplateId, ap.AccountPubID, mfsts.Sequence
	into #scManifestSequenceItems_ItemsAdded
	from #eligibleAccts	e
	join (
		select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId
			, typ.ManifestTypeDescription, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
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
		group by a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId
			, typ.ManifestTypeDescription, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
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
	and e.AccountID not in (
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
		)	
	order by 1

	set @bkp_name = 'scManifestSequenceItems_ItemsAdded_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)

	set @sql = 'select *
				into ' + @bkp_name + '
				from #scManifestSequenceItems_ItemsAdded'
	exec(@sql)			

	set @sql = 'select *
				from ' + @bkp_name
	exec(@sql)		

	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select mfsts.ManifestSequenceTemplateId, ap.AccountPubID, mfsts.Sequence
	from #eligibleAccts	e
	join (
		select a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId
			, typ.ManifestTypeDescription, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
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
		group by a.AccountID, a.AcctCode, mt.ManifestTemplateId, MTCode, mt.ManifestTypeId
			, typ.ManifestTypeDescription, mst.ManifestSequenceTemplateId, mst.Frequency, msi.Sequence
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
	and e.AccountID not in (
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
		)	
	order by 1
	print 'Inserted ' + cast(@@rowcount as varchar) + ' Manifest Sequence Items.'
--*/	
drop table #seqPubCount
drop table #splitAccts
drop table #prelimAccts	
drop table #eligibleAccts

commit tran