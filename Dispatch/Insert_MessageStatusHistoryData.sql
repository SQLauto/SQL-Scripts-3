begin tran
set nocount on
/*
If the status is new (7) then do nothing
if the status is dispatched (0) update the messagestatusdatetime by 1 minute
if the status is 1-5 insert a row into messagestatushistory for each status for the message type

cursor to populate messagestatusdatetime and messagestatushistory

*/
declare @messageid int
	, @messagedatetime datetime
	, @messagetype varchar (25)
	, @messagestatusid int
	, @messagetargetid int
	, @counter int
	, @increment int

declare message_cursor cursor
for
	select messageid, messagedatetime, messagetype, messagestatusid, messagetargetid
	from demessage
	where messagestatusid <> 7

open message_cursor
fetch next from message_cursor into @messageid, @messagedatetime, @messagetype, @messagestatusid, @messagetargetid
while @@fetch_status = 0
begin
	if @messagestatusid = 0
	begin
		update demessage
		set messagestatusdatetime = dateadd(minute, 1, @messagedatetime)
		where messageid = @messageid
	end
	if @messagestatusid in (1, 2, 3, 4)
	begin
		select @counter = 0
		select @increment = 1
		select @messagedatetime = dateadd(minute, @increment, @messagedatetime) 

		while @counter < @messagestatusid
		begin
			insert into demessagestatushistory (sdm_messageid, sdm_messagestatusid, sdm_messagehistorydatetime, sdm_messagetargetid)
			select @messageid, @counter, @messagedatetime, @messagetargetid
		
			select @counter = @counter + 1
			select @increment = right(rand(datepart(ms,getdate())),1)
			select @messagedatetime = dateadd(minute, @increment, @messagedatetime) 
		end

		select @increment = right(rand(datepart(ms,getdate())),1)
		select @messagedatetime = dateadd(minute, @increment, @messagedatetime)

		update demessage
		set messagestatusdatetime = @messagedatetime
		where messageid = @messageid
	end
	if @messagestatusid = 5
	begin
		select @counter = 0
		select @increment = 1
		select @messagedatetime = dateadd(minute, @increment, @messagedatetime) 

		while @counter <= @messagestatusid
		begin
			insert into demessagestatushistory (sdm_messageid, sdm_messagestatusid, sdm_messagehistorydatetime, sdm_messagetargetid)
			select @messageid, @counter, @messagedatetime, @messagetargetid
		
			select @counter = @counter + 1
			select @increment = right(rand(datepart(ms,getdate())),1)
			select @messagedatetime = dateadd(minute, @increment, @messagedatetime) 
		end

		update demessage
		set messagestatusdatetime = @messagedatetime	
		where messageid = @messageid
	end

fetch next from message_cursor into @messageid, @messagedatetime, @messagetype, @messagestatusid, @messagetargetid
end

close message_cursor
deallocate message_cursor

commit tran

