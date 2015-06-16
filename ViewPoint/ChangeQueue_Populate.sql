--sp_helptext EDRListing_Update_25
--exec EDRListing_Update_25 2, 4, 203, 'lastname', 'firstname', 'title', 'dept', 'phone','fax','pager','email'

begin tran
use sdmdata

declare @userid int,
	@siteid int,
	@guid int,
	@Company as varchar(255),
	@Address as varchar(255),
	@LastName  as varchar(255),
	@FirstName as varchar(255),
	@Title as varchar(255),
	@Department as varchar(255),
	@ManagerID as varchar(255),
	@Group as varchar(255),
	@Phone as varchar(25),
	@CellPhone as varchar(255),
	@physicalDeliveryOfficeName as varchar(25),
	@HomePhone as varchar(15),
	@ICM as varchar(10),
	@Fax as varchar(255),
	@Pager as varchar(255),
	@Emergency as varchar(15)

select @userid = userid
from sdmconfig..users
--from mvisconfig..users
where username = 'GeoffreyS'

select @siteid = siteid
from sdmconfig..t2k_site
--from mvisconfig..t2k_site
where sitename = 'Microvision Employee Directory'

declare employee_cursor cursor
for
	select	SDM_GUID,
		SDM_Company,
		SDM_Address,
		SDM_LastName,
		SDM_FirstName,
		SDM_Title,
		SDM_Department,
		SDM_ManagerID,
		SDM_Group,
		SDM_Phone,
		SDM_CellPhone,
		SDM_physicalDeliveryOfficeName,
		SDM_HomePhone,
		SDM_ICM,
		SDM_Fax,
		SDM_Pager,
		SDM_Emergency
	from edremployees
	where sdm_group is not null

open employee_cursor
fetch next from employee_cursor into @guid, @Company, @Address, @LastName, @FirstName, @Title, @Department, @ManagerID, @Group, @Phone, @CellPhone, @physicalDeliveryOfficeName, @HomePhone, @ICM, @Fax, @Pager, @Emergency 

while @@fetch_status = 0
begin
	print 'exec EDRListing_Update_25 ' + cast(@userid as varchar(4)) + ', ' + cast(@siteid as varchar(4)) + ', ' 
		+ cast(@guid as varchar(4)) + ', ''' + isnull(@Company, '') + ''', ''' + isnull(@Address, '') + ''', ''' + isnull(@LastName, '') + ''', ''' + isnull(@FirstName, '') + ''', ''' + isnull(@Title, '') + ''', ''' + isnull(@Department, '') + ''', ''' + isnull(@ManagerID, '') + ''', ''' + isnull(@Group, '') + ''', ''' + isnull(@Phone, '') + ''', ''' + isnull(@CellPhone, '') + ''', ''' + isnull(@physicalDeliveryOfficeName, '') + ''', ''' + isnull(@HomePhone, '') + ''', ''' + isnull(@ICM, '') + ''', ''' + isnull(@Fax, '') + ''', ''' + isnull(@Pager, '') + ''', ''' + isnull(@Emergency, '') + ''''

fetch next from employee_cursor into @guid, @Company, @Address, @LastName, @FirstName, @Title, @Department, @ManagerID, @Group, @Phone, @CellPhone, @physicalDeliveryOfficeName, @HomePhone, @ICM, @Fax, @Pager, @Emergency 
end

close employee_cursor
deallocate employee_cursor

rollback tran

