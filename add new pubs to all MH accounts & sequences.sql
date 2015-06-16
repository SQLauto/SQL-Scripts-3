begin tran

/*
	1)  Add new products to all accounts that deliver a given product (add records to scAccountsPubs)
	2)  Fill in Default Draws for new account pubs
	3)  Add AccountPubs to all ManifestSequences
*/

--target accounts, add MSM and MLM
;with cteCandidateAccounts as (
	select a.AccountID
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where p.PubShortName = 'MH'
)
--/*	
insert scAccountsPubs (
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,deliverystartdate
		,deliverystopdate
		,forecaststartdate
		,forecaststopdate
		,excludefrombilling
		,active
		,apcustom1
		,apcustom2
		,apcustom3
		,apowner
	)
--*/
select 
		 1
		,1
		,tmp.accountid
		,tmp.PublicationID
		,null
		,null
		,null
		,null
		,0
		,1
		,N''
		,N''
		,N''
		,1
from (
	select cte.AccountID, newPubs.PublicationID
	from cteCandidateAccounts cte
	join (
		select PublicationID
		from nsPublications
		WHERE PubShortName in ('MSM','MLM')
	) newPubs
		on 1=1	
) tmp
left join scAccountsPubs ap
	on tmp.AccountID = ap.AccountId
	and tmp.PublicationID = ap.PublicationId
--group by tmp.accountid, tmp.PublicationID
--having COUNT(*) > 1
where ap.AccountPubID is null


create table #tmpDayOfWeek ( DayOfWeek int)
	insert into #tmpDayOfWeek
	select 1
	union all select 2
	union all select 3
	union all select 4
	union all select 5
	union all select 6
	union all select 7

	/*=====================================================================================
	  Find accounts that don't have a default draw defined for each day of the week
	=====================================================================================*/
	select  1 as [companyid], 1 as [distributioncenterid], a.AccountID, p.PublicationID
	into #incompletedefaultdraw
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID
where p.PubShortName in (
					'MLM','MSM'
					)

	/*=====================================================================================
	  Create a temp table with a complete list of account, pub, dayofweek for
	  these accounts
	=====================================================================================*/
	select companyid, distributioncenterid, accountid, publicationid, dayofweek
	into #expandedlist
	from #incompletedefaultdraw
	join #tmpdayofweek dow
	on 1 = 1

	/*=====================================================================================
   	  Insert a zero draw record for the missing days of the week for each account 
	  and Pub
	=====================================================================================*/
	insert into scdefaultdraws (
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,drawweekday
		,drawamount
		,drawrate
		,allowforecasting
		,allowreturns
		,allowadjustments
		,forecastmindraw
		,forecastmaxdraw
	)
	select 
		 t.companyid
		,t.distributioncenterid
		,t.accountid
		,t.publicationid
		,t.dayofweek
		,0 as [drawamount]
		,cast(0 as money) as [drawrate]
		,1 as allowforecasting
		,1 as allowreturns
		,1 as allowadjustments
		,0 as forecastmindraw
		-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
		,2147483647 as forecastmaxdraw

	from #expandedlist t
	left outer join scdefaultdraws dd
		on dd.companyid = t.companyid
		and dd.distributioncenterid = t.distributioncenterid
		and dd.accountid = t.accountid
		and dd.publicationid = t.publicationid
		and dd.drawweekday = t.dayofweek
	where dd.drawamount is null

	print 'Added ' + cast(@@rowcount as varchar) + ' default draw records'
	--print 'scDefaultDraws_Fill completed'
	print ''


	;with cteTargetManifests as (
		select ManifestSequenceTemplateId, AccountId, Sequence
		from scManifestSequenceItems msi
		join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		where p.PubShortName in ('MH')
	)
	, cteAccountPubs as (
		select a.AccountID, ap.AccountPubID
		from scAccounts a
		join scAccountsPubs ap
			on a.AccountID = ap.AccountId
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		where p.PubShortName in (
							'MLM','MSM'
							)
	)
	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select m.ManifestSequenceTemplateId, ap.AccountPubID, m.Sequence
	from cteTargetManifests m
	join cteAccountPubs ap
		on m.AccountId = ap.AccountID
	left join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
		and m.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
	where msi.ManifestSequenceItemId is null	
commit tran