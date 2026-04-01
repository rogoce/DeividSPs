-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud10;

create procedure "informix".sp_aud10() 
returning integer,
          char(50);

define _no_documento	char(20);
define _no_cheque		integer;
define _nombre			char(100);
define _monto			dec(16,2);
define _numrecla		char(20);
define _fecha_cheque	date;
define _fecha_siniestro	date;
define _ramo			char(50);

define _no_poliza		char(10);
define _cod_ramo		char(10);
define _no_requis		char(10);
define _transaccion		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);

create temp table tmp_facturas(
	no_documento	char(20),
	no_cheque		integer,
	nombre			char(50),
	monto			dec(16,2),
	numrecla		char(20),
	fecha_cheque	date,
	fecha_siniestro	date,
	ramo			char(50)
	) with no log;

set isolation to dirty read;

foreach
 select no_cheque,
        a_nombre_de,
		fecha_impresion,
		no_requis
   into _no_cheque,
        _nombre,
		_fecha_cheque,
		_no_requis
   from chqchmae
  where fecha_impresion >= "01/07/2007"
    and fecha_impresion <= "31/10/2007"
	and pagado           = 1

	foreach
	 select transaccion,
	        numrecla,
			monto
	   into _transaccion,
	        _numrecla,
			_monto
	   from chqchrec
	  where no_requis = _no_requis
		and monto     <> 0

		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;

		select no_reclamo
		  into _no_reclamo
		  from rectrmae
		 where no_tranrec = _no_tranrec;

		select no_poliza,
		       fecha_siniestro
		  into _no_poliza,
		       _fecha_siniestro
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select cod_ramo,
			   no_documento
		  into _cod_ramo,
		       _no_documento
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		insert into tmp_facturas
		values (
		_no_documento,
		_no_cheque,
		_nombre,
		_monto,
		_numrecla,
		_fecha_cheque,
		_fecha_siniestro,
		_ramo
		);

	end foreach

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure