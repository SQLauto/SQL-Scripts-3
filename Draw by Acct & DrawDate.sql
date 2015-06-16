declare @acctcode nvarchar(25)
declare @startDate datetime
declare @endDate datetime
declare @pub nvarchar(5)

set @acctcode = '21600061'
set @startDate = null
set @endDate = null
set @pub = 'TREE'

select a.acctcode, pubshortname, d.drawamount, d.drawdate
	--, dh.changeddate
	--, fr.frname, typ.changetypedescription
	--, olddraw, newdraw, dh.userid
	--, frreturntargetpercent, frbasedonweeks, frexcludeexceptiondates, frdrophighlow, frignorezero, fractive, frowner
--	, a.accountid, d.publicationid
from scdraws d
--join scdrawhistory dh
--	on d.drawid = dh.drawid
join scaccounts a
	on d.accountid = a.accountid
join nspublications p
	on d.publicationid = p.publicationid
--join dd_nschangetypes typ
--	on dh.changetypeid = typ.changetypeid
--join scforecastrules fr
--	on dh.forecastruleid = fr.forecastruleid
where (
		( @acctcode is null and a.AccountID > 0 )
		or 
		( @acctcode is not null and a.AcctCode = @acctcode )
	)
and (
		( ( @startDate is null and @endDate is null ) and d.DrawID > 0 )
		or 
		( ( @startDate is not null and @endDate is not null ) and d.drawdate between @startDate and @endDate )
	)
and (
	 ( @pub is null and p.PublicationID > 0 )
	 or
	 ( @pub is not null and p.PubShortName = @pub )
	)	
and d.DrawWeekday = 1	
order by d.DrawDate desc
	--, dh.changeddate desc