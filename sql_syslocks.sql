select tabname[1,30], rowidlk, type, owner
from syslocks
where dbsname = 'deivid' and type = 'X'
order by tabname[1,30] desc, 2;
