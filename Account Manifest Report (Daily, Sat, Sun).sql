;with cte
as (
	select
		a.AcctCode
		, a.AcctName
		, a.AcctAddress
		, case when ( mst.Frequency & 1 > 0 and mt.ManifestTypeId = 1 ) then mt.MTCode end as [sun]
		, case when ( mst.Frequency & 62 > 0 and mt.ManifestTypeId = 1 ) then mt.MTCode end as [daily]
		, case when ( mst.Frequency & 64 > 0 and mt.ManifestTypeId = 1 ) then mt.MTCode end as [sat]
		, case when ( mt.ManifestTypeId in ( 2, 4 ) ) then mt.MTCode end as [Returns Manifest]
		, typ.ManifestTypeDescription
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	--where MTName = 'D07'
--	order by AcctCode
)
select AcctCode, AcctName, AcctAddress
	--, ManifestTypeDescription
	--, daily, sat, sun
	, max(daily) as [Daily], max(sat) as [Sat], max(sun) as [Sun], MAX([Returns Manifest]) as [Returns]
from cte
--where AcctCode = '37653500'
--where [Returns Manifest] is not null
group by AcctCode, AcctName, AcctAddress
order by AcctCode	