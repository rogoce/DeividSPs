-- Reporte de las Comisiones por Corredor - Totales

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che167;

CREATE PROCEDURE sp_che167(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7), a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING CHAR(10), CHAR(5), CHAR(50), CHAR(50),CHAR(40),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(5),CHAR(50);		

DEFINE v_nombre_agt, v_nombre_agt2   	CHAR(50);
DEFINE v_monto        	DEC(16,2);
DEFINE v_prima        	DEC(16,2);
DEFINE v_comision     	DEC(16,2);
DEFINE v_monto_t       	DEC(16,2);
DEFINE v_prima_t       	DEC(16,2);
DEFINE v_comision_t    	DEC(16,2);
DEFINE v_nombre_cia   	CHAR(50);
DEFINE v_no_licencia  	CHAR(10);
DEFINE v_monto_vida   	DEC(16,2);
DEFINE v_monto_danos  	DEC(16,2);
DEFINE v_monto_fianza 	DEC(16,2);
DEFINE v_arrastre	  	DEC(16,2);
DEFINE _cod_agente    	CHAR(5);
DEFINE _fecha_ult_comis DATE;  
DEFINE _tipo_pago     	SMALLINT; 
DEFINE _tipo_agente   	CHAR(1);  
DEFINE v_comision2    	DEC(16,2);
DEFINE v_cnt_vida     	SMALLINT;
DEFINE v_cnt_gen      	SMALLINT;
DEFINE v_cnt_fian     	SMALLINT;
DEFINE _fecha_desde   	DATE;
DEFINE _fecha_hasta   	DATE;
DEFINE _fecha_desde2  	DATE;
DEFINE _fecha_hasta2  	DATE;
DEFINE _dia           	CHAR(2);
DEFINE _mes           	CHAR(2);
DEFINE _ano2          	CHAR(4);
DEFINE _no_requis 	  	CHAR(10);
DEFINE v_monto_vida_t	DEC(16,2);
DEFINE v_monto_danos_t	DEC(16,2);
DEFINE v_monto_fianza_t	DEC(16,2);
DEFINE v_agt_nombre     CHAR(50);
DEFINE v_agt_apellido	CHAR(40);
DEFINE _agente_agrupado CHAR(5);
DEFINE _pp_lic_vida     CHAR(10);
DEFINE _pp_lic_general  CHAR(10);
DEFINE _pp_lic_fianza   CHAR(10);
DEFINE _tipo_persona    CHAR(1);
DEFINE _tipo_licencia       CHAR(2);
DEFINE _comision_desc       SMALLINT;
DEFINE _no_recibo           CHAR(10);
DEFINE _no_documento        CHAR(20);
DEFINE _no_poliza           CHAR(10);
DEFINE _cod_ramo        CHAR(3);	 


SET ISOLATION TO DIRTY READ;
CREATE TEMP TABLE tmp_agt_agrupado(
             agente_agrupado CHAR(5),
			 no_licencia    CHAR(50),
			 monto          DEC(16,2),
			 prima          DEC(16,2),
			 comision       DEC(16,2),
			 monto_vid      DEC(16,2),
			 monto_gen      DEC(16,2),
			 monto_fia      DEC(16,2),
			 cod_agente     CHAR(5)
			 ) WITH NO LOG;

LET _dia = "01";
LET _mes = substring(a_periodo from 6 for 7);
LET _ano2 = substring(a_periodo from 1 for 4);

LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);
LET _fecha_hasta = _fecha_desde + 1 UNITS MONTH - 1 UNITS DAY;

LET _fecha_desde2 = date("16/"||_mes||"/"||_ano2);
LET _fecha_hasta2 = _fecha_desde + 1 UNITS MONTH + 14 UNITS DAY;

LET _fecha_desde2 = _fecha_desde;
LET _fecha_hasta2 = _fecha_hasta;


-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
_fecha_desde,
_fecha_hasta,
0,
a_verif_tipo_pago
);

--CALL sp_che163b(a_compania, a_sucursal, a_periodo);

--	set debug file to "sp_che163.trc";
--	trace on;

FOREACH
 SELECT	sum(prima),
		sum(comision),
		cod_agente
   INTO	v_prima,
		v_comision,
		_cod_agente
   FROM	tmp_agente
   GROUP BY cod_agente
  ORDER BY cod_agente
  
 LET v_monto_vida_t = 0.00;
 LET v_monto_danos_t = 0.00;
 LET v_monto_fianza_t = 0.00;
 LET v_monto_t = 0.00;
 LET v_prima_t = 0.00;
 LET v_comision_t = 0.00;

 FOREACH
	SELECT no_requis
	  INTO _no_requis
	  FROM chqchmae
	 WHERE cod_agente = _cod_agente
	   AND fecha_impresion >= _fecha_desde2 
	   AND fecha_impresion <= _fecha_hasta2
	   AND pagado = 1
 	
	FOREACH
		SELECT monto,
		       monto_vida,
		       monto_danos,
			   monto_fianza,
		       prima,
			   comision,
			   no_poliza
		  INTO v_monto,
		       v_monto_vida,
			   v_monto_danos,
			   v_monto_fianza,
			   v_prima,
			   v_comision,
			   _no_poliza
		  FROM chqcomis
		 WHERE no_requis = _no_requis
		   AND comision <> 0
	       AND no_poliza <> '00000'

{		 IF v_monto_vida IS NULL THEN
			LET v_monto_vida = 0.00;
		 END IF
		 IF v_monto_danos IS NULL THEN
			LET v_monto_danos = 0.00;
		 END IF
		 IF v_monto_fianza IS NULL THEN
			LET v_monto_fianza = 0.00;
		 END IF		
}		 
		 IF v_comision IS NULL THEN
			LET v_comision = 0.00;
		 END IF		 
		 IF v_prima IS NULL THEN
			LET v_prima = 0.00;
		 END IF		 

		 SELECT cod_ramo
		   INTO _cod_ramo
		   FROM emipomae
		  WHERE no_poliza = _no_poliza;
		 
		 IF _cod_ramo = '019' THEN
			LET v_monto_vida_t = v_monto_vida_t + v_comision;
		 ELIF _cod_ramo = '004' THEN		
			LET v_monto_vida_t = v_monto_vida_t + v_comision;
		 ELIF _cod_ramo = '018' THEN		
			LET v_monto_vida_t = v_monto_vida_t + v_comision;
		 ELIF _cod_ramo = '016' THEN		
			LET v_monto_vida_t = v_monto_vida_t + v_comision;
		 ELIF _cod_ramo in ('001','021') THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '003' THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '009' THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '017' THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo in ('002','020','023') THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo in ('007','010','011','012','013','014','022') THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '006' THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '005' THEN		
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELIF _cod_ramo = '008' THEN		
			LET v_monto_fianza_t = v_monto_fianza_t + v_comision;
		 ELSE 
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 END IF
		 
--		 LET v_monto_danos_t = v_monto_danos_t + v_monto_danos;
--		 LET v_monto_vida_t = v_monto_vida_t + v_monto_vida;
--		 LET v_monto_fianza_t = v_monto_fianza_t + v_monto_fianza;
		 LET v_monto_t = v_monto_t + v_monto;
		 LET v_prima_t = v_prima_t + v_prima;
		 LET v_comision_t = v_comision_t + v_comision;
	END FOREACH

	FOREACH
		SELECT monto,
		       monto_vida,
		       monto_danos,
			   monto_fianza,
		       prima,
			   comision
		  INTO v_monto,
		       v_monto_vida,
			   v_monto_danos,
			   v_monto_fianza,
			   v_prima,
			   v_comision
		  FROM chqcomis
		 WHERE no_requis = _no_requis
		   AND comision <> 0
	       AND no_poliza = '00000'

		 IF v_monto_vida IS NULL THEN
			LET v_monto_vida = 0.00;
		 END IF
		 IF v_monto_danos IS NULL THEN
			LET v_monto_danos = 0.00;
		 END IF
		 IF v_monto_fianza IS NULL THEN
			LET v_monto_fianza = 0.00;
		 END IF		 
		 IF v_comision IS NULL THEN
			LET v_comision = 0.00;
		 END IF		 
		 IF v_prima IS NULL THEN
			LET v_prima = 0.00;
		 END IF		 
		 
		 LET v_monto_t = v_monto_t + v_monto;
		 LET v_prima_t = v_prima_t + v_prima;
		 LET v_comision_t = v_comision_t + v_comision;
		 
		 IF v_monto_danos_t <> 0 THEN
			LET v_monto_danos_t = v_monto_danos_t + v_comision;
		 ELSE
			IF v_monto_vida_t <> 0 THEN				
				LET v_monto_vida_t = v_monto_vida_t + v_comision;
			ELSE
				LET v_monto_fianza_t = v_monto_fianza_t + v_comision;
			END IF
		 END IF				
	END FOREACH
	
  END FOREACH
  SELECT agente_agrupado
    INTO _agente_agrupado
	FROM agtagent
   WHERE cod_agente = _cod_agente;
  
  SELECT no_licencia,
         tipo_persona,
		 tipo_agente,
		 pp_lic_vida,
		 pp_lic_general,
		 pp_lic_fianza
	INTO v_no_licencia,
	     _tipo_persona,
		 _tipo_agente,
		 _pp_lic_vida,
		 _pp_lic_general,
		 _pp_lic_fianza
	FROM agtagent
   WHERE cod_agente = _agente_agrupado;

  IF _tipo_agente <> 'A' THEN
	CONTINUE FOREACH;
  END IF
  
  IF _tipo_persona = "N" THEN
	LET v_no_licencia = "PN" || v_no_licencia;
  END IF
  IF _tipo_persona = "J" THEN
 	LET v_no_licencia = "PJ" || v_no_licencia;
  END IF
 
  IF _pp_lic_vida IS NOT NULL AND TRIM(_pp_lic_vida) <> "" THEN
	LET v_no_licencia = "PP" || _pp_lic_vida;
  END IF  
  IF _pp_lic_general IS NOT NULL AND TRIM(_pp_lic_general) <> "" THEN
	LET v_no_licencia = "PP" || _pp_lic_general;
  END IF  
  IF _pp_lic_fianza IS NOT NULL AND TRIM(_pp_lic_fianza) <> "" THEN
	LET v_no_licencia = "PP" || _pp_lic_fianza;
  END IF  
  
  INSERT INTO tmp_agt_agrupado(
          agente_agrupado,
	      no_licencia,
		  monto,
		  prima,
		  comision,
		  monto_vid,
		  monto_gen,
		  monto_fia,
		  cod_agente
		  )  
  VALUES (_agente_agrupado,
          v_no_licencia,
		  v_monto_t,
		  v_prima_t,
		  v_comision_t,
		  v_monto_vida_t,
		  v_monto_danos_t,
		  v_monto_fianza_t,
          _cod_agente		  
		  );			   
  
END FOREACH

FOREACH WITH HOLD
	SELECT agente_agrupado,
	       no_licencia,
		   monto,
		   prima,
		   comision,
		   monto_vid,
		   monto_gen,
		   monto_fia,
		   cod_agente
      INTO _agente_agrupado,
           v_no_licencia,
		   v_monto_t,
		   v_prima_t,
		   v_comision_t,
		   v_monto_vida_t,
		   v_monto_danos_t,
		   v_monto_fianza_t,
           _cod_agente
	  FROM tmp_agt_agrupado
 ORDER BY no_licencia, agente_agrupado
 
  SELECT nombre,
         agt_nombre,
         agt_apellido
	INTO v_nombre_agt,
	     v_agt_nombre,
		 v_agt_apellido
	FROM agtagent
   WHERE cod_agente = _agente_agrupado;

  SELECT nombre
	INTO v_nombre_agt2
	FROM agtagent
   WHERE cod_agente = _cod_agente;
   
   
RETURN  v_no_licencia,
        _agente_agrupado,
        v_nombre_agt,
        v_agt_nombre,
        v_agt_apellido,
        v_monto_t,
        v_prima_t,
		v_comision_t,
		v_monto_vida_t,
		v_monto_danos_t,
		v_monto_fianza_t,
  		_cod_agente,
		v_nombre_agt2 WITH RESUME;
END FOREACH

DROP TABLE tmp_agente;
DROP TABLE tmp_agt_agrupado;

--DROP TABLE tmp_tabla;

END PROCEDURE;