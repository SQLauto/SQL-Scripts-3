
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_FinalizeDateRange]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_FinalizeDateRange]
GO

CREATE PROCEDURE [dbo].[support_FinalizeDateRange]
	@begindate datetime
	, @enddate datetime
AS
begin 
	set nocount on

declare @msg varchar(200)


if @begindate > @enddate
begin
	set @msg = 'Invalid Begin/End Dates'
	print @msg
end	
else 
begin
	while @begindate <= @enddate
	begin
		set @msg = 'finalizing for ' + convert(varchar, @begindate, 1)
		print @msg
		exec syncSystemLog_Insert 2, 0, 1, @msg
	
		exec scmanifestsequence_finalizer @begindate
	
		set @begindate = dateadd(d, 1, @begindate)
	end

end
GO
