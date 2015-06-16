DROP VIEW [dbo].[CustomExport_AccountInfo_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CustomExport_AccountInfo_View]
AS
	select  'AcctCode' as [AcctCode], 'AcctName' as [AcctName], 'AcctDescription' as [AcctDescription], 'AcctNotes' as [AcctNotes], 'AcctAddress' as [AcctAddress], 'AcctCity' as [AcctCity], 'AcctStateProvince' as [AcctStateProvince], 'AcctPostalCode' as [AcctPostalCode], 'AcctCountry' as [AcctCountry], 'AcctContact' as [AcctContact], 'AcctHours' as [AcctHours], 'AcctPhone' as [AcctPhone], 'AcctCreditCardOnFile' as [AcctCreditCardOnFile], 'AcctImported' as [AcctImported], 'AcctCustom1' as [AcctCustom1], 'AcctCustom2' as [AcctCustom2], 'AcctCustom3' as [AcctCustom3], 'AcctActive' as [AcctActive], 'AcctSpecialInstructions' as [AcctSpecialInstructions]
		--, 'AcctTaxExempt' as [AcctTaxExempt]
		--, 'AcctOwner' as [AcctOwner], 'UseAgentRemitToAddress' as [UseAgentRemitToAddress], 'IsCorporate' as [IsCorporate]
		, 'DeliveryManifest(s) (MfstName/SeqName/Seq#)' as [DeliveryManifest(s) (MfstName/SeqName/Seq#)]
		, 'CollectionManifest(s) (MfstName/SeqName/Seq#)'as [CollectionManifest(s) (MfstName/SeqName/Seq#)]
		, 'ReturnsManifest(s) (MfstName/SeqName/Seq#)' as [ReturnsManifest(s) (MfstName/SeqName/Seq#)]
	union all select  AcctCode, AcctName, AcctDescription, AcctNotes, AcctAddress, AcctCity, AcctStateProvince, AcctPostalCode, AcctCountry, AcctContact, AcctHours, AcctPhone
		, cast(AcctCreditCardOnFile as varchar), cast(AcctImported as varchar), AcctCustom1, AcctCustom2, AcctCustom3, cast(AcctActive as varchar), AcctSpecialInstructions
		--, cast(AcctTaxExempt as varchar)
		--, cast(AcctOwner as varchar), cast(UseAgentRemitToAddress as varchar), cast(IsCorporate as varchar)
		, dbo.support_MfstsByAcct( a.AccountId, 1 ) as [DeliveryManifest(s) (MfstName/SeqName/Seq#)]
		, dbo.support_MfstsByAcct( a.AccountId, 2 ) as [CollectionManifest(s) (MfstName/SeqName/Seq#)]
		, dbo.support_MfstsByAcct( a.AccountId, 4 ) as [ReturnsManifest(s) (MfstName/SeqName/Seq#)]
	from scAccounts a
	where AcctActive = 1
GO

GRANT EXECUTE ON [dbo].[CustomExport_AccountInfo_View] TO [nsUser]
GO