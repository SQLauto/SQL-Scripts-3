

begin tran

exec scManifest_Data_Load

;with cteRollupDraw	
as (
	select r.RollupCode, p.PubShortName, dh.drawdate, sum(dh.olddraw) as [olddraw], sum(dh.newdraw) as [newdraw]
	from scDrawHistory dh
	join scAccounts a
		on dh.accountid = a.AccountID
	join nsPublications p
		on dh.publicationid = p.PublicationID
	join dd_nsChangeTypes typ
		on dh.changetypeid = typ.ChangeTypeID
	left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
	join scRollups r
		on ca.AccountID = r.RollupID		
	where DATEDIFF(d, changeddate, getdate()) = 0
	and dh.olddraw <> dh.newdraw
	group by r.RollupCode, p.PubShortName, dh.drawdate
)
	select a.AcctCode, r.RollupCode, p.PubShortName, dh.drawdate, dh.olddraw, dh.newdraw
		, cte.olddraw as [rollup old draw], cte.newdraw as [rollup new draw]
		, typ.ChangeTypeDescription
	from scDrawHistory dh
	join scAccounts a
		on dh.accountid = a.AccountID
	join nsPublications p
		on dh.publicationid = p.PublicationID
	join dd_nsChangeTypes typ
		on dh.changetypeid = typ.ChangeTypeID
	left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
	join scRollups r
		on ca.AccountID = r.RollupID
	left join cteRollupDraw cte
		on r.RollupCode = cte.RollupCode
		and p.PubShortName = cte.PubShortName
		and dh.drawdate = cte.drawdate			
	where DATEDIFF(d, changeddate, getdate()) = 0
	and dh.olddraw <> dh.newdraw

	
rollback tran
