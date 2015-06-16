IF EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[scDrawHistory]') 
											AND name = N'idx_scDrawHistory_AccountID')
BEGIN
	DROP INDEX idx_scDrawHistory_AccountID --ON [dbo].[scDrawHistory] WITH ( ONLINE = OFF )
END
GO


IF EXISTS( SELECT 1 FROM dbo.sysindexes WHERE id=OBJECT_ID( N'dbo.scDrawHistory' )
											AND [Name] = 'idx_scDrawHistory_PublicationID' )
BEGIN
	DROP INDEX idx_scDrawHistory_PublicationID --on dbo.scDrawHistory WITH ( ONLINE = OFF )
	
END
GO

IF EXISTS( SELECT 1 FROM dbo.sysindexes WHERE id=OBJECT_ID( N'dbo.scDrawHistory' )
											AND [Name] = 'idx_scDrawHistory_DrawDate' )
BEGIN
	DROP INDEX idx_scDrawHistory_DrawDate --on dbo.scDrawHistory WITH ( ONLINE = OFF )
END
GO

--CREATE INDEX idx_scDrawHistory_AccountID on dbo.scDrawHistory( AccountID )
--CREATE INDEX idx_scDrawHistory_PublicationID on dbo.scDrawHistory( PublicationID )
--CREATE INDEX idx_scDrawHistory_DrawDate on dbo.scDrawHistory( DrawDate )
