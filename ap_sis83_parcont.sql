drop procedure ap_sis83_parcont;
create procedure ap_sis83_parcont()
returning char(30),
          integer,
		  integer,
		  char(32),
		  integer,
		  char(50);

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
 select tabname[1,30], 
        rowidlk, 
        type, 
        owner
   into _tabname,
        _rowidlk,
		_type,
		_owner
   from sysmaster:syslocks
  where dbsname = "deivid" --'seguridad'  
    and tabname <> "sysdistrib"
	and tabname like 'parcont%'
  order by rowidlk, owner, tabname[1,30] desc

	if _type = "B" then 
		let _type_desc = "Byte lock"; 
	elif _type = "IS" then 
		let _type_desc = "Intent shared lock";
	elif _type = "S" then 
		let _type_desc = "Shared lock"; 
	elif _type = "XS" then 
		let _type_desc = "Shared key value held by a repeatable reader"; 
	elif _type = "U" then 
		let _type_desc = "Update lock"; 
	elif _type = "IX" then 
		let _type_desc = "Intent exclusive lock"; 
	elif _type = "SIX" then 
		let _type_desc = "Shared intent exclusive lock"; 
	elif _type = "X" then 
		let _type_desc = "Exclusive lock"; 
	elif _type = "XR" then 
		let _type_desc = "Exclusive key value held by a repeatable reader"; 
	end if

	select tty,
	       pid
	  into _username,
	       _pid
	  from sysmaster:syssessions
	 where sid = _owner;
	  
	return _tabname,
	       _rowidlk,
		   _owner,
		   _username,
		   _pid,
		   _type_desc
		   with resume;

end foreach

end procedure