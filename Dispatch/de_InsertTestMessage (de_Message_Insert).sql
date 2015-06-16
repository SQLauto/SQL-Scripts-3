use sdmdata

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'de_Message_Insert'
	   AND 	  type = 'P')
    DROP PROCEDURE [dbo].[de_Message_Insert]
GO

CREATE PROCEDURE [dbo].[de_Message_Insert]
	(
	@District varchar(25) = null
	,@MessageType varchar(25) = 'P'
	,@MessageText varchar(1024) = 'MessageText'
	,@SpecialInstructions varchar(1024) = 'SpecialInstructions'
	,@MessageReason varchar(25) = 'MessageReason'
	,@ExtensionAttribute1 varchar(255) = 'ExtensionAttribute1'
	,@ExtensionAttribute2 varchar(255) = 'ExtensionAttribute2'
	,@ExtensionAttribute3 varchar(255) = 'ExtensionAttribute3'
	,@ExtensionAttribute4 varchar(255) = 'ExtensionAttribute4'
	,@ExtensionAttribute5 varchar(255) = 'ExtensionAttribute5'
	)
AS
/* =============================================
Procedure:  de_Message_Insert

Created By:	katokm
Date Created:	6/18/2003	


History
-----------------------------------------------
Date	Name		Change Description
-----------------------------------------------
==============================================*/
begin
set nocount on

declare @rowcount int
	,@error int
	,@errormessage varchar(1024)
	,@procedure varchar(100)

	select @procedure = 'Stored Procedure: de_Message_Insert'

	insert into deMessage
	(
	--|Input Fields
	District
	,MessageType
	,MessageText
	,SpecialInstructions
	,MessageReason
	,ExtensionAttribute1
	,ExtensionAttribute2
	,ExtensionAttribute3
	,ExtensionAttribute4
	,ExtensionAttribute5
	--|System generated
	,MessageDateTime
	,MessageStatusDateTime
	--|Constants
	,MessageStatusID
	,SubscriberAccountNumber
	,SubscriberName
	,SubscriberPhone
	,AddressConcat
	,City
	,State
	,Zip
	,Company
	,DistributionCenter
	,Zone
	,Route
	,Publication
	)
	select 
	--|Input Fields
	@District
	,@MessageType
	, @MessageText
	, @SpecialInstructions
	, @MessageReason
	, @ExtensionAttribute1
	, @ExtensionAttribute2
	, @ExtensionAttribute3
	, @ExtensionAttribute4
	, @ExtensionAttribute5
	--|System generated
	,getdate()
	,getdate()
	--|Constants
	,7  --|7=Pending
	,'00000000'
	,'Joe Subscriber'
	,'555-1212'
	,'2018 156th AVE NE'
	,'Bellevue'
	,'WA'
	,'98007'
	,'Syncronex'
	,'DEMO'
	,'DEMO'
	,'11AA22'
	,'SN'

	select @error = @@error, @rowcount = @@rowcount
	if @error <> 0
	begin
		select @errormessage = 'Error inserting message into deMessage.  ' + @procedure + '.  Error: ' + cast(@error as varchar(25))
		select cast(@error as varchar(25)) as [ResultCode], @errormessage as [Result]
		return(@error)
	end
	else
	begin
		select 'SUCCESS' as [ResultCode], 'SUCCESS' as [Result]
		return(0)
	end
end
