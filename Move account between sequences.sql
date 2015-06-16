
begin tran

--|Preview
select m.manifestdate, ms.manifestid, m.mfstcode
from scmanifestsequences ms
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifests m
	on ms.manifestid = m.manifestid
where a.acctcode = '00011051'


--select m.manifestdate, ms.manifestid as oldmanifestid, m.mfstcode,  newMfst.manifestid, m2.mfstcode 
update scManifestsequences 
	set ManifestId = newMfst.manifestid
from scmanifestsequences ms
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifests m
	on ms.manifestid = m.manifestid
join ( 
	select manifestdate, manifestid
	from scmanifests
	where mfstcode = '04240001'
	and manifestdate between '8/12/2009' and '8/21/2009'
	) newMfst
	on m.ManifestDate = newMfst.ManifestDate
join scmanifests m2
	on newMfst.ManifestId = m2.ManifestId
	
where a.acctcode = '00011051'

--|Preview
select m.manifestdate, ms.manifestid, m.mfstcode
from scmanifestsequences ms
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifests m
	on ms.manifestid = m.manifestid
where a.acctcode = '00011051'

commit tran