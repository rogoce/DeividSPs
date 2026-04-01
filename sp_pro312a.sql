-- Informaci¢n: para Panam  Asistencia Ramo Automovil 
-- Creado     : 16/07/2008 - Autor: Amado Perez

--DROP PROCEDURE sp_pro312a;

create procedure sp_pro312a(a_fecha date)

returning CHAR(30),  -- 1. Nombre del Titular
		  CHAR(20),  -- 2. Ciudad
	      CHAR(14),	 --	3. P¢liza
		  CHAR(8),	 -- 4. Placa
		  CHAR(30),	 -- 5. Vehiculo
	   	  SMALLINT,	 -- 6. Compania
		  CHAR(8),   -- 7. Fecha In 
		  CHAR(8),	 -- 8. Fecha Out
		  CHAR(10),	 -- 9. Unidad
		  CHAR(1),   --10. Uso Auto
		  dec(16,2);

DEFINE v_nombre			 CHAR(30);
DEFINE v_poliza			 CHAR(14);
DEFINE v_marca			 VARCHAR(50);
DEFINE v_modelo			 VARCHAR(50);
DEFINE v_ano_auto		 CHAR(10);
DEFINE v_placa			 CHAR(10);
DEFINE v_vigencia_inic	 CHAR(10);
DEFINE v_vigencia_final	 CHAR(10);
DEFINE v_no_unidad		 CHAR(10);
DEFINE v_uso_auto	 	 CHAR(1);

DEFINE v_titular		 CHAR(30);
DEFINE v_vehiculo		 CHAR(30);
DEFINE v_compania		 SMALLINT;
DEFINE v_fechain		 CHAR(8);
DEFINE v_fechaout		 CHAR(8);
DEFINE v_unidad			 CHAR(10);

DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_saldo			DEC(16,2);

DEFINE _fecha_hoy		DATE;
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
define _fecha_ult_dia   DATE;
DEFINE _no_poliza		CHAR(10);
define _mora            dec(16,2);


let _fecha_hoy    = today;
let _mora = 0.00;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF
LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

CREATE TEMP TABLE tmp_anconvig2 (
	titular  CHAR(30),
	poliza	 CHAR(14),
	placa	 CHAR(8),	
	vehiculo CHAR(30),
	compania SMALLINT,
	fechain	 CHAR(8), 
	fechaout CHAR(8),	
	unidad	 CHAR(10),
	uso_auto CHAR(1),
	mora     dec(16,2),
	PRIMARY KEY (poliza, unidad)) WITH NO LOG; 
   

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro312.trc";
--TRACE ON;

-- *** Particular

FOREACH
  SELECT b.nombre,
         a.no_documento,
         c.nombre,
  		 d.nombre,
  		 e.ano_auto,
  		 e.placa,
         a.vigencia_inic, 
         a.vigencia_final,
         g.no_unidad,
         f.uso_auto
	INTO v_nombre,
		 v_poliza,
		 v_marca,
		 v_modelo,
		 v_ano_auto,
		 v_placa,
		 v_vigencia_inic,
		 v_vigencia_final,
		 v_no_unidad,
		 v_uso_auto
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE b.cod_cliente = a.cod_contratante
     AND a.no_poliza = g.no_poliza
     AND f.no_poliza = g.no_poliza
     AND f.no_unidad = g.no_unidad
     AND e.no_motor = f.no_motor
     AND d.cod_marca = e.cod_marca
     AND d.cod_modelo = e.cod_modelo
     AND c.cod_marca = e.cod_marca
     AND (a.cod_ramo = '002'
     AND g.vigencia_inic <=  a_fecha
     AND g.vigencia_final >= a_fecha
     AND f.cod_tipoveh = '005'
     AND f.uso_auto = 'P'
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

		--CONSULTA LA CIA Y AGENCIA
		
		LET _no_poliza = sp_sis21(v_poliza);
		
		let v_por_vencer = 0.00;
		let v_exigible   = 0.00;  
		let v_corriente	 = 0.00;
		let v_monto_30   = 0.00;
		let v_monto_60   = 0.00;
		let v_monto_90	 = 0.00;			
		let v_saldo	     = 0.00;
		let _mora        = 0.00;

		CALL sp_cob33(
		'001',
		'001',
		v_poliza,
		_periodo,
		_fecha_ult_dia
		) RETURNING v_por_vencer,
					v_exigible,  
					v_corriente,
					v_monto_30,  
					v_monto_60,  
					v_monto_90,
					v_saldo
					;

	    let _mora = v_monto_30 + v_monto_60 + v_monto_90;

	INSERT INTO tmp_anconvig2
	VALUES (v_nombre,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 7	for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7for 4),
	        v_no_unidad,
			v_uso_auto,
			_mora);
	END
   

END FOREACH

-- *** Comercial

FOREACH
	SELECT b.nombre, 
	       a.no_documento, 
	       c.nombre,
           d.nombre, 
           e.ano_auto, 
           e.placa,
           a.vigencia_inic, 
           a.vigencia_final, 
           g.no_unidad,
           f.uso_auto
	  INTO v_nombre,
		   v_poliza,
		   v_marca,
		   v_modelo,
		   v_ano_auto,
		   v_placa,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_no_unidad,
		   v_uso_auto
	  FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h
     WHERE b.cod_cliente = a.cod_contratante
       AND a.no_poliza = g.no_poliza
	   AND f.no_poliza = g.no_poliza
	   AND f.no_unidad = g.no_unidad
	   AND e.no_motor = f.no_motor
	   AND d.cod_marca = e.cod_marca
	   AND d.cod_modelo = e.cod_modelo
	   AND c.cod_marca = e.cod_marca
	   AND h.no_poliza = g.no_poliza
	   AND h.no_unidad = g.no_unidad  
	   AND h.no_poliza = g.no_poliza
	   AND h.no_unidad = g.no_unidad  
	   AND (a.cod_ramo = '002'
	   AND g.vigencia_inic <=  a_fecha
	   AND g.vigencia_final >= a_fecha
	   AND h.cod_cobertura = '00907'
	   AND a.actualizado = 1
	   AND a.linea_rapida <> 1
	   AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

	let v_por_vencer = 0.00;
	let v_exigible   = 0.00;  
	let v_corriente	 = 0.00;
	let v_monto_30   = 0.00;
	let v_monto_60   = 0.00;
	let v_monto_90	 = 0.00;			
	let v_saldo	     = 0.00;
	let _mora        = 0.00;

	CALL sp_cob33(
	'001',
	'001',
	v_poliza,
	_periodo,
	_fecha_ult_dia
	) RETURNING v_por_vencer,
				v_exigible,  
				v_corriente,
				v_monto_30,  
				v_monto_60,  
				v_monto_90,
				v_saldo
				;

	let _mora = v_monto_30 + v_monto_60 + v_monto_90;
	
	INSERT INTO tmp_anconvig2
	VALUES (v_nombre,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
	        v_no_unidad,
			v_uso_auto,_mora);
	END

END FOREACH

-- *** Soda 

FOREACH
  SELECT b.nombre, 
         a.no_documento, 
         c.nombre,
  		 d.nombre, 
  		 e.ano_auto, 
  		 e.placa,
         a.vigencia_inic, 
         a.vigencia_final, 
         g.no_unidad,
         f.uso_auto
	INTO v_nombre,
		 v_poliza,
		 v_marca,
		 v_modelo,
		 v_ano_auto,
		 v_placa,
		 v_vigencia_inic,
		 v_vigencia_final,
		 v_no_unidad,
		 v_uso_auto
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h
   WHERE b.cod_cliente = a.cod_contratante
	 AND a.no_poliza = g.no_poliza
	 AND f.no_poliza = g.no_poliza
	 AND f.no_unidad = g.no_unidad
	 AND e.no_motor = f.no_motor
	 AND d.cod_marca = e.cod_marca
	 AND d.cod_modelo = e.cod_modelo
	 AND c.cod_marca = e.cod_marca
	 AND h.no_poliza = g.no_poliza
	 AND h.no_unidad = g.no_unidad  
	 AND h.no_poliza = g.no_poliza
	 AND h.no_unidad = g.no_unidad  
	 AND (((a.cod_ramo = '002'
	 AND a.linea_rapida = 1)
	  OR a.cod_ramo = '020')
	 AND g.vigencia_inic <=  a_fecha
	 AND g.vigencia_final >= a_fecha
	 AND h.cod_cobertura = '01028'
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

	let v_por_vencer = 0.00;
	let v_exigible   = 0.00;  
	let v_corriente	 = 0.00;
	let v_monto_30   = 0.00;
	let v_monto_60   = 0.00;
	let v_monto_90	 = 0.00;			
	let v_saldo	     = 0.00;
	let _mora        = 0.00;

	CALL sp_cob33(
	'001',
	'001',
	v_poliza,
	_periodo,
	_fecha_ult_dia
	) RETURNING v_por_vencer,
				v_exigible,  
				v_corriente,
				v_monto_30,  
				v_monto_60,  
				v_monto_90,
				v_saldo
				;

	let _mora = v_monto_30 + v_monto_60 + v_monto_90;
	
	INSERT INTO tmp_anconvig2
	VALUES (v_nombre,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
	        v_no_unidad,
			v_uso_auto,_mora);
	END

END FOREACH

-- *** Comercial livianos y medianos

FOREACH
  SELECT b.nombre, 
         a.no_documento, 
         c.nombre,
  		 d.nombre, 
  		 e.ano_auto, 
  		 e.placa,
         a.vigencia_inic, 
         a.vigencia_final, 
         g.no_unidad,
         f.uso_auto
	INTO v_nombre,
		 v_poliza,
		 v_marca,
		 v_modelo,
		 v_ano_auto,
		 v_placa,
		 v_vigencia_inic,
		 v_vigencia_final,
		 v_no_unidad,
		 v_uso_auto
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE b.cod_cliente = a.cod_contratante
     AND a.no_poliza = g.no_poliza
     AND f.no_poliza = g.no_poliza
     AND f.no_unidad = g.no_unidad
     AND e.no_motor = f.no_motor
     AND d.cod_marca = e.cod_marca
     AND d.cod_modelo = e.cod_modelo
     AND c.cod_marca = e.cod_marca
     AND (a.cod_ramo = '002'
	 AND a.cod_subramo = '002'
     AND g.vigencia_inic <=  a_fecha
     AND g.vigencia_final >= a_fecha
     AND f.cod_tipoveh IN ('008','009')
     AND a.actualizado = 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

	let v_por_vencer = 0.00;
	let v_exigible   = 0.00;  
	let v_corriente	 = 0.00;
	let v_monto_30   = 0.00;
	let v_monto_60   = 0.00;
	let v_monto_90	 = 0.00;			
	let v_saldo	     = 0.00;
	let _mora        = 0.00;

	CALL sp_cob33(
	'001',
	'001',
	v_poliza,
	_periodo,
	_fecha_ult_dia
	) RETURNING v_por_vencer,
				v_exigible,  
				v_corriente,
				v_monto_30,  
				v_monto_60,  
				v_monto_90,
				v_saldo
				;

	let _mora = v_monto_30 + v_monto_60 + v_monto_90;
	
	INSERT INTO tmp_anconvig2
	VALUES (v_nombre,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
	        v_no_unidad,
			v_uso_auto,_mora);
	END
   

END FOREACH

-- *** Sucursal 75

FOREACH
  SELECT b.nombre, 
         a.no_documento, 
         c.nombre,
  		 d.nombre, 
  		 e.ano_auto, 
  		 e.placa,
         a.vigencia_inic, 
         a.vigencia_final, 
         g.no_unidad,
         f.uso_auto
	INTO v_nombre,
		 v_poliza,
		 v_marca,
		 v_modelo,
		 v_ano_auto,
		 v_placa,
		 v_vigencia_inic,
		 v_vigencia_final,
		 v_no_unidad,
		 v_uso_auto
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE b.cod_cliente = a.cod_contratante
     AND a.no_poliza = g.no_poliza
     AND f.no_poliza = g.no_poliza
     AND f.no_unidad = g.no_unidad
     AND e.no_motor = f.no_motor
     AND d.cod_marca = e.cod_marca
     AND d.cod_modelo = e.cod_modelo
     AND c.cod_marca = e.cod_marca
     AND (a.cod_ramo = '002'
	 AND a.sucursal_origen = '075'
     AND g.vigencia_inic <=  a_fecha
     AND g.vigencia_final >= a_fecha
     AND a.actualizado = 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF
									
	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION
	
	let v_por_vencer = 0.00;
	let v_exigible   = 0.00;  
	let v_corriente	 = 0.00;
	let v_monto_30   = 0.00;
	let v_monto_60   = 0.00;
	let v_monto_90	 = 0.00;			
	let v_saldo	     = 0.00;
	let _mora        = 0.00;

	CALL sp_cob33(
	'001',
	'001',
	v_poliza,
	_periodo,
	_fecha_ult_dia
	) RETURNING v_por_vencer,
				v_exigible,  
				v_corriente,
				v_monto_30,  
				v_monto_60,  
				v_monto_90,
				v_saldo
				;

	let _mora = v_monto_30 + v_monto_60 + v_monto_90;

	INSERT INTO tmp_anconvig2
	VALUES (v_nombre,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
	        v_no_unidad,
			v_uso_auto,_mora);
	END

END FOREACH

FOREACH WITH HOLD
	SELECT titular, 
		   poliza,	
		   placa,	
		   vehiculo,
		   compania,
		   fechain,	
		   fechaout,
		   unidad,	
		   uso_auto,
		   mora
	  INTO v_titular, 
		   v_poliza,	
		   v_placa,	
		   v_vehiculo,
		   v_compania,
		   v_fechain,	
		   v_fechaout,
		   v_unidad,	
		   v_uso_auto,
		   _mora
	  FROM tmp_anconvig2
  ORDER BY 4

   RETURN  v_titular, 
           "",
		   v_poliza,	
		   v_placa,	
		   v_vehiculo,
		   v_compania,
		   v_fechain,	
		   v_fechaout,
		   v_unidad,	
		   v_uso_auto,
		   _mora
		   WITH RESUME;
END FOREACH 

DROP TABLE tmp_anconvig2;

end procedure;

		   