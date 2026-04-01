-- Procedimiento que actualiza todos los suspensos de una remesa generada por Pagos Externos.

-- Creado    : 26/07/2012 - Autor: Roman Gordon

-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob307;

create procedure "informix".sp_cob307(a_no_remesa char(10))
returning	smallint,
			char(100);


define _error_desc		char(100);
define _doc_suspenso	char(30);
define _no_recibo		char(10);
define _error_isam		smallint;
define _error_code		smallint;
define _secuencia		smallint;
define _cnt_for			smallint;


--set debug file to "sp_cob307.trc"; 
--trace on;                                                                

set isolation to dirty read;

begin
 
on exception set _error_code,_error_isam,_error_desc 
 	return _error_code, _error_desc;
end exception

foreach
	select no_recibo
	  into _no_recibo
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov = 'E'	   
	exit foreach;
end foreach

select secuencia
  into _secuencia
  from cobpaex3
 where no_recibo = _no_recibo;

for _cnt_for = 1 to _secuencia
	let _doc_suspenso     = trim(_no_recibo) || "-" || _cnt_for;

	update cobsuspe
	   set actualizado	= 1
	 where doc_suspenso	= _doc_suspenso;
end for
end
end procedure


	
