select *
into #mfsts
from dbo.listMfstsAccts('Delivery',null, null, -1, null);

--with mfsts (AccountId, AcctCode, PublicationId, PubShortName, MfstCode, ManifestTypeId, ManifestTypeDescription, ManifestOwner, Frequency)
--as 
--(
--	select AccountId, AcctCode, PublicationId, PubShortName, MfstCode, ManifestTypeId, ManifestTypeDescription, ManifestOwner, Frequency
--	from dbo.listMfstsAccts('Delivery','83', null, -1, null)
--),

with returnsAduit_Owner ( DrawId, RetAuditUserId, [Returns] )
as
(
		select ra.DrawId, ra.RetAuditUserId, sum( cast(ra.RetAuditValue as int) ) as [OwnerReturns]
		from scReturnsAudit ra
		join scDraws d
			on ra.DrawId = d.DrawId
		join #mfsts m
			on d.AccountID = m.AccountId
			and d.PublicationID = m.PublicationId
			and dbo.scGetDayFrequency( d.DrawDate ) & m.Frequency > 0
		where ra.RetAuditUserId = m.ManifestOwner	
		and datediff(d, d.DrawDate, getdate()) <= 30
		group by ra.DrawId, ra.RetAuditUserId
)
select *
from returnsAduit_Owner 



drop table #mfsts