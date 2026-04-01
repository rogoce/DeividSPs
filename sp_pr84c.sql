----------------------------------------------------
---  POLIZAS SUSCRITAS Y SINIESTROS INCURRIDOS   ---
---  PARA COLECTIVO EXCLUYENDO LOS FACULTATIVOS	 ---
---  Modificado Diciembre 2001, Lic. Amado Perez ---
---  Ref. Power Builder - dw_pro84c				 ---
----------------------------------------------------

DROP procedure sp_pro84c;

CREATE procedure "informix".sp_pro84c(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. contratante
		  CHAR(50),		 --descr. pagador
          CHAR(20),		 --poliza
		  INT,
          DATE,			 --vig ini
          DECIMAL(16,2), --prima suscrita
		  DEC(16,2),
          DECIMAL(16,2), --suma asegurada
		  DEC(16,2),
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
			 prima_retenida     DEC(16,2),
			 prima_cedida       DEC(16,2),
             incurrido_retenido	DEC(16,2),
			 incurrido_cedido   DEC(16,2),
             PRIMARY KEY (no_poliza))
             WITH NO LOG;

{LET _ano = YEAR(a_periodo);
LET _mes = MONTH(a_periodo);

IF MONTH(a_periodo) < 10 THEN
   LET _mes = '0' || _mes;
END IF

LET _periodo = _ano||'-'||_mes;}

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 7;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_pro26(a_cia,a_agencia,a_periodo1,a_periodo2,a_codsucursal,_cod_ramo);

-- Filtro de Sucursal

IF a_codsucursal <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
 LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

 IF _tipo <> "E" THEN -- Incluir los Registros

    UPDATE tmp_prod
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
 ELSE
    UPDATE tmp_prod
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
 END IF
 DROP TABLE tmp_codigos;
END IF

FOREACH
 SELECT  no_poliza,
		 total_pri_sus
    INTO v_nopoliza,
		 v_prima_suscrita
    FROM tmp_prod
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

	LET _cant_aseg = 0;
	LET _poliza = null;

	BEGIN

	 ON EXCEPTION IN(-239)
  --	    UPDATE tmp_contratos
  --		   SET prima_suscrita = prima_suscrita + v_prima_suscrita
  --		 WHERE no_poliza = v_nopoliza;

	 END EXCEPTION
		INSERT INTO tmp_contratos
		VALUES (v_nopoliza,
		        v_documento,
		        v_contratante,
				v_pagador,
				_cant_aseg,
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

   LET _prima_retencion = 0;
   LET _prima_contratos = 0;

	  FOREACH
		 SELECT	c.cod_contrato,
				c.prima
		   INTO	_cod_contrato,
				_prima
		   FROM emifacon c, endedmae e
		  WHERE	c.no_poliza   = v_nopoliza
		    AND c.no_poliza   = e.no_poliza
			AND c.no_endoso   = e.no_endoso
			AND e.periodo     >= a_periodo1
			AND e.periodo     <= a_periodo2
			AND e.actualizado = 1

			SELECT tipo_contrato
			  INTO _tipo_contrato
			  FROM reacomae
			 WHERE cod_contrato = _cod_contrato;

			IF _tipo_contrato = 1 THEN
			   LET _prima_retencion = _prima_retencion + _prima;
			ELIF _tipo_contrato = 3 THEN
			ELSE
			   LET _prima_contratos = _prima_contratos + _prima;
			END IF

	  END FOREACH	

	UPDATE tmp_contratos
	   SET prima_retenida = _prima_retencion,
	       prima_cedida   = _prima_contratos
 	 WHERE no_poliza = v_nopoliza;

 END FOREACH
END

--SET DEBUG FILE TO "sp_pro843.trc";
--TRACE ON;


BEGIN

	FOREACH 
	   SELECT no_poliza 
	     INTO v_nopoliza
		 FROM tmp_contratos

		LET v_filtros = sp_pro843(
						a_cia,
						a_agencia, 
						a_periodo1,
						a_periodo2,
						v_nopoliza
						);
	END FOREACH


END 

--trace off;

FOREACH WITH HOLD
	 SELECT no_poliza,
	        no_documento,
	        cod_contratante,
			cod_pagador,
			cant_aseg,       
			prima_retenida,  
			prima_cedida,
			incurrido_retenido,
			incurrido_cedido
	   INTO v_nopoliza,
	        v_documento,
			v_contratante,
			v_pagador,
			_cant_aseg,
	        _prima_retencion,
			_prima_contratos,
			v_inc_retencion,
			v_inc_contrato
	   FROM tmp_contratos
	  WHERE prima_retenida <> 0 
	     OR prima_cedida <> 0
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

   SELECT estatus_poliza
     INTO v_estatus
	 FROM emipomae
	WHERE no_poliza = _poliza;

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
              _prima_retencion,
			  _prima_contratos,
			  v_inc_retencion,
			  v_inc_contrato,
			  v_estatus,
              v_filtros
              WITH RESUME;

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_contratos;

END

END PROCEDURE;
