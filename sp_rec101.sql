-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 29/01/2002 - Autor: Amado Perez M. 
-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
-- ano del auto y placa del vehiculo cuando es automovil.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec101;		

CREATE PROCEDURE "informix".sp_rec101(a_no_tranrec CHAR(10))
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

define a_no_reclamo 	CHAR(10);
define _cantidad		smallint;

--set debug file to "sp_rec101.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

select no_reclamo
  into a_no_reclamo
  from rectrmae
 where no_tranrec = a_no_tranrec;

--{
DELETE FROM reccoas  WHERE no_reclamo = a_no_reclamo;
DELETE FROM recreafa WHERE no_reclamo = a_no_reclamo;
DELETE FROM recreaco WHERE no_reclamo = a_no_reclamo;
--}

-- Lectura del Reclamo

SELECT no_unidad,
	   fecha_siniestro,
	   no_poliza,
	   cod_compania,
	   cod_asegurado,
	   cod_conductor,
	   no_motor,
	   incidente
  INTO _no_unidad,
	   _fecha_siniestro,
	   _no_poliza,
	   _cod_compania,
	   _cod_asegurado,
	   _cod_conductor,
	   _no_motor,
	   _incidente
  FROM recrcmae
 WHERE no_reclamo = a_no_reclamo;

-- Lectura de la Poliza

LET _vigencia_final = NULL;

SELECT cod_tipoprod,
       cod_ramo,
	   vigencia_final,
	   abierta
  INTO _cod_tipoprod,
	   _cod_ramo,
	   _vigencia_final,
	   _abierta
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

SELECT SUM(porc_partic_coas)
  INTO _porcentaje
  FROM reccoas
 WHERE no_reclamo = a_no_reclamo;

IF _porcentaje IS NULL THEN
	LET _porcentaje = 0;
END IF

IF _porcentaje <> 100 THEN

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = _cod_compania;

	select count(*)
	  into _cantidad
	  from reccoas
	 where no_reclamo   = a_no_reclamo
	   and cod_coasegur = _cod_coasegur;

	IF _tipo_produccion <> 2 THEN

		if _cantidad = 0 then

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

		end if

	ELSE
		
		if _cantidad = 0 then

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

		end if

	END IF

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

IF _no_cambio IS NULL THEN
	LET _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Contratos

select count(*)
  into _cantidad
  from recreaco
 where no_reclamo   = a_no_reclamo;

if _cantidad = 0 then

--trace a_no_reclamo;
--trace _no_poliza;
--trace _no_unidad;
--trace _no_cambio;
--trace _cod_cober_reas;

	INSERT INTO recreaco(
	no_reclamo,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima,
	cod_cober_reas
	)
	SELECT
	a_no_reclamo,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima,
	cod_cober_reas
	 FROM emireaco
	WHERE no_poliza       = _no_poliza
	  AND no_unidad       = _no_unidad
	  AND no_cambio       = _no_cambio
	  AND cod_cober_reas  = _cod_cober_reas;

--trace "insert";

end if

delete from recreaco
 where no_reclamo        = a_no_reclamo
   and porc_partic_suma  = 0.00
   and porc_partic_prima = 0.00;

-- Facultativos

INSERT INTO recreafa(
no_reclamo,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas
)
SELECT
a_no_reclamo,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas
 FROM emireafa
WHERE no_poliza       = _no_poliza
  AND no_unidad       = _no_unidad
  AND no_cambio       = _no_cambio
  AND cod_cober_reas  = _cod_cober_reas;

SELECT SUM(porc_partic_prima)
  INTO _porcentaje
  FROM recreaco
 WHERE no_reclamo = a_no_reclamo;

IF _porcentaje IS NULL THEN
	LET _porcentaje = 0;
END IF

IF _porcentaje <> 100 THEN
	LET _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

SELECT SUM(porc_partic_suma)
  INTO _porcentaje
  FROM recreaco
 WHERE no_reclamo = a_no_reclamo;

IF _porcentaje IS NULL THEN
	LET _porcentaje = 0;
END IF

IF _porcentaje <> 100 THEN
	LET _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

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

	SELECT SUM(porc_partic_reas)
	  INTO _porcentaje
	  FROM recreafa
	 WHERE no_reclamo = a_no_reclamo;

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

END IF

-- Verificacion de Varias Retenciones

SELECT COUNT(*)                                                                                                        
  INTO _contador_ret                                                                                                   
  FROM recreaco, reacomae                                                                                              
 WHERE recreaco.no_reclamo    = a_no_reclamo                                                                            
   AND recreaco.cod_contrato  = reacomae.cod_contrato                                                                  
   AND reacomae.tipo_contrato = 1;                                                                                     
                                                                                                                       
IF _contador_ret IS NULL THEN                                                                                      
	LET _contador_ret = 0;                                                                                         
END IF                                                                                                             
                                                                                                                   
IF _contador_ret > 1 THEN                                                                                          
	LET _mensaje = 'Existe Mas de Una Retencion ...';
	RETURN 1, _mensaje;
END IF;                                                                                                            

call sp_sis58(a_no_tranrec) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

{
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
}

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
