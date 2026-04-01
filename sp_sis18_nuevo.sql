-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/11/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis18_nuevo;		

CREATE PROCEDURE "informix".sp_sis18_nuevo(a_no_reclamo CHAR(10))
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);

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

-- Lectura del Reclamo

SELECT no_unidad,
	   fecha_siniestro,
	   no_poliza,
	   cod_compania	
  INTO _no_unidad,
	   _fecha_siniestro,
	   _no_poliza,
	   _cod_compania
  FROM recrcmae
 WHERE no_reclamo = a_no_reclamo;

-- Lectura de la Poliza

SELECT cod_tipoprod,
       cod_ramo
  INTO _cod_tipoprod,
	   _cod_ramo	
  FROM emipomae
 WHERE no_poliza = _no_poliza;

-- Lectura del Ramo

SELECT ramo_sis
  INTO _ramo_sis	
  FROM prdramo
 WHERE cod_ramo = _cod_ramo;

-- Lectura de las Coberturas

LET _cod_cober_prod = NULL;

FOREACH
 SELECT	cod_cobertura
   INTO	_cod_cober_prod
   FROM	recrccob
  WHERE	no_reclamo = a_no_reclamo
	EXIT FOREACH;
END FOREACH

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

FOREACH
 SELECT	no_cambio
   INTO	_no_cambio
   FROM	emihcmm
  WHERE	no_poliza      = _no_poliza
    AND vigencia_inic  <= _fecha_siniestro
	AND vigencia_final >= _fecha_siniestro
		EXIT FOREACH;
END FOREACH

IF _tipo_produccion = 2 AND
   _no_cambio IS NULL THEN
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
	LET _mensaje = 'Distribucion de Coaseguro No Suma 100%, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Reaseguradoras

LET _no_cambio = NULL;

-- IF _ramo_sis = 5 THEN -- Salud 
--	LET _no_unidad = '00001';     
-- END IF                         

FOREACH
 SELECT	no_cambio
   INTO	_no_cambio
   FROM	emireama
  WHERE	no_poliza       = _no_poliza
    AND no_unidad       = _no_unidad
	AND cod_cober_reas  = _cod_cober_reas
    AND vigencia_inic  <= _fecha_siniestro
	AND vigencia_final >= _fecha_siniestro
		EXIT FOREACH;
END FOREACH

IF _no_cambio IS NULL THEN
	LET _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

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

SELECT SUM(porc_partic_reas)
  INTO _porcentaje
  FROM recreafa
 WHERE no_reclamo = a_no_reclamo;

IF _porcentaje IS NOT NULL THEN
	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
END IF

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


LET _mensaje = 'Actualizacion Exitosa ...';

RETURN 0, _mensaje;

END PROCEDURE;
