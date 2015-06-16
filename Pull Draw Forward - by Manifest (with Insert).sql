begin tran

;with cteSource
as (
	select d.*
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scDraws d
		on d.AccountID = ap.AccountId
		and d.PublicationID = ap.PublicationId	
	where MTCode = 'ste150'		
	and d.DrawDate in ('7/19/2014', '7/20/2014')
), 
cteTarget
as (
	select d.*
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scDraws d
		on d.AccountID = ap.AccountId
		and d.PublicationID = ap.PublicationId	
	where MTCode = 'ste150'		
	and d.DrawDate in ('7/26/2014', '7/27/2014')
)
insert into scDraws( CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawDate, DeliveryDate, DrawAmount, DrawRate, BillingHistoryID, AdjAmount, AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt, RetAmount, RetExpDateTime, RetExportLastAmt, RollupAcctID, LastChangeType, BillingDate )
select src.CompanyID, src.DistributionCenterID, src.AccountID, src.PublicationID, src.DrawWeekday, dateadd(d, 7, src.drawdate), dateadd(d, 7, src.DeliveryDate), src.DrawAmount, src.DrawRate, src.BillingHistoryID, src.AdjAmount, src.AdjAdminAmount, src.AdjExpDateTime, src.AdjExportLastAmt, src.RetAmount, src.RetExpDateTime, src.RetExportLastAmt, src.RollupAcctID, src.LastChangeType, src.BillingDate
from cteSource src
left join cteTarget tgt
	on src.AccountID = tgt.AccountID
	and src.PublicationID = tgt.PublicationID
	and src.DrawWeekday = tgt.DrawWeekday
join scAccounts a
	on src.AccountID = a.AccountID	
where tgt.DrawID is null
--and a.AcctCode = '1660033'

select *
from scDraws
where DrawDate > getdate()

commit tran
