
declare @p10 int
set @p10=1
exec SubscriberList_Select @Username=N'',@LastName=N'',@FirstName=N'',@AlternateName=N'',@Email=N'ryleruda@gmail.com',@PhoneNumber=N'',@SortExpression=N'',@RecordsPerPage=2147483647,@FirstRecord=0,@TotalRecords=@p10 output
select @p10
go

exec Subscribers_Exists @UserId=10142
go

exec seUsers_Select @UserId=10142
go

exec Subscribers_Select @UserId=10142
go

--declare @p11 binary(8)
--set @p11=0x00000000001084D7
--exec Subscribers_Update @UserId=10142,@FirstName=N'ROGER',@LastName=N' DUNHAM',@MiddleName=N'',@Salutation=N'',@Honorific=N'',@AlternateName=N'',@Birthdate=NULL,@IsActive=1,@LastUpdated=0x00000000001084BF,@NewLastUpdated=@p11 output
--select @p11
--go

--exec SubscriberSources_Update @SubscriberSourceID=16845,@UserId=10142,@SubscriberSource=N'DTI 2012 v3.8',@SyncDate='2015-04-16 18:07:55.157',@SyncStatus=1,@ActivationType=2,@KeyInformation=N'OccupantID="496094";AddressID="251936";',@SyncError=N'',@ResponseTime=2471
--go

exec Subscribers_AdminSelect @UserId=10142
go
