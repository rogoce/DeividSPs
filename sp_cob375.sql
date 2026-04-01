-- Proceso ajusta de manera masiva los registros de emiletra que no concuerdan con el número de pagos de la póliza.
-- Creado    : 08/04/2015 - Autor: Román Gordón
drop procedure sp_cob375;
create procedure sp_cob375()
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(19);
define _nueva_renov			char(1);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _monto_cobrado		dec(16,2);
define _prima_bruta			dec(16,2);
define _monto_desc			dec(16,2);
define _monto_visa			dec(16,2);
define _monto_pen			dec(16,2);
define _porc_desc			dec(16,2);
define _cnt_letras			smallint;
define _existe_rev			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;

--set debug file to "sp_cob375.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

foreach
	select l.no_poliza,
		   e.no_pagos,
		   count(*)
	  into _no_poliza,
		   _no_pagos,
		   _cnt_letras
	  from emipomae e, emiletra l
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2015'))
	   and e.cod_ramo <> '018'
	 group by 1,2
	 having count(*) <> e.no_pagos

	select count(*)
	  into 
end foreach

end
end procedure;