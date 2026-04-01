drop procedure sp_sis339;

create procedure "informix".sp_sis339()
returning char(30),
          char(4),
          integer,
		  char(32);

define _tabname		char(30);
define _rowidlk		integer;
define _type		char(4);
define _owner		integer;
define _type_desc	char(50);
define _username	char(32);
define _pid			integer;

--SET DEBUG FILE TO "sp_sis83.trc";
--TRACE ON;


set isolation to dirty read;

foreach
 select k.tabname[1,30], k.type, k.owner, s.username
   into _tabname, _type, _owner, _username
  from sysmaster:sysdatabases d, sysmaster:syslocks k, sysmaster:syssessions s
 where d.name = "deivid"
   and d.rowid = k.rowidlk
   and k.owner = s.sid
  --and k.tabname like "%cliclien%"
  -- and k.type = "X"
	  
	return _tabname,
	       _type,
	       _owner,
		   _username  
	with resume;

end foreach

end procedure