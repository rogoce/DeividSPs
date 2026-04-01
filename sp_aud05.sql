-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud05;

create procedure "informix".sp_aud05(
a_periodo	char(7)
) returning integer,
            char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _reserva_bruta	dec(16,2);
define _reserva_neta	dec(16,2);
define _ramo			char(50);
define _fecha_emision	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _cod_ramo		char(10);
define _nombre_ramo		char(50);
define _cod_cliente		char(10);

define _cantidad		smallint;
define v_filtros		char(255);

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	reserva_bruta	dec(16,2),
	reserva_neta	dec(16,2),
	ramo			char(50),
	fecha_ult_pago	date,
	vigencia_final	date,
	primary key (no_documento)
	) with no log;

set isolation to dirty read;

let v_filtros = sp_rec02("001", "001", a_periodo);

return 0, "Parte 1" with resume;

foreach
 select no_poliza,
        reserva_bruto,
		reserva_neto,
		ultima_fecha
   into _no_poliza,
        _reserva_bruta,
		_reserva_neta,
		_fecha_emision
   from tmp_sinis

	select cod_ramo,
		   no_documento,
		   cod_contratante,
		   vigencia_final	
	  into _cod_ramo,
	       _no_documento,
	       _cod_cliente,
		   _vigencia_final	
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cantidad
	  from tmp_facturas
	 where no_documento = _no_documento;

	if _cantidad = 0 then
	
		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;

		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		insert into tmp_facturas
		values (
		_no_documento,
		_nombre,
		_reserva_bruta,
		_reserva_neta,
		_ramo,
	    _fecha_emision,
	    _vigencia_final	
		);

	else


		update tmp_facturas
		   set reserva_bruta = reserva_bruta + _reserva_bruta,
			   reserva_neta  = reserva_neta  + _reserva_neta
		 where no_documento   = _no_documento;

	end if

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure