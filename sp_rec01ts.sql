-- Procedimiento que Carga la Siniestralidad mensual por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP procedure sp_rec01ts;
CREATE PROCEDURE "informix".sp_rec01ts(a_periodo  CHAR(7))
RETURNING CHAR(18), 
  		    CHAR(100), 
  		    CHAR(20),
  		    DATE,
  		    DECIMAL(16,2),
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(255),
  		    CHAR(100),
			CHAR(100),
			CHAR(2),
			DECIMAL(16,2),
			DECIMAL(16,2);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE _tipo             CHAR(1);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_corre_nombre    CHAR(100);
DEFINE v_ajust_nombre    CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre,v_agente_nombre     CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo,v_codigo       CHAR(10);
DEFINE v_saber		     CHAR(3);
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);
define _no_registro		 char(10);
define _sac_notrx        integer;
define _res_comprobante	 char(15);
define _parti_reas		 dec(16,2);
define _cnt              integer;
define _cod_ajuest       CHAR(3);
define _nombre_evento	 CHAR(100);
DEFINE _cod_evento		 CHAR(3);
DEFINE _perd_total		 SMALLINT;
DEFINE _perd_total_n	 CHAR(5);  
DEFINE _prima_dev        DECIMAL(16,4);
DEFINE _cnt_dev			 INTEGER; 
DEFINE v_porc_siniest    DECIMAL(16,4); 
DEFINE _return			 integer;  
DEFINE _cont_aj			 integer;  
DEFINE _ajus_nomb        char(100);       

CREATE TEMP TABLE tmp_siniest(
        no_documento         CHAR(20)   ,
		insertado			 SMALLINT   default 1,
	   	pri_dev_aa			 dec(16,2) 	default 0,
		siniestralidad	     dec(16,2) 	default 0,
		incurrido_bruto      dec(16,2)
		) WITH NO LOG;


SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01('001'); 

--Procedimiento de la prima devengada
CALL sp_bo084(a_periodo);

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec01(
'001', 
'001', 
a_periodo, 
a_periodo,
'*', 
'*', 
'002,020;', 
'*', 
'*', 
'*', 
'*',
'*'
); 

FOREACH

 SELECT doc_poliza,
        sum (incurrido_bruto)
   INTO v_doc_poliza,
	    v_incurrido_bruto
   FROM tmp_sinis
  WHERE periodo_reclamo = a_periodo
    AND seleccionado = 1
  GROUP BY doc_poliza
  
   -- Prima Devengada
	SELECT SUM(pri_dev_aa)
	  INTO _prima_dev
	  FROM tmp_dev
	 WHERE no_documento = v_doc_poliza;

     -- Porcentaje de siniestralidad
	 IF _prima_dev = 0 THEN
		IF v_incurrido_bruto = 0 THEN
			LET v_porc_siniest = 0;
		ELSE
			LET v_porc_siniest = 100;
		END IF
	ELSE
	    IF v_incurrido_bruto < 0 THEN
		   LET v_porc_siniest = 0;
		ELSE
		   LET v_porc_siniest = ( v_incurrido_bruto / _prima_dev )*100;
		END IF
	END IF 
       	  
	INSERT INTO tmp_siniest(
	no_documento,		
    pri_dev_aa,		
    siniestralidad,	
    incurrido_bruto
    )
	VALUES(
	v_doc_poliza,
	_prima_dev,
	v_porc_siniest,
	v_incurrido_bruto);

END FOREACH

-- FIN DE FOREACH 

FOREACH 
 SELECT no_reclamo,
		doc_poliza,
		no_poliza,			
 		incurrido_bruto,	
	    cod_ramo,		
		numrecla,
		ajust_interno
   INTO _no_reclamo,
		v_doc_poliza,
		_no_poliza,	   	
   		v_incurrido_bruto,
        _cod_ramo,		
	    v_doc_reclamo,
		_cod_ajuest
   FROM tmp_sinis 
  WHERE periodo_reclamo = a_periodo 
	AND seleccionado = 1
  ORDER BY ajust_interno,cod_ramo,doc_poliza

  FOREACH 
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
		  
		  SELECT nombre
		    INTO v_corre_nombre
		    FROM agtagent
		   WHERE cod_agente = _cod_agente;	
	 EXIT FOREACH;
  END FOREACH

  SELECT cod_evento,
	     cod_reclamante,
	     fecha_siniestro,
	     perd_total
    INTO _cod_evento,
	     _cod_cliente,
	     v_fecha_siniestro,
	     _perd_total
	FROM recrcmae
   WHERE no_reclamo = _no_reclamo;
  
  SELECT nombre
    INTO v_ajust_nombre
    FROM recajust
   WHERE cod_ajustador = _cod_ajuest; 
  	
   SELECT nombre 
     INTO _nombre_evento
     FROM recevent
    WHERE cod_evento = _cod_evento;
			  
   SELECT insertado 
     INTO _cnt
   	 FROM tmp_siniest 
    WHERE no_documento =  v_doc_poliza;
		
   IF _cnt = 1 THEN
		SELECT pri_dev_aa,		
               siniestralidad
		  INTO _prima_dev,
			   v_porc_siniest
		  FROM tmp_siniest
         WHERE no_documento = v_doc_poliza;	  
		
		UPDATE tmp_siniest
		   SET insertado = 0
		 WHERE no_documento = v_doc_poliza;
   END IF 

	--pedida total o perdida parcial
   IF _perd_total = 1 THEN
	   LET _perd_total_n = 'SI';
   ELSE
       LET _perd_total_n = '';
   END IF  
		  
	 
   SELECT nombre
     INTO v_ramo_nombre
     FROM prdramo
    WHERE cod_ramo = _cod_ramo;

   SELECT nombre
     INTO v_cliente_nombre		
     FROM cliclien 
    WHERE cod_cliente = _cod_cliente;  
	 
 
   IF v_porc_siniest IS NULL OR _cnt  = 0 THEN 
      LET v_porc_siniest = 0;
   END IF
	
		
    IF _prima_dev IS NULL  OR _cnt  = 0 THEN 
	    LET _prima_dev = 0;
	END IF

	--IF _cnt  = 0 THEN
	--	LET v_incurrido_bruto = 0;
    -- END IF		
	
	RETURN v_doc_reclamo,
		   v_cliente_nombre, 	
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_incurrido_bruto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_corre_nombre,
		   v_ajust_nombre,
		   _nombre_evento,
		   _perd_total_n,
		   _prima_dev,
		   v_porc_siniest
		   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_dev;
DROP TABLE tmp_siniest;

END PROCEDURE                                                                                                                       
