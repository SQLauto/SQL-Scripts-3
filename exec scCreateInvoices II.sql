begin tran

declare @basedate			datetime
declare @baseDOW			int
declare @InvoiceDateOption	datetime

select @baseDOW datepart(dw, max(invoicedate))
from scInvoices

select 

EXEC	[dbo].[scCreateInvoices]
		@CompanyID = 1,
		@DistributionCenterID = 1,
		@BaseDate = N'3/15/2010',
		@ManifestId = NULL,
		@InvoiceDateOption = N'3/15/2010',
		@PrevPeriodFlag = 0,
		@ValidateInvoices = 1,
		@CreateNew = 1,
		@UpdateBalFwd = 0
		


select *
from scinvoices
where invoicedate = '3/15/2010'