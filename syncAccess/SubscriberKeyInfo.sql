/*
Email address:  mjoanmorrison10@yahoo.com

 

BLOX UUID:        cfcdc7de-c660-11e3-acda-10604b9f0f84

Sync UUID:        cfcdc7de-c660-11e3-acda-10604b9f0f84

 

Sync User Name:            press100648443

BLOX User Name:            mmorrison10
*/

select ss.*, ssk.*
from seMemberships m
join OAuthMembership oa
	on m.UserID = oa.id
join SubscriberSources ss
	on m.UserID = ss.UserId
join SubscriberSourceKeys ssk
	on ssk.SubscriberSourceId = ss.SubscriberSourceId
where email	 = 'mjoanmorrison10@yahoo.com'
