begin tran

select 
AddressConcat
,ApartmentNumber
,City
,Company
,DistributionCenter
,District
,ExtensionAttribute1
,ExtensionAttribute2
,ExtensionAttribute3
,ExtensionAttribute4
,ExtensionAttribute5
,ExtensionAttribute6
,ExtensionAttribute7
,ExtensionAttribute8
,ExtensionAttribute9
,ExtensionAttribute10
,HouseNumber
--,MessageID
,identity(int,1,1) as MessageID
,MessageDateTime
,MessageReason
,MessageStatusID
,MessageStatusDateTime
,MessageTargetID
,MessageText
,MessageType
,Publication
,Route
,SpecialInstructions
,State
,StreetDirection
,StreetName
,StreetType
,SubscriberAccountNumber
,SubscriberName
,SubscriberPhone
,Zip
,Zone
,SDM_IsActive
,SDM_LastUpdated
,SDM_samAccountName
into #demessage
from demessage
order by messagedatetime desc

truncate table demessage

--dbcc checkident('demessage', noreseed)

insert into demessage
(
AddressConcat
,ApartmentNumber
,City
,Company
,DistributionCenter
,District
,ExtensionAttribute1
,ExtensionAttribute2
,ExtensionAttribute3
,ExtensionAttribute4
,ExtensionAttribute5
,ExtensionAttribute6
,ExtensionAttribute7
,ExtensionAttribute8
,ExtensionAttribute9
,ExtensionAttribute10
,HouseNumber
--,MessageID
--,identity(int,1,1) as MessageID
,MessageDateTime
,MessageReason
,MessageStatusID
,MessageStatusDateTime
,MessageTargetID
,MessageText
,MessageType
,Publication
,Route
,SpecialInstructions
,State
,StreetDirection
,StreetName
,StreetType
,SubscriberAccountNumber
,SubscriberName
,SubscriberPhone
,Zip
,Zone
,SDM_IsActive
,SDM_LastUpdated
,SDM_samAccountName
)
select AddressConcat
,ApartmentNumber
,City
,Company
,DistributionCenter
,District
,ExtensionAttribute1
,ExtensionAttribute2
,ExtensionAttribute3
,ExtensionAttribute4
,ExtensionAttribute5
,ExtensionAttribute6
,ExtensionAttribute7
,ExtensionAttribute8
,ExtensionAttribute9
,ExtensionAttribute10
,HouseNumber
--,MessageID
--,identity(int,1,1) as MessageID
,MessageDateTime
,MessageReason
,MessageStatusID
,MessageStatusDateTime
,MessageTargetID
,MessageText
,MessageType
,Publication
,Route
,SpecialInstructions
,State
,StreetDirection
,StreetName
,StreetType
,SubscriberAccountNumber
,SubscriberName
,SubscriberPhone
,Zip
,Zone
,SDM_IsActive
,SDM_LastUpdated
,SDM_samAccountName
from #demessage
order by messagedatetime desc

drop table #demessage
	--select messageid, *
--from demessage

commit tran