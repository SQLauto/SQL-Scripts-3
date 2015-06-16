begin tran

delete from SystemMessageLog

delete from nsLogSystem
dbcc checkident('nsLogSystem', reseed, 0)
/*
delete from nscompany
dbcc checkident('nsCompany', reseed, 0)

delete from nsPublications
dbcc checkident('nsPublications', reseed, 0)

delete from deDistributionCenter
dbcc checkident('deDistributionCenter', reseed, 0)

delete from deZone
dbcc checkident('deZone', reseed, 0)

delete from deDistrict
dbcc checkident('deDistrict', reseed, 0)

delete from deScheduleDetail
dbcc checkident('deScheduleDetail', reseed, 0)

delete from deSchedule
dbcc checkident('deSchedule', reseed, 0)

delete from deMessageTarget
dbcc checkident('deMessageTarget', reseed, 0)
*/
delete from deMessageStatusHistoryArchive

delete from deMessageStatusHistory
dbcc checkident('deMessageStatusHistory', reseed, 0)

delete from deMessageArchive

delete from deMessage
dbcc checkident('deMessage', reseed, 0)

delete from deMessageLoad
dbcc checkident('deMessageLoad', reseed, 0)
/*
delete from dd_deMessageType
delete from dd_deMessageReason

delete from dd_deMessageStatusTransition
dbcc checkident('dd_deMessageStatusTransition', reseed, 0)

delete from deRouteListStage

delete from deRouteListToday
dbcc checkident('deRouteListToday', reseed, 0)

delete from deRouteListAll
dbcc checkident('deRouteListAll', reseed, 0)

delete from sdmconfig..UserGroups
where userid not in (1,2,3)

delete from sdmconfig..UserGroups
where groupid <> 1

delete from sdmconfig..Logins
where userid not in (1,2,3)

delete from sdmconfig..Users
where userid not in (1,2,3)
dbcc checkident ('sdmconfig..users', reseed, 4)
*/

rollback tran