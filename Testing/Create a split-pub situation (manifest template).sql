/*
select mtcode, mtname, count(*)
from scmanifesttemplates mt
join scmanifestsequencetemplates mst
	on mt.manifesttemplateid = mst.manifesttemplateid
join scmanifestsequenceitems msi
	on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
group by mtcode, mtname
*/

select ap.AccountId, msi.ManifestSequenceItemId, msi.Sequence
from scmanifesttemplates mt
join scmanifestsequencetemplates mst
	on mt.manifesttemplateid = mst.manifesttemplateid
join scmanifestsequenceitems msi
	on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
join scaccountspubs ap
	on msi.accountpubid = ap.accountpubid
join (
	select ap.accountid, mt.mtcode, mst.code, count(*) as [pubCount]
	from scmanifesttemplates mt
	join scmanifestsequencetemplates mst
		on mt.manifesttemplateid = mst.manifesttemplateid
	join scmanifestsequenceitems msi
		on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
	join scaccountspubs ap
		on msi.accountpubid = ap.accountpubid
	where mt.mtcode = '150'
	group by accountid, mt.mtcode, mst.code
	having count(*) > 1
	) as [multiPubs]
	on multiPubs.AccountId = ap.AccountId
	and multiPubs.MtCode = mt.MTCode
	and multiPubs.Code = mst.Code
order by ap.AccountId

/*
update scmanifestsequenceitems
set sequence = 31
where manifestsequenceitemid = 3066
*/