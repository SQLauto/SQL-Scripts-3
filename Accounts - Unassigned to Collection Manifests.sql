
select acctcode
from scaccounts a
join scinvoices i
	on a.accountid = i.accountid
where a.accountid not in (
	select accountid
	from scmanifestsequenceitems msi
	join scmanifestsequencetemplates mst
	on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
	join scmanifesttemplates mt
	on mst.manifesttemplateid = mt.manifesttemplateid
	join scaccountspubs ap
	on msi.accountpubid = ap.accountpubid
	where mt.manifesttypeid = 2
	)