
drop index dbo.scDraws.CIX_scDraws_Date
drop index dbo.scDraws.PK_scDraws
drop index dbo.scDraws.IDX_scDraws_DeliveryDate
drop index dbo.scDraws.idx_scDraws_AccountId
drop index dbo.scDraws.idx_scDraws
drop index dbo.scDraws.idx_scDraws_AccountId_DeliveryDate_Covering
drop index dbo.scDraws.idx_scDraws_AccountID_PublicationID_DrawWeekday_DeliveryDate_Covering
drop index dbo.scDraws.idx_scDraws_DeliveryDate_Covering1
drop index dbo.scDraws.idx_scDraws_DeliveryDate_Covering2
drop index dbo.scDraws.idx_scDraws_DeliveryDate_Covering3
drop index dbo.scDraws.idx_scDraws_DrawDate_AccountId_PublicationId_CompanyId_DistributionCenterId_DrawWeekday
drop index dbo.scDraws.idx_scDraws_AccountIdDrawDate
drop index dbo.scDraws.idx_scDraws_AccountId_BillingDate_Covering


create clustered index CIX_scDraws_Date
on dbo.scDraws(DrawDate)
go

create unique index PK_scDraws
on dbo.scDraws(DrawID)
go

create index IDX_scDraws_DeliveryDate
on dbo.scDraws(DeliveryDate)
go

create index idx_scDraws_AccountId
on dbo.scDraws(AccountID)
go

create unique index idx_scDraws
on dbo.scDraws(CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawID)
go

create index idx_scDraws_AccountId_DeliveryDate_Covering
on dbo.scDraws(CompanyID, DistributionCenterID, AccountID, DeliveryDate)
include (PublicationID, DrawWeekday, DrawID, DrawDate, DrawAmount, DrawRate, AdjAmount, AdjAdminAmount, RetAmount)
go

create index idx_scDraws_AccountID_PublicationID_DrawWeekday_DeliveryDate_Covering
on dbo.scDraws(AccountID, PublicationID, DrawWeekday, DeliveryDate)
include (DrawDate, DrawAmount, AdjAmount, AdjAdminAmount)
go

create index idx_scDraws_DeliveryDate_Covering1
on dbo.scDraws(DeliveryDate)
include (CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawID, DrawDate, DrawAmount, DrawRate, AdjAmount, AdjAdminAmount, RetAmount)
go

create index idx_scDraws_DeliveryDate_Covering2
on dbo.scDraws(DeliveryDate)
include (CompanyID, DistributionCenterID, AccountID, PublicationID, DrawID, DrawDate, DrawAmount, DrawRate, AdjAmount, AdjAdminAmount)
go

create index idx_scDraws_DeliveryDate_Covering3
on dbo.scDraws(DeliveryDate)
include (AccountID, PublicationID, DrawWeekday, DrawDate, DrawAmount, AdjAmount, AdjAdminAmount)
go

create index idx_scDraws_DrawDate_AccountId_PublicationId_CompanyId_DistributionCenterId_DrawWeekday
on dbo.scDraws(DrawDate, AccountID, PublicationID, CompanyID, DistributionCenterID, DrawWeekday)
include (DrawAmount)
go

create index idx_scDraws_AccountIdDrawDate
on dbo.scDraws(AccountID, DrawDate)
include (PublicationID, DrawRate, DrawID)
go

create index idx_scDraws_AccountId_BillingDate_Covering
on dbo.scDraws(AccountID, BillingDate)
include (PublicationID, DrawID, DrawDate, DrawAmount, DrawRate)
go

