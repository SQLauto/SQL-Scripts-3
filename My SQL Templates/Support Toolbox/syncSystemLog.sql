select sltimestamp, logmessage
from syncsystemlog
where datediff(d, sltimestamp, getdate()) = 0
order by sltimestamp desc