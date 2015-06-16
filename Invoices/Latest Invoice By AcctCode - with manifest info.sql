
select m.mfstcode, m.mfstname, d.devicecode, a.acctcode,  i.*
from scinvoices i
join scaccountspubs ap
	on i.accountid = ap.accountid
join scmanifestsequences ms
	on ap.accountpubid = ms.accountpubid
join scmanifests m
	on ms.manifestid = m.manifestid
	and m.manifestdate = i.invoicedate
join nsdevices d
	on m.deviceid = d.deviceid	
join scaccounts a
	on i.accountid = a.accountid
where invoicedate = (
	select max(invoicedate) as invoicedate
	from scinvoices
	)
and m.manifesttypeid = ( select manifesttypeid from dd_scmanifesttypes where manifesttypedescription = 'collection' )	
and a.acctcode = 'ac3'	