
begin tran

insert into scaccountforecastrules
select 1, 1, a.accountid, 3, 3, 119, 0, 0, 0, 1
from scaccounts a
left join scaccountforecastrules afr
on a.accountid = afr.accountid
	and afr.forecastruletypeid  = ( 
		select forecastruletypeid 
		from dd_scforecastruletypes 
		where forecastrulename = 'Closed' 
		)
where a.acctcode like 'hs%'
and afr.accountid is null

select *
from scaccountforecastrules
where accountid in (
	select accountid
	from scaccounts
	where acctcode like 'hs%'
	)
and forecastruletypeid  = ( 
	select forecastruletypeid 
	from dd_scforecastruletypes 
	where forecastrulename = 'Closed' 
	)

commit tran