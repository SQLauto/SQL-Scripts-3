declare @manifestType nvarchar(1)	--|  [D=Delivery|C=Collection|R=Returns|Null=All]
declare @pubShortName nvarchar(5)
declare @acctCode nvarchar(25)

set @manifestType = null
set @acctCode = '10002'
set @pubShortName = 'TIMES'

;with cteManifestTemplates as (
	select AccountPubID, ManifestTypeDescription
		, max(sun) as [sun]
		, max(mon) as [mon]
		, max(tue) as [tue]
		, max(wed) as [wed]
		, max(thu) as [thu]
		, max(fri) as [fri]
		, max(sat) as [sat]
	from (
		select 
			ap.AccountPubID, ManifestTypeDescription
			, case when mst.Frequency & 1 > 0 then mt.MTCode  end as [sun]
			, case when mst.Frequency & 2 > 0 then mt.MTCode  end as [mon]
			, case when mst.Frequency & 4 > 0 then mt.MTCode  end as [tue]
			, case when mst.Frequency & 8 > 0 then mt.MTCode  end as [wed]
			, case when mst.Frequency & 16 > 0 then mt.MTCode  end as [thu]
			, case when mst.Frequency & 32 > 0 then mt.MTCode  end as [fri]
		, case when mst.Frequency & 64 > 0 then mt.MTCode  end as [sat]
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
		where ( 
			( @manifestType is null and mt.ManifestTypeId > 0 )
			or
			( @manifestType is not null and typ.ManifestTypeName = @manifestType )	
		)
		and ( 
			( @acctCode is null and a.AccountID > 0 )
			or
			( @acctCode is not null and a.AcctCode = @acctCode )	
		)
		and ( 
			( @pubShortName is null and p.PublicationID > 0 )
			or
			( @pubShortName is not null and p.PubShortName = @pubShortName )	
		)
	) prelim
	group by AccountPubID, ManifestTypeDescription
)
select a.AcctCode, p.PubShortName
	, cte.ManifestTypeDescription, sun, mon, tue, wed, thu, fri, sat
from cteManifestTemplates cte
join scAccountsPubs ap
	on cte.AccountPubID = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID			