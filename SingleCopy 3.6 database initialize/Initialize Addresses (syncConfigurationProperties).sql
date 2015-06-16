set nocount on

--|CompanyAddress
DECLARE	@return_value int,
		@NewLastUpdated timestamp,
		@AddressId int

EXEC	@return_value = [dbo].[scAddresses_Insert]
		@Name = N'CompanyAddress',
		@Address1 = N'Address1',
		@Address2 = N'Address2',
		@City = N'City',
		@State = N'State',
		@Zip = N'Zip',
		@Custom1 = N'Custom1',
		@Custom2 = N'Custom2',
		@Custom3 = N'Custom3',
		@NewLastUpdated = @NewLastUpdated OUTPUT,
		@AddressId = @AddressId OUTPUT

--SELECT	@NewLastUpdated as N'@NewLastUpdated',
--		@AddressId as N'@AddressId'

		update syncConfigurationPropertyValues
		set PropertyValue = @AddressId
		from syncConfigurationProperties p
		join syncConfigurationPropertyValues v
			on p.ConfigurationPropertyId = v.ConfigurationPropertyId
		where PropertyName = 'CompanyAddress'

--|RemitToAddress
EXEC	@return_value = [dbo].[scAddresses_Insert]
		@Name = N'RemitToAddress',
		@Address1 = N'Address1',
		@Address2 = N'Address2',
		@City = N'City',
		@State = N'State',
		@Zip = N'Zip',
		@Custom1 = N'Custom1',
		@Custom2 = N'Custom2',
		@Custom3 = N'Custom3',
		@NewLastUpdated = @NewLastUpdated OUTPUT,
		@AddressId = @AddressId OUTPUT

		update syncConfigurationPropertyValues
		set PropertyValue = @AddressId
		from syncConfigurationProperties p
		join syncConfigurationPropertyValues v
			on p.ConfigurationPropertyId = v.ConfigurationPropertyId
		where PropertyName = 'RemitToAddress'

	select *
	from scAddresses