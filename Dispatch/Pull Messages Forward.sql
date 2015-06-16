begin tran

declare @maxId int
select @maxId = max(MessageId)
from demessage

insert into deMessage (AddressConcat, ApartmentNumber, City, Company, DistributionCenter, District, ExtensionAttribute1, ExtensionAttribute2, ExtensionAttribute3, ExtensionAttribute4, ExtensionAttribute5, HouseNumber, MessageDateTime, MessageReason, MessageStatusID, MessageStatusDateTime, MessageTargetID, MessageText, MessageType, Publication, Route, SpecialInstructions, State, StreetDirection, StreetName, StreetType, SubscriberAccountNumber, SubscriberName, SubscriberPhone, Zip, Zone, SDM_IsActive, SDM_LastUpdated, SDM_samAccountName, TRANS_NUM)
select top 10
	AddressConcat, ApartmentNumber, City, Company, DistributionCenter, District, ExtensionAttribute1, ExtensionAttribute2, ExtensionAttribute3, ExtensionAttribute4, ExtensionAttribute5, HouseNumber
	--, @maxId + n.N
	, dateadd(d, datediff(d, MessageDateTime, getdate()), messagedatetime )
	, MessageReason, MessageStatusID, MessageStatusDateTime, MessageTargetID, MessageText, MessageType, Publication, Route, SpecialInstructions, State, StreetDirection, StreetName, StreetType, SubscriberAccountNumber, SubscriberName, SubscriberPhone, Zip, Zone, SDM_IsActive, SDM_LastUpdated, SDM_samAccountName
	, TRANS_NUM
from deMessage m
order by MessageDateTime
/*


select datediff(d, MessageDateTime, getdate()), messagedatetime
	, dateadd(d, datediff(d, MessageDateTime, getdate()), messagedatetime )
from demessage

*/

commit tran