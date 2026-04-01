-- Reporte de Simulacion de Registros Contables

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par52;

create procedure sp_par52(
a_compania 		char(3),
a_periodo 		char(7),
a_periodo2		char(7), 
a_no_cuadran	smallint) 
returning char(10),
		  char(10),
		  char(5),
		  char(3),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(20),
		  dec(16,2),
		  char(50);

define _prima_suscrita	dec(16,2);
define _impuesto_5		dec(16,2);
define _impuesto_1		dec(16,2);
define _prod_directa	dec(16,2);
define _prod_minor		dec(16,2);
define _prima_x_cobrar	dec(16,2);
define _prima_neta		dec(16,2);
define _coas_ced_1		dec(16,2);
define _coas_ced_2		dec(16,2);
define _impuesto_5_ced	dec(16,2);
define _impuesto_1_ced	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_vida		dec(16,2);
define _prima_vida2		dec(16,2);

define _cod_impuesto	char(3);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_factura		char(10);
define _cod_tipoprod	char(3);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _impuesto	    dec(16,2);
define _no_cambio		char(3);
define _fecha_emision	date;
define _porc_partic		dec(7,4);
define v_descr_cia		char(50);
define _cod_endomov  	char(3);

define _porc_comision	dec(16,2);
define _porc_comis_par	dec(16,2);
define v_comision_sus 	dec(16,2);
define v_comision_ced 	dec(16,2);
define v_comision_tot 	dec(16,2);
define _comision_monto	dec(16,2);
define v_no_documento   char(20);
define _ramo_sis		smallint;
define _cod_origen		char(3);
define _aplica_impuesto smallint;
define _cant_impuestos	smallint;
define _gasto_manejo	dec(16,2);
define _nombre_origen	char(50);

define _cod_agente		char(10);
define _tipo_agente		char(1);

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_compania);

foreach
 select	prima_suscrita,
		impuesto,
		no_poliza,
		no_endoso,
		prima_neta,
		prima_bruta,
		no_factura,
		cod_endomov,
		no_documento,
		fecha_emision,
		cod_tipoprod,
		gastos
   into	_prima_suscrita,
        _impuesto,
		_no_poliza,
		_no_endoso,
		_prima_neta,
		_prima_bruta,
		_no_factura,
		_cod_endomov,
		v_no_documento,		
		_fecha_emision,
		_cod_tipoprod,
		_gasto_manejo
   from endedmae
  where periodo    >= a_periodo
    and periodo    <= a_periodo2
	and actualizado = 1
--	and no_documento in ("0404-00030-01", "1604-00038-01", "1604-00034-01")
--    and no_factura in ("01-332401", "01-332409", "01-332400", "01-332442", "01-332445", "01-332446")
--	and cod_tipocan is null
--	and cod_endomov <> "017"
--	and prima_suscrita <> 0.00

--	let _impuesto = 1.00;

	select cod_ramo,
	       cod_origen	
	  into _cod_ramo,
	       _cod_origen	
	  from emipomae
     where no_poliza = _no_poliza;

	-- Si es Reaseguro Aumido

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select nombre,
	       ramo_sis
	  into _nombre_ramo,
	       _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select aplica_impuesto,
	       nombre
	  into _aplica_impuesto,
	       _nombre_origen
	  from parorig
	 where cod_origen = _cod_origen;

	let _nombre_origen = _cod_origen || " " || trim(_nombre_origen);

	-- Calculo de Impuesto para Prima Suscrita	

	let _prima_vida2 = 0.00;

	if _cod_ramo = "018" then

		foreach
		 select no_unidad
		   into _no_unidad
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    
			select prima_vida
			  into _prima_vida
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _prima_vida is null then
				let _prima_vida = 0.00;
			end if

			let _prima_vida2 = _prima_vida2 + _prima_vida;
			
		end foreach 	

	end if

	let _impuesto_5 = 0.00;
	let _impuesto_1 = 0.00;

	if _impuesto <> 0.00 then

		foreach	
		 select cod_impuesto
		   into _cod_impuesto
		   from endedimp
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    
		    if _cod_impuesto = "001" then
		    	let _impuesto_5 = (_prima_suscrita - _prima_vida2) * 0.05;
		    else
		    	let _impuesto_1 = (_prima_suscrita - _prima_vida2) * 0.01;
		    end if	

		end foreach

	end if

	-- Calculo para Coaseguro Cedido

	--let _coas_ced_1     = _prima_neta - _prima_suscrita;


	-- Coaseguro Cedido de la Forma del Reporte (sp_pro31)

	let _coas_ced_1 = 0.00;

	select sum(porc_partic_coas)
	  into _porc_partic
	  from endcoama
     where no_poliza    = _no_poliza
       and no_endoso    = _no_endoso
       and cod_coasegur <> "036";

	IF _porc_partic IS NULL THEN
		LET _porc_partic = 0;
	END IF

    LET _coas_ced_1 = (_prima_neta * _porc_partic / 100);
    LET _coas_ced_2 = (_prima_neta * _porc_partic / 100);

	let _impuesto_5_ced = 0.00;
	let _impuesto_1_ced = 0.00;

	if _coas_ced_1 <> 0.00 then

		if _impuesto <> 0.00 then

			foreach	
			 select cod_impuesto
			   into _cod_impuesto
			   from endedimp
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
			    
			    if _cod_impuesto = "001" then
			    	let _impuesto_5_ced = _coas_ced_1 * 0.05;
			    else
			    	let _impuesto_1_ced = _coas_ced_1 * 0.01;
			    end if	
			end foreach

		end if

	end if

	-- Calculo para Comision Corredor de Prima Suscrita

	LET v_comision_sus = 0.00;

{
      SELECT porc_comis_agt,
			 porc_partic_agt
        INTO _porc_comision,
		     _porc_comis_par
        FROM emipoagt
       WHERE no_poliza = _no_poliza
}

     FOREACH
      SELECT porc_comis_agt,
			 porc_partic_agt,
			 cod_agente
        INTO _porc_comision,
		     _porc_comis_par,
			 _cod_agente
        FROM endmoage
       WHERE no_poliza = _no_poliza
	     and no_endoso = _no_endoso

		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		-- Solo procesa las comisiones para los Agentes normales, para los especiales y para oficina,
		-- no genera registro de comisiones

		if _tipo_agente = "O"  then
			continue foreach;
		end if

		IF _porc_comision IS NULL THEN
			LET _porc_comision = 0.00;
		END IF

		LET _comision_monto = (_prima_suscrita * (_porc_comision/100) * (_porc_comis_par/100));
		LET v_comision_sus  = v_comision_sus + _comision_monto;

	END FOREACH;

	-- Calculo para Impuesto de 2% de Prima Suscrita

	If _aplica_impuesto = 1 Then
		If _ramo_sis = 3 Then
			LET v_comision_ced = 0.00;
		Else
			LET v_comision_ced = (_prima_suscrita * 2.00)/100;
		End If
	Else
		LET v_comision_ced = 0.00;
	End If

	LET v_comision_tot = 0.00;

{
	let _no_cambio  = NULL;

	 SELECT	MAX(no_cambio)
	   INTO	_no_cambio
	   FROM	emihcmm
	  WHERE	no_poliza  = _no_poliza
	    AND fecha_mov <= _fecha_emision;

	IF _no_cambio IS NOT NULL THEN

	    SELECT porc_partic_coas
	      INTO _porc_partic
	      FROM emihcmd
	     WHERE no_poliza    = _no_poliza
	       AND no_cambio    = _no_cambio
	       AND cod_coasegur = "036";

		IF _porc_partic IS NULL THEN
			LET _porc_partic = 100;
		END IF

	    LET _coas_ced_2 = _prima_neta - (_prima_neta * _porc_partic / 100);

	END IF
}

	-- Calculo para Prima por Cobrar

	let _prima_x_cobrar = _prima_suscrita + _impuesto_5 + _impuesto_1 + _coas_ced_1 + _impuesto_5_ced + _impuesto_1_ced + _gasto_manejo;

	let _prod_directa = 0.00;
	let _prod_minor   = 0.00;

	if _cod_tipoprod = "002" then
		let _prod_minor   = _prima_x_cobrar;
	else
		let _prod_directa = _prima_x_cobrar;
	end if

	if a_no_cuadran = 1 then

		if abs(_prima_x_cobrar - _prima_bruta) > 0.01 then

			return _no_factura,
				   _no_poliza,
				   _no_endoso,
				   _cod_endomov,
				   _prima_suscrita,
				   _impuesto_5,
				   _impuesto_1,
				   _coas_ced_1,
				   _impuesto_5_ced,
				   _impuesto_1_ced,
				   _prima_x_cobrar,
				   _prod_directa,
				   _prod_minor,
				   (_prima_x_cobrar - _prima_bruta),
				   _prima_bruta,
				   _cod_ramo,
				   _nombre_ramo,
				   v_descr_cia,
				   v_comision_sus,
				   v_comision_ced,
				   v_comision_tot,
				   v_no_documento,
				   _gasto_manejo,
				   _nombre_origen
				   with resume;

		end if

	else

		return _no_factura,
			   _no_poliza,
			   _no_endoso,
			   _cod_endomov,
			   _prima_suscrita,
			   _impuesto_5,
			   _impuesto_1,
			   _coas_ced_1,
			   _impuesto_5_ced,
			   _impuesto_1_ced,
			   _prima_x_cobrar,
			   _prod_directa,
			   _prod_minor,
			   (_prima_x_cobrar - _prima_bruta),
			   _prima_bruta,
			   _cod_ramo,
			   _nombre_ramo,
			   v_descr_cia,
			   v_comision_sus,
			   v_comision_ced,
			   v_comision_tot,
			   v_no_documento,
			   _gasto_manejo,
			   _nombre_origen
			   with resume;

	end if

end foreach

end procedure 