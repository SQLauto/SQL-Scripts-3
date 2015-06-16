begin tran
	set nocount on
	/*  
		This procedure will identify and correct instances where AcctPubs 
		are split between Sequences on the same manifest

		$History: $
	*/

	--|  Declarations
	declare @commitTran		int
	declare @useMaxSequence	int				--| If the correct sequence cannot be determined use min or max sequence
	declare @msg			nvarchar(1024)

	set @commitTran = 0		--|  (0|1) 0 = Rollback, 1 = Commit
	set @useMaxSequence	= 1 --|  (0|1) 0 = Min, 1 = Max

	--|  First group by Sequence so that Accounts with more than one Sequence can be identified
	select m.ManifestId, m.ManifestTemplateId, mst.ManifestSequenceTemplateId, a.AccountId, Sequence
	into #manifests_prelim
	from scManifests m
	join scManifestSequences ms
		on m.Manifestid = ms.Manifestid
	join scaccountspubs ap
		on ms.AccountPubId = ap.AccountPubId
	join scaccounts a
		on ap.Accountid = a.Accountid
	join scManifestsequencetemplates mst
		on ms.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	group by m.ManifestId, m.ManifestTemplateId, mst.ManifestSequenceTemplateId, a.AccountId, Sequence

	/*  
		The nested table contains the actual split acct/pubs, we're just joining with these other tables
		to fill in additional information for preview purposes
	*/ 
	select m.ManifestId, m.MfstCode, m.ManifestTemplateId, ms.ManifestSequenceTemplateId, split.AccountId, a.AcctCode, ap.AccountPubId, p.PubShortName, ms.Sequence, count(*) as [Count]
	into #manifests_splitAcctPubs
	from scManifests m
	join scManifestSequences ms
		on m.Manifestid = ms.Manifestid
	join scaccountspubs ap
		on ms.AccountPubId = ap.AccountPubId
	join scaccounts a
		on ap.Accountid = a.Accountid
	join nsPublications p
		on ap.PublicationId = p.PublicationId
	join scManifestSequenceTemplates mst
		on ms.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join (
			--|  Split Account/Pubs
			select ManifestId, ManifestTemplateId, ManifestSequenceTemplateId, AccountId, count(*) as [Count]
			from #manifests_prelim
			group by ManifestId, ManifestTemplateId, ManifestSequenceTemplateId, AccountId
			having count(*) > 1
		) as split
		on a.AccountId = split.AccountId
		and m.ManifestId = split.ManifestId
	group by m.ManifestId, m.MfstCode, m.ManifestTemplateId, ms.ManifestSequenceTemplateId, split.AccountId, a.AcctCode, ap.AccountPubId, p.PubShortName, ms.Sequence, split.[Count]
	order by split.AccountId

		select @msg = 'Found ' + cast( count(distinct AccountId) as varchar) + ' Accounts'
		from #manifests_splitAcctPubs

/*
	select *
	from #manifests_splitAcctPubs
	order by accountid
*/

	--|  create temp table to store Pub Count per Account
	select AccountId, count(*) as PubCount
	into #pubCount
	from scAccountsPubs
	where AccountId in (
		select AccountId 
		from #manifests_splitAcctPubs
		)
	group by AccountId
/*
	select *
	from #pubCount
*/

	/* Step #templates_3 - Get the most recent Sequence where all pubs have the same sequence.
		The sequence where all pubs were on the same sequence is the "old" sequence. 
	 */
	select ManifestId, AccountId, Sequence, max(ManifestDate) as [ManifestDate]
	into #lastKnownGood
	from (
			/* Step #templates_2 - Get a list of pub counts that match the actual pub count */
			select hist.ManifestId, hist.AccountId, hist.ManifestDate, hist.Sequence, hist.[Count], pc.PubCount
			from #pubCount pc
			join (
					/* Step #templates_1 - Get a list of dates and the number of pubs associated with an account */
					select split.ManifestId, split.AccountId, m.ManifestDate, ms.Sequence, count(*) as [Count]
					from scManifests m
					join scManifestSequences ms
						on ms.ManifestId = m.ManifestId
					join #manifests_splitAcctPubs split
						on ms.AccountPubId = split.AccountPubId
						and ms.ManifestSequenceTemplateid = split.ManifestSequenceTemplateid
					group by split.ManifestId, split.AccountId, m.ManifestDate, ms.Sequence
				) as hist --|Historical Pub Count
				on hist.Accountid = pc.AccountId
			where hist.[Count] = pc.PubCount
		) as lastKnownGood
	group by ManifestId, AccountId, Sequence

		select @msg = @msg + ' with ' + cast( sum(PubCount) as varchar ) + ' publications.  '
		from #pubCount		
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
		print @msg

/*
select *
from #lastKnownGood
*/

	if @useMaxSequence = 1		--|  #lastKnownGood could potentially contain more than one *new* sequences so we use either the min or max of the *new* sequences
	begin
			--|Preview
			select --split.ManifestId, split.AccountId, split.AccountPubId, 
				m.ManifestDate, split.MfstCode, split.AcctCode, split.PubShortName
				, ms.Sequence as [Old Sequence]
				, case
					when ms.Sequence <> new.Sequence then cast( new.Sequence as varchar ) + '*'
					else cast( new.Sequence as varchar )
					end as [New Sequence]
			from scManifests m
			join scManifestSequences ms
				on m.ManifestId = ms.ManifestId
			join #manifests_splitAcctPubs split
				on ms.ManifestId = split.ManifestId
				and ms.AccountPubId = split.AccountPubId
			join (
						select split.ManifestId, split.AccountId, max(split.Sequence) as [Sequence]
						from #manifests_splitAcctPubs split
						join #lastKnownGood last
							on split.Accountid = last.AccountId
							and split.ManifestId = last.ManifestId
						where split.Sequence <> last.Sequence
						group by split.ManifestId, split.AccountId
					) as New
				on split.AccountId = new.AccountId
				and split.ManifestId = new.ManifestId
			where ms.Sequence <> new.Sequence

			update scManifestSequences	
			set Sequence = new.Sequence
			from scManifestSequences ms
			join #manifests_splitAcctPubs split
				on ms.ManifestId = split.ManifestId
				and ms.AccountPubId = split.AccountPubId
			join (
						select split.ManifestId, split.AccountId, max(split.Sequence) as [Sequence]
						from #manifests_splitAcctPubs split
						join #lastKnownGood last
							on split.Accountid = last.AccountId
							and split.ManifestId = last.ManifestId
						where split.Sequence <> last.Sequence
						group by split.ManifestId, split.AccountId
					) as New
				on split.AccountId = new.AccountId
				and split.ManifestId = new.ManifestId
			where ms.Sequence <> new.Sequence
			print 'Updated ' + cast(@@rowcount as varchar) + ' Sequences.'
	end
	else
	begin
			select --split.ManifestId, split.AccountId, split.AccountPubId, 
				m.ManifestDate, split.MfstCode, split.AcctCode, split.PubShortName
				, ms.Sequence as [Old Sequence]
				, case
					when ms.Sequence <> new.Sequence then cast( new.Sequence as varchar ) + '*'
					else cast( new.Sequence as varchar )
					end as [New Sequence]
			from scManifests m
			join scManifestSequences ms
				on m.ManifestId = ms.ManifestId
			join #manifests_splitAcctPubs split
				on ms.ManifestId = split.ManifestId
				and ms.AccountPubId = split.AccountPubId
			join (
						select split.ManifestId, split.AccountId, min(split.Sequence) as [Sequence]
						from #manifests_splitAcctPubs split
						join #lastKnownGood last
							on split.Accountid = last.AccountId
							and split.ManifestId = last.ManifestId
						where split.Sequence <> last.Sequence
						group by split.ManifestId, split.AccountId
					) as New
				on split.AccountId = new.AccountId
				and split.ManifestId = new.ManifestId
			where ms.Sequence <> new.Sequence

			update scManifestSequences	
			set Sequence = new.Sequence
			from scManifestSequences ms
			join #manifests_splitAcctPubs split
				on ms.ManifestId = split.ManifestId
				and ms.AccountPubId = split.AccountPubId
			join (
						select split.ManifestId, split.AccountId, min(split.Sequence) as [Sequence]
						from #manifests_splitAcctPubs split
						join #lastKnownGood last
							on split.Accountid = last.AccountId
							and split.ManifestId = last.ManifestId
						where split.Sequence <> last.Sequence
						group by split.ManifestId, split.AccountId
					) as New
				on split.AccountId = new.AccountId
				and split.ManifestId = new.ManifestId
			where ms.Sequence <> new.Sequence
			print 'Updated ' + cast(@@rowcount as varchar) + ' Sequences.'
	end

drop table #manifests_prelim
drop table #manifests_splitAcctPubs
drop table #lastKnownGood
drop table #pubCount

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

