

begin tran

declare @cat nvarchar(5)
set @cat = 'USAT'

delete scAccountsCategories
from scAccountsCategories ac
join dd_scAccountCategories dd
	on ac.CategoryID = dd.CategoryID
where CatShortName = @cat
	
delete dd_scAccountCategories
where CatShortName = @cat


commit tran