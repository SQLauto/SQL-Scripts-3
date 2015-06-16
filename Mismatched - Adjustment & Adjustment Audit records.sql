

SELECT d.DrawID, d.DrawDate, d.DrawAmount, d.AdjAmount, ca.AdjAuditValue as [Carried Adjustment], ca.AdjAuditDate
	, d.AdjAdminAmount, aa.AdjAuditValue as [Admin Adjustment], aa.AdjAuditDate
	, ca.AdjAuditUserId, aa.AdjAuditUserId
FROM scDraws d
left join (	
	select da.*
	from scDrawAdjustmentsAudit da
	join (
		select drawid, MAX(DrawAdjustmentAuditId) as DrawAdjustmentAuditId
		from scDrawAdjustmentsAudit
		where AdjAuditField = 'Carrier Adjustment'
		group by DrawId
		) lastAdminAdj
		on da.DrawId = lastAdminAdj.DrawId
		and da.DrawAdjustmentAuditId = lastAdminAdj.DrawAdjustmentAuditId
	) ca
	on d.DrawID = ca.DrawId
left join (	
	select da.*
	from scDrawAdjustmentsAudit da
	join (
		select drawid, MAX(DrawAdjustmentAuditId) as DrawAdjustmentAuditId
		from scDrawAdjustmentsAudit
		where AdjAuditField = 'Admin Amount'
		group by DrawId
		) lastAdminAdj
		on da.DrawId = lastAdminAdj.DrawId
		and da.DrawAdjustmentAuditId = lastAdminAdj.DrawAdjustmentAuditId
	) aa
	on d.DrawID = aa.DrawId	
where (
	d.AdjAmount <> ca.AdjAuditValue
	or d.AdjAdminAmount <> aa.AdjAuditValue 
	)
and d.DrawDate > '12/1/2013'