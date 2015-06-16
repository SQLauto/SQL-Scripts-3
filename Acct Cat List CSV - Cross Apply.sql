
declare @acctCategories table ( AccountId int, CatShortName nvarchar(5) )

insert into @acctCategories
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

	
/*
SELECT DISTINCT AccountId,
  STUFF((SELECT ', ' + cast(CatShortName as varchar(5))
         from @acctCategories ac1
         where ac.AccountId = ac1.AccountId
         group by AccountId, CatShortName
         order by CatShortName
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'') catCSV
from @acctCategories ac
*/

SELECT AccountId
  , LEFT(catCSV , LEN(catCSV)-1) catCSV
FROM @acctCategories p
CROSS APPLY
(
    SELECT cast(CatShortName as varchar(5)) + ','
    FROM @acctCategories m
    WHERE p.AccountId = m.AccountId
    FOR XML PATH('')
) m (catCSV)
group by AccountId, catCSV