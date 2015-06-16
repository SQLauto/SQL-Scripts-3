begin tran

;with cteDraw 
as 
( 
	select distinct drawdate from scDraws
)

insert into scDraws ( CompanyID	, DistributionCenterID	, AccountID	, PublicationID	, DrawWeekday
	, DrawDate, DeliveryDate, DrawAmount, DrawRate, RetAmount, RollupAcctID )
select 1, 1, a.AccountId, 1 as [Publicaiton]
	, DATEPART(dw, cte.DrawDate), cte.DrawDate, cte.DrawDate, 0, 0.0, 0, r.RollupId
from scAccounts a
join cteDraw cte
	on 1 = 1
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID	
left join scRollups r
	on ca.AccountID = r.RollupID
left join scDraws d
	on a.AccountID = d.AccountID
	and cte.DrawDate = d.DrawDate
where d.DrawAmount is null



commit tran