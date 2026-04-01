-- Facturas sin Coberturas

DROP PROCEDURE sp_par24;

CREATE PROCEDURE "informix".sp_par24(
a_periodo  CHAR(4)
) 
RETURNING CHAR(20),
		  CHAR(10),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(100),
		  CHAR(6),
		  CHAR(10),
		  DATE,
		  CHAR(5),
		  CHAR(5);

DEFINE a_compania       CHAR(3);
DEFINE _no_poliza		CHAR(10);
DEFINE _no_endoso		CHAR(6);
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);
DEFINE _prima_neta		DEC(16,2);
DEFINE _prima_suscrita	DEC(16,2);
DEFINE _prima_retenida	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _prima_sus_reas	DEC(16,2);
DEFINE _no_documento	CHAR(20);
DEFINE _no_factura		CHAR(10);
DEFINE _cod_endomov		CHAR(5);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _fecha			DATE;
DEFINE _asterix			CHAR(1);
DEFINE _no_cambio       CHAR(3);
DEFINE _vigencia_inic	DATE;
DEFINE _vigencia_final	DATE;
DEFINE _contador        INTEGER;

DEFINE _no_endoso_or    CHAR(5);
DEFINE _mas             CHAR(1);

DEFINE _no_poliza_int	INTEGER;
DEFINE _no_endoso_int	INTEGER;
DEFINE _no_unidad_int	INTEGER;
DEFINE _no_cobert_int	INTEGER;
DEFINE _no_serie_int	INTEGER;
DEFINE _no_contrato_int	INTEGER;
DEFINE _no_coasegur_int	INTEGER;
DEFINE _porc_comision	DEC(16,4);
DEFINE _porc_impuesto	DEC(16,4);

DEFINE _orden           SMALLINT;
DEFINE _cod_contrato    CHAR(5);
DEFINE _porcentaje2		DEC(16,4);
DEFINE _suma_reas   	DEC(16,2);
DEFINE _cod_reasegur	CHAR(3);

DEFINE _1_prima_anual  	DEC(16,2);
DEFINE _1_prima_descto 	DEC(16,2);
DEFINE _1_prima     	DEC(16,2);

DEFINE _dias            SMALLINT;

DEFINE _ret_cha			CHAR(30);
DEFINE _ret_sma			SMALLINT;
DEFINE _ret_dec			DEC(16,2);
DEFINE _factor			dec(16,6);

DEFINE _cod_producto    CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _cod_asegurado   CHAR(10);
DEFINE _cod_ruta        CHAR(5);
	
--SET DEBUG FILE TO "sp_par24.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET a_compania = '001';

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

LET _contador = 0;

FOREACH
 SELECT no_poliza,
		no_endoso,
		prima_neta,
		prima_suscrita,
		no_factura,
		cod_endomov,
		prima_retenida,
		fecha_emision,
		vigencia_inic,
		vigencia_final,
		factor_vigencia
   INTO _no_poliza,
		_no_endoso,
		_prima_neta,
		_prima_suscrita,
		_no_factura,
		_cod_endomov,
		_prima_retenida,
		_fecha,
		_vigencia_inic,
		_vigencia_final,
		_factor
   FROM endedmae
  WHERE actualizado  = 1
    AND periodo[1,4] = a_periodo
	AND cod_endomov  NOT IN ('009', '010', '012', '013', '015', '018')
  ORDER BY fecha_emision DESC, no_factura DESC

	LET _no_unidad = '00000';
	LET _contador  = _contador + 1;
	LET _mas       = '';

	SELECT cod_tipoprod,
	       no_documento,
		   cod_ramo,
		   cod_subramo,
		   cod_contratante
	  INTO _cod_tipoprod,
		   _no_documento,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_asegurado
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _no_endoso = '00000' THEN

		SELECT COUNT(*)
		  INTO _cantidad
		  FROM endedmae
		 WHERE no_poliza = _no_poliza;

		IF _cantidad > 1 THEN
			LET _mas          = '+';
			LET _no_documento = TRIM(_no_documento) || '+';
--			CONTINUE FOREACH;
		END IF

	END IF

	LET _asterix = '';

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emihcmm
	 WHERE no_poliza = _no_poliza;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad > 1 THEN
		LET _asterix   = '%';
	END IF

	IF _asterix = '%' THEN
		LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
	ELSE

		SELECT COUNT(*)
		  INTO _cantidad
		  FROM endcoama
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;

		IF _cantidad IS NULL THEN
			LET _cantidad = 0;
		END IF

		IF _cantidad <> 0 THEN
			LET _asterix     = '?';
			LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
		END IF

	END IF

	IF _tipo_produccion = 2 THEN
		LET _asterix     = '*';
		LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
	END IF

	-- Verificacion de Prima Neta

	SELECT SUM(prima_neta)
	  INTO _prima_sus_cal
	  FROM endedcob
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _prima_sus_cal IS NULL THEN

		--{
		SELECT MIN(cod_producto)
		  INTO _cod_producto
		  FROM prdprod
		 WHERE cod_ramo    = _cod_ramo
		   AND cod_subramo = _cod_subramo;

		SELECT MIN(cod_ruta)
		  INTO _cod_ruta
		  FROM rearumae
		 WHERE cod_ramo = _cod_ramo
		   AND serie    = YEAR(_vigencia_inic);

		IF _cod_ruta IS NULL THEN
			LET _cod_ruta = '00001';
		END IF
		
		SELECT MIN(cod_cobertura)
		  INTO _cobertura
		  FROM prdcobpd
		 WHERE cod_producto = _cod_producto;
		 	
		BEGIN 
		ON EXCEPTION IN(-268)
		END EXCEPTION

			INSERT INTO endeduni(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_ruta,
			cod_producto,
			cod_cliente,
			suma_asegurada,
			prima,
			descuento,
			recargo,
			prima_neta,
			impuesto,
			prima_bruta,
			reasegurada,
			vigencia_inic,
			vigencia_final,
			beneficio_max,
			desc_unidad,
			prima_suscrita,
			prima_retenida
			)
			VALUES(
			_no_poliza,
			_no_endoso,
			'00001',
			_cod_ruta,
			_cod_producto,
			_cod_asegurado,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			_vigencia_inic,
			_vigencia_final,
			0,
			'',
			0,
			0
			);

		END

		INSERT INTO endedcob(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_cobertura,
		orden,
		tarifa,
		deducible,
		limite_1,
		limite_2,
		prima_anual,
		prima,
		descuento,
		recargo,
		prima_neta,
		date_added,
		date_changed,
		desc_limite1,
		desc_limite2,
		factor_vigencia,
		opcion
		)
		VALUES(
		_no_poliza,
		_no_endoso,
		'00001',
		_cobertura,
		1,
		0,
		'',
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		_fecha,
		_fecha,
		'',
		'',
		_factor,
		0
		);
		--}

		RETURN _no_documento,
		       _no_factura,
			   _prima_neta,
			   _prima_neta,
			   _prima_sus_cal,
			   'Factura sin Coberturas',
			   _no_endoso,
			   _no_poliza,
			   _fecha,
			   _no_unidad,
			   _cod_endomov
			   WITH RESUME;

	END IF

END FOREACH

LET _prima_sus_cal = _contador;

RETURN '',
       '',
	   0,
	   0,
	   _prima_sus_cal,
	   'Registros Procesados',
	   '',
	   '',
	   '',
	   '',
	   ''
	   WITH RESUME;

END PROCEDURE;

