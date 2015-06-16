begin tran

	select d.DrawID, d.DrawAmount, d.AdjAdminAmount, d.AdjAmount, d.RetAmount
		, dh.olddraw, dh.newdraw
		, d.DrawAmount + isnull(AdjAmount,0) + isnull(AdjAdminAmount,0) - isnull(RetAmount,0) as net
	into support_scDraws_Backup_05062015_2
	from scdraws d
	join (
		select dh.drawid, min(dh.changeddate) as lastchanged
		from scDrawHistory dh
		join (
			select d.DrawID, d.AdjExpDateTime
			from scdraws d
			where DrawDate between '4/26/2015' and '5/2/2015'
		) tmp
			on dh.drawid = tmp.DrawID
		where dh.changeddate > tmp.AdjExpDateTime
		--and dh.drawid = 4778013
		group by dh.drawid
	) tmp
		on d.DrawID = tmp.drawid
	join scDrawHistory dh
		on d.DrawID = dh.drawid
		and tmp.lastchanged = dh.changeddate
	where dh.olddraw <> d.DrawAmount	
	
	update d
		set d.DrawAmount = dh.olddraw
	from scdraws d
	join (
		select dh.drawid, min(dh.changeddate) as lastchanged
		from scDrawHistory dh
		join (
			select d.DrawID, d.AdjExpDateTime
			from scdraws d
			where DrawDate between '4/26/2015' and '5/2/2015'
		) tmp
			on dh.drawid = tmp.DrawID
		where dh.changeddate > tmp.AdjExpDateTime
		--and dh.drawid = 4778013
		group by dh.drawid
	) tmp
		on d.DrawID = tmp.drawid
	join scDrawHistory dh
		on d.DrawID = dh.drawid
		and tmp.lastchanged = dh.changeddate
	where dh.olddraw <> d.DrawAmount	

	--select *
	--from scdraws d
	--where d.DrawAmount + isnull(AdjAmount,0) + isnull(AdjAdminAmount,0) - isnull(RetAmount,0) < 0
	--and DrawDate between '4/26/2015' and '5/2/2015'

commit tran