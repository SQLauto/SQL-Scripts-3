SELECT AccountId
	  , LEFT(catCSV , LEN(catCSV)-1) catCSV
FROM (
	select a.AccountId, c.CatShortName
	from (
		select AccountID
		from scAccountsCategories
		group by AccountID
		having count(*) > 1
		) a
	join scAccountsCategories ac
		on a.accountid = ac.accountid
	join dd_scAccountCategories c
		on ac.categoryid = c.categoryid
) p
CROSS APPLY
(
    SELECT cast(CatShortName as varchar(5)) + ','
    FROM (
		select a.AccountId, c.CatShortName
		from (
			select AccountID
			from scAccountsCategories
			group by AccountID
			having count(*) > 1
			) a
		join scAccountsCategories ac
			on a.accountid = ac.accountid
		join dd_scAccountCategories c
			on ac.categoryid = c.categoryid
	) m
    WHERE p.AccountId = m.AccountId
    FOR XML PATH('')
) m (catCSV)
group by AccountId, catCSV
union all 
select a.AccountId, c.CatShortName
from (
	select AccountID
	from scAccountsCategories
	group by AccountID
	having count(*) = 1
	) a
join scAccountsCategories ac
	on a.accountid = ac.accountid
join dd_scAccountCategories c
	on ac.categoryid = c.categoryid

order by 1