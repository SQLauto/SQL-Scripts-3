-- Post a message
--   From: admin@SingleCopy.com
--   To: (Everyone) group
--   Priority: High (3)
--   Status: None (3)
--   Type: Issue (2)
--   State: Unread (1)

declare @everyoneGroupId int
select @everyoneGroupId = GroupId from groups where GroupName = '(Everyone)'

declare @nowTime datetime, @compareTime datetime
set @nowTime = getDate()
set @compareTime = dateadd(Month, -2, @nowTime)
set @msg = cast(@totalDupCount as varchar) + ' duplicates found.  ' + cast(@counter as varchar) + ' records removed.'

--exec nsMessages_INSERTNOTALREADY 'Duplicates in import', @msg, 1, 0, 1, @nowTime, 3, 3, 2, 1, @compareTime
print @msg
