-- Procedimiento que Genera el correo de la siniestralidad de ajustadores 
-- 
-- Creado    : 22/04/2014 - Autor: Angel Tello
-- 
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_rec01cor;
CREATE PROCEDURE "informix".sp_rec01cor(a_periodo CHAR(7)
) RETURNING CHAR(100),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);

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
DEFINE _return			  integer;  
DEFINE _cont_aj			  integer;  
DEFINE _ajus_nomb         char(100);       
DEFINE _periodo1          char(7);
DEFINE _periodo2		  char(7);
define _ano_char		  char(4);
DEFINE _sinis_anual		  DEC(16,2);
DEFINE _mes_char          CHAR(2);
DEFINE _ano_evaluar		  smallint;
DEFINE _nombre_ajustador  CHAR(100);
DEFINE _prima_dev_anu     DEC(16,2);	
DEFINE _prima_dev_acu     DEC(16,2);	
DEFINE _prima_dev_men     DEC(16,2);
DEFINE _incu_bruto_anu    DEC(16,2);
DEFINE _incu_bruto_acu    DEC(16,2);
DEFINE _incu_bruto_men    DEC(16,2);
DEFINE _fecha_siniestro   date;
DEFINE _ano_siniestro     CHAR(4);
DEFINE _verificador 	  smallint;


CREATE TEMP TABLE tmp_siniest(
	   nombre_ajustador 	CHAR(20),		
	   prima_dev_anu    	DEC(16,2),
	   prima_dev_acu        DEC(16,2),
	   prima_dev_men    	DEC(16,2),
	   incurrido_bruto_anu	DEC(16,2),
	   incurrido_bruto_acu	DEC(16,2),
	   incurrido_bruto_men	DEC(16,2),
	   men_anual            CHAR(2)
	   ) WITH NO LOG;	

CREATE TEMP TABLE tmp_verficador(
	   no_documento 	CHAR(20)
	   ) WITH NO LOG;		   
	   
	   

SET ISOLATION TO DIRTY READ;

--PROCESO ANUAL	***********************************

--ARMAR PERIODO 1 Y PERDIODO 2
IF  MONTH(today) < 10 THEN
   	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF

LET _ano_char = YEAR(today);


LET _periodo1   = _ano_char || "-" || "01";
LET _periodo2   = _ano_char || "-" || _mes_char;

--Procedimiento de la prima devengada
CALL  sp_bo084(_periodo2);

-- Cargar el Incurrido

--set debug file to "sp_pro43.trc";	
--trace on;


LET v_filtros = sp_rec01(
'001', 
'001', 
_periodo1, 
_periodo2,
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

  SELECT no_reclamo
    INTO _no_reclamo
	FROM tmp_sinis
   WHERE seleccionado = 1

  SELECT fecha_siniestro
    INTO _fecha_siniestro
	FROM recrcmae
   WHERE no_reclamo = _no_reclamo;

  LET _ano_siniestro = YEAR(_fecha_siniestro);

  IF _ano_siniestro = _ano_char THEN
  ELSE
     UPDATE tmp_sinis
        SET seleccionado = 0
      WHERE no_reclamo   = _no_reclamo;
  END IF      	

END FOREACH

FOREACH 
 
 SELECT no_poliza,
 		incurrido_bruto,	
	    ajust_interno
   INTO	_no_poliza,
   		v_incurrido_bruto,	
	    _cod_ajuest
   FROM tmp_sinis 
  WHERE periodo_reclamo >= _periodo1
    AND periodo_reclamo <= _periodo2 
	AND seleccionado = 1
  ORDER BY ajust_interno
  
	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _ajus_nomb
	  FROM recajust
	 WHERE cod_ajustador = _cod_ajuest;
	
	SELECT COUNT(*)
	  INTO _verificador
	  FROM tmp_verficador
	 WHERE no_documento = v_doc_poliza;
	 
	IF _verificador = 0 THEN
		-- Prima Devengada
		SELECT SUM(pri_dev_aa)
		  INTO _prima_dev
		  FROM tmp_dev
		 WHERE no_documento = v_doc_poliza;
	ELSE 
		LET _prima_dev = 0;
	END IF  
	
	
	IF _prima_dev IS NULL THEN 
	   LET _prima_dev = 0;
	END IF
	 
    INSERT INTO tmp_siniest (nombre_ajustador,
							  prima_dev_anu,
							  incurrido_bruto_anu,
							  men_anual) 
					  VALUES (_ajus_nomb,
							  _prima_dev,
							  v_incurrido_bruto,
				              "A");
							  
	INSERT INTO tmp_verficador(
	no_documento		
    )
	VALUES(
	v_doc_poliza);
							  

END FOREACH

--DROP TABLE tmp_sinis;
DROP TABLE tmp_dev;

UPDATE tmp_sinis
   SET seleccionado = 1
 WHERE cod_ramo in('002','020'); 

 DELETE FROM tmp_verficador;

--ARMAR PERIODO ACUMULADOS ----------------------------------------------------------------------------------------------

IF  MONTH(today) < 10 THEN
   	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF

LET _ano_char = YEAR(today);


LET _periodo1   = _ano_char || "-" || "01";
LET _periodo2   = _ano_char || "-" || _mes_char;


--Procedimiento de la prima devengada PROCESO ACUMULADOS
CALL  sp_bo084(_periodo2);

{LET v_filtros = sp_rec01(
'001', 
'001', 
_periodo1, 
_periodo2,
'*', 
'*', 
'002,020;', 
'*', 
'*', 
'*', 
'*',
'*'
); }


FOREACH 
 SELECT no_poliza,
 		incurrido_bruto,	
	    ajust_interno
   INTO	_no_poliza,
   		v_incurrido_bruto,	
	    _cod_ajuest
   FROM tmp_sinis 
  WHERE periodo_reclamo >= _periodo1
    AND periodo_reclamo <= _periodo2 
	AND seleccionado = 1
  ORDER BY ajust_interno
  
	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _ajus_nomb
	  FROM recajust
	 WHERE cod_ajustador = _cod_ajuest;


    SELECT COUNT(*)
	  INTO _verificador
	  FROM tmp_verficador
	 WHERE no_documento = v_doc_poliza;

   
     IF _verificador = 0 THEN
		-- Prima Devengada
		SELECT SUM(pri_dev_aa)
		  INTO _prima_dev
		  FROM tmp_dev
		 WHERE no_documento = v_doc_poliza;
	ELSE 
		LET _prima_dev = 0;
	END IF  
	
	
	IF _prima_dev IS NULL THEN 
	   LET _prima_dev = 0;
	END IF
	 
    INSERT INTO tmp_siniest (nombre_ajustador,
							  prima_dev_acu,
							  incurrido_bruto_acu,
							  men_anual) 
					  VALUES (_ajus_nomb,
							  _prima_dev,
							  v_incurrido_bruto,
				              "AC");
							  
	INSERT INTO tmp_verficador(
	no_documento		
    )
	VALUES(
	v_doc_poliza);
							  
END FOREACH

--DROP TABLE tmp_sinis;
DROP TABLE tmp_dev;	
 DELETE FROM tmp_verficador;

--ARMAR PERDIODO MENSUAL--------------------------------------------------------------------------------------------------------
IF  MONTH(today) < 10 THEN
	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF
LET _ano_char = YEAR(today);

LET _periodo2  = _ano_char || "-" || _mes_char;


--Procedimiento de la prima devengada
CALL  sp_bo084(_periodo2);

{LET v_filtros = sp_rec01(
'001', 
'001', 
_periodo2, 
_periodo2,
'*', 
'*', 
'002,020;', 
'*', 
'*', 
'*', 
'*',
'*'
);}

FOREACH 
 SELECT no_poliza,
 		incurrido_bruto,	
	    ajust_interno
   INTO	_no_poliza,
   		v_incurrido_bruto,	
	    _cod_ajuest
   FROM tmp_sinis 
  WHERE periodo_reclamo >= _periodo2
    AND periodo_reclamo <= _periodo2 
	AND seleccionado = 1
  ORDER BY ajust_interno
  
	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _ajus_nomb
	  FROM recajust
	 WHERE cod_ajustador = _cod_ajuest;
	
	SELECT COUNT(*)
	  INTO _verificador
	  FROM tmp_verficador
	 WHERE no_documento = v_doc_poliza;
	 
	IF _verificador = 0 THEN
		-- Prima Devengada
		SELECT SUM(pri_dev_aa)
		  INTO _prima_dev
		  FROM tmp_dev
		 WHERE no_documento = v_doc_poliza;
	ELSE 
		LET _prima_dev = 0;
	END IF  
	 
	IF _prima_dev IS NULL THEN 
	   LET _prima_dev = 0;
	END IF
	 
	 INSERT INTO tmp_siniest (nombre_ajustador,
							  prima_dev_men,
							  incurrido_bruto_men,
				              men_anual) 
	                  VALUES (_ajus_nomb,
							  _prima_dev,
				              v_incurrido_bruto,
			            	  "ME");

	INSERT INTO tmp_verficador(
	no_documento		
    )
	VALUES(
	v_doc_poliza);						  
							  
END FOREACH	

DROP TABLE tmp_sinis;
DROP TABLE tmp_dev;	

FOREACH

SELECT  nombre_ajustador,	
        prima_dev_anu,    	
        prima_dev_acu,   	
        prima_dev_men,    	
        incurrido_bruto_anu,	
        incurrido_bruto_acu,	
        incurrido_bruto_men	
   INTO _nombre_ajustador, 
        _prima_dev_anu,   
        _prima_dev_acu,   
        _prima_dev_men,   
        _incu_bruto_anu,  
        _incu_bruto_acu,  
        _incu_bruto_men  
   FROM tmp_siniest
   ORDER BY nombre_ajustador
   
   RETURN _nombre_ajustador, 
          _prima_dev_anu,   
          _prima_dev_acu,   
          _prima_dev_men,   
          _incu_bruto_anu,  
          _incu_bruto_acu,  
          _incu_bruto_men 
		  WITH RESUME;
   
END FOREACH 
	   
DROP TABLE tmp_siniest;	
DROP TABLE tmp_verficador;	

END PROCEDURE                                                                                                                       
