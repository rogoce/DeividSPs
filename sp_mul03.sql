-- Informacion para Multinacional

drop procedure sp_mul03;

create procedure sp_mul03() 
returning char(3),
          char(5),
		  char(3),
		  char(5),
		  char(10),
		  char(50),
		  char(20),
		  char(20),
		  date,
		  date,
		  date,
		  char(10),
		  dec(16,2),
		  char(3),
		  char(3),
		  dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _numrecla		char(20);
define _no_poliza		char(10);
define _no_reclamo		char(10);
define _transaccion		char(10);
define _no_tranrec		char(10);

define _cod_ramo		char(3);
define _cod_producto	char(5);
define _cod_sucursal	char(3);
define _cod_agente		char(5);

define _fecha_siniestro	date;
define _fecha_documento	date;
define _fecha_pago		date;
define _cod_evento		char(3);

define _no_unidad		char(5);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _porc_contrato	dec(16,2);
define _porc_faculta	dec(16,2);
define _porc_reaseguro	dec(16,2);

define _cod_cobertura	char(5);
define _nombre_cober	char(50);
define _monto_aviso		dec(16,2);

set isolation to dirty read;

foreach
 select	no_reclamo,
        no_tranrec,
		fecha,
		transaccion,
		monto
   into _no_reclamo,
        _no_tranrec,
		_fecha_pago,
		_transaccion,
		_monto_aviso
   from rectrmae
  where periodo      >= "2007-05"
    and periodo      <= "2007-09"
	and actualizado  = 1
   	and cod_tipotran = "004"

	select no_poliza,
		   numrecla,
	       no_unidad,
	       cod_sucursal,
	       fecha_siniestro,
	       fecha_documento,
	       cod_evento
	  into _no_poliza,
	       _numrecla,
	       _no_unidad,
	       _cod_sucursal,
	       _fecha_siniestro,
	       _fecha_documento,
	       _cod_evento
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from rectrcob
	  where no_tranrec = _no_tranrec
	  order by monto desc
		exit foreach;
	end foreach

	select nombre
	  into _nombre_cober
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	select cod_ramo,
	       no_documento
	  into _cod_ramo,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _cod_producto is null then

		foreach	
		 select cod_producto
		   into _cod_producto
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		  order by no_endoso
			exit foreach;
		end foreach

	end if

	let _cod_agente = null;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach


	let _porc_contrato = 0.00;
	let _porc_faculta  = 0.00;
	

	foreach
	 select cod_contrato,
	        porc_partic_suma
	   into _cod_contrato,
	        _porc_reaseguro
	   from rectrrea
	  where no_tranrec = _no_tranrec

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then -- Retencion
		elif _tipo_contrato = 3 then  -- Facultativos
			let _porc_faculta = _porc_faculta + _porc_reaseguro;
		else
			let _porc_contrato = _porc_contrato + _porc_reaseguro;
		end if
		
	end foreach

	return _cod_ramo,
	       _cod_producto,
		   _cod_sucursal,
		   _cod_agente,
			"",
		   _nombre_cober,
		   _numrecla,	
		   _no_documento,
		   _fecha_siniestro,
		   _fecha_documento,
		   _fecha_pago,
		   _transaccion,	
		   _monto_aviso,
		   _cod_evento,
		   "",
		   _porc_contrato,
		   _porc_faculta
		   with resume;
	
end foreach

end procedure
