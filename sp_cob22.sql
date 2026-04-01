-- Reporte de las Cartas de
-- Recorderis, Avisos de Cancelacion, Primas Ganadas y Vencidas con Saldo
-- 
-- Creado    : 22/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/08/2004 - Autor: Armando Moreno  argumento para cuando es callcenter y cobra poliza
--
-- SIS v.2.0 - d_cobr_sp_cob22a_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_cobr_sp_cob22b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_cob22;
CREATE PROCEDURE "informix".sp_cob22(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_sucursal CHAR(3) DEFAULT '*',a_agente CHAR(5) DEFAULT '*',a_ramo CHAR(3) DEFAULT '*',a_acreedor	CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0)
 RETURNING  CHAR(100),	-- Asegurado
		    CHAR(20),	-- Poliza 
		    DATE,     	-- Vigencia Inic	
		    DATE,     	-- Vigencia Final
		    DEC(16,2),	-- Prima
		    DEC(16,2),	-- Saldo
		    DEC(16,2),  -- Por Vencer
		    DEC(16,2),	-- Exigible
		    DEC(16,2),	-- Corriente
		    DEC(16,2),	-- 30 Dias
		    DEC(16,2),	-- 60 Dias
		    DEC(16,2),	-- 90 Dias
		    CHAR(50), 	-- Agente
		    SMALLINT,	-- Ano
		    CHAR(50), 	-- Cobrador
		    CHAR(50), 	-- Compania
			CHAR(50);   -- forma de pago

DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_vigencia_inic   DATE;     
DEFINE v_vigencia_final  DATE;     
DEFINE v_prima_orig      DEC(16,2);
DEFINE v_saldo           DEC(16,2);
DEFINE v_por_vencer      DEC(16,2);
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente       DEC(16,2);
DEFINE v_monto_30        DEC(16,2);
DEFINE v_monto_60        DEC(16,2);
DEFINE v_monto_90        DEC(16,2);
DEFINE v_nombre_agente   CHAR(50); 
DEFINE v_ano             SMALLINT;
DEFINE v_nombre_cobrador CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_nombre_formapag CHAR(50);
DEFINE _cod_cliente      CHAR(10);
DEFINE _no_poliza        CHAR(20);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cobrador     CHAR(3); 
DEFINE _cod_formapag     CHAR(3);
define _cobra_poliza	 char(1);

SET ISOLATION TO DIRTY READ;

IF a_sucursal = '%'	THEN
	LET a_sucursal = '*';
END IF

IF a_agente = '%'	THEN
	LET a_agente = '*';
END IF

IF a_ramo = '%'	THEN
	LET a_ramo = '*';
END IF

IF a_acreedor = '%'	THEN
	LET a_acreedor = '*';
END IF

IF a_asegurado = '%'	THEN
	LET a_asegurado = '*';
END IF

IF a_cobrador = '%'	THEN
	LET a_cobrador = '*';
END IF

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Cobrador

SELECT nombre
  INTO v_nombre_cobrador
  FROM cobcobra
 WHERE cod_cobrador = a_cobrador;

if a_callcenter = 0 then	--se puso temporalmente a 3=consumo, segun instr. de correo de Enilda. 05/09/2011
	let _cobra_poliza = "3"; --let _cobra_poliza = "C";
else
	let _cobra_poliza = "*"; --let _cobra_poliza = "E";
end if
-- Reporte de las Cartas a Imprimir

FOREACH 
 SELECT cod_cliente,
		no_poliza,
		prima,
		saldo,
		por_vencer,  
		exigible,    
		corriente,   
		monto_30,    
		monto_60,    
		monto_90,
		cod_agente,
		ano,
		nombre_agente,
		nombre_cliente,
		cod_cobrador,
	    no_documento,
		vigencia_inic,
		vigencia_final	
   INTO _cod_cliente,
		_no_poliza,
		v_prima_orig,
		v_saldo,
		v_por_vencer,  
		v_exigible,    
		v_corriente,   
		v_monto_30,    
		v_monto_60,    
		v_monto_90,
		_cod_agente,
		v_ano,
		v_nombre_agente,
		v_nombre_cliente,
		_cod_cobrador,
	    v_doc_poliza,
		v_vigencia_inic,
		v_vigencia_final	
   FROM cobaviso
  WHERE cod_cobrador MATCHES a_cobrador
	AND cod_sucursal MATCHES a_sucursal
	AND cod_agente   MATCHES a_agente
	AND cod_ramo     MATCHES a_ramo
	AND cod_acreedor MATCHES a_acreedor
	AND cod_cliente  MATCHES a_asegurado
    AND tipo_aviso   = a_tipo_aviso
	AND impreso      = 0
	AND imprimir     = "1"
	AND cobra_poliza MATCHES _cobra_poliza
  ORDER BY cod_cobrador, ano, nombre_agente, nombre_cliente, no_documento

	  SELECT cod_formapag
	    INTO _cod_formapag
	    FROM emipomae
       WHERE no_poliza = _no_poliza;

	  SELECT nombre
	    INTO v_nombre_formapag
	    FROM cobforpa
       WHERE cod_formapag = _cod_formapag;              

	RETURN v_nombre_cliente,  
		   v_doc_poliza,      
		   v_vigencia_inic,   
		   v_vigencia_final,  
		   v_prima_orig,      
		   v_saldo,           
		   v_por_vencer,      
		   v_exigible,        
		   v_corriente,       
		   v_monto_30,        
		   v_monto_60,        
		   v_monto_90,        
		   v_nombre_agente,   
		   v_ano,             
		   v_nombre_cobrador, 
		   v_compania_nombre,
		   v_nombre_formapag
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

