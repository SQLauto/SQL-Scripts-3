select dd.changetypename, d.drawdate, d.drawamount, d.*
from scdraws d
join dd_nschangetypes dd
	on d.lastchangetype = dd.changetypeid
where d.accountid = ( select accountid from scaccounts where acctcode = '2276012' )
order by drawdate desc