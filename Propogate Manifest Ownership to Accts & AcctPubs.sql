begin tran

;with cteOwners
as (
	select ap.AccountId, ap.AccountPubId, mt.MTOwner, ap.APOwner, a.AcctOwner
	from scAccountsPubs ap
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scAccounts a	
		on ap.AccountId = a.AccountID	
	where MTOwner <> ( select UserId from Users where UserName = 'admin@singlecopy.com' )
	and (
			( mt.MTOwner <> a.AcctOwner 
				or 
			  mt.MTOwner <> ap.APOwner )
			or ( a.AcctOwner <> ap.APOwner )
	)			
) 
update scAccounts
set AcctOwner = MTOwner
from cteOwners	cte
join scAccounts a
	on a.AccountID = cte.AccountId

;with cteOwners
as (
	select ap.AccountId, ap.AccountPubId, mt.MTOwner, ap.APOwner, a.AcctOwner
	from scAccountsPubs ap
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scAccounts a	
		on ap.AccountId = a.AccountID	
	where MTOwner <> ( select UserId from Users where UserName = 'admin@singlecopy.com' )
	and (
			( mt.MTOwner <> a.AcctOwner 
				or 
			  mt.MTOwner <> ap.APOwner )
			or ( a.AcctOwner <> ap.APOwner )
	)			
) 
update scAccountsPubs
set APOwner = MTOwner
from cteOwners	cte
join scAccountsPubs ap
	on ap.AccountPubID = cte.AccountPubID


	select ap.AccountId, ap.AccountPubId, mt.MTOwner, ap.APOwner, a.AcctOwner
	from scAccountsPubs ap
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scAccounts a	
		on ap.AccountId = a.AccountID	
	where MTOwner <> ( select UserId from Users where UserName = 'admin@singlecopy.com' )
	and (
			( mt.MTOwner <> a.AcctOwner 
				or 
			  mt.MTOwner <> ap.APOwner )
			or ( a.AcctOwner <> ap.APOwner )
	)			


commit tran