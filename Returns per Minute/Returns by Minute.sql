Declare @startMinute smalldatetime Set @startMinute = '4/21/2015'
 Declare @endMinute smalldatetime Set @endMinute = '4/22/2015';
 
 ;With cteRetAudit as (
	SELECT MT.MTCode, retauditdate
		, ap.AccountPubID
	FROM scReturnsAudit RA
	JOIN SCACCOUNTSPUBS AP
		ON AP.AccountId = RA.AccountId
		and ap.PublicationId = ra.PublicationId
	JOIN scManifestSequenceItems MSI
		ON AP.AccountPubID = MSI.AccountPubId
	JOIN scManifestSequenceTemplates MST
		ON MSI.ManifestSequenceTemplateId = MST.ManifestSequenceTemplateId
	JOIN scManifestTemplates MT
		ON MST.ManifestTemplateId = MT.ManifestTemplateId
	
	where datediff(d, RetAuditDate, getdate()) = 0
	and ManifestTypeId = 1

 )
 , minuteList(aMinute) As 
 (Select @startMinute Union All
    Select dateadd(minute,1, aMinute)
    From minuteList
    Where aMinute < @endMinute)
 Select aMinute, Count(T.RetAuditDate)
 From minuteList ml 
 Left Join cteRetAudit T
      On DateAdd(minute, DateDiff(minute, 0, T.RetAuditDate), 0) = aMinute
 Group By aMinute
 Option (MaxRecursion 10000);