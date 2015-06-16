
insert into scDraws ( CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawDate, DeliveryDate, DrawAmount, DrawRate
	, BillingHistoryID, AdjAmount, AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt, RetAmount, RetExpDateTime, RetExportLastAmt
	, RollupAcctID, LastChangeType, BillingDate )
select 1, 1, a.AccountID, p.PublicationID, DATEPART(dw, tmp.DrawDate), tmp.DrawDate, tmp.DrawDate, tmp.NetDraw, 0.0
	, null, null, null, null, null, null, null, null
	, ca.AccountID, 1, tmp.DrawDate
from nsdb_advor..adhocImport_NetSales tmp
join scAccounts a
	on tmp.RouteID = a.AcctCode
join nsPublications p
	on tmp.Product = p.PubShortName
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
join scDefaultDraws dd
	on a.AccountID = dd.AccountID
	and p.PublicationID = dd.PublicationID
	and DATEPART(dw, tmp.DrawDate) = dd.DrawWeekday	
--left join scRollups r
--	on ca.AccountID = r.RollupID	
left join scDraws d
	on dd.AccountID = d.AccountID
	and dd.PublicationID = d.PublicationID
	and dd.DrawWeekday = d.DrawWeekday
	and tmp.DrawDate = d.DrawDate
where d.DrawID is null	


update scDraws
	set DrawAmount = tmp.NetDraw
from nsdb_advor..adhocImport_NetSales tmp
join scAccounts a
	on tmp.RouteID = a.AcctCode
join nsPublications p
	on tmp.Product = p.PubShortName
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
--left join scRollups r
--	on ca.AccountID = r.RollupID	
left join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate
where d.DrawID is not null	
and d.DrawAmount <> tmp.NetDraw
