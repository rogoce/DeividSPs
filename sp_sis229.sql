-- Procedimiento que Elimina de las campañas de nulidad las pólizas con pagos.
-- Creado: 15/04/2017 - Autor: Román Gordon

drop procedure sp_sis229;
create procedure sp_sis229()--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje				varchar(250);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _monto_letra			dec(16,2);
define _monto_pag			dec(16,2);
define _cnt_cliente			smallint;
define _cnt_ley68			smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_sis228.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

foreach
	{select p.cod_campana,
		   p.cod_cliente,
		   p.no_documento
	  into _cod_campana,
		   _cod_cliente,
		   _no_documento
	  from cascampana c, caspoliza p
	 where c.cod_campana = p.cod_campana
	   and c.tipo_campana = 3

	--call sp_pro544(_no_documento) returning _error,_mensaje;

	let _cnt_ley68 = 0;

	select count(*)
	  into _cnt_ley68
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
	   and limite_1 <= 5000 and limite_2 <= 10000
	   and e.no_documento = _no_documento;

	if _cnt_ley68 is null then
		let _cnt_ley68 = 0;
	end if

	call sp_sis21(_no_documento) returning _no_poliza;

	let _monto_pag = 0.00;

	select monto_pag,
		   monto_letra
	  into _monto_pag,
		   _monto_letra
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = 1;

	if _monto_pag is null then
		let _monto_pag = 0.00;
	end if

	if _monto_letra is null then
		let _monto_letra = 0.00;
	end if}

	select no_documento,
		   cod_cliente,
		   cod_campana
	  into _no_documento,
		   _cod_cliente,
		   _cod_campana
	  from tmp_ley68
	   
	--if _monto_pag > 0 or _monto_letra = 0.00 or _cnt_ley68 > 0 then
		select count(*)
		  into _cnt_cliente
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		if _cnt_cliente is null then
			let _cnt_cliente = 0;
		end if

		if _cnt_cliente <= 1 then
			delete from cascliente
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_cliente;
		end if
		
		delete from caspoliza
		 where cod_campana = _cod_campana
		   and no_documento = _no_documento;
	--end if
end foreach

return 0,'Actualización Exitosa';
end
end procedure;