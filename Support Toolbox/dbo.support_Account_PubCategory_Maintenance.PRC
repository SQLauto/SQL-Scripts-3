IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_Account_PubCategory_Maintenance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_Account_PubCategory_Maintenance]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_Account_PubCategory_Maintenance]
AS
/*
	[dbo].[support_Account_PubCategory_Maintenance]
	
	$History:  $
*/
BEGIN
	set nocount on
	
	declare @cnt int
	declare @msg nvarchar(1024)
	
	
	declare @maxId int
	select @maxId = max(CategoryId)
	from dd_scAccountCategories

	--|  Add new "Pub Categories"
	insert into dd_scAccountCategories ( CompanyId, DistributionCenterID, CategoryId, CatShortName, CatName, CatDescription
		, CatActive, Catimported, System 
		)
	select 1, 1
		, @maxId + row_number() over ( order by p.PubShortName )
		, p.PubShortName
		, 'Pub: ' + p.PubName 
		, 'Category added on '  + convert(varchar, getdate(), 1)
		, 1, 1, 0
	from nsPublications p
	left join dd_scAccountCategories dd
		on p.PubShortName = dd.CatShortName
	where dd.CategoryId is null	
	set @cnt = @@rowcount
	
	set @msg = 'Added ' + cast(@cnt as nvarchar) + ' categories for new publications.'
    print @msg
    exec nsSystemLog_Insert 2, 0, @msg

	--|  Associate Accounts with Pub Categories
	;with cteAccountsPubCats as
	(
		select a.AccountId, ac.CategoryId
		from scAccounts a
		join scAccountsPubs ap
			on a.AccountId = ap.AccountId
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		join dd_scAccountCategories ac
			on p.PubShortName = ac.CatShortName	
	)
	insert into scAccountsCategories (companyid, distributioncenterid, AccountId, CategoryId)
	select 1, 1, cte.AccountId, cte.CategoryId
	from cteAccountsPubCats cte
	left join scAccountsCategories ac
		on cte.AccountId = ac.AccountId
		and cte.CategoryId = ac.CategoryId
	where ac.CompanyID is null
	
	set @msg = 'Associated ' + cast(@@rowcount as nvarchar) + ' Accounts  with Publication Categories'
    print @msg
    exec nsSystemLog_Insert 2, 0, @msg

	--|  Remove any obsolete Pub Categories
	delete scAccountsCategories
	from scAccountsCategories ac
	left join (
		select a.AccountId, dd.CategoryId, p.PubShortName, dd.CatShortName
		from scAccounts a
		join scAccountsPubs ap
			on a.AccountId = ap.AccountId
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		join dd_scAccountCategories dd
			on p.PubShortName = dd.CatShortName
		where dd.CatName like 'Pub%'
		) kg
		on ac.AccountId = kg.AccountId
		and ac.CategoryId = kg.CategoryId
	join dd_scAccountCategories dd
		on ac.CategoryId = dd.CategoryId
	where dd.CatName like 'Pub%'
	and kg.CategoryId is null

	set @msg = 'Removed obsolete Pub Category associations from ' + cast(@@rowcount as nvarchar) + ' Accounts.'
    print @msg
    exec nsSystemLog_Insert 2, 0, @msg


	--|  Remove 'NONE' designation from Accounts with more than one Category
	delete from scAccountsCategories
	where CategoryId = ( select CategoryId from dd_scAccountCategories where CatName = 'NONE' )
	and AccountId in ( 
		select AccountId
		from scAccountsCategories
		group by AccountId
		having count(*) > 1
		)
	print 'Removed ''NONE'' category designation from ' + cast(@@rowcount as varchar) + ' Accounts.'
END
GO	