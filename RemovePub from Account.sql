
begin tran

declare @acctcode varchar(20)
declare @pubname varchar(5)

set @acctcode =  'ST01-033'
set @pubname = 'UT'

declare @acctid int
declare @pubid int
select @acctid = accountid from scaccounts where acctcode = @acctcode
select @pubid = publicationid from nspublications where pubshortname = @pubname

delete from scdrawadjustmentsaudit where accountid = @acctid and publicationid = @pubid
delete from scdrawadjustments where accountid = @acctid and publicationid = @pubid

delete from screturnsaudit where accountid = @acctid and publicationid = @pubid
delete from screturns where accountid = @acctid and publicationid = @pubid

delete from scdraws where accountid = @acctid and publicationid = @pubid

delete from scdefaultdrawhistory where accountid = @acctid and publicationid = @pubid

delete from scdrawforecasts where accountid = @acctid and publicationid = @pubid

delete from scdefaultdraws where accountid = @acctid and publicationid = @pubid

commit tran