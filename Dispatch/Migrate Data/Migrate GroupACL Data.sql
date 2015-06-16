begin tran

	;with cteSFC as (
		select g.GroupName
			, gacl.GroupID, gacl.SecuredObjectID, gacl.Category, gacl.Predicate, gacl.AccessMask
			--, so.SecuredObjectID, so.Description, so.SiteID
			--, ts.SiteName
		from sdmconfig_sfc..groupacl gacl
		join sdmconfig_sfc..Groups g
			on gacl.GroupID = g.GroupID
		join sdmconfig_sfc..SecuredObjects so
			on gacl.SecuredObjectID = so.SecuredObjectID
		join sdmconfig_sfc..t2k_Site ts
			on so.SiteID = ts.SiteID
	)
	insert into GroupACL ( GroupID, SecuredObjectID, Category, Predicate, AccessMask )
	select 
		g.GroupID
		, sfc.SecuredObjectID, sfc.Category, sfc.Predicate, sfc.AccessMask
	from cteSFC sfc
	join groups g
		on sfc.GroupName = g.GroupName
	left join GroupACL gacl
		on g.GroupID = gacl.GroupID
		and sfc.SecuredObjectID = gacl.SecuredObjectID
	where gacl.GroupACLID is null


commit tran