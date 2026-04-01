-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud09;

create procedure "informix".sp_aud09(
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
define _numrecla		char(20);

define v_filtros		char(255);

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	numrecla		char(20),
	ramo			char(50),
	reserva_bruta	dec(16,2),
	reserva_neta	dec(16,2)
	) with no log;

set isolation to dirty read;

let v_filtros = sp_rec02("001", "001", a_periodo);

foreach
 select no_poliza,
        reserva_bruto,
		reserva_neto,
		ultima_fecha,
		numrecla
   into _no_poliza,
        _reserva_bruta,
		_reserva_neta,
		_fecha_emision,
		_numrecla
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
	_numrecla,
	_ramo,
	_reserva_bruta,
	_reserva_neta
	);

end foreach

drop table tmp_sinis;

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure