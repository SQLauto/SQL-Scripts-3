/*
	Auto-run the InsertDraw sproc for a range of dates...
*/
SET Nocount On
Declare @start	datetime,
	@days	int,
	@cur	datetime

-- Set these vars to control the date range...
Set @start = getdate()		-- Start date
Set @days  = 9					-- # of days 'back' from start date


while @days >= 0
begin
	Set @cur = dateadd(d, -1 * @days, @start)

	exec scInsertDraw @cur	

	Set @days = @days - 1
end

print 'done'

Set NoCount Off

