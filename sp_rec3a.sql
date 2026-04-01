-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec03a;

CREATE PROCEDURE "informix".sp_rec03a(
a_compania  CHAR(3),
a_periodo1  CHAR(7),
a_periodo2  CHAR(7),
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*",
a_origen    CHAR(3)   DEFAULT "%",
a_evento    CHAR(255) DEFAULT "*"
) 
RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,DATE,DATE,CHAR(50),CHAR(50),CHAR(50),CHAR(10),CHAR(255); 

DEFINE v_filtros         		CHAR(255);

DEFINE v_numrecla        		CHAR(18);
DEFINE v_no_poliza       		CHAR(20);
DEFINE v_asegurado       		CHAR(100);
DEFINE v_fecha_siniestro 		DATE;     
DEFINE v_fecha_reclamo   		DATE; 
DEFINE v_fecha_documento        DATE;    
DEFINE v_ramo_nombre     		CHAR(50);
DEFINE v_compania_nombre 		CHAR(50);
DEFINE v_ajustador				CHAR(50);
DEFINE v_status                 CHAR(10);

DEFINE _periodo          		CHAR(7);
DEFINE _cod_ramo,_ajust_interno CHAR(3);
DEFINE _estatus_reclamo			CHAR(1);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec03(
a_compania, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
a_ramo,
a_ajustador,
a_agente,
a_origen,
a_evento
);

FOREACH 
 SELECT numrecla,        
		no_poliza,       
		asegurado,       
		fecha_siniestro, 
		fecha_reclamo, 
		fecha_documento,  
		cod_ramo,        
		periodo
   INTO v_numrecla,        
		v_no_poliza,       
		v_asegurado,       
		v_fecha_siniestro, 
		v_fecha_reclamo,
		v_fecha_documento,
		_cod_ramo,
		_periodo
   FROM tmp_sinis
  WHERE seleccionado = 1
  ORDER BY cod_ramo, periodo, numrecla
    
	SELECT ajust_interno,
	       estatus_reclamo
	  INTO _ajust_interno,
	       _estatus_reclamo
	  FROM recrcmae
	 WHERE numrecla = v_numrecla
	   AND actualizado = 1;

    SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo 
	 WHERE cod_ramo = _cod_ramo;

	IF _estatus_reclamo = 'A' THEN
		LET v_status =	'ABIERTO';
	ELIF _estatus_reclamo = 'C' THEN
		LET v_status =	'CERRADO';
	ELIF _estatus_reclamo = 'R' THEN
		LET v_status =	'RE-ABIERTO';
	ELIF _estatus_reclamo = 'T' THEN
		LET v_status =	'EN TRAMITE';
	ELIF _estatus_reclamo = 'D' THEN
		LET v_status =	'DECLINADO';
	ELIF _estatus_reclamo = 'N' THEN
		LET v_status =	'NO APLICA';
	END IF

	RETURN v_numrecla,        
		   v_no_poliza,       
		   v_asegurado,       
		   v_fecha_siniestro, 
		   v_fecha_reclamo,   
		   v_fecha_documento,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_ajustador,
		   v_status,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
                                                     
END PROCEDURE;




