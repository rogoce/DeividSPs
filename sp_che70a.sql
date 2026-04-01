-- Procedimiento que Carga las Comisiones Descontadas por Corredor

-- Creado    : 02/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che70a;

CREATE PROCEDURE sp_che70a(a_fecha_desde DATE, a_fecha_hasta DATE)

RETURNING   CHAR(50),
            DEC(16,2),
            DEC(16,2),
			DEC(16,2),
            CHAR(10),
			CHAR(1),
			VARCHAR(30),
			CHAR(2);

DEFINE _cod_agente   CHAR(5);  
DEFINE _no_poliza    CHAR(10); 
DEFINE _no_remesa    CHAR(10); 
DEFINE _renglon      SMALLINT;  
DEFINE _monto        DEC(16,2);
DEFINE _gen_cheque   SMALLINT; 
DEFINE _no_recibo    CHAR(10); 
DEFINE _fecha        DATE;     
DEFINE _prima        DEC(16,2);
DEFINE _porc_partic  DEC(5,2); 
DEFINE _porc_comis   DEC(5,2); 
DEFINE _comision     DEC(16,2);
DEFINE _nombre       CHAR(50); 
DEFINE _no_documento CHAR(20); 
DEFINE _no_requis    CHAR(10); 
DEFINE _cod_tipoprod CHAR(3);
DEFINE _tipo_prod    SMALLINT;
DEFINE _cod_tiporamo CHAR(3);
DEFINE _tipo_ramo    SMALLINT;
DEFINE _cod_ramo     CHAR(3);
DEFINE _no_licencia  CHAR(10);

DEFINE v_cuenta		 CHAR(25);
DEFINE v_debito		 DEC(16,2);
DEFINE v_credito	 DEC(16,2);
DEFINE v_no_cheque	 CHAR(10);
DEFINE v_nombre_ben	 CHAR(100);
DEFINE _anulado		 SMALLINT;
DEFINE v_fecha_imp	 DATE;
DEFINE v_monto		 DEC(16,2);
DEFINE _tipo_persona CHAR(1);
DEFINE _comi_ck		 DEC(16,2);
DEFINE _cinco_seis   DEC(16,2);
DEFINE _cedula       VARCHAR(30);
DEFINE _digito_ver   CHAR(2);


--DROP TABLE tmp_agente;

CREATE TEMP TABLE tmp_carta(
	cod_agente		CHAR(5),
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	no_licencia     CHAR(10),
	cuenta		    CHAR(25),
	tipo_persona    CHAR(1),
	no_cheque       CHAR(10),  
	no_remesa       CHAR(10),
	renglon         SMALLINT,
	cedula          VARCHAR(30),
	digito_ver      CHAR(2)   
	) WITH NO LOG;

CREATE TEMP TABLE tmp_carta2(
	cod_agente		CHAR(5),
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	no_licencia     CHAR(10),
	cuenta		    CHAR(25),
	tipo_persona    CHAR(1),
	no_cheque       CHAR(10),  
	no_remesa       CHAR(10),
	renglon         SMALLINT,   
	cedula          VARCHAR(30),
	digito_ver      CHAR(2),   
	PRIMARY KEY (nombre, no_cheque)) WITH NO LOG;

CREATE TEMP TABLE tmp_carta3(
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	no_licencia     CHAR(10),
	tipo_persona    CHAR(1),
	cedula          VARCHAR(30),
	digito_ver      CHAR(2)   
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	no_poliza,
		no_remesa,
		renglon,
		no_recibo,
		fecha,
		monto,
		prima_neta
   INTO	_no_poliza,
		_no_remesa,
		_renglon,
		_no_recibo,
		_fecha,
		_monto,
		_prima
   FROM	cobredet
  WHERE	actualizado      = 1
	AND tipo_mov         IN ('P','N','C')
	AND fecha            >= a_fecha_desde
	AND fecha            <= a_fecha_hasta
	AND monto_descontado <> 0
  ORDER BY no_remesa, renglon  

	SELECT no_documento,
		   cod_tipoprod,
		   cod_ramo	
	  INTO _no_documento,
		   _cod_tipoprod,
		   _cod_ramo	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

	IF _tipo_prod = 3 OR
	   _tipo_prod = 4 THEN
	   CONTINUE FOREACH;
	END IF
	
  {	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;
   }
	FOREACH
	 SELECT	cod_agente,
			monto_man,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_comision,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon

   {		LET _monto_vida   = 0;
		LET _monto_danos  = 0;
		LET _monto_fianza = 0;

		IF   _tipo_ramo = 1 THEN
			LET _monto_vida   = _comision;
		ELIF _tipo_ramo = 2 THEN	
			LET _monto_danos  = _comision;
		ELSE
			LET _monto_fianza = _comision;
		END IF
	}
		SELECT nombre,
			   no_licencia,
			   tipo_persona,
			   cedula,
			   digito_ver	
		  INTO _nombre,
			   _no_licencia,
			   _tipo_persona,
			   _cedula,
			   _digito_ver
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
 
		INSERT INTO tmp_carta(
		cod_agente,		
		nombre,			
		com_desc,     
		comision,        
		cinco_seis,		
		no_licencia,  
		cuenta,		 
		tipo_persona,
		no_cheque, 
		no_remesa, 
		renglon,
		cedula,
		digito_ver    
		)
		VALUES(
		_cod_agente,
		trim(_nombre),
		_comision,
		0.00,
		0.00,
		_no_licencia,
		null,
		_tipo_persona,
		null,
		_no_remesa,
		_renglon,
		_cedula,
		_digito_ver    
		);


	END FOREACH
END FOREACH

--  Cheques pagados a nombre de
{	FOREACH
	  SELECT no_cheque, 
	         cod_agente,   
	         fecha_impresion,   
	         a_nombre_de,   
	         monto,   
	         periodo  
		INTO v_no_cheque,
		     _cod_agente,
		     v_fecha_impresion,
			 v_a_nombre_de,   
			 v_monto,   
			 v_periodo  
	    FROM chqchmae  
	   WHERE pagado = 1 
	     AND anulado = 0  
	     AND fecha_impresion >= a_fecha1 
	     AND fecha_impresion <= a_fecha2

	  RETURN v_no_cheque,
	         v_fecha_impresion,
			 v_a_nombre_de,   
			 v_monto,   
			 v_periodo
			 with resume;

	END FOREACH
 }
-- Cheques por cuenta
	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				y.a_nombre_de,
				y.anulado,
				y.fecha_impresion,
				y.monto,
				y.cod_agente
		   INTO	v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp,
				v_monto,
				_cod_agente
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND y.fecha_impresion >= a_fecha_desde 
		    AND y.fecha_impresion <= a_fecha_hasta
		    AND y.pagado = 1
	     	AND y.anulado = 0  
			AND (x.cuenta[1,3] in ("564")
			 OR x.cuenta[1,5] in ("26401", "26410"))
		  ORDER BY y.no_cheque

	   LET _comi_ck	= 0.00;
	   LET _cinco_seis = 0.00;

	   IF v_cuenta[1,3] = "264" THEN
		  LET _comi_ck = v_monto;
	   ELSE 
	   	  LET _cinco_seis = v_monto;
	   END IF


		SELECT nombre,
			   no_licencia,
			   tipo_persona,
			   cedula,
			   digito_ver	
		  INTO _nombre,
			   _no_licencia,
			   _tipo_persona,
			   _cedula,
			   _digito_ver
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

        BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

			INSERT INTO tmp_carta2(
			cod_agente,		
			nombre,			
			com_desc,     
			comision,        
			cinco_seis,		
			no_licencia,  
			cuenta,		 
			tipo_persona,
			no_cheque,
			no_remesa,
			renglon,    
			cedula,
			digito_ver    
			)
			VALUES(
			_cod_agente,
			trim(v_nombre_ben),
			0.00,
			_comi_ck,
			_cinco_seis,
			_no_licencia,
			v_cuenta,
			_tipo_persona,
			v_no_cheque,
			null,
			null,
			_cedula,
			_digito_ver    
			);
		END
	   
	END FOREACH

	FOREACH	WITH HOLD
		SELECT cod_agente,		
			   nombre,			
		       com_desc,     
			   comision,        
			   cinco_seis,		
		       no_licencia,  
		       cuenta,		 
		       tipo_persona,
		       no_cheque,
		       no_remesa,
		       renglon,   
			   cedula,
			   digito_ver    
		 INTO  _cod_agente,
		       v_nombre_ben,
		       _comision,
			   _comi_ck,
			   _cinco_seis,
		       _no_licencia,
		       v_cuenta,
		       _tipo_persona,
			   v_no_cheque,
			   _no_remesa,
			   _renglon,
			   _cedula,
			   _digito_ver    
		 FROM tmp_carta
	 ORDER BY nombre, no_remesa, renglon


		INSERT INTO tmp_carta3(
		nombre,			
		com_desc,     
		comision,      
		cinco_seis,		    
		no_licencia,  
		tipo_persona,  
	    cedula,
		digito_ver    
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
		_no_licencia,
		_tipo_persona,
		_cedula,
		_digito_ver    
		);
		 
	END FOREACH

	FOREACH	WITH HOLD
		SELECT cod_agente,		
			   nombre,			
		       com_desc,     
			   comision,        
			   cinco_seis,		
		       no_licencia,  
		       cuenta,		 
		       tipo_persona,
		       no_cheque,
		       no_remesa,
		       renglon,   
			   cedula,
			   digito_ver    
		 INTO  _cod_agente,
		       v_nombre_ben,
		       _comision,
			   _comi_ck,
			   _cinco_seis,
		       _no_licencia,
		       v_cuenta,
		       _tipo_persona,
			   v_no_cheque,
			   _no_remesa,
			   _renglon,
	           _cedula,
		       _digito_ver    
		 FROM tmp_carta2
	 ORDER BY nombre, no_cheque

		INSERT INTO tmp_carta3(
		nombre,			
		com_desc,     
		comision,      
		cinco_seis,		    
		no_licencia,  
		tipo_persona,  
	    cedula,
		digito_ver    
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
		_no_licencia,
		_tipo_persona,
	    _cedula,
		_digito_ver    
		);
	END FOREACH

	FOREACH	WITH HOLD
		SELECT nombre,			
			   SUM(com_desc),   	
		       SUM(comision),    
			   SUM(cinco_seis),	    
			   no_licencia,	
		       tipo_persona,
			   cedula,
			   digito_ver    
		 INTO  v_nombre_ben,
		       _comision,
		       _comi_ck,
			   _cinco_seis,
			   _no_licencia,
		       _tipo_persona,
		       _cedula,
			   _digito_ver    
		 FROM tmp_carta3
	 GROUP BY nombre, no_licencia, tipo_persona, cedula, digito_ver
	 ORDER BY nombre, no_licencia, tipo_persona, cedula, digito_ver 

		 RETURN v_nombre_ben,
				_comision,
			    _comi_ck,
			    _cinco_seis,
				_no_licencia,
				_tipo_persona,
				_cedula,
				_digito_ver
		   WITH RESUME;


	END FOREACH


DROP TABLE tmp_carta;
DROP TABLE tmp_carta2;
DROP TABLE tmp_carta3;


END PROCEDURE;