-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 29/01/2002 - Autor: Amado Perez M.

	-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
	-- ano del auto y placa del vehiculo cuando es automovil.

-- SIS v.2.0 - DEIVID, S.A.

drop PROCEDURE sp_sis18;
CREATE PROCEDURE sp_sis18(a_no_reclamo CHAR(10))
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       CHAR(5);
DEFINE _fecha_siniestro DATE; 
DEFINE _no_cambio       CHAR(3);
DEFINE _cod_cober_prod  CHAR(5);
DEFINE _cod_cober_reas  CHAR(3);
DEFINE _cod_tipoprod 	CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _cod_coasegur    CHAR(3);
DEFINE _cod_compania    CHAR(3);
DEFINE _cod_ramo        CHAR(3);
DEFINE _ramo_sis        SMALLINT;
DEFINE _porcentaje      DEC(7,4);
DEFINE _contador_ret	SMALLINT;
DEFINE _abierta         SMALLINT;
DEFINE _vigencia_final  DATE;
DEFINE _cod_asegurado 	CHAR(10); 
DEFINE _cod_conductor 	CHAR(10); 
DEFINE _placa 			CHAR(10); 
DEFINE _cedula_aseg 	CHAR(30); 
DEFINE _cedula_cond 	CHAR(30); 
DEFINE _no_motor 		CHAR(30); 
DEFINE _cod_marca 		CHAR(5);
DEFINE _cod_modelo 		CHAR(5);
DEFINE _ano_auto 		SMALLINT;
DEFINE _tipo_persona    CHAR(1); 
DEFINE _incidente       INTEGER;
define _no_tranrec		char(10);
DEFINE _fecha_reclamo   DATE;
DEFINE _cod_contrato    char(5);
DEFINE _porc_partic_prima DEC(9,6); 
DEFINE _porc_partic_suma  DEC(9,6);
define _porc_partic_reas  DEC(9,6);
define _orden             smallint; 
DEFINE _cod_grupo         CHAR(5);
DEFINE _cnt_uni_end       smallint;
DEFINE _cnt_uni           smallint;
DEFINE _busca_end         smallint;
DEFINE _no_endoso         CHAR(5);

SET ISOLATION TO DIRTY READ;

DELETE FROM reccoas  WHERE no_reclamo = a_no_reclamo;
DELETE FROM recreafa WHERE no_reclamo = a_no_reclamo;
DELETE FROM recreaco WHERE no_reclamo = a_no_reclamo;

if a_no_reclamo = '694720' then
	SET DEBUG FILE TO "sp_sis18.trc";
	TRACE ON;
end if

-- Lectura del Reclamo

SELECT no_unidad,
	   fecha_siniestro,
	   no_poliza,
	   cod_compania,
	   cod_asegurado,
	   cod_conductor,
	   no_motor,
	   incidente,
	   fecha_reclamo
  INTO _no_unidad,
	   _fecha_siniestro,
	   _no_poliza,
	   _cod_compania,
	   _cod_asegurado,
	   _cod_conductor,
	   _no_motor,
	   _incidente,
	   _fecha_reclamo
  FROM recrcmae
 WHERE no_reclamo = a_no_reclamo;

-- Verificaciones de Reclamos

IF _fecha_reclamo <= "01/01/1900" THEN
	LET _mensaje = 'La Fecha del Reclamo es Invalida, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Lectura de la Poliza

LET _vigencia_final = NULL;

SELECT cod_tipoprod,
       cod_ramo,
	   vigencia_final,
	   abierta,
	   cod_grupo
  INTO _cod_tipoprod,
	   _cod_ramo,
	   _vigencia_final,
	   _abierta,
	   _cod_grupo
  FROM emipomae
 WHERE no_poliza = _no_poliza;

-- Lectura del Ramo

SELECT ramo_sis
  INTO _ramo_sis	
  FROM prdramo
 WHERE cod_ramo = _cod_ramo;

-- Lectura de las Coberturas

LET _cod_cober_prod = NULL;

IF _incidente IS NULL OR _incidente = 0 then
	FOREACH
	 SELECT	cod_cobertura
	   INTO	_cod_cober_prod
	   FROM	recrccob
	  WHERE	no_reclamo = a_no_reclamo
		EXIT FOREACH;
	END FOREACH

ELSE
	-- buscar la primera cobertura de emipocob para
	-- el numero de poliza y numero de unidad
	FOREACH
	 SELECT	cod_cobertura
	   INTO	_cod_cober_prod
	   FROM	emipocob
	  WHERE	no_poliza = _no_poliza
	    AND no_unidad = _no_unidad
		EXIT FOREACH;
	END FOREACH

   	IF _cod_cober_prod IS NULL OR _cod_cober_prod = "" THEN
		FOREACH
		 SELECT	cod_cobertura
		   INTO	_cod_cober_prod
		   FROM	endedcob
		  WHERE	no_poliza = _no_poliza
		    AND no_unidad = _no_unidad
			EXIT FOREACH;
		END FOREACH
	END IF
END IF

IF _cod_cober_prod IS NULL THEN
	LET _mensaje = 'Este Reclamo No Tiene Coberturas, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

SELECT cod_cober_reas
  INTO _cod_cober_reas
  FROM prdcober
 WHERE cod_cobertura = _cod_cober_prod;

IF _cod_cober_reas IS NULL THEN
	LET _mensaje = 'No Existe Enlace de Reaseguro para esta Cobertura, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Coaseguradoras

SELECT tipo_produccion
  INTO _tipo_produccion
  FROM emitipro
 WHERE cod_tipoprod = _cod_tipoprod;

LET _no_cambio = NULL;

IF _vigencia_final IS NULL OR _vigencia_final = '' OR _abierta = 1 THEN
	FOREACH
	 SELECT	no_cambio
	   INTO	_no_cambio
	   FROM	emihcmm
	  WHERE	no_poliza      = _no_poliza
	    AND vigencia_inic  <= _fecha_siniestro
			EXIT FOREACH;
	END FOREACH
ELSE
	FOREACH
	 SELECT	no_cambio
	   INTO	_no_cambio
	   FROM	emihcmm
	  WHERE	no_poliza      = _no_poliza
	    AND vigencia_inic  <= _fecha_siniestro
		AND vigencia_final >= _fecha_siniestro
			EXIT FOREACH;
	END FOREACH
END IF

IF _tipo_produccion = 2 AND _no_cambio IS NULL THEN
	LET _mensaje = 'No Existe Distribucion de Coaseguro para Este Reclamo, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

IF _tipo_produccion <> 2 THEN

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = _cod_compania;

	INSERT INTO reccoas(
	no_reclamo,
	cod_coasegur,
	porc_partic_coas
	)
	VALUES(
	a_no_reclamo,
	_cod_coasegur,
	100
	);

ELSE

	INSERT INTO reccoas(
	no_reclamo,
	cod_coasegur,
	porc_partic_coas
	)
	SELECT 
	a_no_reclamo,
	cod_coasegur,
	porc_partic_coas
	 FROM emihcmd
	WHERE no_poliza = _no_poliza
	  AND no_cambio = _no_cambio;

END IF

SELECT SUM(porc_partic_coas)
  INTO _porcentaje
  FROM reccoas
 WHERE no_reclamo = a_no_reclamo;

IF _porcentaje IS NULL THEN
	LET _porcentaje = 0;
END IF

IF _porcentaje <> 100 THEN
	LET _mensaje = 'Distribucion de Coaseguro No Suma 100%, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Reaseguradoras

LET _no_cambio = NULL;

-- IF _ramo_sis = 5 THEN -- Salud 
--	LET _no_unidad = '00001'; 
-- END IF


IF _vigencia_final IS NULL OR _vigencia_final = '' OR _abierta = 1 THEN

	FOREACH
	 SELECT	no_cambio
	   INTO	_no_cambio
	   FROM	emireama
	  WHERE	no_poliza       = _no_poliza
	    AND no_unidad       = _no_unidad
		AND cod_cober_reas  = _cod_cober_reas
	    AND vigencia_inic  <= _fecha_siniestro
	  ORDER BY no_cambio DESC
			EXIT FOREACH;
	END FOREACH

ELSE

	FOREACH
	 SELECT	no_cambio
	   INTO	_no_cambio
	   FROM	emireama
	  WHERE	no_poliza       = _no_poliza
	    AND no_unidad       = _no_unidad
		AND cod_cober_reas  = _cod_cober_reas
	    AND vigencia_inic  <= _fecha_siniestro
		AND vigencia_final >= _fecha_siniestro
	  ORDER BY no_cambio DESC
			EXIT FOREACH;
	END FOREACH

END IF

if  _no_poliza = '0002855085' and _no_unidad = '00014' then
	let _no_cambio = 0;
end if
if  _no_poliza = '0002969802' and _no_unidad = '01231' then
	let _no_cambio = 0;
end if
if  _no_poliza = '2962939' and _no_unidad = '01219' then
	let _no_cambio = 0;
end if
if  _no_poliza = '3289887' and _no_unidad = '00979' then
	let _no_cambio = 0;
end if
let _cnt_uni_end = 0;
let _cnt_uni = 0;
let _busca_end = 0;

IF _no_cambio IS NULL THEN
    -- Verificar si la unidad existía al momento del siniestro y ahora no está -- Amado 12-06-2023
    SELECT count(a.no_endoso)
      INTO _cnt_uni_end
	  FROM endedmae a, endeduni b
	 WHERE a.no_poliza = b.no_poliza
       AND a.no_endoso = b.no_endoso
       AND a.no_poliza = _no_poliza
       AND b.no_unidad = _no_unidad
	   AND a.vigencia_inic <= _fecha_siniestro;

    SELECT count(no_unidad)
      INTO _cnt_uni
	  FROM emipouni 
	 WHERE no_poliza = _no_poliza
       AND no_unidad = _no_unidad;
       
    if _cnt_uni_end is null then
        let _cnt_uni_end = 0;
    end if   

    if _cnt_uni is null then
        let _cnt_uni = 0;
    end if   

    if _cnt_uni_end > 0 and _cnt_uni = 0 then
        let _busca_end = 1;
    else
    	LET _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
    	RETURN 1, _mensaje;
    end if    
END IF

IF _cod_grupo = "77960" THEN -- 77960 - BANISI COLECTIVOS DESGRAVAMEN -- ID de la solicitud	# 4225 -- Amado 09/08/2022
			--Retencion
			select e.cod_contrato
			  into _cod_contrato
			  from emireaco e, reacomae r
			 where e.cod_contrato = r.cod_contrato
			   and e.no_poliza = _no_poliza
			   and e.no_unidad = _no_unidad
			   and e.no_cambio = _no_cambio
			   and r.tipo_contrato = 1;
			   
			INSERT INTO recreaco(
			no_reclamo,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima,
			cod_cober_reas)
			values(
			a_no_reclamo,
			1,
			_cod_contrato,
			60,
			60,
			'015');
			
			--Cuota Parte
			select e.cod_contrato
			  into _cod_contrato
			  from emireaco e, reacomae r
			 where e.cod_contrato = r.cod_contrato
			   and e.no_poliza = _no_poliza
			   and e.no_unidad = _no_unidad
			   and e.no_cambio = _no_cambio
			   and r.tipo_contrato = 5;
			   
			INSERT INTO recreaco(
			no_reclamo,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima,
			cod_cober_reas)
			values(
			a_no_reclamo,
			2,
			_cod_contrato,
			40,
			40,
			'015');
ELSE
    IF _busca_end = 1 THEN
        FOREACH
          SELECT a.no_endoso
            INTO _no_endoso
            FROM endedmae a, endeduni b
           WHERE a.no_poliza = b.no_poliza
             AND a.no_endoso = b.no_endoso
             AND a.no_poliza = _no_poliza
             AND b.no_unidad = _no_unidad
	         AND a.vigencia_inic <= _fecha_siniestro
           ORDER BY no_endoso DESC
           EXIT FOREACH;
        END FOREACH
        FOREACH
    		select cod_contrato,
				   porc_partic_prima,
				   orden,
				   porc_partic_suma,
				   cod_cober_reas
			  into _cod_contrato,
				   _porc_partic_prima,
				   _orden,
				   _porc_partic_suma,
				   _cod_cober_reas
		 	  from emifacon
			 where no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and no_endoso      = _no_endoso
				
			if _cod_ramo = '019' then	--Reclamos de vida, el % para distribuir es el de la suma.
				let _porc_partic_prima = _porc_partic_suma;
			end if	

			INSERT INTO recreaco(
			no_reclamo,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima,
			cod_cober_reas)
			values(
			a_no_reclamo,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima,
			_cod_cober_reas);
        END FOREACH    
        
    	delete from recreaco
    	 where no_reclamo        = a_no_reclamo
    	   and porc_partic_suma  = 0.00
    	   and porc_partic_prima = 0.00;

    	-- Facultativos

    	foreach
    	   select a.orden,
    			  a.cod_contrato,
    			  a.cod_coasegur,
    			  a.porc_partic_reas,
    			  a.cod_cober_reas
    		 into _orden,
    			  _cod_contrato,
    			  _cod_coasegur,
    			  _porc_partic_reas,
    			  _cod_cober_reas
    		 FROM emifafac a
    		WHERE a.no_poliza       = _no_poliza
    		  AND a.no_unidad       = _no_unidad
    		  AND a.no_endoso       = _no_endoso

    			INSERT INTO recreafa(
    			no_reclamo,
    			orden,
    			cod_contrato,
    			cod_coasegur,
    			porc_partic_reas,
    			cod_cober_reas)
    			values(
    			a_no_reclamo,
    			_orden,
    			_cod_contrato,
    			_cod_coasegur,
    			_porc_partic_reas,
    			_cod_cober_reas);

    	end foreach
    ELSE
    	foreach
    		 select cod_contrato,
    				porc_partic_prima,
    				orden,
    				porc_partic_suma,
    				cod_cober_reas
    		   into _cod_contrato,
    				_porc_partic_prima,
    				_orden,
    				_porc_partic_suma,
    				_cod_cober_reas
    		   from emireaco
    		  where no_poliza      = _no_poliza
    			and no_unidad      = _no_unidad
    			and no_cambio      = _no_cambio

				if _cod_ramo = '019' then	--Reclamos de vida, el % para distribuir es el de la suma.
					let _porc_partic_prima = _porc_partic_suma;
				end if
    			INSERT INTO recreaco(
    			no_reclamo,
    			orden,
    			cod_contrato,
    			porc_partic_suma,
    			porc_partic_prima,
    			cod_cober_reas)
    			values(
    			a_no_reclamo,
    			_orden,
    			_cod_contrato,
    			_porc_partic_suma,
    			_porc_partic_prima,
    			_cod_cober_reas);

    	end foreach
    
    	delete from recreaco
    	 where no_reclamo        = a_no_reclamo
    	   and porc_partic_suma  = 0.00
    	   and porc_partic_prima = 0.00;

    	-- Facultativos

    	foreach
    	   select a.orden,
    			  a.cod_contrato,
    			  a.cod_coasegur,
    			  a.porc_partic_reas,
    			  a.cod_cober_reas
    		 into _orden,
    			  _cod_contrato,
    			  _cod_coasegur,
    			  _porc_partic_reas,
    			  _cod_cober_reas
    		 FROM emireafa a, emireaco b
    		WHERE a.no_poliza       = b.no_poliza
              AND a.no_unidad       = b.no_unidad
              AND a.no_cambio       = b.no_cambio
              AND a.cod_cober_reas  = b.cod_cober_reas
              AND a.orden           = b.orden
              AND a.cod_contrato    = b.cod_contrato
    		  AND a.no_poliza       = _no_poliza
    		  AND a.no_unidad       = _no_unidad
    		  AND a.no_cambio       = _no_cambio
    		  AND b.porc_partic_suma  <> 0.00
              AND b.porc_partic_prima <> 0.00


			INSERT INTO recreafa(
			no_reclamo,
			orden,
			cod_contrato,
			cod_coasegur,
			porc_partic_reas,
			cod_cober_reas)
			values(
			a_no_reclamo,
			_orden,
			_cod_contrato,
			_cod_coasegur,
			_porc_partic_reas,
			_cod_cober_reas);

    	end foreach
    END IF
		
END IF
foreach
	SELECT SUM(porc_partic_prima)
	  INTO _porcentaje
	  FROM recreaco
	 WHERE no_reclamo = a_no_reclamo
  GROUP BY no_reclamo,cod_cober_reas

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

end foreach
foreach
	SELECT SUM(porc_partic_suma)
	  INTO _porcentaje
	  FROM recreaco
	 WHERE no_reclamo = a_no_reclamo
  GROUP BY no_reclamo,cod_cober_reas

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF
	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
end foreach

-- Verificacion para el Facultativo

SELECT COUNT(*)
  INTO _contador_ret 
  FROM recreaco, reacomae
 WHERE recreaco.no_reclamo    = a_no_reclamo 
   AND recreaco.cod_contrato  = reacomae.cod_contrato
   AND reacomae.tipo_contrato = 3; 
 
IF _contador_ret IS NULL THEN
	LET _contador_ret = 0;
END IF 

IF _contador_ret <> 0 THEN

	SELECT COUNT(*)
	  INTO _contador_ret
	  FROM recreafa
	 WHERE no_reclamo = a_no_reclamo;

	IF _contador_ret IS NULL THEN
		LET _contador_ret = 0; 
	END IF

	IF _contador_ret = 0 THEN
		LET _mensaje = 'No Existe Distribucion de Facultativos, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

	foreach

		SELECT SUM(porc_partic_reas)
		  INTO _porcentaje
		  FROM recreafa
		 WHERE no_reclamo = a_no_reclamo
		 group by no_reclamo,cod_cober_reas

		IF _porcentaje IS NULL THEN
			LET _porcentaje = 0;
		END IF

		IF _porcentaje <> 100 THEN
			LET _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF
	end foreach

END IF

-- Verificacion de Varias Retenciones

foreach

	SELECT COUNT(*) 
	  INTO _contador_ret 
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = a_no_reclamo 
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1
	 group by recreaco.no_reclamo,recreaco.orden,recreaco.cod_cober_reas	    	    
	    
	 
	IF _contador_ret IS NULL THEN
		LET _contador_ret = 0;
	END IF 
	 
	IF _contador_ret > 1 THEN
		LET _mensaje = 'Existe Mas de Una Retencion ...';
		RETURN 1, _mensaje;
	END IF;

end foreach


-- Procedure para crear los reaseguro por transaccion

let _no_tranrec = "00000";

foreach
	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where no_reclamo   = a_no_reclamo
	   and cod_tipotran = "001"
	 order by no_tranrec
	exit foreach;
end foreach

if _no_tranrec <> "00000" then

	call sp_sis58(_no_tranrec) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if

-- Campo Subir_BO para el DWH

if _no_tranrec <> "00000" then

	call sp_sis96(1, a_no_reclamo, _no_tranrec) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if

-- Verificacion de las cedulas del Asegurado y del Conductor
-- Verificacion de Motor, Marca, Modelo, Placa y Ano del Auto

IF _ramo_sis = 1 AND _tipo_produccion <> 3 THEN
	IF _incidente IS NULL OR _incidente = 0 THEN
		IF _cod_asegurado IS NOT NULL THEN
			SELECT cedula
			  INTO _cedula_aseg
			  FROM cliclien
			 WHERE cod_cliente = _cod_asegurado;

			IF (_cedula_aseg IS NULL OR _cedula_aseg = '') AND _tipo_persona = 'N' THEN
				LET _mensaje = '!! Al Asegurado le falta la Cedula, Por Favor Verifique ...';
				RETURN 1, _mensaje;
			END IF; 
		END IF

		IF _cod_conductor IS NOT NULL THEN
			SELECT cedula,
			       tipo_persona
			  INTO _cedula_cond,
			       _tipo_persona
			  FROM cliclien
			 WHERE cod_cliente = _cod_conductor;

			IF (_cedula_cond IS NULL OR _cedula_cond = '') AND _tipo_persona = 'N' THEN
				LET _mensaje = '!* El Conductor le falta la Cedula, Por Favor Verifique ...';
				RETURN 1, _mensaje;
			END IF;
		END IF

		IF _no_motor IS NULL OR _no_motor = '' THEN
				LET _mensaje = '** Al Automovil le falta el # de motor, Por Favor Verifique ...';
				RETURN 1, _mensaje;
		ELSE
		  SELECT cod_marca,
				 cod_modelo,
				 ano_auto,
				 placa
			INTO _cod_marca,
			     _cod_modelo,
				 _ano_auto,
				 _placa
			FROM emivehic
		   WHERE no_motor = _no_motor;

		   IF _cod_marca IS NULL OR _cod_marca = '' THEN
				LET _mensaje = '** Al Automovil le falta la Marca, Por Favor Verifique ...';
				RETURN 1, _mensaje;
		   ELIF _cod_modelo IS NULL OR _cod_modelo = '' THEN
				LET _mensaje = '** Al Automovil le falta el Modelo, Por Favor Verifique ...';
				RETURN 1, _mensaje;
		   ELIF _ano_auto IS NULL OR _ano_auto = '' THEN
				LET _mensaje = '** Al Automovil le falta el Año, Por Favor Verifique ...';
				RETURN 1, _mensaje;
		   ELIF _placa IS NULL OR _placa = '' THEN
				LET _mensaje = '** Al Automovil le falta la Placa, Por Favor Verifique ...';
				RETURN 1, _mensaje;
		   END IF

	   END IF
    END IF
END IF

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
