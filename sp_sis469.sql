--Procedure para consultar el consumo de CPU 
--Amado 17-02-2023
drop procedure sp_sis469;

create procedure "informix".sp_sis469()
returning integer as sid,
          char(8) as username,
		  integer as uid,
		  integer as pid,
		  varchar(30) as hostname,
		  integer as tid,
		  varchar(30) as name,
		  varchar(15) as statedesc,
		  varchar(30) as statedetail,
		  char(255) as sqs_statement,
		  varchar(50) as cpu_time,
		  decimal(20,10) as cpu_time_int;

define _sid         integer;
define _username    char(8);
define _uid         integer;
define _pid         integer;
define _hostname    varchar(30);
define _tid 		integer;
define _name  		varchar(30);
define _statedesc   varchar(15);
define _statedetail varchar(30);
define _sqs_statement char(255);
define _cpu_time    varchar(30);
define _cpu_time_int    decimal(20,10);

--SET DEBUG FILE TO "sp_sis469.trc";
--TRACE ON;


set isolation to dirty read;

foreach
	SELECT s.sid, 
	       s.username, 
		   s.uid, 
		   s.pid, 
		   s.hostname, 
		   t.tid,
		   t.name, 
		   t.statedesc, 
		   t.statedetail, 
		   q.sqs_statement, 
		   t.cpu_time
	  INTO _sid, 
	       _username, 
		   _uid, 
		   _pid, 
		   _hostname, 
		   _tid,
		   _name, 
		   _statedesc, 
		   _statedetail, 
		   _sqs_statement, 
		   _cpu_time_int
	  FROM sysmaster:syssessions s, sysmaster:systcblst t, sysmaster:sysrstcb r, sysmaster:syssqlstat q
     WHERE t.tid = r.tid 
	   AND s.sid = r.sid 
	   AND s.sid = q.sqs_sessionid
  ORDER BY t.cpu_time desc

	--let _cpu_time_int = _cpu_time;
	
	let _cpu_time = convertir_cpu_time(_cpu_time_int);
	
	return _sid, 
	       _username, 
		   _uid, 
		   _pid, 
		   _hostname, 
		   _tid,
		   _name, 
		   _statedesc, 
		   _statedetail, 
		   _sqs_statement, 
		   _cpu_time,
		   _cpu_time_int
		   with resume;

end foreach

end procedure