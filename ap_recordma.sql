-- Procedure que llena los nuevos campos en recordma

-- Creado    : 03/10/2014 - Autor: Amado

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure ap_recordma;

create procedure ap_recordma() returning integer,
            char(100);

define _no_orden		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _no_tramite		char(10);
define _numrecla		char(18);
define _transaccion, _trans_pend char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_ttc11.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- 

foreach	with hold
 select no_orden,
        transaccion,
		trans_pend
   into	_no_orden,		
		_transaccion,
		_trans_pend		
   from	recordma

{ let _numrecla = null;
 let _no_tramite = null;
 let _no_reclamo = null;

{ select numrecla, no_reclamo, transaccion
   into _numrecla, _no_reclamo, _transaccion  
   from rectrmae
  where no_tranrec = _no_tranrec;

 select no_tramite
   into _no_tramite
   from recrcmae
  where no_reclamo = _no_reclamo; }

--if _numrecla is not null and trim(_numrecla) <> "" then 
if _trans_pend is null or trim(_trans_pend) = "" then
	update recordma
	   set trans_pend = _transaccion
	 where no_orden = _no_orden;
end if

end foreach

--}

end

return 0, "Actualizacion Exitosa";

end procedure
