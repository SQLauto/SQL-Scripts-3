begin tran

;with cteLastStatus as (
	select msh.SDM_MessageID, msh.SDM_MessageStatusID
	from deMessageStatusHistory msh
	join (
		select messageid, max(sdm_messagehistorydatetime) as [messagestatusdatetime]
		from demessage m
		inner join demessagestatushistory msh
		on m.messageid = msh.sdm_messageid
		group by messageid
		) tmp
		on msh.SDM_MessageID = tmp.MessageID
		and msh.SDM_MessageHistoryDateTime = tmp.messagestatusdatetime
)
update demessage
set MessageStatusID = cte.SDM_MessageStatusID
from deMessage m
join cteLastStatus cte
	on m.MessageID = cte.SDM_MessageID

select messagestatusid, COUNT(*)
from deMessage
group by MessageStatusID

--rollback tran
commit tran