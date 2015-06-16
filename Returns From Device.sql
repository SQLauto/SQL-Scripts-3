;with cteReturnsAudit
as
(
	select a.AcctCode, p.PubShortName, d.DrawDate, d.RetAmount, ra.RetAuditDate, m.MfstCode, v.DeviceCode
		, ManifestOwner
		, a.AcctOwner
		, ap.APOwner
		, ra.RetAuditUserId
		, m.ManifestID
		, m.ManifestDate
	from scReturnsAudit ra
	join scDraws d 
		on ra.DrawId = d.DrawID
	join scAccountsPubs ap
		on d.AccountID = ap.AccountId
		and d.PublicationID = ap.PublicationId
	join scManifestSequences ms
		on ap.AccountPubID = ms.AccountPubId
	join scmanifests m
		on m.ManifestID = ms.ManifestId
		and m.ManifestDate = d.DrawDate
	join nsDevices v
		on m.DeviceId = v.deviceid	
	join scAccounts a
		on a.AccountID = d.AccountID
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where RetAuditUserId = 6
	--order by RetAuditDate desc
), cteManifestTransfers
as (
	select m.ManifestID, m.ManifestDate
		, a.AcctCode
		, mt.MfstDownloadStarted, mt.MfstDownloadFinished, mt.MfstUploadStarted, mt.MfstUploadFinished
		, mtd.DropDownloaded, mtd.DropUploaded
	from scManifestTransfers mt
	join scManifestTransferDrops mtd
		on mt.ManifestTransferId = mtd.ManifestTransferId
	join scManifests m
		on mt.ManifestID = m.ManifestID
	join scAccounts a
		on mtd.OriginalAccountId = a.AccountID
	where MfstCode = 'G046-Returns'
	and DATEDIFF(d, mfstdate, '8/30/2011') = 0
	--order by MfstDate desc
)
select ra.AcctCode, ra.ManifestDate, ra.DrawDate, ra.RetAuditDate, mt.DropUploaded
	, mt.MfstUploadFinished
	, case when 
				( datepart(hour, RetAuditDate) = datepart(hour, DropUploaded)
					and datepart(minute, RetAuditDate) = datepart(minute, DropUploaded)
					and datepart(second, RetAuditDate) = DATEPART(second, DropUploaded) 
				)
				then 'True' 
				else 'False'
				end as [UpdateFromDevice]
from cteReturnsAudit ra
join cteManifestTransfers mt
	on ra.ManifestID = mt.ManifestID
	and ra.ManifestDate = mt.ManifestDate
	and ra.AcctCode = mt.AcctCode