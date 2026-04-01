-- Procedimiento para insertar registros en COBPRONPA para proceso diario de pronto pago
-- Creado: 03/09/2009 - Autor: Roberto Silvera
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro863bk;

CREATE PROCEDURE "informix".sp_pro863bk(a_poliza CHAR(10), a_prima_end DEC(16,2), a_user_added CHAR(8))
RETURNING SMALLINT, CHAR(30);

DEFINE	v_cod_ramo		CHAR(3);
DEFINE	v_prima_bruta	DEC(16,2);
DEFINE	v_cod_formapag	CHAR(3);
DEFINE	v_fecha_susc	DATE;
DEFINE	v_no_doc		CHAR(20);
DEFINE	v_nombre		CHAR(255);
DEFINE	v_fecha			SMALLINT;
DEFINE	v_zona_libre	SMALLINT;
DEFINE	v_cant_pag		SMALLINT;
DEFINE  v_existe_end	SMALLINT;
DEFINE	v_saldo			DEC(16,2);
DEFINE 	v_soda			SMALLINT;
DEFINE	v_prima_modu	DEC(16,2);
DEFINE  v_saldo_end		DEC(16,2);
DEFINE	v_grupo			CHAR(5);
DEFINE	v_flag_flota	SMALLINT;
DEFINE	v_v_inicial		DATE;
DEFINE	v_v_final		DATE;
DEFINE	v_flag_modu		SMALLINT;
DEFINE	v_saldo_endp	DEC(16,2);
DEFINE  v_flag_existe	SMALLINT;
DEFINE	v_contratante	CHAR(10);
DEFINE 	v_pagador		CHAR(10);
DEFINE	v_prima_end		DEC(16,2);
define _dias            integer;
define _vigencia_i      date;
define _fecha_hoy       date;

BEGIN

  --VERIFICA SI YA EXISTE EN LA TABLA
  SELECT count(*)
	INTO v_flag_existe
    FROM cobpronpa
   WHERE cobpronpa.no_poliza = a_poliza ;

   let _dias = 0;
   let _fecha_hoy = '11/04/2012';

	IF v_flag_existe > 0 THEN
		RETURN 1, "Ya existe.";
	END IF

	--CONSULTA DATOS GENERALES
	  SELECT emipomae.cod_ramo,
			 emipomae.prima_bruta,
			 emipomae.cod_formapag,
			 emipomae.fecha_suscripcion,
			 emipomae.vigencia_inic,
			 emipomae.no_documento,
			 cliclien.nombre,
			 emipomae.cod_grupo,
			 emipomae.vigencia_inic,
			 emipomae.vigencia_final,
			 emipomae.cod_contratante,
			 emipomae.cod_pagador
	    INTO v_cod_ramo,
			 v_prima_bruta,
			 v_cod_formapag,
			 v_fecha_susc,
			 _vigencia_i,
			 v_no_doc,
			 v_nombre,
			 v_grupo,
			 v_v_inicial,
			 v_v_final,
			 v_contratante,
			 v_pagador
	    FROM emipomae, cliclien
	   WHERE emipomae.cod_contratante = cliclien.cod_cliente
		 AND emipomae.no_poliza = a_poliza
		 AND emipomae.cod_ramo not in ("004", "008", "016", "018", "019", "020")
		 AND emipomae.prima_bruta > 100
		 AND emipomae.estatus_poliza = 1
		 AND emipomae.actualizado = 1;

		--Buscar los dias, se toma la mayor fecha entre la vig ini vs la fecha de suscripcion

		if v_fecha_susc > _vigencia_i then
			let _dias = _fecha_hoy - v_fecha_susc;
		else
			let _dias = _fecha_hoy - _vigencia_i;	
		end if

		if _dias > 30 then
			RETURN 1, "No cumple condiciones.";
		end if

		--SINO NO RETORNA DATOS, NO CUMPLE CONDICIONES
		IF v_no_doc = "" OR v_no_doc is null THEN
			RETURN 1, "No cumple condiciones.";
		END IF

		--VERIFICA SI ES UNA FLOTA
		LET v_flag_flota = 0;

		  SELECT COUNT(*)
			INTO v_flag_flota
			FROM emipouni
		   WHERE emipouni.no_poliza =  a_poliza ;

			IF v_flag_flota > 1 THEN
				RETURN 1, "Es flota.";
			END IF

		--VERIFICA SI YA SE LE HIZO EL DESCUENTO A LA PÓLIZA
		LET v_existe_end 	= 0;
		 SELECT count(*)
			 INTO v_existe_end
			 FROM endedmae
			WHERE ( endedmae.no_poliza = a_poliza ) AND
				  ( endedmae.cod_endomov = "024" ) ;

			IF v_existe_end > 0 THEN
				RETURN 1, "Ya tiene el descuento.";
			END IF

		--VERIFICA SI LA POLIZA TIENE DESCUENTO POR MODIFCACION DE UNIDAD EN POLIZAS VIGENTES(2)
			SELECT endedmae.prima_bruta
				INTO v_saldo_endp
				FROM endedmae, emipomae
				WHERE endedmae.no_poliza = emipomae.no_poliza AND
					( endedmae.no_poliza = a_poliza ) AND
					( endedmae.no_endoso = "00000" )   AND
					( emipomae.estatus_poliza = 1 ) AND
					(emipomae.actualizado = 1) ;

			LET v_flag_modu = 0;

			FOREACH
				  SELECT endedmae.prima_bruta
					INTO v_saldo_end
					FROM endedmae, emipomae
					WHERE endedmae.no_poliza = emipomae.no_poliza AND 
						( endedmae.no_documento = v_no_doc ) AND
						( endedmae.no_endoso = "00000" )   AND
						( emipomae.estatus_poliza = 1 ) AND
						(emipomae.actualizado = 1)

				FOREACH
				   SELECT endedmae.prima_bruta
					 INTO v_prima_modu
					 FROM endedmae, emipomae
					WHERE endedmae.no_poliza = emipomae.no_poliza AND
						 ( endedmae.no_documento = v_no_doc ) AND
						 ( endedmae.cod_endomov = "006" ) AND
						 emipomae.estatus_poliza = 1 AND
						emipomae.actualizado = 1

					IF v_grupo <> "00967" THEN --GRUPO FELIX B MADURO
						IF v_prima_modu < 0 THEN
							IF (ABS(v_prima_modu) <= (ROUND((v_saldo_end * 0.05),2) + 0.02) 
								AND ABS(v_prima_modu) >= (ROUND((v_saldo_end * 0.05),2) - 0.02))
								OR ABS(v_prima_modu) = ROUND((v_saldo_end * 0.05),2) THEN
									LET v_flag_modu = 1;
									EXIT FOREACH;
							END IF
						END IF
					ELSE
						IF v_prima_modu < 0 THEN
							IF (ABS(v_prima_modu) <= (ROUND((v_saldo_end * 0.07),2) + 0.02)
								AND ABS(v_prima_modu) >= (ROUND((v_saldo_end * 0.07),2) - 0.02))
								OR ABS(v_prima_modu) = ROUND((v_saldo_end * 0.07),2) THEN
									LET v_flag_modu = 1;
									EXIT FOREACH;
							END IF
						END IF
					END IF

					IF v_flag_modu = 1 THEN
						LET v_flag_modu = 1;
						EXIT FOREACH;
					END IF

				END FOREACH

			END FOREACH

			IF v_flag_modu = 1 THEN
				RETURN 1, "Moficiación de unidad.";
			END IF

			--VERIFICA SI SON POLIZAS SODA
			LET v_soda	= 0;

			LET v_soda = sp_pro861(a_poliza);

			IF v_soda = 1 THEN
				RETURN 1, "Póliza SODA.";
			END IF

			--UNIDADES CON MANZANA EN ZONA LIBRE NO APLICAN
			LET v_zona_libre 	= 0;

			LET v_zona_libre = sp_pro857(a_poliza);

			IF v_zona_libre = 1 THEN
				RETURN 1, "Zona Libre.";
			END IF

			--VERIFICA EL SALDO DE LA PÓLIZA
			LET v_saldo = sp_cob115c("", "",v_no_doc,"");

			IF v_saldo <= 0 THEN
				RETURN 1, "Saldo menor a 0.";
			END IF

			--FORMA DE PAGO ELECTRONICA
			IF v_cod_formapag = "003" OR v_cod_formapag = "005" THEN

				--No. PAGOS REALIZADOS
				LET v_cant_pag = 0;

				SELECT COUNT(*)
				  INTO v_cant_pag
				  FROM cobredet d, cobremae m, emipomae e
				 WHERE d.actualizado  = 1
					AND d.cod_compania = '001'
					AND d.no_poliza    =  a_poliza
					AND d.tipo_mov     IN ('P','N')
					AND d.no_remesa    = m.no_remesa
					AND m.tipo_remesa  IN ('A', 'M', 'C')
					AND d.no_poliza = e.no_poliza
					AND m.fecha >= e.vigencia_inic ;

				IF v_cant_pag > 2 THEN

					IF v_grupo <> "00967" THEN --GRUPO FELIX B MADURO
						LET v_prima_end = (v_prima_bruta * 0.05) * -1;
					ELSE
						LET v_prima_end = (v_prima_bruta * 0.07) * -1;
					END IF

				  INSERT INTO cobpronpa
					 ( no_poliza,
					   no_documento,
					   cod_pagador,
					   cod_contratante,
					   prima_bruta,
					   monto_descuento,
					   factura,
					   fecha,
					   seleccionado,
					   user_added)
					VALUES (a_poliza,
						v_no_doc,
						v_contratante,
						v_pagador,
						v_prima_bruta,
						v_prima_end,
						"",
					    sp_sis26(),
					    0,
						a_user_added);

					RETURN 0, "Aplica para descuento. ";

				ELSE

					RETURN 1, "Sin pagos.";

				END IF

			ELSE

				RETURN 1, "No Electrónico.";

			END IF

END

END PROCEDURE
