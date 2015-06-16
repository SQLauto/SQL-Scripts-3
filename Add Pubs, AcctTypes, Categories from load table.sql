set nocount on

	declare @counter int

--|Import Publications
	declare @pubshortname nvarchar(5)
	declare @maxpubid int

	select @maxpubid = isnull(publicationid, 0) + 1
	from nspublications

	declare pub_cursor cursor
	for 
		select distinct publication
		from scmanifestload_view
		where publication not in (
			select pubshortname
			from nspublications
			)

	open pub_cursor 
	fetch next from pub_cursor into @pubshortname
	while @@fetch_status = 0
	begin
		set @counter = isnull(@counter, 0)
		
		exec dbo.nsPublications_INSERT @CompanyId=1
			, @DistributionCenterId=1
			, @PubName=@pubshortname
			, @PubDescription=@pubshortname
			, @PubShortName=@pubshortname
			, @PubFrequency=127
			, @PubCustom1=null
			, @PubCustom2=null
			, @PubCustom3=null
			, @PubActive=1
			, @TaxCategoryId=0
			, @PrintSortOrder=@counter
			, @PublicationId=@maxpubid
		set @maxpubid = @maxpubid + 1
		set @counter = isnull(@counter, 0) + 1

		fetch next from pub_cursor into @pubshortname
	end

	close pub_cursor
	deallocate pub_cursor

	print cast( isnull(@counter,0) as varchar) + ' Publications added'
	set @counter = 0

--|Import Account Types
	declare @atname varchar(50)
	declare @atdescription varchar(128)

	create table #tempAcctTypes ( 
		atname nvarchar(50)
		, atdescription nvarchar(128)
		)

	insert into #tempAcctTypes
	select distinct AcctType, AcctType
	from scManifestLoad_View
	where isnull(AcctType, '') <> ''

	declare at_curs cursor
	for 
		select distinct atname, atdescription
		from #tempAcctTypes

	open at_curs
	fetch next from at_curs into @atname, @atdescription
	while @@fetch_status = 0
	begin
		if not exists ( select 1 from dd_scaccounttypes where atname = @atname )
		begin
			insert into dd_scaccounttypes ( atname, atdescription, system)
			select @atname, @atdescription, 0
			set @counter = isnull(@counter, 0) + 1
		end

		fetch next from at_curs into @atname, @atdescription
	end
	close at_curs
	deallocate at_curs

	drop table #tempAcctTypes
	
	print cast(@counter as varchar) + ' AcctTypes added'
	set @counter = 0

--|Import Account Categories
	declare @catname varchar(50)
	declare @catdescription varchar(128)
	declare @catshortname varchar(5)
	declare @id int

	select @id = (select max(categoryid) from dd_scaccountcategories) + 1

	create table #tempAcctCategories ( 
		catname nvarchar(50)
		, catdescription nvarchar(128)
		, catshortname nvarchar(5)
		)
	insert into #tempAcctCategories
	select distinct acctcategory, acctcategory, left(acctcategory, 5)
	from scmanifestload_view
	where isnull(acctcategory,'') <> ''
	order by 1

	declare cat_curs cursor
	for 
		select distinct catname, catdescription, catshortname
		from #tempAcctCategories

	open cat_curs
	fetch next from cat_curs into @catname, @catdescription, @catshortname
	while @@fetch_status = 0
	begin
		if not exists ( select 1 from dd_scaccountcategories where catname = @catname or catshortname = @catshortname )
		begin
			insert into dd_scaccountcategories ( companyid, distributioncenterid, categoryid, catname, catdescription, catshortname, catactive, catimported, system)
			select 1, 1, @id, @catname, @catdescription, @catshortname, 1, 0, 0
		
			set @id = @id + 1
			set @counter = isnull(@counter, 0) + 1
		end

		fetch next from cat_curs into @catname, @catdescription, @catshortname
	end
	close cat_curs
	deallocate cat_curs

	drop table #tempAcctCategories

	print cast(@counter as varchar) + ' AcctCategories added'
	set @counter = 0
