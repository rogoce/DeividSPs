-- Reporte de las Comisiones por Corredor - Totales

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che163;

CREATE PROCEDURE sp_che163(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7), a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING	CHAR(10),	
            CHAR(50), 
			CHAR(50),
			CHAR(40),
			DEC(16,2),
			DEC(16,2),	
			DEC(16,2),	
			INTEGER,
			INTEGER,
			INTEGER,
			CHAR(50),
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2),	
			DEC(16,2);	

DEFINE v_nombre_agt   	CHAR(50);
DEFINE v_monto        	DEC(16,2);
DEFINE v_prima        	DEC(16,2);
DEFINE v_comision     	DEC(16,2);
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
DEFINE _prima_vid       DEC(16,2);
DEFINE _prima_gen       DEC(16,2);
DEFINE _prima_fia       DEC(16,2);
DEFINE _prima_v_ind_1	DEC(16,2);
DEFINE _prima_v_ind_2	DEC(16,2);
DEFINE _prima_acc	    DEC(16,2); 			 
DEFINE _prima_salud     DEC(16,2); 		
DEFINE _prima_colec	    DEC(16,2);		 
DEFINE _prima_incen	    DEC(16,2);		 
DEFINE _prima_multi	    DEC(16,2);		 
DEFINE _prima_trans	    DEC(16,2);		 
DEFINE _prima_casco	    DEC(16,2);	
DEFINE _prima_auto  	DEC(16,2);		 
DEFINE _prima_tec  	    DEC(16,2);		 
DEFINE _prima_r_civil	DEC(16,2);		 
DEFINE _prima_robo 	    DEC(16,2);		 
DEFINE _prima_fianza	DEC(16,2);		 
DEFINE _prima_otro 	    DEC(16,2);	
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);	 
DEFINE _nueva_renov     CHAR(1);	 
DEFINE _comision_v_ind_1	DEC(16,2);
DEFINE _comision_v_ind_2	DEC(16,2);
DEFINE _comision_acc	    DEC(16,2); 			 
DEFINE _comision_salud     DEC(16,2); 		
DEFINE _comision_colec	    DEC(16,2);		 
DEFINE _comision_incen	    DEC(16,2);		 
DEFINE _comision_multi	    DEC(16,2);		 
DEFINE _comision_trans	    DEC(16,2);		 
DEFINE _comision_casco	    DEC(16,2);	
DEFINE _comision_auto  	DEC(16,2);		 
DEFINE _comision_tec  	    DEC(16,2);		 
DEFINE _comision_r_civil	DEC(16,2);		 
DEFINE _comision_robo 	    DEC(16,2);		 
DEFINE _comision_fianza	DEC(16,2);		 
DEFINE _comision_otro 	    DEC(16,2);	

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_agt_agrupado(
             agente_agrupado CHAR(5),
			 no_licencia    CHAR(50),
			 cnt_vid        SMALLINT,
			 cnt_gen        SMALLINT,
			 cnt_fia        SMALLINT,
			 monto_vid      DEC(16,2),
			 monto_gen      DEC(16,2),
			 monto_fia      DEC(16,2),
             prima_vid      DEC(16,2),
             prima_gen      DEC(16,2),
             prima_fia      DEC(16,2),
             prima_v_ind_1	DEC(16,2),
             prima_v_ind_2	DEC(16,2),
             prima_acc	    DEC(16,2), 			 
             prima_salud    DEC(16,2), 		
             prima_colec	DEC(16,2),		 
             prima_incen	DEC(16,2),		 
             prima_multi	DEC(16,2),		 
             prima_trans	DEC(16,2),		 
             prima_casco	DEC(16,2),	
             prima_auto  	DEC(16,2),		 
             prima_tec  	DEC(16,2),		 
             prima_r_civil	DEC(16,2),		 
             prima_robo 	DEC(16,2),		 
             prima_fianza	DEC(16,2),		 
             prima_otro 	DEC(16,2),
             comision_v_ind_1 DEC(16,2),			 
             comision_v_ind_2	DEC(16,2),
             comision_acc	    DEC(16,2), 			 
			 comision_salud     DEC(16,2), 		
			 comision_colec	    DEC(16,2),		 
			 comision_incen	    DEC(16,2),		 
			 comision_multi	    DEC(16,2),		 
			 comision_trans	    DEC(16,2),		 
			 comision_casco	    DEC(16,2),	
			 comision_auto  	DEC(16,2),		 
			 comision_tec  	    DEC(16,2),		 
			 comision_r_civil	DEC(16,2),		 
			 comision_robo 	    DEC(16,2),		 
			 comision_fianza	DEC(16,2),		 
			 comision_otro 	    DEC(16,2)	
			 ) WITH NO LOG;

LET _dia = "01";
LET _mes = substring(a_periodo from 6 for 7);
LET _ano2 = substring(a_periodo from 1 for 4);

LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);
LET _fecha_hasta = _fecha_desde + 1 UNITS MONTH - 1 UNITS DAY;

LET _fecha_desde2 = date("16/"||_mes||"/"||_ano2);
LET _fecha_hasta2 = _fecha_desde + 1 UNITS MONTH + 14 UNITS DAY;

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

CALL sp_che163b(a_compania, a_sucursal, a_periodo);

--SET DEBUG FILE TO "c:\sp_che04.trc";
--TRACE ON;

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
 LET _prima_vid = 0.00;
 LET _prima_gen = 0.00;
 LET _prima_fia = 0.00;
 LET _prima_v_ind_1 = 0.00;
 LET _prima_v_ind_2 = 0.00;
 LET _prima_acc = 0.00; 			 
 LET _prima_salud = 0.00; 		
 LET _prima_colec = 0.00;		 
 LET _prima_incen = 0.00;		 
 LET _prima_multi = 0.00;		 
 LET _prima_trans = 0.00;		 
 LET _prima_casco = 0.00;	
 LET _prima_auto = 0.00;		 
 LET _prima_tec = 0.00;		 
 LET _prima_r_civil = 0.00;		 
 LET _prima_robo = 0.00;		 
 LET _prima_fianza = 0.00;		 
 LET _prima_otro = 0.00;		 
 LET _comision_v_ind_1 = 0.00;
 LET _comision_v_ind_2 = 0.00;
 LET _comision_acc = 0.00; 			 
 LET _comision_salud = 0.00; 		
 LET _comision_colec = 0.00;		 
 LET _comision_incen = 0.00;		 
 LET _comision_multi = 0.00;		 
 LET _comision_trans = 0.00;		 
 LET _comision_casco = 0.00;
 LET _comision_auto = 0.00;		 
 LET _comision_tec  = 0.00;		 
 LET _comision_r_civil = 0.00;		 
 LET _comision_robo  = 0.00;	 
 LET _comision_fianza = 0.00;		 
 LET _comision_otro  = 0.00;	

 FOREACH
	SELECT no_requis
	  INTO _no_requis
	  FROM chqchmae
	 WHERE cod_agente = _cod_agente
	   AND fecha_impresion >= _fecha_desde2 
	   AND fecha_impresion <= _fecha_hasta2
	   AND pagado = 1
    
	FOREACH
		SELECT monto_vida,
			   monto_danos,
			   monto_fianza,
			   prima,
			   no_poliza,
			   comision
		  INTO v_monto_vida,
			   v_monto_danos,
			   v_monto_fianza,
			   v_prima,
			   _no_poliza,
			   v_comision
		  FROM chqcomis
		 WHERE no_requis = _no_requis
		   AND comision <> 0

		 IF v_monto_vida IS NULL THEN
			LET v_monto_vida = 0.00;
		 END IF
		 IF v_monto_danos IS NULL THEN
			LET v_monto_danos = 0.00;
		 END IF
		 IF v_monto_fianza IS NULL THEN
			LET v_monto_fianza = 0.00;
		 END IF
		 IF v_prima IS NULL THEN
			LET v_prima = 0.00;
		 END IF
		 
		 IF v_monto_vida <> 0.00 THEN
			LET _prima_vid = _prima_vid + v_prima;
		 END IF
		 IF v_monto_danos <> 0.00 THEN
			LET _prima_gen = _prima_gen + v_prima;
		 END IF
		 IF v_monto_fianza <> 0.00 THEN
			LET _prima_fia = _prima_fia + v_prima;
		 END IF

		 LET v_monto_vida_t = v_monto_vida_t + v_monto_vida;
		 LET v_monto_danos_t = v_monto_danos_t + v_monto_danos;
		 LET v_monto_fianza_t = v_monto_fianza_t + v_monto_fianza;
		 
		 IF _no_poliza <> "00000" then
			 SELECT cod_ramo,
			        nueva_renov
			   INTO _cod_ramo,
			        _nueva_renov
			   FROM emipomae
			  WHERE no_poliza = _no_poliza;
			  
			 IF _cod_ramo = '019' THEN
			    IF _nueva_renov = 'N' THEN
					LET _prima_v_ind_1 = _prima_v_ind_1 + v_prima;
					LET _comision_v_ind_1 = _comision_v_ind_1 + v_comision;
				ELSE 
					LET _prima_v_ind_2 = _prima_v_ind_1 + v_prima;
					LET _comision_v_ind_2 = _comision_v_ind_2 + v_comision;
				END IF
             ELIF _cod_ramo = '004' THEN		
				LET _prima_acc = _prima_acc + v_prima;
				LET _comision_acc = _comision_acc + v_comision;
             ELIF _cod_ramo = '018' THEN		
				LET _prima_salud = _prima_salud + v_prima;
				LET _comision_salud = _comision_salud + v_comision;
             ELIF _cod_ramo = '016' THEN		
				LET _prima_colec = _prima_colec + v_prima;
				LET _comision_colec = _comision_colec + v_comision;
             ELIF _cod_ramo in ('001','021') THEN		
				LET _prima_incen = _prima_incen + v_prima;
				LET _comision_incen = _comision_incen + v_comision;
             ELIF _cod_ramo = '003' THEN		
				LET _prima_multi = _prima_multi + v_prima;
				LET _comision_multi = _comision_multi + v_comision;
             ELIF _cod_ramo = '009' THEN		
				LET _prima_trans = _prima_trans + v_prima;
				LET _comision_trans = _comision_trans + v_comision;
             ELIF _cod_ramo = '017' THEN		
				LET _prima_casco = _prima_casco + v_prima;
				LET _comision_casco = _comision_casco + v_comision;
             ELIF _cod_ramo in ('002','020','023') THEN		
				LET _prima_auto = _prima_auto + v_prima;
				LET _comision_auto = _comision_auto + v_comision;
             ELIF _cod_ramo in ('007','010','011','012','013','014','022') THEN		
				LET _prima_tec = _prima_tec + v_prima;
				LET _comision_tec = _comision_tec + v_comision;
             ELIF _cod_ramo = '006' THEN		
				LET _prima_r_civil = _prima_r_civil + v_prima;
				LET _comision_r_civil = _comision_r_civil + v_comision;
             ELIF _cod_ramo = '005' THEN		
				LET _prima_robo = _prima_robo + v_prima;
				LET _comision_robo = _comision_robo + v_comision;
             ELIF _cod_ramo = '008' THEN		
				LET _prima_fianza = _prima_fianza + v_prima;
				LET _comision_fianza = _comision_fianza + v_comision;
			 ELSE 
				LET _prima_otro = _prima_otro + v_prima;
				LET _comision_otro = _comision_otro + v_comision;
			 END IF
		 END IF	 

		 IF _no_poliza = "00000" then
			LET _comision_auto = _comision_auto + v_comision;		 
		 END IF
    END FOREACH
  END FOREACH


  LET v_cnt_vida = 0;
  LET v_cnt_gen  = 0;
  LET v_cnt_fian = 0;

  SELECT SUM(cnt_vid),
    	 SUM(cnt_gen),
		 SUM(cnt_fia)
	INTO v_cnt_vida,
	     v_cnt_gen,
		 v_cnt_fian
	FROM tmp_tabla
   WHERE cod_corredor = _cod_agente;

  IF v_cnt_vida IS NULL THEN
     LET v_cnt_vida = 0;
  END IF
  IF v_cnt_gen IS NULL THEN
     LET v_cnt_gen = 0;
  END IF
  IF v_cnt_fian IS NULL THEN
    LET v_cnt_fian = 0;
  END IF

  IF v_monto_vida_t + v_monto_danos_t + v_monto_fianza_t + v_cnt_vida + v_cnt_gen + v_cnt_fian = 0 THEN
     CONTINUE FOREACH;
  END IF

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
		  cnt_vid,
		  cnt_gen, 
		  cnt_fia,
		  monto_vid,
		  monto_gen,
		  monto_fia,
		  prima_vid,
		  prima_gen,
		  prima_fia,
		  prima_v_ind_1,
		  prima_v_ind_2,
		  prima_acc, 			 
		  prima_salud, 		
		  prima_colec,		 
		  prima_incen,		 
		  prima_multi,		 
		  prima_trans,		 
		  prima_casco,	
		  prima_auto,		 
		  prima_tec,		 
		  prima_r_civil,		 
		  prima_robo,		 
		  prima_fianza,		 
		  prima_otro,		 
		  comision_v_ind_1,			 
		  comision_v_ind_2,
		  comision_acc, 			 
		  comision_salud, 		
		  comision_colec,		 
		  comision_incen,		 
		  comision_multi,		 
		  comision_trans,		 
		  comision_casco,	
		  comision_auto,		 
		  comision_tec,		 
		  comision_r_civil,		 
		  comision_robo,		 
		  comision_fianza,		 
		  comision_otro	
		  )  
  VALUES (_agente_agrupado,
          v_no_licencia,
		  v_cnt_vida,
		  v_cnt_gen,
		  v_cnt_fian,
		  v_monto_vida_t,
		  v_monto_danos_t,
		  v_monto_fianza_t,
          _prima_vid,
          _prima_gen,
          _prima_fia,
          _prima_v_ind_1,
          _prima_v_ind_2,
          _prima_acc, 			 
          _prima_salud, 		
          _prima_colec,		 
          _prima_incen,		 
          _prima_multi,		 
          _prima_trans,		 
          _prima_casco,	
          _prima_auto,		 
          _prima_tec,		 
          _prima_r_civil,		 
          _prima_robo,		 
          _prima_fianza,		 
          _prima_otro,		 
		  _comision_v_ind_1,			 
		  _comision_v_ind_2,
		  _comision_acc, 			 
		  _comision_salud, 		
		  _comision_colec,		 
		  _comision_incen,		 
		  _comision_multi,		 
		  _comision_trans,		 
		  _comision_casco,	
		  _comision_auto,		 
		  _comision_tec,		 
		  _comision_r_civil,		 
		  _comision_robo,		 
		  _comision_fianza,		 
		  _comision_otro	
		  );			   
END FOREACH

FOREACH WITH HOLD
   SELECT agente_agrupado,
	      no_licencia,
		  sum(cnt_vid),
		  sum(cnt_gen), 
		  sum(cnt_fia),
		  sum(monto_vid),
		  sum(monto_gen),
		  sum(monto_fia),
		  sum(prima_vid),
		  sum(prima_gen),
		  sum(prima_fia),
		  sum(prima_v_ind_1),
		  sum(prima_v_ind_2),
		  sum(prima_acc), 			 
		  sum(prima_salud), 		
		  sum(prima_colec),		 
		  sum(prima_incen),		 
		  sum(prima_multi),		 
		  sum(prima_trans),		 
		  sum(prima_casco),	
		  sum(prima_auto),		 
		  sum(prima_tec),		 
		  sum(prima_r_civil),		 
		  sum(prima_robo),		 
		  sum(prima_fianza),		 
		  sum(prima_otro),		 
		  sum(comision_v_ind_1),			 
		  sum(comision_v_ind_2),
		  sum(comision_acc), 			 
		  sum(comision_salud), 		
		  sum(comision_colec),		 
		  sum(comision_incen),		 
		  sum(comision_multi),		 
		  sum(comision_trans),		 
		  sum(comision_casco),	
		  sum(comision_auto),		 
		  sum(comision_tec),		 
		  sum(comision_r_civil),		 
		  sum(comision_robo),		 
		  sum(comision_fianza),		 
		  sum(comision_otro)	
	 INTO _agente_agrupado,
          v_no_licencia,
		  v_cnt_vida,
		  v_cnt_gen,
		  v_cnt_fian,
		  v_monto_vida_t,
		  v_monto_danos_t,
		  v_monto_fianza_t,
          _prima_vid,
          _prima_gen,
          _prima_fia,
          _prima_v_ind_1,
          _prima_v_ind_2,
          _prima_acc, 			 
          _prima_salud, 		
          _prima_colec,		 
          _prima_incen,		 
          _prima_multi,		 
          _prima_trans,		 
          _prima_casco,	
          _prima_auto,		 
          _prima_tec,		 
          _prima_r_civil,		 
          _prima_robo,		 
          _prima_fianza,		 
          _prima_otro,		 
		  _comision_v_ind_1,			 
		  _comision_v_ind_2,
		  _comision_acc, 			 
		  _comision_salud, 		
		  _comision_colec,		 
		  _comision_incen,		 
		  _comision_multi,		 
		  _comision_trans,		 
		  _comision_casco,	
		  _comision_auto,		 
		  _comision_tec,		 
		  _comision_r_civil,		 
		  _comision_robo,		 
		  _comision_fianza,		 
		  _comision_otro	
     FROM tmp_agt_agrupado
 GROUP BY no_licencia, agente_agrupado
 ORDER BY no_licencia, agente_agrupado
 
  SELECT nombre,
         agt_nombre,
         agt_apellido
	INTO v_nombre_agt,
	     v_agt_nombre,
		 v_agt_apellido
	FROM agtagent
   WHERE cod_agente = _agente_agrupado;
 
  RETURN  v_no_licencia,
	      v_nombre_agt,
		  v_agt_nombre,
		  v_agt_apellido,
		  v_monto_vida_t,
		  v_monto_danos_t,
		  v_monto_fianza_t,
		  v_cnt_vida,
		  v_cnt_gen,
		  v_cnt_fian,
		  v_nombre_cia,
          _prima_vid,
          _prima_gen,
          _prima_fia,
          _prima_v_ind_1,
		  _comision_v_ind_1,			 
          _prima_v_ind_2,
   		  _comision_v_ind_2,
          _prima_acc, 			 
		  _comision_acc, 			 
          _prima_salud, 		
		  _comision_salud, 		
          _prima_colec,		 
		  _comision_colec,		 
          _prima_incen,		 
		  _comision_incen,		 
          _prima_multi,		 
		  _comision_multi,		 
          _prima_trans,		 
 		  _comision_trans,		 
          _prima_casco,	
  		  _comision_casco,	
          _prima_auto,		 
		  _comision_auto,		 
          _prima_tec,		 
 		  _comision_tec,		 
          _prima_r_civil,		 
  		  _comision_r_civil,		 
          _prima_robo,		 
 		  _comision_robo,		 
          _prima_fianza,		 
 		  _comision_fianza,		 
          _prima_otro,		 
		  _comision_otro	
		  WITH RESUME;
END FOREACH

DROP TABLE tmp_agente;
DROP TABLE tmp_tabla;
DROP TABLE tmp_agt_agrupado;

END PROCEDURE;