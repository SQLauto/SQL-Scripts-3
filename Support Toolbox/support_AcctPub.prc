IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'support_AcctPub' 
)
   DROP PROCEDURE dbo.support_AcctPub
GO

CREATE PROCEDURE dbo.support_AcctPub
	@AccountPubId int = null
AS
	select a.AcctCode, p.PubShortName, a.AccountId, ap.AccountPubId, p.PublicationId
	from scAccountsPubs ap
	join scAccounts a
		on a.AccountId = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationId	
	where 
		(
			( @accountPubId is null and ap.AccountPubId > 0 )
			or ( @accountPubId is not null and ap.AccountPubId = @accountPubId )
		)
GO

-- =============================================
-- Example to execute the stored procedure
-- =============================================
EXECUTE dbo.support_AcctPub @AccountPubId=null
GO