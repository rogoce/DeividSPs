-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/09/2002 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro102;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro102c(a_cia CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7))
			RETURNING   CHAR(50),			 --	v_ramo,	
	   					CHAR(50),			 --	v_subramo,
						CHAR(20),			 --	v_poliza,
						CHAR(10),			 --	v_factura,	
						SMALLINT,
						CHAR(7),
						CHAR(50),
						DEC(16,2),
						DEC(16,2),			 --	v_prima 1,
						DEC(16,2),			 --			2
						DEC(16,2),			 --			3
						DEC(16,2),			 --	 		4
						DEC(16,2),			 --			5
						DEC(16,2),			 -- 		6
						DEC(16,2),			 --			7
						DEC(16,2),			 --			8
						DEC(16,2),			 --			9
						DEC(16,2),			 --		   10
						DEC(16,2),			 --		   11
						DEC(16,2),			 --		   12
						DEC(16,2),			 --		   13
						DEC(16,2),			 --		   14
						DEC(16,2),			 --		   15
						DEC(16,2),			 --		   16
						DEC(16,2),			 --		   17
						DEC(16,2),			 --		   18
						DEC(16,2),			 --		   19
						DEC(16,2),			 --		   20
						DEC(16,2),			 --		   21
						DEC(16,2),			 --		   22
						DEC(16,2),			 --		   23
						DEC(16,2);			 --		   24


	
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_documento	   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_perpago       CHAR(50);
DEFINE v_prima_1	   DEC(16,2);
DEFINE v_prima_2	   DEC(16,2);
DEFINE v_prima_3	   DEC(16,2);
DEFINE v_prima_4	   DEC(16,2);
DEFINE v_prima_5	   DEC(16,2);
DEFINE v_prima_6	   DEC(16,2);
DEFINE v_prima_7	   DEC(16,2);
DEFINE v_prima_8	   DEC(16,2);
DEFINE v_prima_9	   DEC(16,2);
DEFINE v_prima_10	   DEC(16,2);
DEFINE v_prima_11	   DEC(16,2);
DEFINE v_prima_12	   DEC(16,2);
DEFINE v_prima_13	   DEC(16,2);
DEFINE v_prima_14	   DEC(16,2);
DEFINE v_prima_15	   DEC(16,2);
DEFINE v_prima_16	   DEC(16,2);
DEFINE v_prima_17	   DEC(16,2);
DEFINE v_prima_18	   DEC(16,2);
DEFINE v_prima_19	   DEC(16,2);
DEFINE v_prima_20	   DEC(16,2);
DEFINE v_prima_21	   DEC(16,2);
DEFINE v_prima_22	   DEC(16,2);
DEFINE v_prima_23	   DEC(16,2);
DEFINE v_prima_24	   DEC(16,2);

DEFINE _periodo        CHAR(7);
DEFINE _no_poliza      CHAR(10);
DEFINE _prima_suscrita, _letra DEC(16,2);
DEFINE _cod_perpago    CHAR(3);
DEFINE _no_pagos       SMALLINT;
DEFINE _meses          SMALLINT;
DEFINE _mes1, _mes2, _mes, _desde    SMALLINT;
DEFINE _ano1, _ano2, _ano, _i        INT; 
DEFINE _fecha_primer_pago            DATE;
DEFINE _cod_ramo, _cod_subramo       CHAR(3);

SET ISOLATION TO DIRTY READ;

-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
		no_factura       CHAR(10), 
		no_poliza        CHAR(10),
		no_documento     CHAR(20),
		no_pagos         SMALLINT,
		periodo          CHAR(7),
		cod_perpago      CHAR(3),
		prima_suscrita   DEC(16,2),
		prima1		     DEC(16,2),
		prima2		     DEC(16,2),
		prima3		     DEC(16,2),
		prima4		  	 DEC(16,2),
		prima5 	  	     DEC(16,2),
		prima6		     DEC(16,2),
		prima7	  	     DEC(16,2),
		prima8		     DEC(16,2),
		prima9		     DEC(16,2),
		prima10		     DEC(16,2),
		prima11		  	 DEC(16,2),
		prima12 	  	 DEC(16,2),
		prima13		     DEC(16,2),
		prima14	  	     DEC(16,2),
		prima15		     DEC(16,2),
		prima16		     DEC(16,2),
		prima17		     DEC(16,2),
		prima18		  	 DEC(16,2),
		prima19 	  	 DEC(16,2),
		prima20		     DEC(16,2),
		prima21	  	     DEC(16,2),
		prima22 	  	 DEC(16,2),
		prima23		     DEC(16,2),
		prima24	  	     DEC(16,2),
		PRIMARY KEY (no_factura)
		) WITH NO LOG;


-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;                                                                     

LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7]; 

FOREACH	

-- Lectura de endedmae

 SELECT no_poliza,
        no_factura,
		no_documento,
        periodo,
		prima_suscrita,
		cod_perpago,
		no_pagos,
		fecha_primer_pago
   INTO _no_poliza,
        v_factura,
		v_documento,
		_periodo,
		_prima_suscrita,
		_cod_perpago,
		_no_pagos,
		_fecha_primer_pago
   FROM endedmae
  WHERE periodo >= a_periodo1
    AND periodo <= a_periodo2
	AND actualizado = 1
	AND prima_suscrita <> 0

   LET _letra =  _prima_suscrita / _no_pagos;

   SELECT meses
     INTO _meses
	 FROM cobperpa
	WHERE cod_perpago = _cod_perpago;

	LET _ano2 = _periodo[1,4];
	LET _mes2 = _periodo[6,7]; 

	LET _ano = _ano2 - _ano1;

	IF _ano > 0 THEN
	   LET _mes = 12 * _ano;
	   LET _mes2 = _mes2 + _mes;
	END IF

    LET _desde = _mes2 - _mes1 + 1;

	LET v_prima_1 = 0;
	LET v_prima_2 = 0;
	LET v_prima_3 = 0;
	LET v_prima_4 = 0;
	LET v_prima_5 = 0;
	LET v_prima_6 = 0;
	LET v_prima_7 = 0;
	LET v_prima_8 = 0;
	LET v_prima_9 = 0;
	LET v_prima_10 = 0;
	LET v_prima_11 = 0;
	LET v_prima_12 = 0;
	LET v_prima_13 = 0;
	LET v_prima_14 = 0;
	LET v_prima_15 = 0;
	LET v_prima_16 = 0;
	LET v_prima_17 = 0;
	LET v_prima_18 = 0;
	LET v_prima_19 = 0;
	LET v_prima_20 = 0;
	LET v_prima_21 = 0;
	LET v_prima_22 = 0;
	LET v_prima_23 = 0;
	LET v_prima_24 = 0;

	FOR _i = 1 to _no_pagos
	   IF _desde = 1 THEN
	      LET v_prima_1 = _letra;
	   ELIF _desde = 2 THEN
	      LET v_prima_2 = _letra;
	   ELIF _desde = 3 THEN
	      LET v_prima_3 = _letra;
	   ELIF _desde = 4 THEN
	      LET v_prima_4 = _letra;
	   ELIF _desde = 5 THEN
	      LET v_prima_5 = _letra;
	   ELIF _desde = 6 THEN
	      LET v_prima_6 = _letra;
	   ELIF _desde = 7 THEN
	      LET v_prima_7 = _letra;
	   ELIF _desde = 8 THEN
	      LET v_prima_8 = _letra;
	   ELIF _desde = 9 THEN
	      LET v_prima_9 = _letra;
	   ELIF _desde = 10 THEN
	      LET v_prima_10 = _letra;
	   ELIF _desde = 11 THEN
	      LET v_prima_11 = _letra;
	   ELIF _desde = 12 THEN
	      LET v_prima_12 = _letra;
	   ELIF _desde = 13 THEN
	      LET v_prima_13 = _letra;
	   ELIF _desde = 14 THEN
	      LET v_prima_14 = _letra;
	   ELIF _desde = 15 THEN
	      LET v_prima_15 = _letra;
	   ELIF _desde = 16 THEN
	      LET v_prima_16 = _letra;
	   ELIF _desde = 17 THEN
	      LET v_prima_17 = _letra;
	   ELIF _desde = 18 THEN
	      LET v_prima_18 = _letra;
	   ELIF _desde = 19 THEN
	      LET v_prima_19 = _letra;
	   ELIF _desde = 20 THEN
	      LET v_prima_20 = _letra;
	   ELIF _desde = 21 THEN
	      LET v_prima_21 = _letra;
	   ELIF _desde = 22 THEN
	      LET v_prima_22 = _letra;
	   ELIF _desde = 23 THEN
	      LET v_prima_23 = _letra;
	   ELSE
	      LET v_prima_24 = _letra;
	   END IF

	   LET _desde = _desde + _meses;

	   IF _desde > 24 THEN
	      EXIT FOR;
	   END IF

	END FOR


	INSERT INTO tmp_arreglo(
	no_factura,  
	no_poliza,
	no_documento,
	no_pagos,
	periodo,
	cod_perpago,
	prima_suscrita,
	prima1,		
	prima2,		
	prima3,		
	prima4,		
	prima5, 	  	
	prima6,		
	prima7,	  	
	prima8,		
	prima9,		
	prima10,		
	prima11,		
	prima12, 	
	prima13,		
	prima14,	  	
	prima15,		
	prima16,		
	prima17,		
	prima18,		
	prima19, 	
	prima20,		
	prima21,	  	
	prima22, 	
	prima23,		
	prima24	  	
	)
	VALUES(
	v_factura,
	_no_poliza,	
	v_documento,
	_no_pagos,
	_periodo,
	_cod_perpago,
	_prima_suscrita,
	v_prima_1,	
	v_prima_2,	
	v_prima_3,	
	v_prima_4,	
	v_prima_5,	
	v_prima_6,	
	v_prima_7,	
	v_prima_8,	
	v_prima_9,	
	v_prima_10,	
	v_prima_11,	
	v_prima_12,	
	v_prima_13,	
	v_prima_14,	
	v_prima_15,	
	v_prima_16,	
	v_prima_17,	
	v_prima_18,	
	v_prima_19,	
	v_prima_20,	
	v_prima_21,	
	v_prima_22,	
	v_prima_23,	
	v_prima_24
	);

END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_factura,  
		no_poliza,
		no_documento,
		no_pagos,
		periodo,
		cod_perpago,
		prima_suscrita,
		prima1,		
		prima2,		
		prima3,		
        prima4,		
 		prima5, 	 
 		prima6,		
 		prima7,	  	
 		prima8,		
 		prima9,		
		prima10,		
		prima11,		
		prima12, 	
		prima13,		
		prima14,	 
		prima15,		
		prima16,		
		prima17,		
		prima18,		
		prima19, 	
		prima20,		
		prima21,	 
		prima22, 	
		prima23,		
		prima24	  	
   INTO v_factura,
        _no_poliza,	
		v_documento,
		_no_pagos,
		_periodo,
		_cod_perpago,
		_prima_suscrita,
		v_prima_1,	
		v_prima_2,	
		v_prima_3,	
		v_prima_4,	
		v_prima_5,	
		v_prima_6,	
		v_prima_7,	
		v_prima_8,	
		v_prima_9,	
		v_prima_10,	
		v_prima_11,	
		v_prima_12,	
		v_prima_13,	
		v_prima_14,	
		v_prima_15,	
		v_prima_16,	
		v_prima_17,	
		v_prima_18,	
		v_prima_19,	
		v_prima_20,	
		v_prima_21,	
		v_prima_22,	
		v_prima_23,	
		v_prima_24
   FROM tmp_arreglo

    -- Lectura del Ramo y Subramo

    SELECT cod_ramo,
	       cod_subramo
	  INTO _cod_ramo,
	       _cod_subramo
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	
	SELECT nombre
	  INTO v_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	SELECT nombre
	  INTO v_perpago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

	RETURN v_ramo,
	       v_subramo,
		   v_documento,
	       v_factura,
		   _no_pagos,
		   _periodo,
		   v_perpago,
		   _prima_suscrita / 1000,
		   v_prima_1 / 1000,	
		   v_prima_2 / 1000,	
		   v_prima_3 / 1000,	
		   v_prima_4 / 1000,	
		   v_prima_5 / 1000,	
		   v_prima_6 / 1000,	
		   v_prima_7 / 1000,	
		   v_prima_8 / 1000,	
		   v_prima_9 / 1000,	
		   v_prima_10 / 1000,	
		   v_prima_11 / 1000,	
		   v_prima_12 / 1000,	
		   v_prima_13 / 1000,	
		   v_prima_14 / 1000,	
		   v_prima_15 / 1000,	
		   v_prima_16 / 1000,	
		   v_prima_17 / 1000,	
		   v_prima_18 / 1000,	
		   v_prima_19 / 1000,	
		   v_prima_20 / 1000,	
		   v_prima_21 / 1000,	
		   v_prima_22 / 1000,	
		   v_prima_23 / 1000,	
		   v_prima_24 / 1000
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
