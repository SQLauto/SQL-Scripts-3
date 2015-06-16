begin tran

use nsdb

declare @srcuser varchar(25)
declare @tgtuser varchar(25)

set @srcuser = 'admin@singlecopy.com'
set @tgtuser = 'seatac@singlecopy.com'

select userid, email, password
from logins
where email in ( @srcuser, @tgtuser )

update logins
set password = ( select password from logins where email = @srcuser )
where email = @tgtuser

select userid, email, password
from logins
where email in ( @srcuser, @tgtuser )

commit tran