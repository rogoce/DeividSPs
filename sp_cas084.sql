--Procedure que elimina las pólizas que han tenido un abono de las campañas de nulidad

drop procedure sp_cas084;
create procedure sp_cas084()
returning smallint;

define _no_documento	char(20);
define _cod_campana		char(10);
define _cod_pagador		char(10);
define _cnt_cliente		smallint;
define _cnt_letra		smallint;
define _error			smallint;

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

foreach
	select cod_campana,
		   cod_cliente,
		   no_documento
	  into _cod_campana,
		   _cod_pagador,
		   _no_documento
	  from caspoliza
	  where cod_campana in (select cod_campana from cascampana where tipo_campana = 3)
	    and no_documento in (select distinct e.no_documento
		  from emipomae e, emipouni u, emipocob c, prdprod p, emipoliza z, prdramo r
		 where e.no_poliza = c.no_poliza
		   and e.no_poliza = u.no_poliza
		   and u.no_unidad = c.no_unidad
		   and p.cod_producto = u.cod_producto
		   and z.no_documento = e.no_documento
		   and r.cod_ramo = e.cod_ramo
		   and e.cod_ramo in ('002','020','023')
		   and e.no_poliza in (select distinct e.no_poliza
								 from emipomae e, emipouni u, emipocob c
								where e.no_poliza = u.no_poliza
								  and u.no_poliza = c.no_poliza
								  and u.no_unidad = c.no_unidad
								  and e.cod_ramo in ('002','020')
								  and e.fecha_suscripcion >= '14/03/2017'
								  and e.actualizado = 1
								  and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'DAÑOS A LA PRO%')
								  and limite_1 <= 5000)
		   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'LESIONES%')
		   and limite_1 <= 5000 and limite_2 <= 10000)
	 --where cod_campana in (select cod_campana from cascampana where tipo_campana = 3)

	let _cnt_letra = 0;

	{select count(*)
	  into _cnt_letra
	  from emiletra
	 where no_documento = _no_documento
	   and no_letra = 1
	   and monto_pag = 0;

	if _cnt_letra is null then
		let _cnt_letra = 0;
	end if}

	let _cnt_cliente = 0;

	if _cnt_letra = 0 then
		select count(*)
		  into _cnt_cliente
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_pagador
		   and no_documento <> _no_documento;

		if _cnt_cliente is null then
			let _cnt_cliente = 0;
		end if

		if _cnt_cliente = 0 then
			delete from cascliente
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_pagador;
		end if
		
		delete from caspoliza
		 where cod_campana = _cod_campana
		   and no_documento = _no_documento;
	end if
end foreach

return 0;
end
end procedure;