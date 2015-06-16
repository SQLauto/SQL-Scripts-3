SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[support_DeleteDraw_ByDrawDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[support_DeleteDraw_ByDrawDate]
GO

CREATE PROCEDURE [dbo].[support_DeleteDraw_ByDrawDate]
	@DrawDate datetime
AS

/*=========================================================
     support_DeleteDraw_ByDrawDate

		Deletes Draw and DrawHistory by Draw Date

==========================================================*/
BEGIN
	set nocount on

	select DrawId
	into #draws
	from scDraws
	where datediff(d, drawdate, @DrawDate) = 0
	print cast(@@rowcount as varchar) + ' records in scDrawDates for Draw Date ''' + convert(varchar, @DrawDate, 1) + ''''

	delete scDrawHistory 
	from scDrawHistory dh
	join #draws tmp
		on dh.DrawId = tmp.DrawId
	print cast(@@rowcount as varchar) + ' Draw History records deleted.'

	delete scDraws
	from scDraws d
	join #draws tmp
		on d.DrawId = tmp.DrawId
	print cast(@@rowcount as varchar) + ' Draw records deleted.'

	drop table #draws

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


/*
begin tran

exec support_DeleteDraw_ByDrawDate @DrawDate='11/1/2009'

commit tran
*/