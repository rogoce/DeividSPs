-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud11;

create procedure "informix".sp_aud11() 
returning integer,
          char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _monto			dec(16,2);
define _numrecla		char(20);
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _ramo			char(50);

define _no_poliza		char(10);
define _cod_ramo		char(10);
define _no_reclamo		char(10);
define _cantidad		smallint;
define _procesar		smallint;
define _cod_cliente		char(10);
define _no_requis		char(10);
define _fecha_impresion	date;
define _pagado			smallint;
define _fecha_pagado	date;

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	monto			dec(16,2),
	numrecla		char(20),
	fecha_siniestro	date,
	fecha_reclamo	date,
	ramo			char(50)
	) with no log;

set isolation to dirty read;

foreach
 select no_reclamo,
		numrecla,
		fecha_siniestro,
		fecha_reclamo,
		no_poliza
   into _no_reclamo,
		_numrecla,
		_fecha_siniestro,
		_fecha_reclamo,
		_no_poliza
   from recrcmae
  where actualizado = 1

    IF _numrecla = "00-0000-00000-00" THEN
	   CONTINUE FOREACH;
	END IF;

	let _procesar = 0;

	select count(*)
	  into _cantidad
	  from rectrmae
	 where cod_compania = "001"
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and periodo      <= "2007-10"
	   and no_reclamo   = _no_reclamo
	   and monto        > 0;

	if _cantidad = 0 then

		let _procesar = 1;

	else

		foreach
		 select pagado,
		        no_requis,
				fecha_pagado
		   into _pagado,
		        _no_requis,
				_fecha_pagado
		   from rectrmae
		  where cod_compania = "001"
		    and actualizado  = 1
		    and cod_tipotran = "004"
		   and periodo      <= "2007-10"
	        and no_reclamo   = _no_reclamo
			and monto        > 0

			if _pagado = 0 then
				
				let _procesar = 1;
				exit foreach;

			else

				select fecha_impresion 
				  into _fecha_impresion
				  from chqchmae
				 where no_requis = _no_requis;

				if _fecha_impresion is null then
					let _fecha_impresion = _fecha_pagado;
				end if
				 
				if _fecha_impresion > "31/10/2007" then
					let _procesar = 1;
					exit foreach;
				end if

			end if

		end foreach

	end if

	if _procesar = 1 then

		select cod_ramo,
			   no_documento,
			   cod_contratante
		  into _cod_ramo,
		       _no_documento,
			   _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;

		SELECT SUM(variacion)
		  INTO _monto
		  FROM rectrmae 
		 WHERE cod_compania = "001"
		   AND actualizado  = 1
		   AND periodo     <= "2007-10" 
		   and no_reclamo	= _no_reclamo;
		
		if _monto is null then
			let _monto = 0;
		end if

		if _monto < 0 then
			let _monto = 0;
		end if

		insert into tmp_facturas
		values (
		_no_documento,
		_nombre,
		_monto,
		_numrecla,
		_fecha_siniestro,
		_fecha_reclamo,
		_ramo
		);

	end if

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure