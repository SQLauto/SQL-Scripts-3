IF NOT EXISTS( SELECT 1 FROM dbo.sysindexes WHERE id=OBJECT_ID( N'dbo.scDrawHistory' )
											AND [Name] = 'idx_scDrawHistory_ForecastDetailHistory' )
BEGIN
	CREATE INDEX idx_scDrawHistory_ForecastDetailHistory on dbo.scDrawHistory( 
		AccountId
		, PublicationId 
		, DrawDate
		, UserId
		, ChangedDate
		)
END
GO