

begin tran
declare @today datetime
set @today = '6/24/2009'

exec sccreateinvoices @CompanyId=1, @DistributionCenterId=1, @BaseDate=@today, @ManifestId=null, @InvoiceDateOption='start', @PrevPeriodFlag=0, @EnforceCutoff=0, @ValidateInvoices=0, @CreateNew=1, @UpdateBalFwd=1

select *
from scinvoices

commit tran