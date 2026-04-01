-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud08;

create procedure "informix".sp_aud08(
a_periodo1	char(7),
a_periodo2	char(7)
) returning integer,
            char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _monto			dec(16,2);
define _ramo			char(50);
define _fecha_trans		date;
define _fecha_emision	date;
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _fecha_pago		date;
define _vigencia_final	date;
define _numrecla		char(20);

define _no_requis		char(10);
define _no_cheque		integer;

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_ramo		char(10);
define _nombre_ramo		char(50);
define _cod_cliente		char(10);

create temp table tmp_facturas(
	no_documento	char(20),
	no_cheque		integer,
	nombre			char(50),
	monto			dec(16,2),
	ramo			char(50),
	numrecla		char(20),
	fecha_reclamo	date,
	fecha_siniestro	date,
	fecha_pago		date,
	fecha_poliza	date,
	vigencia_final	date,
	fecha_trans		date
	) with no log;

set isolation to dirty read;

foreach
 select no_reclamo,
        monto,
		fecha,
		no_requis
   into _no_reclamo,
        _monto,
		_fecha_trans,
		_no_requis
   from rectrmae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1
	and cod_tipotran in ("004")
	and monto      <> 0
  order by no_reclamo, fecha

	select no_poliza,
	       numrecla,
		   fecha_siniestro,
		   fecha_reclamo
	  into _no_poliza,
	       _numrecla,
		   _fecha_siniestro,
		   _fecha_reclamo
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo,
		   no_documento,
		   cod_contratante,
		   vigencia_final,
		   fecha_suscripcion	
	  into _cod_ramo,
	       _no_documento,
	       _cod_cliente,
		   _vigencia_final,
		   _fecha_emision	
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

	select no_cheque,
	       fecha_impresion
	  into _no_cheque,
	       _fecha_pago
	  from chqchmae
	 where no_requis = _no_requis;

	insert into tmp_facturas
	values (
	_no_documento,
	_no_cheque,
	_nombre,
	_monto,
	_ramo,
	_numrecla,
    _fecha_reclamo,	
	_fecha_siniestro,
	_fecha_pago,
	_fecha_emision,
    _vigencia_final,
    _fecha_trans
	);

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure