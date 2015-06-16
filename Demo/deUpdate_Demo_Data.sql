use sdmdata

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'deUpdate_Demo_Data' 
	   AND 	  type = 'P')
    DROP PROCEDURE [dbo].[deUpdate_Demo_Data]
GO

CREATE PROCEDURE [dbo].[deUpdate_Demo_Data]
AS
	set nocount on

	/*
	This script will add the number of months difference between the messagedate and the current date
	i.e.  if the current date is july 8 and the messagedate is june 30, it will add one month to make the 
	message date equal to the current month.  
	
	This script will then adjust the month by -1 for any messagedates that are greater than the current date
	*/
	update demessage
	set messagedatetime = dateadd(
		month, 
		datediff(month, messagedatetime, current_timestamp),
		messagedatetime
		)
	where datediff(month, messagedatetime, current_timestamp) <> 0 
	
	update demessage
	set messagedatetime = dateadd(month, -1, messagedatetime)
	where messagedatetime > dateadd(d, 1, convert(varchar, current_timestamp, 1))
	
	--Sets date to today for non-complete messages
	update demessage
	set messagedatetime = dateadd(day, datediff(day, dateadd(month,datediff(month, messagedatetime, current_timestamp),messagedatetime), current_timestamp), dateadd(month,datediff(month, messagedatetime, current_timestamp),messagedatetime))
	where messagestatusid not in (5,6)
	
	--Keeps datepart(day) equal to messagedatetime day
	update demessage
	set messagestatusdatetime = dateadd
				(
				day,
				datediff(day, messagestatusdatetime, messagedatetime),
				messagestatusdatetime
				)
	where datediff(day, messagestatusdatetime, messagedatetime) <> 0
	
	update demessagestatushistory
	set sdm_messagehistorydatetime = dateadd
				(
				day,
				datediff(day, sdm_messagehistorydatetime, messagedatetime),
				sdm_messagehistorydatetime
				)
	from demessagestatushistory msh
	inner join demessage m
	on m.messageid = msh.sdm_messageid
	where datediff(day, sdm_messagehistorydatetime, messagedatetime) <> 0
GO