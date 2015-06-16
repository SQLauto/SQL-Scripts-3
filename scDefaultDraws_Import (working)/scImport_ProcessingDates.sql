IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[import_ProcessingDates]') AND type in (N'U'))
DROP TABLE [dbo].[import_ProcessingDates]
GO

CREATE TABLE [dbo].[import_ProcessingDates](
	  [DrawDate]	[datetime]
	, [DrawWeekday]	[int]
	constraint pk_import_ProcessingDates primary key clustered ( [DrawDate], [DrawWeekday] )
) ON [PRIMARY]

GO

insert into dbo.import_ProcessingDates
select distinct drawdate, datepart(dw, drawdate)
from scManifestLoad_View
union 
select distinct drawdate, datepart(dw, drawdate)
from scManifestLoad_View