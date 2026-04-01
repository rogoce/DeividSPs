-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud07;

create procedure "informix".sp_aud07(
a_periodo	char(7)
) returning integer,
            char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _monto_inicial	dec(16,2);
define _monto_recobrado	dec(16,2);
define _monto_saldo		dec(16,2);
define _ramo			char(50);
define _fecha_emision	date;
define _vigencia_final	date;

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_ramo		char(10);
define _nombre_ramo		char(50);
define _cod_cliente		char(10);

define _cantidad		smallint;
define _fecha			date;

define _fecha_evaluar	date;

let _fecha_evaluar = sp_sis36(a_periodo);

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	monto_inicial	dec(16,2),
	monto_recobrado	dec(16,2),
	monto_saldo		dec(16,2),
	ramo			char(50),
	fecha_ult_pago	date,
	primary key (no_documento)
	) with no log;

set isolation to dirty read;

foreach
 select no_reclamo,
        monto_arreglo
   into _no_reclamo,
        _monto_inicial
   from recrecup
  where fecha_recupero <= _fecha_evaluar

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

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

	select sum(monto),
	       max(fecha)
	  into _monto_recobrado,
	       _fecha_emision
	  from cobredet
	 where no_reclamo  = _no_reclamo
	   and tipo_mov    = "R"
	   and actualizado = 1
	   and periodo    <= a_periodo;
	
	let _monto_saldo = _monto_inicial - _monto_recobrado;

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
		_monto_inicial,
		_monto_recobrado,
		_monto_saldo,
		_ramo,
	    _fecha_emision
		);

	else

		select fecha_ult_pago
		  into _fecha
		  from tmp_facturas
		 where no_documento = _no_documento;

		if _fecha_emision > _fecha then
			let _fecha = _fecha_emision;
		end if

		update tmp_facturas
		   set monto_inicial   = monto_inicial   + _monto_inicial,
			   monto_recobrado = monto_recobrado + _monto_recobrado,
			   monto_saldo     = monto_saldo     + _monto_saldo,
		       fecha_ult_pago  = _fecha 
		 where no_documento    = _no_documento;

	end if

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure