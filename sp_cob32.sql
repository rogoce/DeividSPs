-- Comparacion Produccion - Cobros - Devolucion de Primas
-- 
-- Creado    : 25/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 18/01/2002 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob32_dw1 DEIVID, S.A.

DROP PROCEDURE sp_cob32;

CREATE PROCEDURE "informix".sp_cob32(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 
RETURNING CHAR(50),		-- Nombre Ramo
    	  DEC(16,2),	-- Facturas
		  DEC(16,2),	-- Cobros
		  CHAR(50),  	-- Nombre Compania
		  DEC(16,2),	-- Cheques
		  char(10);

DEFINE v_nombre          CHAR(50); 
DEFINE v_facturas        DEC(16,2);
DEFINE v_cobros          DEC(16,2);
DEFINE v_cheques		 DEC(16,2);   
DEFINE v_compania_nombre CHAR(50); 

DEFINE _no_poliza        CHAR(10); 
DEFINE _prima_bruta      DEC(16,2);
DEFINE _cod_ramo         CHAR(3);  
DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _no_requis 		 CHAR(10);

DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;
DEFINE _tipo			 char(10); 
define _incobrable		 smallint;

--SET DEBUG FILE TO "sp_cob32.trc"; 
-- trace on;                                                                

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_comparacion(
	tipo		char(10),
	cod_ramo	CHAR(3),
	facturas	DEC(16,2),
	cobros  	DEC(16,2),
	cheques		DEC(16,2) DEFAULT 0.00
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
	AND prima_bruta <> 0 

	SELECT cod_ramo,
	       cod_tipoprod,
		   incobrable
	  INTO _cod_ramo,
	       _cod_tipoprod,
		   _incobrable
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	if _incobrable = 1 then

		let _tipo = "Incobrable";

	else

		IF _cod_tipoprod = "002" THEN
			let _tipo = "Coaseguro";
		else
			let _tipo = "Cartera";
		END IF 	
	
	end if

	INSERT INTO tmp_comparacion(
	tipo,
	cod_ramo,
	facturas,
	cobros
	)
	VALUES(
	_tipo,
	_cod_ramo,
	_prima_bruta,
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
	       cod_tipoprod,
		   incobrable
	  INTO _cod_ramo,
	       _cod_tipoprod,
		   _incobrable
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	if _incobrable = 1 then

		let _tipo = "Incobrable";

	else

		IF _cod_tipoprod = "002" THEN
			let _tipo = "Coaseguro";
		else
			let _tipo = "Cartera";
		END IF 	
	
	end if
	
	INSERT INTO tmp_comparacion(
	tipo,
	cod_ramo,
	facturas,
	cobros
	)
	VALUES(
	_tipo,
	_cod_ramo,
	0,
	_prima_bruta
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
		       cod_tipoprod,
		   	   incobrable
		  INTO _cod_ramo,
		       _cod_tipoprod,
		   	   _incobrable
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		if _incobrable = 1 then

			let _tipo = "Incobrable";

		else

			IF _cod_tipoprod = "002" THEN
				let _tipo = "Coaseguro";
			else
				let _tipo = "Cartera";
			END IF 	
		
		end if

		INSERT INTO tmp_comparacion(
		tipo,
		cod_ramo,
		facturas,
		cobros,
		cheques
		)
		VALUES(
		_tipo,
		_cod_ramo,
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
		       cod_tipoprod,
		   	   incobrable
		  INTO _cod_ramo,
		       _cod_tipoprod,
		   	   _incobrable
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		let _prima_bruta = _prima_bruta * -1;

		if _incobrable = 1 then

			let _tipo = "Incobrable";

		else

			IF _cod_tipoprod = "002" THEN
				let _tipo = "Coaseguro";
			else
				let _tipo = "Cartera";
			END IF 	
		
		end if
		
		INSERT INTO tmp_comparacion(
		tipo,
		cod_ramo,
		facturas,
		cobros,
		cheques
		)
		VALUES(
		_tipo,
		_cod_ramo,
		0,
		0,
		_prima_bruta
		);

	END FOREACH

END FOREACH

-- Impresion

FOREACH
 SELECT	tipo,
 		cod_ramo,
        sum(facturas),
		sum(cobros),
		sum(cheques)
   INTO	_tipo,
   		_cod_ramo,
        v_facturas,
		v_cobros,
		v_cheques
   FROM tmp_comparacion
  group by tipo, cod_ramo
  ORDER BY tipo, cod_ramo

	SELECT nombre
	  INTO v_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	RETURN v_nombre,
	       v_facturas,
		   v_cobros,
		   v_compania_nombre,
		   v_cheques,
		   _tipo        
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_comparacion;

END PROCEDURE;

