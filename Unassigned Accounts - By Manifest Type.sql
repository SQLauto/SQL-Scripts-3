

select a.AcctCode, au.UserName as [AcctOwner], apu.UserName as [AcctPubOwner]
from scaccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join Users au
	on a.AcctOwner = au.UserID
join Users apu
	on ap.APOwner = apu.UserID
left join (
	select distinct mt.ManifestTypeId, msi.AccountPubId
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where ManifestTypeId = 1  --|  [1=Delivery|2=Collection|4=Returns]

	) m
	on ap.AccountPubID = m.AccountPubId
where m.AccountPubId is null
and au.UserName = 'genewperry1010@aol.com'