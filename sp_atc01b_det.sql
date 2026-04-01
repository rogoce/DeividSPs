-- Procedimiento que Carga las Comisiones Descontadas por Corredor

-- Creado    : 02/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

-- execute procedure sp_atc01b_det('001','001', 2025, '03223;')

DROP PROCEDURE sp_atc01b_det;

CREATE PROCEDURE sp_atc01b_det(a_compania CHAR(3),a_sucursal CHAR(3), a_ano integer, a_agente VARCHAR(255))

RETURNING   CHAR(5) as cod_agente,
            VARCHAR(100) as nombre,
            CHAR(10) as no_requis,
            DEC(16,2) as comision,
			DEC(16,2) as bonos,
            DATE as fecha,
			CHAR(10) as no_cheque;

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
DEFINE v_nombre_ben	 VARCHAR(100);
DEFINE _anulado		 SMALLINT;
DEFINE v_fecha_imp	 DATE;
DEFINE v_monto		 DEC(16,2);
DEFINE _tipo_persona CHAR(1);
DEFINE _comi_ck		 DEC(16,2);
DEFINE _cinco_seis   DEC(16,2);
DEFINE _cedula       VARCHAR(30);
DEFINE _tipo_agente  CHAR(1);

DEFINE _tipo                CHAR(1);
DEFINE _codigo				CHAR(5);
DEFINE _nombre_filtro		VARCHAR(50);

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
	nom_cheq  		CHAR(50)
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
	nom_cheq  		CHAR(50),
	no_requis       CHAR(10),
    fecha           DATE,
	PRIMARY KEY (no_requis)) WITH NO LOG;

CREATE TEMP TABLE tmp_carta3(
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	no_licencia     CHAR(10),
	tipo_persona    CHAR(1),
	cedula          VARCHAR(30),   
	nom_cheq  		CHAR(50),
	no_cheque       CHAR(10) DEFAULT NULL,
	cod_agente      CHAR(5),
    no_requis       CHAR(10),
    fecha           DATE
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

IF a_agente <> "*" THEN
	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos
END IF

FOREACH
 SELECT	a.no_poliza,
		a.no_remesa,
		a.renglon,
		a.no_recibo,
		a.fecha,
		a.monto,
		a.prima_neta,
        b.cod_agente,
        b.monto_man
   INTO	_no_poliza,
		_no_remesa,
		_renglon,
		_no_recibo,
		_fecha,
		_monto,
		_prima,
        _cod_agente,
		_comision
   FROM	cobredet a, cobreagt b
  WHERE	a.no_remesa = b.no_remesa
    AND a.renglon = b.renglon
    AND a.actualizado      = 1
	AND a.tipo_mov         IN ('P','N','C')
	AND year(a.fecha)      = a_ano
	AND a.monto_descontado <> 0
    AND b.cod_agente in (SELECT codigo FROM tmp_codigos)
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
	
		SELECT nombre,
			   no_licencia,
			   tipo_persona,
			   cedula,
			   tipo_agente	
		  INTO _nombre,
			   _no_licencia,
			   _tipo_persona,
			   _cedula,
			   _tipo_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		IF _tipo_agente = 'E' THEN
			CONTINUE FOREACH;
		END IF
 
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
		nom_cheq    
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
		_nombre
		);

END FOREACH

--  Cheques pagados a nombre de
-- Cheques por cuenta

  FOREACH
	SELECT codigo
	  INTO _codigo
	  FROM tmp_codigos


    SELECT nombre,
		   tipo_agente
	  INTO _nombre_filtro,
           _tipo_agente
	  FROM agtagent
	 WHERE cod_agente = _codigo;
 
	IF _tipo_agente = 'E' THEN
		CONTINUE FOREACH;
	END IF
    
-- Cheques por cuenta
	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				REPLACE(TRIM(y.a_nombre_de)," ","%"),
				y.anulado,
				y.fecha_impresion,
				y.monto,
				y.cod_agente,
				y.no_requis
		   INTO	v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp,
				v_monto,
				_cod_agente,
				_no_requis
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND year(y.fecha_impresion) = a_ano 
		    AND y.pagado = 1
	     	AND y.anulado = 0  
			AND (x.cuenta[1,3] in ("564")
			 OR x.cuenta[1,3] in ("521","570")		   	-->HONORARIOS PROFESIONALES-AGENTES Y CORREDORES
			 OR x.cuenta[1,5] in ("26401", "26410")		-->HONORARIOS POR PAGAR AGENTES Y CORREDORES / HONORARIOS Y COMISIONES POR PAGAR AGENTES AUXILIAR
			 OR x.cuenta = "266200171")   				-->Bonificacion por Rentabilidad / Bono Persistencia Anual
		    AND (y.cod_agente = _codigo
			 OR REPLACE(TRIM(y.a_nombre_de)," ","%") LIKE _nombre_filtro)
		  ORDER BY y.no_cheque

	   LET _comi_ck	= 0.00;
	   LET _cinco_seis = 0.00;
	   let _nombre = null;

	   IF v_cuenta[1,3] = "264" THEN
		  LET _comi_ck = v_monto;
	   ELSE 
	   	  LET _cinco_seis = v_monto;
	   END IF


	   IF _cod_agente IS NOT NULL THEN
			SELECT nombre,
				   no_licencia,
				   tipo_persona,
				   cedula,
				   tipo_agente	
			  INTO _nombre,
				   _no_licencia,
				   _tipo_persona,
				   _cedula,
				   _tipo_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;
		ELSE
		    FOREACH
				SELECT nombre,
					   no_licencia,
					   tipo_persona,
					   cedula,
					   cod_agente,
					   tipo_agente	
				  INTO _nombre,
					   _no_licencia,
					   _tipo_persona,
					   _cedula,
					   _cod_agente,
					   _tipo_agente
				  FROM agtagent
				 WHERE nombre LIKE "%" || TRIM(v_nombre_ben) || "%"
				EXIT FOREACH;
			END FOREACH
		END IF

        IF _nombre IS NULL OR _cod_agente IS NULL OR _tipo_agente = "E" THEN
			CONTINUE FOREACH;
		END IF

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
			nom_cheq,
			no_requis,
            fecha    
			)
			VALUES(
			_cod_agente,
			trim(_nombre),
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
			v_nombre_ben,
			_no_requis,
            v_fecha_imp
			);
		END
	   
	END FOREACH
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
			   nom_cheq    
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
			   _nombre
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
   	    nom_cheq,
   	    cod_agente   
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
		_no_licencia,
		_tipo_persona,
		_cedula,
		_nombre,
		_cod_agente
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
   	           nom_cheq,
			   no_requis,
               fecha    
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
		       _nombre,
			   _no_requis,
               v_fecha_imp
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
   	    nom_cheq,
   	    no_cheque,
   	    cod_agente,
        no_requis,
        fecha     
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
		_no_licencia,
		_tipo_persona,
		_cedula,
		_nombre,
		v_no_cheque,
		_cod_agente,
        _no_requis,
        v_fecha_imp
		);
	END FOREACH

	FOREACH	WITH HOLD
		SELECT com_desc,   	
		       comision,    
			   cinco_seis,	    
			   no_licencia,	
		       tipo_persona,
			   cedula,
			   nom_cheq,
			   no_cheque,
			   cod_agente,
               no_requis,
               fecha 
		 INTO  _comision,
		       _comi_ck,
			   _cinco_seis,
			   _no_licencia,
		       _tipo_persona,
			   _cedula,
			   _nombre,
			   v_no_cheque,
			   _cod_agente,
               _no_requis,
               v_fecha_imp
		 FROM tmp_carta3
	 ORDER BY no_licencia, tipo_persona, cedula 
--	 GROUP BY no_licencia, tipo_persona, cedula

     	LET _monto = _comision + _comi_ck + _cinco_seis;

{        FOREACH
			SELECT nombre
			  INTO v_nombre_ben
			  FROM agtagent
			 WHERE cedula = trim(_cedula)
			   AND estatus_licencia = "A"
			EXIT FOREACH;
		END FOREACH
		}
			SELECT nombre
			  INTO v_nombre_ben
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

		 RETURN _cod_agente,
                TRIM(v_nombre_ben),
                _no_requis,				
			    _comi_ck,
			    _cinco_seis,
                v_fecha_imp,
				v_no_cheque
		   WITH RESUME;


	END FOREACH


DROP TABLE tmp_carta;
DROP TABLE tmp_carta2;
DROP TABLE tmp_carta3;
DROP TABLE tmp_codigos;

END PROCEDURE;