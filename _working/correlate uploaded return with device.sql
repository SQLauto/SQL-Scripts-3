select a.AcctCode, m.MfstCode, m.ManifestTypeId, ra.DrawId, ra.ReturnsAuditId
	, mt.MfstDate
	, mt.MfstUploadStarted, mt.MfstUploadFinished
	, mtd.DropUploaded
	
	, mt.MfstDownloadStarted, mt.MfstDownloadFinished
	, mtd.DropDownloaded
	, ra.RetAuditDate
	
	--, d.DrawDate/*, d.DeliveryDate*/, ra.PublicationId, ra.RetAuditValue, dv.DeviceCode as [Uploaded from Device]
from scManifestTransferDrops mtd
join scReturnsAudit ra
	--on DATEADD(MS, -1*DATEPART(ms, mtd.DropUploaded), mtd.DropUploaded) = ra.RetAuditDate
	
	on DATEPART(MONTH, mtd.DropUploaded) = DATEPART(MONTH, ra.retauditdate)
	and DATEPART(d, mtd.DropUploaded) = DATEPART(d, ra.retauditdate)
	and DATEPART(HOUR, mtd.DropUploaded) = DATEPART(HOUR, ra.retauditdate)
	and DATEPART(MINUTE, mtd.DropUploaded) = DATEPART(MINUTE, ra.retauditdate)
	and mtd.OriginalAccountId = ra.AccountId 
join scAccounts a
	on mtd.OriginalAccountId = a.AccountID
join scManifestTransfers mt
	on  mt.ManifestTransferId = mtd.ManifestTransferId	
join scmanifests m
	on mt.ManifestID = m.ManifestID	 
join nsDevices dv
	on m.DeviceId = dv.DeviceId
join scDraws d
	on d.DrawID = ra.DrawId		
where d.DrawID = 8334524
--and DATEDIFF(d, DropUploaded, '6/4/2012') = 0
order by DrawId, ra.RetAuditDate