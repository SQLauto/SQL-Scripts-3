IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[nsMessages_INSERTNOTALREADY]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[nsMessages_INSERTNOTALREADY]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[nsMessages_INSERTNOTALREADY]
(
@nsSubject nvarchar(255),
@nsMessageText nvarchar(4000),
@nsFromID int,
@nsToID int,
@nsGroupID int,
@nsTime datetime,
@nsPriorityID int,
@nsStatusID int,
@nsTypeID int,
@nsStateID int,
@nsCompareTime datetime,
@nsAccountID int
)
AS
DECLARE @ID int

SELECT @ID = IdentityCol FROM nsMessages
WHERE nsSubject=@nsSubject
AND nsMessageText=@nsMessageText
AND nsFromID =@nsFromID
AND nsToID=@nsToID
AND nsGroupID=@nsGroupID
AND nsPriorityID=@nsPriorityID
AND nsStatusID=@nsStatusID
AND nsTypeID=@nsTypeID
AND nsStateID=@nsStateID
AND nsTime>@nsCompareTime
AND nsAccountID = @nsAccountID
IF @ID IS NOT NULL
      RETURN  -1
ELSE
	INSERT nsMessages
	(
	nsSubject,
	nsMessageText,
	nsFromID,
	nsToID,
	nsGroupID,
	nsTime,
	nsPriorityID,
	nsStatusID,
	nsTypeID,
	nsStateID,
	nsAccountID
	) VALUES (
	@nsSubject,
	@nsMessageText,
	@nsFromID,
	@nsToID,
	@nsGroupID,
	  --|  if @nsTime is in the past (e.g. 1/1/1900) adjust the date portion of the timestamp
	case when DATEDIFF(d, @nsTime, getdate()) > 0 then dateadd(d, DATEDIFF(d, 0, GETDATE()), @nsTime)
			else @nsTime end,
	@nsPriorityID,
	@nsStatusID,
	@nsTypeID,
	@nsStateID,
	@nsAccountID
	)
RETURN @@IDENTITY



GO


GRANT EXECUTE ON [dbo].[nsMessages_INSERTNOTALREADY] TO [nsUser]
GO