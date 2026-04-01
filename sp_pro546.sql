-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro546;
create procedure sp_pro546()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _monto_pendiente	dec(16,2);
define _letra_residuo	dec(16,2);
define _monto_residuo	dec(16,2);
define _monto_pagado	dec(16,2);
define _total_pen		dec(16,2);
define _monto_pen		dec(16,2);
define _monto_letra		dec(16,2);
define _monto_bruto		dec(16,2);
define _residuo			dec(16,2);
define _resto           dec(16,2);
define _cnt_no_pagada	smallint;
define _letra_pagada	smallint;
define _no_letra_c		smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _pagada			smallint;
define _error_isam		integer;
define _error			integer;
define _min_fecha_venc	date;
define _max_fecha_venc	date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob346a.trc";
--trace on;
foreach with hold
	select distinct l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2014'))
	  --from emiletra
	 order by no_documento

	begin work;
	
	select min(fecha_vencimiento),
		   max(fecha_vencimiento)
	  into _min_fecha_venc,
		   _max_fecha_venc
	  from emiletra
	 where no_documento = _no_documento
	   and monto_pen > 0
	   and monto_letra <> 0;

	select count(*)
	  into _pagada
	  from emiletra
	 where no_documento = _no_documento
	   and fecha_vencimiento between _min_fecha_venc and _max_fecha_venc
	   and pagada = 1
	   and monto_letra <> 0;

	if _pagada is null then
		let _pagada = 0;
	end if

	if _pagada <> 0 then
		{call sp_pro544(_no_documento) returning _error,_error_desc;
		
		if _error <> 0 then
			return _error,_error_desc;
		else}
			return 1,_no_documento with resume;
		--end if
	end if	
	
	commit work;
end foreach

--return 0,'Actualización Exitosa';
end
end procedure;