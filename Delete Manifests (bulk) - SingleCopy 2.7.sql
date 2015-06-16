
begin tran

select m.ManifestId
	, d.DropId
	, ad.AccountId
	, d.DropActive
	, a.AcctActive
into #accts
from scmanifests m
left join scdrops d
	on m.manifestid = d.manifestid
left join scAccountDrops ad
	on d.DropId = ad.DropId
	and d.ManifestId = ad.ManifestId
left join scaccounts a
	on ad.accountid = a.accountid
where mfstcode in (
	'G57'
	,'H46'
	,'H48'
	,'H49'
	,'F33'
	,'F47'
	,'C55'
	,'A83'
	,'C61'
	,'F32'
	,'G54'
	,'ELY'
	,'SANBORN'
	)

select *
from #accts

--/*
delete scAccountDrops
from scAccountdrops ad
join #accts tmp
	on ad.AccountId = tmp.AccountId
	and ad.DropId = tmp.DropId
	and ad.ManifestId = tmp.ManifestId


delete scDrops
from scDrops d
join #accts tmp
	on d.DropId = tmp.DropId
	and d.ManifestId = tmp.ManifestId

delete scManifestHistory 
from scManifestHistory mh
join #accts tmp
	on tmp.ManifestId = mh.ManifestId
--*/

select m.ManifestId
	, d.DropId
	, ad.AccountId
	, d.DropActive
	, a.AcctActive
from scmanifests m
join scdrops d
	on m.manifestid = d.manifestid
join scaccountdrops ad
	on d.manifestid = ad.manifestid
	and d.dropid = ad.dropid
join scaccounts a
	on ad.accountid = a.accountid
where mfstcode in (
	'G57'
	,'H46'
	,'H48'
	,'H49'
	,'F33'
	,'F47'
	,'C55'
	,'A83'
	,'C61'
	,'F32'
	,'G54'
	,'ELY'
	,'SANBORN'
	)


delete from scmanifests
where mfstcode in (
	'G57'
	,'H46'
	,'H48'
	,'H49'
	,'F33'
	,'F47'
	,'C55'
	,'A83'
	,'C61'
	,'F32'
	,'G54'
	,'ELY'
	,'SANBORN'
	)

drop table #accts

commit tran