DROP procedure sp_pro98c;

CREATE procedure "informix".sp_pro98c(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. cliente
          CHAR(20),		 --poliza
          DECIMAL(16,2), --prima suscrita
          DECIMAL(16,2), --prima
          DECIMAL(16,2), --prima
          DECIMAL(16,2), --prima
          CHAR(255), --v_filtros
          CHAR(50);	 --subramo

-----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS SALUD      ---
---  Creado el 12 de Abril 2002, Lic. Amado Perez ---
---  Ref. Power Builder - dw_pro98				  ---
-----------------------------------------------------
 BEGIN

DEFINE v_nopoliza,v_contratante, v_no_factura  CHAR(10);
DEFINE v_documento                       	   CHAR(20);
DEFINE v_codsucursal, v_cod_endomov        	   CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final,v_vigencia_inic_salud,v_vigencia_final_salud  DATE;
DEFINE _vigencia_inic, _vigencia_inic_pol      DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 	   DECIMAL(16,2);
DEFINE v_prima_asegurada 					   DECIMAL(16,2);
DEFINE v_desc_cliente                    	   CHAR(45);
DEFINE v_descr_cia, v_desc_ramo,v_subramo  	   CHAR(50);
DEFINE v_filtros                         	   CHAR(100);
DEFINE _tipo                             	   CHAR(1);
DEFINE _cod_ramo						 	   CHAR(255);
DEFINE _no_endoso                              CHAR(5);
DEFINE v_periodo                               CHAR(7);

DEFINE _cod_contrato, _cod_contrato_salud 	   CHAR(5);
DEFINE _tipo_contrato, _es_terremoto, v_serie, _ano,v_estatus  SMALLINT;
DEFINE _suma, _prima, _prima_exceso		 	   DEC(16,2);
DEFINE _suma_retencion,	   _prima_retencion    DEC(16,2);
DEFINE _suma_contratos,	   _prima_contratos    DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos DEC(16,2);
DEFINE _porc_partic_prima, _porc_exceso        DEC(9,6);
DEFINE _cod_cober_reas,v_cod_subramo           CHAR(3);
	
SET ISOLATION TO DIRTY READ; 

LET v_descr_cia = sp_sis01(a_cia);

CREATE TEMP TABLE tmp_contratos
            (cod_contrato       CHAR(5),
             no_poliza          CHAR(10),
			 no_endoso          CHAR(5),
			 cod_contratante    CHAR(10),
			 vigencia_inic		DATE,
			 vigencia_final		DATE,
			 prima_suscrita     DEC(16,2),
			 prima_exceso       DEC(16,2),
			 prima_contratos    DEC(16,2),
			 estatus			SMALLINT
             );

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_pro981(a_cia,a_agencia, a_periodo1, a_periodo2, _cod_ramo);

CALL sp_pro982(a_cia, a_agencia, a_periodo1, a_periodo2, _cod_ramo); 


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

FOREACH	WITH HOLD
	SELECT no_poliza,
	       no_endoso,
	       no_documento,
	       cod_contratante,
		   prima_suscrita,
		   vigencia_inic
	  INTO v_nopoliza,
	       _no_endoso,
	       v_documento,
	       v_contratante,
	  	   v_prima_suscrita,
		   _vigencia_inic
	  FROM temp_perfil
	  WHERE seleccionado = 1

	SELECT vigencia_inic
	  INTO _vigencia_inic_pol
	  FROM emipomae
	 WHERE no_poliza = v_nopoliza;

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	IF _vigencia_inic < _vigencia_inic_pol  THEN
	   LET _vigencia_inic = _vigencia_inic_pol;
	END IF

--	IF _vigencia_inic < '01/05/1998' THEN
--	   LET _vigencia_inic = '01/05/1998';
--	END IF

	 SELECT ano,
	        vigencia_inic,
			vigencia_final,
			cod_contrato,
			porc_partic_prima,
			porc_exceso,
			estatus
	   INTO _ano,
			v_vigencia_inic,
			v_vigencia_final,
			_cod_contrato_salud,
			_porc_partic_prima,
			_porc_exceso,
			v_estatus
	   FROM tmp_vigencias
	  WHERE no_poliza = v_nopoliza
	    AND vigencia_inic <= _vigencia_inic
		AND vigencia_final >= _vigencia_inic;

		LET _prima_exceso =  v_prima_suscrita * _porc_exceso / 100;

		LET _prima_contratos = (v_prima_suscrita - _prima_exceso) * _porc_partic_prima / 100;

		INSERT INTO tmp_contratos
		VALUES (_cod_contrato_salud,
		        v_nopoliza,
		        _no_endoso,
				v_contratante,
				v_vigencia_inic,
				v_vigencia_final,
				v_prima_suscrita,
				_prima_exceso,
		        _prima_contratos, 
				v_estatus
		        );


 END FOREACH



 FOREACH
     
	 SELECT no_poliza,
			cod_contratante,
		    SUM(prima_suscrita),
			SUM(prima_exceso), 
			SUM(prima_contratos)
	   INTO v_nopoliza,
			v_contratante,
			v_prima_suscrita,
			_prima_exceso,
			_prima_contratos 
	   FROM tmp_contratos
	  WHERE prima_suscrita <> 0
   GROUP BY no_poliza, cod_contratante

   SELECT b.nombre
     INTO v_desc_cliente
     FROM cliclien b
    WHERE b.cod_cliente = v_contratante;

     SELECT no_documento,
			cod_subramo
       INTO v_documento,
			v_cod_subramo
	   FROM emipomae
	  WHERE no_poliza =  v_nopoliza;

--	 IF v_cod_subramo in ('001','005') Then
--	    CONTINUE FOREACH;
--	 END IF
	  

     SELECT nombre
       INTO v_subramo
	   FROM prdsubra
	  WHERE cod_ramo = "018"
	    AND cod_subramo = v_cod_subramo;


       RETURN v_descr_cia,			 --1
       		  _cod_ramo,			 --2
              v_desc_ramo,			 --3
              v_desc_cliente,		 --4
              v_documento,			 --5
              v_prima_suscrita,		 --9
			  _prima_exceso,	     --15
			  (v_prima_suscrita - _prima_exceso),  --	16
			  _prima_contratos, 	 -- contrato
              v_filtros,			 --20
              v_subramo
              WITH RESUME;

END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;
DROP TABLE tmp_vigencias;
END

END PROCEDURE;
