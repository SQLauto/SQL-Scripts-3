begin tran 

	DECLARE	@RollupID		INT
		,		@PublicationID	INT
		,		@DrawDate		DATETIME
		,		@DeliveryDate	DATETIME
		,		@BulkDraw		INT
		, 		@RC				INT	-- return code from bulk dist sproc
		,		@RollupCode		NVARCHAR(20)
		,		@PubCode		NVARCHAR(5)	

		SELECT	@RollupId = R.RollupID
			, @PublicationID = P.PublicationID
			, @DrawDate = V.DrawDate
			, @DeliveryDate = V.DeliveryDate
			, @BulkDraw = V.DrawAmount
			FROM	scManifestLoad_View V
			JOIN	scRollups R ON V.AcctCode = R.RollupCode
			JOIN	nsPublications P ON V.Publication = P.PubShortName
			WHERE	V.AcctRollup = 1
			and v.acctcode = 'r52951'

	print @rollupid
	print @publicationid
	print @drawdate
	print @deliverydate
	print @bulkdraw
			
	exec dbo.support_scDistributeImportedBulkDraw
							@RollupID, @DrawDate, @PublicationID, @BulkDraw, @DeliveryDate
							
	exec dbo.scImportedBulkDistribution_Select 
					@drawDate = @DrawDate
				,	@RollupID = @RollupID
				,	@PublicationID = @PublicationID


rollback tran