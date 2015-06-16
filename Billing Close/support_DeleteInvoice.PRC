IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_DeleteInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_DeleteInvoice]
GO


                
CREATE PROCEDURE [dbo].[support_DeleteInvoice]
	@invoiceNumber	nvarchar(50)
AS
/*=========================================================
	dbo.support_DeleteInvoice
	
	Deletes *all* invoice-related data for the given billing
	period.
	
	Note: Only billing periods that were cancelled or are
	in an error state can have invoices deleted

	It is assumed that this procedure is called from code
	running in a TransactionScope (no transactional support
	is built in here)

	$History: /SingleCopy/Trunk/Database/Scripts/Sprocs/dbo.support_DeleteInvoice.prc $
-- 
-- ****************** Version 1 ****************** 
-- User: robcom   Date: 2010-06-02   Time: 13:34:24-07:00 
-- Updated in: /SingleCopy/Trunk/Database/Scripts/Sprocs 
-- Case 13583 -- Missed checkin with previous batches. 
=========================================================*/
BEGIN
	SET NOCOUNT ON
	
	----------------------------------------------------
	--	Hold a list of items to be deleted
	----------------------------------------------------
	CREATE TABLE #invoicesToDelete
	(
		InvoiceId	INT	PRIMARY KEY
	)

	
	INSERT	INTO #invoicesToDelete( InvoiceId )
	select InvoiceId
	from scInvoiceMasters
	where InvoiceNumber = @invoiceNumber

	PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' invoices selected for delete'

	----------------------------------------------------
	--	Delete ARAccountBalances entries and links back
	--	to invoice masters
	----------------------------------------------------
	SELECT	AB.ARAccountBalanceId INTO #ABtoDelete
	FROM	dbo.scARAccountBalances AB
	JOIN	dbo.scInvoiceMastersARAccountBalances IMAB
		ON	AB.ARAccountBalanceId = IMAB.ARAccountBalanceId
	JOIN	#invoicesToDelete ITD
		ON	ITD.InvoiceId = IMAB.InvoiceId

	DELETE	IMAB
	FROM	dbo.scInvoiceMastersARAccountBalances IMAB
	JOIN	#invoicesToDelete ITD ON IMAB.InvoiceId = ITD.InvoiceId

	DELETE	AB
	FROM	dbo.scARAccountBalances AB
	JOIN	#ABtoDelete ABTD ON ABTD.ARAccountBalanceId = AB.ARAccountBalanceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' AR Balances removed'

	DROP TABLE #ABtoDelete

	----------------------------------------------------
	--	Delete Product-related line item details
	----------------------------------------------------
	DELETE	PLD
	FROM	dbo.scProductLineItemDetails PLD
	JOIN	dbo.scInvoiceLineItems LI 
		ON LI.InvoiceLineItemId = PLD.InvoiceLineItemId
	JOIN	#invoicesToDelete ITD 
		ON LI.InvoiceId = ITD.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Product Line Item Details removed'
	
	----------------------------------------------------
	--	Delete Non-product-related line item details
	----------------------------------------------------	
	DELETE	NPLD
	FROM	dbo.scNonProductLineItemDetails NPLD
	JOIN	dbo.scInvoiceLineItems LI 
		ON LI.InvoiceLineItemId = NPLD.InvoiceLineItemId
	JOIN	#invoicesToDelete ITD 
		ON LI.InvoiceId = ITD.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Non-Product Line Item Details removed'
	
	----------------------------------------------------
	--	Delete the invoice line items
	----------------------------------------------------	
	DELETE	LI
	FROM	dbo.scInvoiceLineItems LI 
	JOIN	#invoicesToDelete ITD 
		ON LI.InvoiceId = ITD.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Line Items removed'

	----------------------------------------------------
	--	Delete displayed payment information
	----------------------------------------------------
	DELETE	IMPD
	FROM	dbo.scInvoiceMastersPaymentsDisplay IMPD
	JOIN	#invoicesToDelete ITD
		ON ITD.InvoiceId = IMPD.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Payment Display records removed'
	
	----------------------------------------------------
	--	Delete Invoice Header data
	----------------------------------------------------	
	DELETE	IH
	FROM	dbo.scInvoiceHeaders IH	
	JOIN	#invoicesToDelete ITD 
		ON ITD.InvoiceId = IH.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Invoice Headers removed'
	
	----------------------------------------------------
	--	Last, delete the invoice master records themselves
	----------------------------------------------------	
	DELETE	IM
	FROM	dbo.scInvoiceMasters IM	
	JOIN	#invoicesToDelete ITD ON IM.InvoiceId = ITD.InvoiceId

	--PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' Invoices Removed'

	DROP TABLE #invoicesToDelete


	SET NOCOUNT OFF
END
