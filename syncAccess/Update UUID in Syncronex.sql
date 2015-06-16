

begin tran

declare @syncUUID nvarchar(1000)
declare @TNID nvarchar(1000)

SET @syncUUID = 'd1c3a6ee-c660-11e3-ad7a-10604b9f0f84'
set @TNID ='d1c3a6ee-c660-11e3-ad7a-10604b9f0f84'

update OAuthMembership
set ProviderUserID = @syncUUID
where ProviderUserID = @TNID

ROLLBACK TRAN


