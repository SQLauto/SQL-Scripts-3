



select max(d.drawdate)
from scdraws d
join screturnsaudit ra
	on d.drawid = ra.drawid
join scaccounts a
	on d.accountid = a.accountid
join sunmediaaccountmap_working map
	on a.acctcode = map.baseacctcode
where d.retamount > 0


select acctcode, mfstcode
from scdraws d
join scaccounts a
	on d.accountid = a.accountid
join scaccountspubs ap
	on a.accountid = ap.accountid
join scmanifestsequences ms
	on ap.accountpubid = ms.accountpubid
join scmanifests m
	on ms.manifestid = m.manifestid
join sunmediaaccountmap_working map
	on a.acctcode = map.baseacctcode
where manifesttypeid = 1
and retamount > 0
and drawdate = '2/28/2010'
and manifestdate = '2/28/2010'
and unmap = 1