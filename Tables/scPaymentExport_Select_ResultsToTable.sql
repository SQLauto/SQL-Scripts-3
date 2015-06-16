

create table scPaymentExport_Select_ResultsToTable (
		ATName					nvarchar(50)
	,	ATDescription			nvarchar(128)
	,	AcctCode				nvarchar(20)	
	,	AcctName				nvarchar(50) 	
	,	Address					nvarchar(128)
	,	City 					nvarchar(50)
	,	StateProvince 			nvarchar(5)
	,	PostalCode 				nvarchar(15)
	,	Country 				nvarchar(50)
	,	Contact 				nvarchar(50)
	,	Phone 					nvarchar(50)
	,	Hours 					nvarchar(20)
	,	SpecialInstructions		nvarchar(256)
	,	Custom1 				nvarchar(50)
	,	Custom2 				nvarchar(50)
	,	Custom3 				nvarchar(50)
	,	Notes 					nvarchar(256)
	,	PaymentDate 			datetime
	,	PaymentAmount 			decimal(7,2)
	,	PaymentReference 		nvarchar(100)
	,	PaymentTypeCode 		nvarchar(10)
	,	PaymentTypeName 		nvarchar(100)
	,	PaymentMemo 			nvarchar(200)
	,	InvoiceDate 			datetime
	,	InvoiceNumber 			nvarchar(50)
	,	BillingPeriodBeginDate 	datetime
	,	BillingPeriodEndDate 	datetime
	,	InvoiceAmount 			decimal(7,2)
	,	InvoiceNote 			nvarchar(200)
	,	BillingAcctCode 		varchar(50)
	,	DocumentImage 			varbinary(max)
)

delete from scPaymentExport_Select_ResultsToTable

insert into scPaymentExport_Select_ResultsToTable
exec scPaymentExport_Select '12/7/2014', '12/15/2014', 1, 1