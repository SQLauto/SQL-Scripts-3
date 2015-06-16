begin tran

/*
This script will create a return and adjustment record for each draw record in the system for today's date.
*/

set nocount on

declare @date datetime

set @date = getdate()

declare @companyid int
	, @distributioncenterid int
	, @accountid int
	, @publicationid int
	, @drawweekday int
	, @drawid int
	, @drawamount int
	, @retamount int
	, @adjamount int

declare draw_cursor cursor
for
	select companyid, distributioncenterid, accountid, publicationid, drawweekday, drawid, drawamount
	from scdraws
	where datediff(d, drawdate, @date) = 0

open draw_cursor
fetch next from draw_cursor into @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, @drawamount

while @@fetch_status = 0
begin
	--Determine random return and adj amount
	if @drawamount <> 0
	begin 
		set @retamount = right( rand( datepart(ms,getdate() ) ), 1 )
		if @retamount > @drawamount
		begin 
			set @retamount = right( rand( datepart(ms,getdate() ) ), 1 )
		end

		set @adjamount = cast( right( rand( datepart(ms,getdate() ) ), 1 ) as int ) - cast( right( rand( datepart(ms,getdate() ) ), 1 ) as int )
	end
	else
	begin
		set @retamount = 0
	end

if not exists (
	select *
	from scdrawadjustments
	where companyid = @companyid
		and distributioncenterid = @distributioncenterid
		and accountid = @accountid
		and publicationid = @publicationid
		and drawweekday = @drawweekday
		and drawid = @drawid
		and datediff(d, adjeffectivedate, @date) = 0
	)
begin
	insert into scdrawadjustments (
		companyid
		,distributioncenterid
		,accountid
		,publicationid
		,drawweekday
		,drawid
		,drawadjustmentid
		,adjentrydate
		,adjeffectivedate
		,adjamount
		)
	select @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, 
		1, @date, @date, @adjamount
end

if not exists (
	select *
	from screturns
	where companyid = @companyid
		and distributioncenterid = @distributioncenterid
		and accountid = @accountid
		and publicationid = @publicationid
		and drawweekday = @drawweekday
		and drawid = @drawid
		and datediff(d, reteffectivedate, @date ) = 0
	)
begin
	insert into screturns (
		companyid
		,distributioncenterid
		,accountid
		,publicationid
		,drawweekday
		,drawid
		,returnid
		,retentrydate
		,reteffectivedate
		,retamount
		)
	select @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, 
		1, @date, @date, @retamount
end

fetch next from draw_cursor into @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, @drawamount
end

close draw_cursor
deallocate draw_cursor

select drw.drawid, drawamount, retamount, adjamount
from scdraws drw
join screturns ret
	on drw.drawid = ret.drawid
join scdrawadjustments adj
	on drw.drawid = adj.drawid
where datediff(d, drawdate, @date) = 0

commit tran