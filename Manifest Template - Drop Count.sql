

select mtcode, code, count(*)
from scmanifesttemplates mt
join scmanifestsequencetemplates mst
	on mt.manifesttemplateid = mst.manifesttemplateid
join scmanifestsequenceitems msi
	on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
group by mtcode, code
order by 3 desc