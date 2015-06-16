exec [SyncAccess_Po_Etn_Prod].[Subscribers_Select] 43983

declare @userid  int
set @userid = 43983

	SELECT	S.UserId
	,		S.FirstName
	,		S.MiddleName
	,		S.LastName
	,		S.AlternateName
	,		S.Birthdate
	,		S.Salutation
	,		S.Honorific
	,		S.IsActive
	FROM	[SyncAccess_Po_Etn_Prod].Subscribers S
	WHERE	S.UserId = @UserId
	AND		S.IsDeleted = 0x00
	
	--
	--	Get any subscriber phone numbers
	SELECT	P.PhoneNumberId
	,		P.PhoneNumber
	,		P.Extension
	,		P.PhoneTypeId
	,		P.IsPrimary
	FROM	[SyncAccess_Po_Etn_Prod].PhoneNumbers P
	JOIN	[SyncAccess_Po_Etn_Prod].Subscribers S ON S.UserId = P.UserId
	WHERE	P.UserId = @UserId
	AND		S.IsDeleted = 0x00
	
	--
	--	Get any registered devices
	SELECT	D.RegisteredDeviceId
	,		D.DeviceName
	,		D.DeviceTypeId
	,		D.DeviceUniqueId
	FROM	[SyncAccess_Po_Etn_Prod].RegisteredDevices D
	JOIN	[SyncAccess_Po_Etn_Prod].Subscribers S ON S.UserId = D.UserId
	WHERE	D.UserId = @UserId
	AND		D.IsDeleted = 0x00

	--
	--	Get the primary billing address
	SELECT	AD.AddressId
	,		AD.HouseNumber
	,		AD.HouseNumberSuffix
	,		AD.StreetSuffixId
	,		AD.StreetName
	,		AD.StreetPreDirection
	,		AD.StreetPostDirection
	,		AD.SecondaryUnitDesignatorId
	,		AD.SecondaryUnitDesignator
	,		AD.Town
	,		AD.City
	,		AD.County
	,		AD.Country
	,		AD.State
	,		AD.PostalCode
	,		AD.PostalCodeExtension
	,		CAST(0x01 AS BIT) AS IsBilling
	,		BA.IsPrimary
	FROM	[SyncAccess_Po_Etn_Prod].BillToAddresses BA
	JOIN	[SyncAccess_Po_Etn_Prod].Addresses AD ON BA.AddressId = AD.AddressId
	WHERE	BA.UserId = @UserId
	AND		BA.IsPrimary = 0x01	
	
	--
	--	Get any active purchases for this subscriber
	SELECT	SP.SubscriberPlanID
	,		SP.PlanID
	,		SP.OriginalPlanCode AS Code
	,		SP.OriginalPlanName AS Name
	,		SP.PurchaseDate
	,		SP.LastRenewalDate
	,		SP.ExpirationDate
	,		SP.CancelledDate
	,		SP.OriginalPlanRate
	,		SP.OriginalPlanDiscount
	,		SP.OriginalPlanLength
	,		SP.OriginalPlanSubTerm
	,		SP.Active
	,		SP.CirculationDetails
	,		SP.MappedPlan
	FROM	[SyncAccess_Po_Etn_Prod].SubscriberPlans SP
	WHERE	SP.UserId = @UserId
	AND		SP.ExpirationDate > GETUTCDATE()
	AND		SP.CancelledDate IS NULL
	
	--
	--	Any alternate sources for this subscriber?
	SELECT	SS.SubscriberSourceId
	,		SS.SubscriberSource
	,   SS.CreateDate
	,   SS.LastSyncDate
	,   SS.SyncStatus
    ,   SS.SyncError
	,   SS.ActivationType
	,		SK.KeyType
	,		SK.KeyField
	,		SK.KeyValue
	FROM	[SyncAccess_Po_Etn_Prod].SubscriberSources SS
	JOIN	[SyncAccess_Po_Etn_Prod].SubscriberSourceKeys SK ON SS.SubscriberSourceId = SK.SubscriberSourceId
	WHERE	SS.UserId = @UserId
	
	--
	--	Get Payment Card Info for this subscriber
	SELECT	PC.CardNumber
	,		PC.Token
	,		PC.CardHolderName
	,		PC.PaymentCardTypeId
	,		PC.CardExpirationMonth
	,		PC.CardExpirationYear
	,		PC.IsPrimary
	,		PC.PaymentCardId
	FROM	[SyncAccess_Po_Etn_Prod].PaymentCards PC
	WHERE	PC.UserId = @UserId
	
	--
	--	Last 100 transactions for this subscriber
	SELECT	TOP( 100 )
			trx.TransactionId
	,		trx.TrxAmount
	,		trx.TrxDate
	,		trx.TrxDescription
	,		trx.TrxPaymentMethod
	,		trx.TrxReference
	,		trx.ErrorMessage
	,		trx.Is3rdPartyTrx
	,   trx.CCAuthCode
	FROM	[SyncAccess_Po_Etn_Prod].SubscriberTransactions trx
	WHERE	trx.UserId = @UserId
	ORDER BY trx.TransactionId DESC