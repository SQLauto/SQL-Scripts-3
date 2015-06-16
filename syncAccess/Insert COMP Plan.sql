begin tran
	set nocount on

	declare @planCode nvarchar(10)
	declare @subscriptionId int

	set @planCode = 'COMP'

	/*
	--run the following query to determine the appropriate Subscription to map the COMP plan to, then
	--update the [Name] in the subsequent query to set the PublicationSubscriptionId

	select *
	from sePublicationSubscriptions
	where name like '%digital only%'

	*/

	select @subscriptionId = PublicationSubscriptionID
	from sePublicationSubscriptions
	where name = 'Digital Only'


	if not exists (
		select *
		from sePlans
		where code = @planCode
	)
	begin
		print 'creating plan ''' + @planCode + ''''
		declare @p15 int
		set @p15=7
		declare @p16 binary(8)
		set @p16=0x000000000000272C
		exec sePlans_Insert 
			 @Code=@planCode
			,@Name=N'Complimentary'
			,@Description=N'Complimentary Plan'
			,@OfferToPrintSubscribers=0
			,@OfferToDigitalSubscribers=1
			,@AllowRepurchase=0
			,@ConvertsToPlanId=0
			,@PromotionID=1					
			,@PublicationSubscriptionID=@subscriptionId	--PublicationSubscriptionId --> Subscription (aka DDIGONLY)
			,@SubscriptionLength=0
			,@DiscountPercent=100
			,@Active=0
			,@AllowedContentCategories=N''
			,@DisplaySortOrder=997
			,@PlanID=@p15 output
			,@NewLastUpdated=@p16 output
		print 'PlanId=' + cast(@p15 as varchar)
		--print 'PlanId=' + cast(@p16 as varchar)
	end
	else
	begin
		declare @planId int

		select @planId = PlanID
		from sePlans
		where Code = @planCode

		print '''COMP'' plan already exists.  PlanId=' + cast(@planId as varchar)
	end

	declare @ApiUrl nvarchar(256)

	select @ApiUrl = v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'ApiUrl'
	print 'ApiUrl = ' + @ApiUrl


	print 'preloadleeusers.exe -f"DEC free and bulk accounts.csv" -sEvans -dlee_dec_stage -P7 -uhttps://stage.syncaccess.net/lee/dec/api'

rollback tran
