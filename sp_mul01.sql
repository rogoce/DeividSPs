-- Informacion para Multinacional

drop procedure sp_mul01;

create procedure sp_mul01(
a_periodo_desde		char(7),
a_periodo_hasta		char(7)
) returning char(3),
            char(5),
			char(20),
			char(10),
			char(5),
			date,
			date,
			date,
			date,
			date,
			char(10),
			char(10),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_ramo		char(3);
define _cod_producto	char(5);
define _no_documento	char(20);
define _cod_agente		char(5);

define _fecha_emision	date;
define _vig_desde_end	date;
define _vig_hasta_end	date;
define _vig_desde_pol	date;
define _vig_hasta_pol	date;

define _cod_endomov		char(3);
define _nueva_renov		char(1);
define _tipo_emision	char(10);

define _suma			dec(16,2);
define _prima			dec(16,2);
define _comision		dec(16,2);
define _porc_comision	dec(16,2);
define _tipo_agente		char(1);

define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _porc_contrato	dec(16,2);
define _porc_faculta	dec(16,2);
define _porc_reaseguro	dec(16,2);

set isolation to dirty read;

foreach
 select	no_poliza,
        no_endoso,
		vigencia_inic,
		vigencia_final,
		cod_endomov,
		suma_asegurada,
		prima_suscrita,
		fecha_emision
   into _no_poliza,
        _no_endoso,
		_vig_desde_end,
		_vig_hasta_end,
		_cod_endomov,
		_suma,
		_prima,
		_fecha_emision
   from endedmae
  where periodo     >= a_periodo_desde
    and periodo     <= a_periodo_hasta
	and actualizado = 1
   order by fecha_emision, no_documento

	select cod_ramo,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   nueva_renov
	  into _cod_ramo,
	       _no_documento,
		   _vig_desde_pol,
		   _vig_hasta_pol,
		   _nueva_renov
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_producto,
	        no_unidad
	   into _cod_producto,
	        _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
		exit foreach;
	end foreach
	
	let _cod_agente = null;

	foreach
	 select cod_agente,
	        porc_comis_agt
	   into _cod_agente,
	        _porc_comision
	   from endmoage
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
		exit foreach;
	end foreach

	if _cod_agente is null then

		foreach
		 select cod_agente,
	            porc_comis_agt
		   into _cod_agente,
	            _porc_comision
		   from emipoagt
		  where no_poliza = _no_poliza
			exit foreach;
		end foreach

	end if

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	if _tipo_agente = "O" then
		let _comision = 0;
	else
		let _comision = _prima * _porc_comision / 100;
	end if

	if _cod_endomov = "011" then
		if _nueva_renov = "N" then
			let _tipo_emision = "NUEVA";
		else
			let _tipo_emision = "RENOVACION";
		end if
	else
		let _tipo_emision = "ANEXO";
	end if

	let _porc_contrato = 0.00;
	let _porc_faculta  = 0.00;
	

	foreach
	 select cod_cober_reas
	   into _cod_cober_reas
	   from emifacon
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
	    and no_unidad = _no_unidad
	  order by cod_cober_reas
		exit foreach;
	end foreach
		
	foreach
	 select cod_contrato,
	        porc_partic_suma
	   into _cod_contrato,
	        _porc_reaseguro
	   from emifacon
	  where no_poliza      = _no_poliza
	    and no_endoso      = _no_endoso
	    and no_unidad      = _no_unidad
		and cod_cober_reas = _cod_cober_reas

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
		   _no_documento,
		   "",
		   _cod_agente,
		   _fecha_emision,
		   _vig_desde_end,
		   _vig_hasta_end,
		   _vig_desde_pol,
		   _vig_hasta_pol,
		   "",
		   _tipo_emision,
		   _suma,
		   _prima,
		   _comision,
		   _porc_contrato,
		   _porc_faculta
		   with resume;
	
end foreach

end procedure
