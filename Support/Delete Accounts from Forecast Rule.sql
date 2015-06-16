begin tran

select a.acctcode, a.acctactive
from scforecastrules fr
join scforecastaccountrules far
	on fr.forecastruleid = far.forecastruleid
	and fr.publicationid = far.publicationid
join scaccounts a
	on far.accountid = a.accountid
where frname = 'Daily Rack (WEST, PARK)'


delete scforecastaccountrules
from scforecastrules fr
join scforecastaccountrules far
	on fr.forecastruleid = far.forecastruleid
	and fr.publicationid = far.publicationid
join scaccounts a
	on far.accountid = a.accountid
where frname = 'Daily Rack (WEST, PARK)'

commit tran