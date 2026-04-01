--Procedimiento que verifica si alguna de las unidades de la póliza tiene facultativo
--Creado    : 23/03/2016 - Autor: Román Gordón
--SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis439;
create procedure sp_sis439(a_no_poliza char(10))
returning smallint;

define _no_unidad 		char(5);
define _cnt_facultativo	smallint;
define _no_cambio		smallint;
define _error			integer;

--set lock mode to wait;
set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	select count(*)
	  into _cnt_facultativo
	  from emireaco r, reacomae c
	 where r.cod_contrato = c.cod_contrato
	   and r.no_poliza = a_no_poliza
	   and r.no_unidad = _no_unidad
	   and r.no_cambio = _no_cambio
	   and c.tipo_contrato = 3
	   and r.porc_partic_prima <> 0;

	if _cnt_facultativo is null then
		let _cnt_facultativo = 0;
	end if
	
	if _cnt_facultativo > 0 then
		return 1;
	end if
end foreach

return 0;
end
end procedure;