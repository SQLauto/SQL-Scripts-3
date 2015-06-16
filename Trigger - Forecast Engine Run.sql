-- =============================================
-- Create trigger basic template(After trigger)
-- =============================================
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'ForecastEngineRun' 
	   AND 	  type = 'TR')
    DROP TRIGGER ForecastEngineRun
GO

CREATE TRIGGER ForecastEngineRun
ON [dbo].[merc_ControlPanel]
FOR UPDATE 
AS 
BEGIN
	if exists ( 
		select 1
		from merc_ControlPanel
		where AppLayer = 'ForecastEngine'
		and AttributeName = 'EngineRequest'
		and AttributeValue = 'True'
	)
	begin
		declare @msg varchar(4000)
		declare @name varchar(50)
		declare @value varchar(50)

		set @msg = 'Forecast Engine requested to run with parameters: '

		declare @date datetime
		set @date = getdate()
		
		declare params_cursor cursor
		for 
			select AttributeName, AttributeValue
			from merc_ControlPanel
			where AppLayer = 'ForecastEngine'

		open params_cursor
		fetch next from params_cursor into @name, @value
		while @@fetch_status = 0
		begin
			set @msg = @msg + '''' + @name + ''': ' + isnull(@value, 'NULL') + ' '

			fetch next from params_cursor into @name, @value
		end 

		close params_cursor
		deallocate params_cursor
		
		exec nsMessages_INSERTNOTALREADY 
			@nsSubject='Forecast Engine'
			, @nsMessageText=@msg
			, @nsFromId = 8
			, @nsToId = 0
			, @nsGroupId = 2
			, @nsTime = @date
			, @nsPriorityId = 2 	--|  Normal
			, @nsStatusId = 3  	--|
			, @nsTypeId = 1		--|  Memo 
			, @nsStateId = 1
			, @nsCompareTime = @date
			, @nsAccountId = 0
	end	
END
GO

