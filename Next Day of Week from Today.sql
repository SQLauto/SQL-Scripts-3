
declare @datetime datetime
set @datetime = getdate()

select DATEADD(dd,(DATEDIFF(dd, 0, @DateTime) / 7 * 7) + 7, 0)
