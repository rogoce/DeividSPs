--DROP procedure sp_pro96;

CREATE procedure "informix".sp_pro96(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. cliente
          CHAR(20),		 --poliza
		  CHAR(10),      --factura
          DATE,			 --vig ini
          DATE,			 --vig fin
          DECIMAL(16,2), --prima suscrita
          DATE,			 --fecha
          DECIMAL(16,2), --suma asegurada
          CHAR(255),	 --v_filtros
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2); --suma asegurada

----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS VIGENTES  ---
---  Armando Moreno mayo 2001 - AMM          	 ---
---  Modificado junio 2001, Lic. Amado Perez	 ---
---  Ref. Power Builder - dw_pro66				 ---
----------------------------------------------------
 BEGIN

DEFINE v_nopoliza,v_contratante, v_no_factura  CHAR(10);
DEFINE v_documento                       	   CHAR(20);
DEFINE v_codsucursal, v_cod_endomov        	   CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final  	   DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 	   DECIMAL(16,2);
DEFINE v_prima_asegurada 					   DECIMAL(16,2);
DEFINE v_desc_cliente                    	   CHAR(45);
DEFINE v_descr_cia, v_desc_ramo          	   CHAR(50);
DEFINE v_filtros                         	   CHAR(100);
DEFINE _tipo                             	   CHAR(1);
DEFINE _cod_ramo						 	   CHAR(255);
DEFINE _no_endoso                              CHAR(5);

DEFINE _cod_contrato					 	   CHAR(5);
DEFINE _tipo_contrato, _es_terremoto	 	   SMALLINT;
DEFINE _suma, _prima 		  			 	   DEC(16,2);
DEFINE _suma_retencion,	   _prima_retencion    DEC(16,2);
DEFINE _suma_contratos,	   _prima_contratos    DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos DEC(16,2);
DEFINE _cod_cober_reas                         CHAR(3);
	
SET ISOLATION TO DIRTY READ; 

LET v_descr_cia = sp_sis01(a_cia);

CREATE TEMP TABLE tmp_contratos
            (no_poliza          CHAR(10),
			 no_endoso          CHAR(5),
             suma_retencion     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2),
			 prima_retencion    DEC(16,2),
			 prima_contratos    DEC(16,2),
			 prima_facultativos DEC(16,2)
             );

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 6;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_pro961(a_cia,a_agencia, a_periodo1, a_periodo2, _cod_ramo);

-- Filtro de Sucursal

IF a_codsucursal <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
 LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

 IF _tipo <> "E" THEN -- Incluir los Registros

    UPDATE temp_perfil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
 ELSE
    UPDATE temp_perfil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
 END IF
 DROP TABLE tmp_codigos;
END IF

FOREACH
 SELECT  no_poliza,
         no_endoso,
         no_documento,
         cod_contratante,
         vigencia_inic,
         vigencia_final,
		 prima_suscrita
    INTO v_nopoliza,
	     _no_endoso,
         v_documento,
         v_contratante,
         v_vigencia_inic,
         v_vigencia_final,
		 v_prima_suscrita
    FROM temp_perfil
   WHERE seleccionado = 1
ORDER BY cod_contratante,vigencia_final

   SELECT b.nombre
     INTO v_desc_cliente
     FROM cliclien b
    WHERE b.cod_cliente = v_contratante;


	FOREACH
	 SELECT	c.cod_contrato,
			c.suma_asegurada,
			c.prima,
			c.cod_cober_reas
	   INTO	_cod_contrato,
			_suma,
			_prima,
			_cod_cober_reas
	   FROM emifacon c, endedmae e
	  WHERE	c.no_poliza   = v_nopoliza
	    AND c.no_poliza   = e.no_poliza
		AND c.no_endoso   = e.no_endoso
		AND e.no_endoso   = _no_endoso
		AND e.actualizado = 1

		SELECT tipo_contrato
		  INTO _tipo_contrato
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

        SELECT es_terremoto
		  INTO _es_terremoto
		  FROM reacobre
		 WHERE cod_cober_reas = _cod_cober_reas;


		LET _suma_retencion    = 0;
		LET _suma_facultativos = 0;
		LET _suma_contratos    = 0;
		LET _prima_retencion    = 0;
		LET _prima_contratos    = 0;
		LET _prima_facultativos = 0;

		IF   _tipo_contrato = 1 THEN
			IF _es_terremoto = 1 THEN
				LET _suma_retencion    = 0;
			ELSE
				LET _suma_retencion    = _suma;
			END IF
			LET _prima_retencion    = _prima;
		ELIF _tipo_contrato = 3 THEN
			IF _es_terremoto = 1 THEN
				LET _suma_facultativos    = 0;
			ELSE
				LET _suma_facultativos = _suma;
			END IF
			LET _prima_facultativos = _prima;
		ELSE
			IF _es_terremoto = 1 THEN
				LET _suma_contratos    = 0;
			ELSE
				LET _suma_contratos    = _suma;
			END IF
			LET _prima_contratos    = _prima;
		END IF

		INSERT INTO tmp_contratos
		VALUES (v_nopoliza,
		        _no_endoso,
		        _suma_retencion, 
		        _suma_contratos, 
		        _suma_facultativos, 
		        _prima_retencion, 
		        _prima_contratos, 
		        _prima_facultativos
		        );
	END FOREACH
	
	 SELECT SUM(suma_retencion),
	        SUM(suma_contratos),
			SUM(suma_facultativos),
			SUM(prima_retencion), 
			SUM(prima_contratos), 
			SUM(prima_facultativos)
	   INTO _suma_retencion,
	        _suma_contratos,
			_suma_facultativos,
			_prima_retencion, 
			_prima_contratos, 
			_prima_facultativos
	   FROM tmp_contratos
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = _no_endoso;

	 SELECT no_factura,
	        cod_endomov
	   INTO v_no_factura,
	        v_cod_endomov
	   FROM endedmae
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = _no_endoso;   

      

	   LET v_suma_asegurada = _suma_retencion + _suma_contratos + _suma_facultativos;
	   LET v_prima_asegurada = _prima_retencion + _prima_contratos + _prima_facultativos;	

       RETURN v_descr_cia,
       		  _cod_ramo,
              v_desc_ramo,
              v_desc_cliente,
              v_documento,
			  v_no_factura,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
              a_periodo,
			  v_suma_asegurada,
              v_filtros,
              _suma_retencion,
              _suma_contratos,
              _suma_facultativos,
			  _prima_retencion, 
			  _prima_contratos, 
			  _prima_facultativos,
			  v_prima_asegurada
              WITH RESUME;

END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;

END

END PROCEDURE;
