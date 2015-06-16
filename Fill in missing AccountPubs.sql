begin tran

insert into scAccountsPubs ( AccountId, PublicationId, CompanyID, DistributionCenterID )
select distinct dd.AccountID, dd.PublicationID, 1, 1
from scDefaultDraws dd
left join scAccountsPubs ap
	on dd.AccountID = ap.AccountId
	and dd.PublicationID = ap.PublicationId
where ap.AccountPubID is null


commit tran