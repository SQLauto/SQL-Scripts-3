begin tran
	set nocount on
	/*  
		This procedure will identify and correct instances where AcctPubs 
		are split between sequences on the same manifest

		$History: $
	*/

	--|  Declarations
	declare @commitTran		int
	declare @useMaxSequence	int				--| If the correct sequence cannot be determined use min or max sequence
	declare @msg			nvarchar(1024)

	set @commitTran = 0		--|  (0|1) 0 = Rollback, 1 = Commit
	set @useMaxSequence	= 1 --|  (0|1) 0 = Min, 1 = Max

	--|First we identify Accounts that appear more than once on a Manifest Sequence Template
	select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
	into #templates_prelim
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence

	--|Next we identify those Accounts that have more than once sequence
	select mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence
	into #templates_splitAcctPubs
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	join scAccounts a
		on a.AccountId = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationId
	join (
		select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
		from #templates_prelim
		group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
		having count(*) > 1
		) as split
	on mt.ManifestTemplateId = split.ManifestTemplateId
	and mst.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
	and ap.AccountId = split.AccountId
	group by mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence

		select @msg = 'Found ' + cast( count(distinct AccountId) as varchar) + ' Accounts'
		from #templates_splitAcctPubs
		print @msg
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
		
/*
select *
from #templates_splitAcctPubs
*/
	--|  create temp table to store Pub Count per Account
	select AccountId, count(*) as PubCount
	into #pubCount
	from scAccountsPubs
	where AccountId in (
		select AccountId 
		from #templates_splitAcctPubs
		)
	group by AccountId

	--|  Compare the the pub count by date to the actual pub count to identify the most recent date
	--|  that all acct/pubs were on the same sequence

	/* Step #templates_3 - Get the most recent Sequence where all pubs have the same sequence.
		The sequence where all pubs were on the same sequence is the "old" sequence. 
	 */
	select AccountId, Sequence, max(ManifestDate) as [ManifestDate]
	into #lastKnownGood
	from (
			/* Step #templates_2 - Get a list of pub counts that match the actual pub count */
			select hist.AccountId, hist.ManifestDate, hist.Sequence, hist.[Count], pc.PubCount
			from #pubCount pc
			join (
					/* Step #templates_1 - Get a list of dates and the number of pubs associated with an account */
					select split.AccountId, m.ManifestDate, ms.Sequence, count(*) as [Count]
					from scManifests m
					join scManifestSequences ms
						on ms.ManifestId = m.ManifestId
					join #templates_splitAcctPubs split
						on ms.AccountPubId = split.AccountPubId
						and ms.ManifestSequenceTemplateid = split.ManifestSequenceTemplateid
					group by split.AccountId, m.ManifestDate, ms.Sequence
				) as hist --|Historical Pub Count
				on hist.Accountid = pc.AccountId
			where hist.[Count] = pc.PubCount
		) as lastKnownGood
	group by AccountId, Sequence

/*
select *
from #lastKnownGood
*/

	if @useMaxSequence = 1		--|  #lastKnownGood could potentially contain more than one *new* sequences so we use either the min or max of the *new* sequences
	begin
		--|Preview
		select MTCode, Code as [Mfst Sequence], AcctCode, PubShortName, split.Sequence as [Old Sequence]
			, case
				when split.Sequence <> new.Sequence then cast( new.Sequence as varchar ) + '*'
				else cast( new.Sequence as varchar )
				end as [New Sequence]
		from #templates_splitAcctPubs split
		left join (
					select split.AccountId, max(split.Sequence) as [Sequence]
					from #templates_splitAcctPubs split
					join #lastKnownGood last
						on split.Accountid = last.AccountId
					where split.Sequence <> last.Sequence
					group by split.AccountId
				) as [new]
		on split.AccountId = new.AccountId
		order by 1, 2, 3

		--|Update
		update scManifestSequenceItems
		set Sequence = new.Sequence
		from scManifestSequenceItems msi
		join #templates_splitAcctPubs split
			on msi.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
			and msi.AccountPubId = split.AccountPubId
		left join (
					select split.AccountId, max(split.Sequence) as [Sequence]
					from #templates_splitAcctPubs split
					join #lastKnownGood last
						on split.Accountid = last.AccountId
					where split.Sequence <> last.Sequence
					group by split.AccountId
				) as [new]
		on split.AccountId = new.AccountId
		where msi.Sequence <> new.Sequence
		set @msg = 'Updated ' + cast( @@rowcount as varchar) + ' drop sequences'
	end
	else
	begin
		--|Preview
		select MTCode, Code as [Mfst Sequence], AcctCode, PubShortName, split.Sequence as [Old Sequence]
			, case
				when split.Sequence <> new.Sequence then cast( new.Sequence as varchar ) + '*'
				else cast( new.Sequence as varchar )
				end as [New Sequence]
		from #templates_splitAcctPubs split
		left join (
					select split.AccountId, min(split.Sequence) as [Sequence]
					from #templates_splitAcctPubs split
					join #lastKnownGood last
						on split.Accountid = last.AccountId
					where split.Sequence <> last.Sequence
					group by split.AccountId
				) as [new]
		on split.AccountId = new.AccountId
		order by 1, 2, 3

		--|Update
		update scManifestSequenceItems
		set Sequence = new.Sequence
		from scManifestSequenceItems msi
		join #templates_splitAcctPubs split
			on msi.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
			and msi.AccountPubId = split.AccountPubId
		left join (
					select split.AccountId, min(split.Sequence) as [Sequence]
					from #templates_splitAcctPubs split
					join #lastKnownGood last
						on split.Accountid = last.AccountId
					where split.Sequence <> last.Sequence
					group by split.AccountId
				) as [new]
		on split.AccountId = new.AccountId
		where msi.Sequence <> new.Sequence
		set @msg = 'Updated ' + cast( @@rowcount as varchar) + ' drop sequences'
	end
		
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
		print @msg	

	--|Cleanup
	drop table #templates_prelim
	drop table #templates_splitAcctPubs
	drop table #pubCount
	drop table #lastKnownGood

if @commitTran = 1
begin
	print 'Transaction committed'
	commit tran	
end
else
begin
	print 'Transaction rolled back'
	rollback tran
end