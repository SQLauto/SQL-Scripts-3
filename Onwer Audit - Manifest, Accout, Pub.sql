

select m.MTCode, a.AcctCode, p.PubShortName, mu.username as [MTOwnerName], au.username as [AccountOwnerName], apu.username as [AccountPubOwnerName]
from (
	select distinct mt.MTCode, msi.AccountPubID
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId= mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	) as [m]	
join scAccountsPubs ap
	on m.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.Accountid = ap.Accountid
join nsPublications p
	on ap.PublicationId = p.PublicationID	
left join users mu
	on mt.MTOwner = mu.userid
left join users au
	on a.AcctOwner= au.userid
left join users apu
	on ap.APOwner = apu.userid
where ( mt.MTOwner <> a.AcctOwner
		or a.AcctOwner is null )
	or ( mt.MTOwner <> ap.APOwner
		or ap.APOwner is null )