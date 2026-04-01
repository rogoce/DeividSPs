
DROP PROCEDURE mart_unidades;

CREATE PROCEDURE "informix".mart_unidades(a_no_poliza CHAR(10), a_no_endoso	CHAR(5)
)
 RETURNING	integer,char(70);

	DEFINE _null           CHAR(1);      
	DEFINE _suma_asegurada DECIMAL(16,2);
	DEFINE _suma_aseg_adic DECIMAL(16,2);
	DEFINE _no_unidad      CHAR(5);      
	DEFINE _cod_cober_reas CHAR(3);      
	DEFINE _no_cambio      SMALLINT;
	DEFINE _error          INTEGER;
	DEFINE _mensaje        CHAR(70);

	BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, 'Error al Actualizar el Endoso ...';         
		END EXCEPTION           

		LET _null      = NULL;
		LET _no_cambio = 0;

		-- Actualiza las vigencia de las unidades del endoso

 {		UPDATE endeduni
		   SET vigencia_inic  = _vigencia_inic,
		       vigencia_final = _vigencia_final
		 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;
 }
		-- Insercion de Unidades

		INSERT INTO emipouni(
	    no_poliza,
	    no_unidad,
	    cod_ruta,
	    cod_producto,
	    cod_asegurado,
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
	    activo,
	    prima_asegurado,
	    prima_total,
	    no_activo_desde,
	    facturado,
	    user_no_activo,
	    perd_total,
	    impreso,
	    fecha_emision,
	    prima_suscrita,
	    prima_retenida,
		suma_aseg_adic,
		tipo_incendio,
		cod_manzana
		)
		SELECT no_poliza,
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
			   1,
			   0,
			   0,
			   _null,
			   1,
			   _null,
			   0,
			   1,
			   CURRENT,
			   prima_suscrita,
			   prima_retenida,
			   suma_aseg_adic,
			   tipo_incendio,
			   cod_manzana
		  FROM endeduni
	 	 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;

		-- Autos por Unidad

		INSERT INTO emiauto(
	    no_poliza,
	    no_unidad,
	    cod_tipoveh,
	    no_motor,
	    uso_auto,
	    ano_tarifa
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_tipoveh,
			   no_motor,
			   uso_auto,
			   ano_tarifa
		  FROM endmoaut
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descripcion por Unidad

		INSERT INTO emipode2(
	    no_poliza,
	    no_unidad,
	    descripcion
		)
		SELECT no_poliza,
			   no_unidad,
			   descripcion
		  FROM endedde2
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descuentos por Unidad

		INSERT INTO emiunide(
	    no_poliza,
	    no_unidad,
	    cod_descuen,
	    porc_descuento
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_descuen,
			   porc_descuento
		  FROM endunide
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		
		
		-- Recargos por Unidad

		INSERT INTO emiunire(
	    no_poliza,
	    no_unidad,
	    cod_recargo,
	    porc_recargo
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_recargo,
			   porc_recargo
		  FROM endunire
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Insercion de Acreedores

		INSERT INTO emipoacr(
		no_poliza,
		no_unidad, 
		cod_acreedor,
		limite
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_acreedor,
			   limite
	 	  FROM endedacr
	 	 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;

		-- Insercion de Coberturas

		INSERT INTO emipocob(
	    no_poliza,
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
	    factor_vigencia,
	    desc_limite1,
	    desc_limite2
		)
		SELECT no_poliza,
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
			   factor_vigencia,
			   desc_limite1,
			   desc_limite2
		  FROM endedcob
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descuentos por Cobertura

		INSERT INTO emicobde(
	    no_poliza,
	    no_unidad,
	    cod_cobertura,
	    cod_descuen,
	    porc_descuento
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_descuen,
			   porc_descuento
		  FROM endcobde
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		
		
		-- Recargos por Cobertura

		INSERT INTO emicobre(
	    no_poliza,
	    no_unidad,
	    cod_cobertura,
	    cod_recargo,
	    porc_recargo
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_recargo,
			   porc_recargo
		  FROM endcobre
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Historico de Reaseguro Individual
	
  {		FOREACH
		 SELECT	no_unidad,
		        cod_cober_reas
		   INTO	_no_unidad,
		        _cod_cober_reas
		   FROM	emifacon
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso
		  GROUP BY no_unidad, cod_cober_reas

			DELETE FROM emireafa
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireaco
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireama
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			INSERT INTO emireama(
			no_poliza,
			no_unidad,
			no_cambio,
			cod_cober_reas,
			vigencia_inic,
			vigencia_final
			)
			VALUES(
			a_no_poliza, 
			_no_unidad,
			_no_cambio,
			_cod_cober_reas,
			_vigencia_inic,
			_vigencia_final
			);

		END FOREACH

		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso;

		INSERT INTO emireafa(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		FROM emifafac
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso;
   }
		-- Insercion de Beneficiarios

		INSERT INTO emibenef(
	    no_poliza,
	    no_unidad,
	    cod_cliente,
	    cod_parentesco,
	    benef_desde,
	    porc_partic_ben,
		nombre
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cliente,
			   cod_parentesco,
			   benef_desde,
			   porc_partic_ben,
			   nombre
		  FROM endbenef
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;
		   
		-- Insercion de Cumulos

		INSERT INTO emicupol(
	    no_poliza,
	    no_unidad,
	    cod_ubica,
	    suma_incendio,
	    suma_terremoto,
	    prima_incendio,
		prima_terremoto
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_ubica,
			   suma_incendio,
			   suma_terremoto,
			   prima_incendio,
			   prima_terremoto
		  FROM endcuend
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		   		

	SELECT SUM(suma_asegurada)
		  INTO _suma_asegurada
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza;

 --		UPDATE emipomae
 --		   SET suma_asegurada = _suma_asegurada
 --		 WHERE no_poliza = a_no_poliza;

		-- Transporte Salud

		INSERT INTO emitrans(
	    no_poliza,
	    no_unidad,
		cod_nave,
		consignado,
		tipo_embarque,
		clausulas,
		contenedor,
		sello,
		fecha_viaje,
		viaje_desde,
		viaje_hasta,
		sobre
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_nave,
			   consignado,
			   tipo_embarque,
			   clausulas,
			   contenedor,
			   sello,
			   fecha_viaje,
			   viaje_desde,
			   viaje_hasta,
			   sobre
		  FROM endmotra
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

	END 

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE