
declare @manifestTemplateId int

select @manifestTemplateId = ManifestTemplateId
from scManifestTemplates mt
where MTCode = '200-ret'

EXEC [dbo].[scDrawEntryByManifest]
		@CompanyID = 1,
		@DistributionCenterID = 1,
		@ManifestID = 1571,
		@FIRSTDATE = N'2/17/2013',
		@LASTDATE = N'2/23/2013',
		@SELECTEDDATE = N'2/20/2013',
		@SortColumn = 0
