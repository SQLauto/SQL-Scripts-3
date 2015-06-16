declare @deliveryManifestTypeId int
set @deliveryManifestTypeId = 1
;with cte as (
	select 
		ap.AccountPubID
		, case when mst.Frequency & 1 > 0 then mt.ManifestTemplateId  end as [sun]
		, case when mst.Frequency & 2 > 0 then mt.ManifestTemplateId  end as [mon]
		, case when mst.Frequency & 4 > 0 then mt.ManifestTemplateId  end as [tue]
		, case when mst.Frequency & 8 > 0 then mt.ManifestTemplateId  end as [wed]
		, case when mst.Frequency & 16 > 0 then mt.ManifestTemplateId  end as [thu]
		, case when mst.Frequency & 32 > 0 then mt.ManifestTemplateId  end as [fri]
		, case when mst.Frequency & 64 > 0 then mt.ManifestTemplateId  end as [sat]
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
	where mt.ManifestTypeId = @deliveryManifestTypeId
	--order by ap.AccountPubID
)
select *
from cte
order by AccountPubID