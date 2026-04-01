-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud02;

create procedure "informix".sp_aud02(
a_periodo1	char(7),
a_periodo2	char(7)
)

define _no_factura		char(10);
define _no_documento	char(20);
define _fecha			date;
define _prima_bruta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _ramo			char(50);
define _periodo			char(7);

define _no_poliza		char(10);
define _cod_ramo		char(10);
define _cod_origen		char(3);
define _nombre_origen   char(50);

create temp table tmp_facturas(
	no_factura		char(10),
	no_documento	char(20),
	fecha			date,
	prima_bruta		dec(16,2),
	prima_suscrita	dec(16,2),
	ramo			char(50),
	periodo			char(7),
	origen			char(50)
	) with no log;

set isolation to dirty read;

foreach
 select no_factura, 
        no_poliza, 
        fecha_emision, 
        prima_bruta, 
        prima_suscrita,
		periodo
   into _no_factura, 
        _no_poliza, 
        _fecha, 
        _prima_bruta, 
        _prima_suscrita,
		_periodo
   from endedmae
  where actualizado = 1
    and periodo     >= a_periodo1
    and periodo     <= a_periodo2
  order by fecha_emision

	select cod_ramo,
		   no_documento,	
	       cod_origen	
	  into _cod_ramo,
	       _no_documento,	
	       _cod_origen
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_origen
	  from parorig
	 where cod_origen = _cod_origen;

	insert into tmp_facturas
	values (
	_no_factura,
	_no_documento,
	_fecha,
	_prima_bruta,
	_prima_suscrita,
	_ramo,
	_periodo,
	_nombre_origen
	);

end foreach

--unload to facturas.txt select * from tmp_facturas;

end procedure