begin tran

	declare @messagetype nvarchar(25)

	set @messagetype = 'Complaint'

	--|Insert Default Transitions for new Message Type
	create table #transitions (
		messagetype nvarchar(25)
		,currentmessagestatusid int
		,newmessagestatusid int
		,[description] nvarchar(255)
		,displayname nvarchar(255)
		,isactive tinyint
	)

	insert into #transitions(messagetype, currentmessagestatusid, newmessagestatusid, description, displayname, isactive)
	select 
	--|Dispatched
		@MessageType,    0,    1,    'Dispatched => Received'  ,  'Dispatched => Received'  ,    0
	--|Received
	union all select
		@MessageType,    1,    2,    'Received => Accepted'  ,    'Received => Accepted'  ,    0
	union all select
		@MessageType,    1,    3,    'Received => Rejected'  ,    'Received => Rejected'  ,    0
	union all select
		@MessageType,    1,    4,    'Received => Enroute'   ,    'Received => Enroute'   ,    0
	union all select
		@MessageType,    1,    5,    'Received => Complete'  ,    'Received => Complete'  ,    0
	union all select
		@MessageType,    1,    6,    'Received => Cancelled'  ,    'Received => Cancelled'  ,    0
/*	union all select
		@MessageType,    1,    11,    'Received => Complete - Alt1'  ,    'Received => Complete - Alt1'  ,    0
	union all select
		@MessageType,    1,    12,    'Received => Complete - Alt2'  ,    'Received => Complete - Alt2'  ,    0
	union all select
		@MessageType,    1,    13,    'Received => Complete - Alt3'  ,    'Received => Complete - Alt3'  ,    0
*/
	--|Accepted
	union all select
		@MessageType,    2,    3,    'Accepted => Rejected'   ,   'Accepted => Rejected'   ,    0
	union all select
		@MessageType,    2,    4,    'Accepted => Enroute'   ,    'Accepted => Enroute'   ,    0
	union all select
		@MessageType,    2,    5,    'Accepted => Complete'   ,   'Accepted => Rejected'   ,    0
	union all select
		@MessageType,    2,    6,    'Accepted => Cancelled'   ,   'Accepted => Cancelled'   ,    0
/*	union all select
		@MessageType,    2,    11,    'Accepted => Complete - Alt1'  ,    'Accepted => Complete - Alt1'  ,    0
	union all select
		@MessageType,    2,    12,    'Accepted => Complete - Alt2'  ,    'Accepted => Complete - Alt2'  ,    0
	union all select
		@MessageType,    2,    13,    'Accepted => Complete - Alt3'  ,    'Accepted => Complete - Alt3'  ,    0
*/
	--|Rejected
	union all select
		@MessageType,    3,    2,    'Rejected => Accepted'  ,    'Rejected => Accepted'  ,    0
	--|Enroute
	union all select
		@MessageType,    4,    3,    'Enroute => Rejected'   ,    'Enroute => Rejected'   ,    0
	union all select
		@MessageType,    4,    5,    'Enroute => Complete'   ,    'Enroute => Complete'   ,    0
	union all select
		@MessageType,    4,    6,    'Enroute => Cancelled'   ,   'Enroute => Cancelled'   ,    0
/*	union all select
		@MessageType,    4,    11,    'Enroute => Complete - Alt1'  ,    'Enroute => Complete - Alt1'  ,    0
	union all select
		@MessageType,    4,    12,    'Enroute => Complete - Alt2'  ,    'Enroute => Complete - Alt2'  ,    0
	union all select
		@MessageType,    4,    13,    'Received => Complete - Alt3'  ,    'Enroute => Complete - Alt3'  ,    0
*/

	insert into dd_demessagestatustransition ( messagetype, currentmessagestatusid, newmessagestatusid, description, displayname, isactive )
	select tmp.*
	from #transitions tmp
	left join dd_demessagestatustransition trx
	on tmp.messagetype = trx.messagetype
	and tmp.currentmessagestatusid = trx.currentmessagestatusid
	and tmp.newmessagestatusid = trx.newmessagestatusid
	where trx.messagetype is null

	drop table #transitions

rollback tran