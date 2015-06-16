truncate table scGateway_Get_Returns01File_ResultsToTable 

create table scGateway_Get_Returns01File_ResultsToTable (
	Route_Unit	varchar(	20	)
,	VendorNumber	varchar(	20	)
,	VendorModifier	varchar(	3	)
,	PubID	varchar(	5	)
,	Edition	varchar(	2	)
,	Issue	varchar(	8	)
,	PubType	varchar(	1	)
,	ExpDraw	varchar(	5	)
,	Cost	varchar(	13	)
,	QtyDelivered	varchar(	5	)
,	QtyReturned	varchar(	5	)
,	QtyPrevReturn	varchar(	5	)
,	ItemStatus	varchar(	1	)
,	InvoiceNumber	varchar(	20	)
,	ReturnsAllowed	varchar(	1	)
,	DayOfWeek	varchar(	1	)
,	Week	varchar(	1	)
,	DrawID	varchar(	8	)
,	Spare	varchar(	12	)
)
insert into scGateway_Get_Returns01File_ResultsToTable
exec scGateway_Get_Returns01File_TEST '2/5/2015'

