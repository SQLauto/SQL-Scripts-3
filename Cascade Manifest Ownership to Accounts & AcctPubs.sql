begin tran

print 'Filling temp table with candidate records...'
select mt.ManifestTemplateId, mt.MTCode, mt.MTOwner, mu.username as [MTOwnerName], a.AccountId, a.AcctOwner, au.username as [AccountOwnerName], ap.AccountPubId, ap.PublicationId, ap.APOwner, apu.username as [AccountPubOwnerName]
into #owners
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId= mst.ManifestTemplateId
join scManifestSequenceItems msi
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.Accountid = ap.Accountid
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

print '  Preview recordset...'
select *
from #owners
order by MTCode, AccountId

print '  Updating AcctOwner in scAccounts...'
update scAccounts
set AcctOwner = MTOwner
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId= mst.ManifestTemplateId
join scManifestSequenceItems msi
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.Accountid = ap.Accountid 
where ( mt.MTOwner <> a.AcctOwner
	or a.AcctOwner is null )

print '  Updating APOwner in scAccountsPubs...'
update scAccountsPubs
set APOwner = MTOwner
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId= mst.ManifestTemplateId
join scManifestSequenceItems msi
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
where ( mt.MTOwner <> ap.APOwner
		or ap.APOwner is null )


print '  Review results'
select mt.ManifestTemplateId, mt.MTCode, mt.MTOwner, mu.username as [MTOwnerName], a.AccountId, a.AcctOwner, au.username as [AccountOwnerName], ap.AccountPubId, ap.PublicationId, ap.APOwner, apu.username as [AccountPubOwnerName]
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId= mst.ManifestTemplateId
join scManifestSequenceItems msi
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.Accountid = ap.Accountid
left join users mu
	on mt.MTOwner = mu.userid
left join users au
	on a.AcctOwner= au.userid
left join users apu
	on ap.APOwner = apu.userid
join #owners tmp
	on tmp.ManifestTemplateId = mt.ManifestTemplateId
	and tmp.AccountId = a.AccountId
	and tmp.AccountPubId = ap.AccountPubId
order by mt.MTCode, a.AccountId

drop table #owners

rollback tran