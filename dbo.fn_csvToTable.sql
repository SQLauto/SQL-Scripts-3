Create Function dbo.fn_csvToTable (@csvlist varchar(3000))
returns @table table (columndata varchar(50))
as
begin
if right(@csvlist, 1) <> ','
select @csvlist = @csvlist + ','

declare	@pos	smallint,
@oldpos	smallint
select	@pos	= 1,
@oldpos = 1

while	@pos < len(@csvlist)
begin
select	@pos = charindex(',', @csvlist, @oldpos)
insert into @table
select	ltrim(rtrim(substring(@csvlist, @oldpos, @pos - @oldpos))) col001
select	@oldpos = @pos + 1
end

return
end