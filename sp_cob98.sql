-- Comparacion Produccion - Cobros - Devolucion de Primas
-- 
-- Creado    : 14/02/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/02/2003 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob98;

CREATE PROCEDURE "informix".sp_cob98(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 

DEFINE v_compania_nombre CHAR(50); 

DEFINE _no_poliza        CHAR(10); 
DEFINE _prima_bruta      DEC(16,2);
DEFINE _cod_ramo         CHAR(3);  
DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _no_requis 		 CHAR(10);
DEFINE _no_documento	 CHAR(10);

DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;

--SET DEBUG FILE TO "sp_cob32.trc"; 
-- trace on;                                                                

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_comparacion(
	no_poliza	CHAR(10),
	facturas	DEC(16,2),
	cobros  	DEC(16,2),
	cheques		DEC(16,2)
	) WITH NO LOG;

-- Facturas

FOREACH
 SELECT prima_bruta,
		no_poliza
   INTO _prima_bruta,
		_no_poliza
   FROM endedmae
  WHERE cod_compania = a_compania
    AND periodo     >= a_periodo1
    AND periodo     <= a_periodo2
	AND actualizado  = 1
	AND prima_bruta  <> 0 

	SELECT cod_ramo,
	       cod_tipoprod
	  INTO _cod_ramo,
	       _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;
	 
	 IF _tipo_produccion = 4 THEN
	 	CONTINUE FOREACH;
	 END IF 	

	INSERT INTO tmp_comparacion(
	no_poliza,
	facturas,
	cobros,
	cheques
	)
	VALUES(
	_no_poliza,
	_prima_bruta,
	0,
	0
	);

END FOREACH	

-- Recibos 

FOREACH
 SELECT	monto,
        no_poliza
   INTO	_prima_bruta,
        _no_poliza
   FROM	cobredet
  WHERE cod_compania = a_compania
	AND actualizado = 1
	AND tipo_mov   IN ('P', 'N')
    AND periodo    >= a_periodo1
    AND periodo    <= a_periodo2
	AND monto      <> 0

	SELECT cod_ramo,
	       cod_tipoprod
	  INTO _cod_ramo,
	       _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;
	 
	 IF _tipo_produccion = 4 THEN
	 	CONTINUE FOREACH;
	 END IF 	

	INSERT INTO tmp_comparacion(
	no_poliza,
	facturas,
	cobros,
	cheques
	)
	VALUES(
	_no_poliza,
	0,
	_prima_bruta,
	0
	);

END FOREACH

-- Cheques Pagados

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.periodo      >= a_periodo1
    AND m.periodo      <= a_periodo2
	AND m.origen_cheque = "6"

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_ramo,
		       cod_tipoprod
		  INTO _cod_ramo,
		       _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN
		 	CONTINUE FOREACH;
		 END IF 	

		INSERT INTO tmp_comparacion(
		no_poliza,
		facturas,
		cobros,
		cheques
		)
		VALUES(
		_no_poliza,
		0,
		0,
		_prima_bruta
		);

	END FOREACH

END FOREACH

-- Cheques Anulados

LET _fecha_anulado1 = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);

IF a_periodo2[6,7] = 12 THEN
	LET _fecha_anulado2 = MDY(1, 1, a_periodo2[1,4] + 1);
ELSE
	LET _fecha_anulado2 = MDY(a_periodo2[6,7] + 1, 1, a_periodo2[1,4]);
END IF

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= _fecha_anulado1
    AND m.fecha_anulado < _fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_ramo,
		       cod_tipoprod
		  INTO _cod_ramo,
		       _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN
		 	CONTINUE FOREACH;
		 END IF 	

		LET _prima_bruta = _prima_bruta * -1;

		INSERT INTO tmp_comparacion(
		no_poliza,
		facturas,
		cobros,
		cheques
		)
		VALUES(
		_no_poliza,
		0,
		0,
		_prima_bruta
		);

	END FOREACH

END FOREACH

END PROCEDURE;

