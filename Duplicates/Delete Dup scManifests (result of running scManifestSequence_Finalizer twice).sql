
--remove duplicate manifests
--| sequence items?

begin tran

select manifestid, m.mfstcode, m.manifestdate
	from scmanifests m
		join ( 
			select mfstcode, manifestdate
			from scmanifests
			where datediff(d, manifestdate, '7/31/2012')  = 0
			group by mfstcode, manifestdate
			having count(*) > 1
		) as tmp1
		on m.mfstcode = tmp1.mfstcode
		and m.manifestdate = tmp1.manifestdate

delete scmanifesthistory
from scmanifests m
join scManifestHistory mh
	on m.ManifestID = mh.ManifestId
join (
	select manifestid, m.mfstcode, m.manifestdate
	from scmanifests m
		join ( 
			select mfstcode, manifestdate
			from scmanifests
			where datediff(d, manifestdate, '7/31/2012')  = 0
			group by mfstcode, manifestdate
			having count(*) > 1
		) as tmp1
		on m.mfstcode = tmp1.mfstcode
		and m.manifestdate = tmp1.manifestdate
	) as tmp2
on m.mfstcode = tmp2.mfstcode
and m.manifestdate = tmp2.manifestdate
where tmp2.manifestid > m.manifestid

delete scmanifestsequences
from scmanifests m
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join (
	select manifestid, m.mfstcode, m.manifestdate
	from scmanifests m
		join ( 
			select mfstcode, manifestdate
			from scmanifests
			where datediff(d, manifestdate, '7/31/2012')  = 0
			group by mfstcode, manifestdate
			having count(*) > 1
		) as tmp1
		on m.mfstcode = tmp1.mfstcode
		and m.manifestdate = tmp1.manifestdate
	) as tmp2
on m.mfstcode = tmp2.mfstcode
and m.manifestdate = tmp2.manifestdate
where tmp2.manifestid > m.manifestid

delete scmanifests
from scmanifests m
join (
	select manifestid, m.mfstcode, m.manifestdate
	from scmanifests m
		join ( 
			select mfstcode, manifestdate
			from scmanifests
			where datediff(d, manifestdate, '7/31/2012')  = 0
			group by mfstcode, manifestdate
			having count(*) > 1
		) as tmp1
		on m.mfstcode = tmp1.mfstcode
		and m.manifestdate = tmp1.manifestdate
	) as tmp2
on m.mfstcode = tmp2.mfstcode
and m.manifestdate = tmp2.manifestdate
where tmp2.manifestid > m.manifestid

select manifestid, m.mfstcode, m.manifestdate
	from scmanifests m
		join ( 
			select mfstcode, manifestdate
			from scmanifests
			where datediff(d, manifestdate, '7/31/2012')  = 0
			group by mfstcode, manifestdate
			having count(*) > 1
		) as tmp1
		on m.mfstcode = tmp1.mfstcode
		and m.manifestdate = tmp1.manifestdate

commit tran