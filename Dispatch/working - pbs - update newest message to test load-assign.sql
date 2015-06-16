
/*
	PBS - Test Load/Assign of new messages

	**DO NOT COMMIT THIS TRANSACTION.  LEAVE AS ROLLBACK**

*/
begin tran

declare @today datetime
declare @datestring varchar(8)
declare @time varchar(8)
declare @internalseqno int

set @today = getdate()
set @datestring = right( '00' + cast( datepart( month, @today ) as varchar ), 2 )
		+ right( '00' + cast( datepart( day, @today ) as varchar ), 2 )
		+ cast( datepart( year, @today ) as varchar )

print @datestring

--|reset the status of the "newest" message to New so that it can be reloaded and reassigned
--|modify the following nested query to identify a specific message that you want to see if it 
--|	gets imported/assigned correctly
select @internalseqno = (
 	select top 1 internalseqno
	from demessageload
	where createdate = @datestring
	order by createtime desc
	)

print @internalseqno

update demessageload
set loadstatus = 'New'
where internalseqno = @internalseqno

select *
from demessageload
where internalseqno = @internalseqno

--|reload/reassign message
exec de_newmessages_load
exec de_newmessages_assign

--|comment/uncomment the following to toggle the display of pertinent log information
/*
select top 10 sdm_syslogdatetime, logmessage
from nslogsystem 
order by sdm_syslogdatetime desc
*/

select *
from demessage
where pbsdispatchid = @internalseqno
 
rollback tran


