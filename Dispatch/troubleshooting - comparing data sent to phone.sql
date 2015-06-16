--|update a messagestatus to view what date is sent to the phones 
begin tran

declare @username varchar(255)
declare @userid int
declare @messageid int

set @messageid = 135667
set @username = 'support@syncronex.com'

select @userid = userid
from sdmconfig..users
where username = @username

update demessage
set messagetargetid = ( select messagetargetid from demessagetarget where syncronexusername = @username )
	,messagestatusid = 0
where messageid = @messageid

exec de_spGetMessage @messageid, @userid

select *
from demessage
where messageid = @messageid

rollback tran