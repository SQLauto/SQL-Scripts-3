

select ms.manifestsequenceid, sequence, ms.accountpubid, ap.accountid
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
where m.mfstname = 'airport6'
and datediff(d, manifestdate, getdate()) = 0
order by sequence

update scmanifestsequences
set sequence = 21
where manifestsequenceid = 1157770