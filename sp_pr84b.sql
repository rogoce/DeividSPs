----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS VIGENTES  ---
---  Modificado junio 2001, Lic. Amado Perez	 ---
---  Ref. Power Builder - dw_pro84				 ---
----------------------------------------------------

--DROP procedure sp_pro84b;

CREATE procedure "informix".sp_pro84b(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo DATE)
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. contratante
		  CHAR(50),		 --descr. pagador
          CHAR(20),		 --poliza
		  INT,
          DATE,			 --vig ini
          DECIMAL(16,2), --prima suscrita
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --suma asegurada
		  SMALLINT,     
          CHAR(255);	 --v_filtros

 BEGIN

DEFINE v_nopoliza,v_contratante,v_pagador  	   CHAR(10);
DEFINE v_documento                       	   CHAR(20);
DEFINE v_codsucursal                     	   CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final  	   DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 	   DECIMAL(16,2);
DEFINE v_prima_asegurada 					   DECIMAL(16,2);
DEFINE v_desc_contratante, v_desc_pagador      CHAR(50);
DEFINE v_descr_cia, v_desc_ramo          	   CHAR(50);
DEFINE v_filtros                         	   CHAR(100);
DEFINE _tipo                             	   CHAR(1);
DEFINE _cod_ramo						 	   CHAR(255);
DEFINE _cant_aseg                              INT;
DEFINE _no_poliza                              CHAR(10);
DEFINE _cod_contrato					 	   CHAR(5);
DEFINE _tipo_contrato, _es_terremoto, v_estatus  SMALLINT;
DEFINE _suma, _prima, _suma_endoso_cero	 	   DEC(16,2);
DEFINE _suma_retencion,	   _prima_retencion    DEC(16,2);
DEFINE _suma_contratos,	   _prima_contratos    DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos DEC(16,2);
DEFINE v_incurrido,v_inc_retencion,v_inc_contrato,v_inc_facultativo	DEC(16,2);
DEFINE _cod_cober_reas                         CHAR(3);
DEFINE _poliza 								   CHAR(10);
DEFINE _mes                                    CHAR(2);
DEFINE _ano                                    CHAR(4);
DEFINE _periodo                                CHAR(7);
DEFINE _unidad                                 CHAR(5);
DEFINE _limite_1, _limite_2                    DEC(16,2); 
	
SET ISOLATION TO DIRTY READ; 

LET v_descr_cia = sp_sis01(a_cia);

CREATE TEMP TABLE tmp_contratos
            (no_poliza          CHAR(10),
			 no_documento       CHAR(20),
			 cod_contratante    CHAR(10),
			 cod_pagador        CHAR(10),
			 cant_aseg          INT,
			 suma_asegurada     DEC(16,2),
			 prima_suscrita     DEC(16,2),
             incurrido          DEC(16,2),
             incu_retencion     DEC(16,2),
             incu_contrato      DEC(16,2),
			 incu_facultativo   DEC(16,2),
             PRIMARY KEY (no_poliza))
             WITH NO LOG;

LET _ano = YEAR(a_periodo);
LET _mes = MONTH(a_periodo);

IF MONTH(a_periodo) < 10 THEN
   LET _mes = '0' || _mes;
END IF

LET _periodo = _ano||'-'||_mes;

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 7;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,_cod_ramo);

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
		 prima_suscrita
    INTO v_nopoliza,
		 v_prima_suscrita
    FROM temp_perfil
   WHERE seleccionado = 1
ORDER BY no_poliza

   SELECT cod_pagador,
          no_documento,
          cod_contratante,
          vigencia_inic,
          vigencia_final
	 INTO v_pagador,
	      v_documento,
          v_contratante,
          v_vigencia_inic,
          v_vigencia_final
	 FROM emipomae
	WHERE no_poliza = v_nopoliza;

   SELECT suma_asegurada
     INTO _suma_endoso_cero
	 FROM endedmae
	WHERE no_poliza = v_nopoliza
	  AND no_endoso = '00000';


	LET _cant_aseg = 0;
	LET _poliza = null;

  {	FOREACH
		SELECT no_poliza
		  INTO _poliza
		  FROM emipouni
		 WHERE no_poliza = v_nopoliza
		  
		 LET _cant_aseg = _cant_aseg + 1;
	END FOREACH}


	BEGIN

	 ON EXCEPTION IN(-239)
	    UPDATE tmp_contratos
		   SET prima_suscrita = prima_suscrita + v_prima_suscrita
		 WHERE no_poliza = v_nopoliza;

	 END EXCEPTION
		INSERT INTO tmp_contratos
		VALUES (v_nopoliza,
		        v_documento,
		        v_contratante,
				v_pagador,
				_cant_aseg,
				_suma_endoso_cero,
				v_prima_suscrita,
				0,
				0,
				0,
				0
				);
	END
 END FOREACH

BEGIN

	FOREACH 
	   SELECT no_poliza 
	     INTO v_nopoliza
		 FROM tmp_contratos

		LET v_filtros = sp_pro842(
						a_cia,
						a_agencia, 
						_periodo,
						v_nopoliza
						);
	END FOREACH


END 

FOREACH WITH HOLD
	 SELECT no_poliza,
	        no_documento,
	        cod_contratante,
			cod_pagador,
			cant_aseg,       
			suma_asegurada,  
			prima_suscrita,  
			incurrido,       
			incu_retencion,  
			incu_contrato,   
			incu_facultativo
	   INTO v_nopoliza,
	        v_documento,
			v_contratante,
			v_pagador,
			_cant_aseg,
	        v_suma_asegurada,
	        v_prima_suscrita,
			v_incurrido,
			v_inc_retencion,
			v_inc_contrato,
			v_inc_facultativo
	   FROM tmp_contratos
	  ORDER BY no_documento

   SELECT b.nombre
     INTO v_desc_contratante
     FROM cliclien b
    WHERE b.cod_cliente = v_contratante;

   SELECT b.nombre
     INTO v_desc_pagador
     FROM cliclien b
    WHERE b.cod_cliente = v_pagador;  

   SELECT MIN(vigencia_inic)
	 INTO v_vigencia_inic
	 FROM emipomae
	WHERE no_documento = v_documento;

   SELECT MAX(no_poliza)
     INTO _poliza
	 FROM emipomae
	WHERE no_documento = v_documento;

   FOREACH
	   SELECT max(b.suma_asegurada)
		 INTO v_suma_asegurada
		 FROM endedmae b
		WHERE b.no_poliza = _poliza
		  AND b.no_endoso = '00000'
         EXIT FOREACH;
   END FOREACH

   SELECT estatus_poliza
     INTO v_estatus
	 FROM emipomae
	WHERE no_poliza = _poliza;

 {  FOREACH
	   SELECT max(b.limite_1)
		 INTO _limite_1
		 FROM endedcob b
		WHERE b.no_poliza = _poliza
		  AND b.no_endoso = '00000'
         EXIT FOREACH;
   END FOREACH

   FOREACH
	   SELECT max(b.limite_2)
		 INTO _limite_2
		 FROM endedcob b
		WHERE b.no_poliza = _poliza
		  AND b.no_endoso = '00000'
         EXIT FOREACH;
   END FOREACH

   IF _limite_1 > _limite_2 THEN
      LET v_suma_asegurada = _limite_1;
   ELSE
      LET v_suma_asegurada = _limite_2;
   END IF}

   LET _cant_aseg = 0; 

	FOREACH
		SELECT no_unidad
		  INTO _unidad
		  FROM emipouni
		 WHERE no_poliza = _poliza
		  
		 LET _cant_aseg = _cant_aseg + 1;
	END FOREACH
    
       RETURN v_descr_cia,
       		  _cod_ramo,
              v_desc_ramo,
              v_desc_contratante,
			  v_desc_pagador,
              v_documento,
			  _cant_aseg,
              v_vigencia_inic,
              v_prima_suscrita,
			  v_suma_asegurada,
			  v_incurrido,
			  v_inc_retencion,
			  v_inc_contrato,
			  v_inc_facultativo,
			  v_estatus,
              v_filtros
              WITH RESUME;

END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;

END

END PROCEDURE;
