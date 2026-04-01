-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas113;

create procedure sp_cas113(a_cod_campana char (10))
returning	integer,
			char(100);

define _no_documento	char(21);
define _no_poliza		char(10);
define _nueva_renov		char(1);
define _pagos			dec(16,2);
define _error			smallint;
define _cnt				integer;

on exception set _error
	return _error, "Error al Ingresar los Registro";
end exception  

--set debug file to "sp_cas113.trc";
--trace on;

set isolation to dirty read;

select count(*)
  into _cnt
  from campoliza
 where cod_campana = a_cod_campana;

if _cnt is null then
	let _cnt = 0;
end if

foreach
	select no_documento
	  into _no_documento
	  from campoliza
	 where cod_campana = a_cod_campana

	call sp_sis21(_no_documento) returning _no_poliza;

	select nueva_renov
	  into _nueva_renov
	  from emipomae
	 where no_poliza = _no_poliza;

	if _nueva_renov = 'N' then
		select sum(monto)
		  into _pagos
		  from cobredet
		 where no_poliza = _no_poliza
		   and tipo_mov in ('P','N');

		if _pagos is null then
			let _pagos = 0.00;
		end if

		if _pagos <> 0.00 then
			delete from campoliza
			 where no_documento = _no_documento;
		end if
	else
		--delete from campoliza	 where no_documento = _no_documento;
        select sum(monto)
		  into _pagos
		  from cobredet
		 where no_poliza = _no_poliza
		   and tipo_mov in ('P','N');

		if _pagos is null then
			let _pagos = 0.00;
		end if

		if _pagos <> 0.00 then
			delete from campoliza
			 where no_documento = _no_documento;
		end if		
	end if
end foreach
end procedure;