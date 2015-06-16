begin tran

set nocount on 

declare @retentionPeriod_Months int
declare @msg nvarchar(512)
set @retentionPeriod_Months = 12

select MessageID
into #messagesToDelete
from deMessage
where MessageDateTime <  DATEADD( month, -1*@retentionPeriod_Months, CONVERT(varchar, getdate(), 1) )

--deMessageStatusHistory
select @msg = 'Min MessageHistoryDateTime in deMessageStatusHistory is ' + convert(varchar, MIN(SDM_MessageHistoryDateTime), 1)
from deMessageStatusHistory
print @msg

delete msh
from deMessageStatusHistory msh
join #messagesToDelete mtd
	on msh.SDM_MessageID = mtd.MessageID
select @msg = cast(@@rowcount as varchar) + ' rows deleted from deMessageStatusHistory.  Min MessageHistoryDateTime is now ' + convert(varchar, MIN(SDM_MessageHistoryDateTime), 1)
from deMessageStatusHistory
print @msg

--deMessageArchive
select @msg = 'Min MessageDateTime in deMessageArchive is ' + isnull( convert(varchar, MIN(MessageDateTime), 1), 'NULL')
from deMessageArchive
print @msg

delete ma
from deMessageArchive ma
join #messagesToDelete mtd
	on ma.MessageID = mtd.MessageID
select @msg = cast(@@rowcount as varchar) + ' rows deleted from deMessageArchive.  Min MessageDateTime is now ' + isnull( convert(varchar, MIN(MessageDateTime), 1), 'NULL')
from deMessageArchive
print @msg

--deMessage
select @msg = 'Min MessageDateTime in deMessage is  ' + convert(varchar, MIN(MessageDateTime), 1)
from deMessage
print @msg

delete m
from deMessage m
join #messagesToDelete mtd
	on m.MessageID = mtd.MessageID
select @msg = cast(@@rowcount as varchar) + ' rows deleted from deMessage.  Min MessageDateTime is now ' + convert(varchar, MIN(MessageDateTime), 1)
from deMessage
print @msg

--|deMessageLoad
select @msg = 'Min MessageDateTime in deMessageLoad is ' + convert(varchar, cast( left(createdate, 2) + '/' + substring(createdate, 3 , 2) + '/' + right(createdate, 4) as datetime), 1)
from deMessageLoad
print @msg

delete ld
from deMessageLoad ld
where cast( left(createdate, 2) + '/' + substring(createdate, 3 , 2) + '/' + right(createdate, 4) as datetime) < DATEADD( month, -1*@retentionPeriod_Months, CONVERT(varchar, getdate(), 1) )
select @msg = cast(@@rowcount as varchar) + ' rows deleted from deMessageLoad.  Min MessageDateTime is now ' + convert(varchar, cast( left(createdate, 2) + '/' + substring(createdate, 3 , 2) + '/' + right(createdate, 4) as datetime), 1)
from deMessageLoad
print @msg

--|nsLogSystem
select @msg = 'Min SysLogDateTime in nsLogSystem is ' + convert(varchar, SDM_SysLogDateTime, 1)
from nsLogSystem
print @msg

delete
from nsLogSystem
where SDM_SysLogDateTime < DATEADD( month, -1*@retentionPeriod_Months, CONVERT(varchar, getdate(), 1) )
select @msg = cast(@@rowcount as varchar) + ' rows deleted from nsLogSystem.  Min SysLogDateTime is now ' + convert(varchar, SDM_SysLogDateTime, 1)
from nsLogSystem
print @msg

commit tran


