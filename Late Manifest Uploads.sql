
/*
	a late upload, is an upload that occurs
	
	downloads occur around 1am on the drawdate
	uploads should occur before 11:30 on the same day so that any returns entered will show up on the HH
*/

select MfstCode, MfstDate, upl.[UploadStarted], upl.UploadFinished, drps.[Drops w/ Returns]
from scManifestTransfers mt
join (
	select ManifestTransferId, min(DropUploaded) as [UploadStarted], max(DropUploaded) as [UploadFinished]
	from scManifestTransferDrops mtd
	group by ManifestTransferId
	) as upl
	on mt.ManifestTransferId = upl.ManifestTransferId
join (
	select mt.ManifestTransferId, count(*) as [Drops w/ Returns]
	from scManifestTransfers mt
	join scManifestTransferDrops mtd
		on mt.ManifestTransferId = mtd.ManifestTransferId
	join scDraws d
		on mtd.OriginalAccountId = d.AccountID
		and mt.MfstDate = d.DrawDate
	where mt.MfstDate > '1/1/2011' 
	and isnull(d.RetAmount,0) > 0
	group by mt.ManifestTransferId	
	) as drps 
	on mt.ManifestTransferId = drps.ManifestTransferId
join scmanifests m
	on m.manifestid = mt.ManifestID
where m.ManifestDate > '1/1/2011'
and ( m.MfstCode like '83%'
	and m.ManifestTypeId = 1 )
and MfstDownloadStarted is not null
and ( 
		( datediff(d, mfstdate, [UploadStarted]) = 0
		  and datepart(hour, upl.[UploadStarted]) > 23 
		  and datepart(minute, upl.[UploadStarted]) > 30
		)
		or 
		( datediff(d, mfstdate, [UploadStarted]) = 1 )
	)
order by MfstDate desc		
