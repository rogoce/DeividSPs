DROP procedure sp_pro98i;

CREATE procedure "informix".sp_pro98i(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING CHAR(50), 	 --1 cia					 v_descr_cia,			 
		  CHAR(03),		 --2 cod_ramo				 _cod_ramo,			 
		  CHAR(50),		 --3 descr. ramo			 v_desc_ramo,			 
		  CHAR(50),		 --4 descr. cliente			 v_desc_cliente,
          CHAR(20),		 --5 poliza					 v_documento,			 
		  CHAR(10),      --6 factura				 v_no_factura,			 
          DATE,			 --7 vig ini				 v_vigencia_inic,		 
          DATE,			 --8 vig fin				 v_vigencia_final,		 
          DECIMAL(16,2), --9 prima suscrita			 v_prima_suscrita,		 
          DECIMAL(16,2), --10 suma asegurada		 v_suma_asegurada,		 
          DECIMAL(16,2), --11 comision				 _comision,		     
          DECIMAL(16,2), --12 suma asegurada		 _suma_contratos,		 
          DECIMAL(16,2), --13 suma asegurada-		 _suma_facultativos,	 
          DECIMAL(16,2), --14 prima					 _prima_contratos, 	 
          DECIMAL(16,2), --15 prima					 _prima_facultativos,	 
          DECIMAL(16,2), --16 prima					 _comision_fac,
		  DECIMAL(16,2), --17               		 _impuesto_fac,
		  SMALLINT,		 --18						 v_serie,				 
		  DATE,			 --19						 v_vigencia_inic_salud, 
          DATE,			 --20						 v_vigencia_final_salud,
          CHAR(255),     --21 v_filtros				 v_filtros,			 
		  CHAR(50),	     --22 subramo				 v_subramo,			 
		  CHAR(10),	     --23 estatus poliza		 v_estatus,
		  CHAR(7),	     --24 periodo				 v_periodo
		  SMALLINT,    	 --25 edad
		  CHAR(1),	 	 --26 sexo
		  DATE;
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
DEFINE _vigencia_inic,_vigencia_inic_pol       DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 	   DECIMAL(16,2);
DEFINE v_prima_asegurada 					   DECIMAL(16,2);
DEFINE v_desc_cliente                    	   CHAR(45);
DEFINE v_descr_cia, v_desc_ramo,v_subramo  	   CHAR(50);
DEFINE v_movimiento, _nueva_renov              CHAR(1);
DEFINE v_filtros                         	   CHAR(100);
DEFINE _tipo                             	   CHAR(1);
DEFINE _cod_ramo						 	   CHAR(255);
DEFINE _no_endoso, _no_unidad                  CHAR(5);

DEFINE _cod_contrato, _cod_contrato_salud 	   CHAR(5);
DEFINE _tipo_contrato, _es_terremoto, v_serie, _ano,v_estatus  SMALLINT;
DEFINE _suma, _prima 		  			 	   DEC(16,2);
DEFINE _suma_retencion, _prima_retencion       DEC(16,2);
DEFINE _impuesto_fac,	   _comision_fac       DEC(16,2);
DEFINE _suma_contratos,	   _prima_contratos    DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos DEC(16,2);
DEFINE _cod_cober_reas,v_cod_subramo           CHAR(3);
DEFINE _porc_partic_agt, _porc_comis_agt	   DEC(5,2);
DEFINE _comision                               DEC(16,2);
DEFINE _porc_partic_reas                       DEC(9,6);
DEFINE _porc_comis_fac                         DEC(5,2);
DEFINE _porc_impuesto                          DEC(5,2);
DEFINE v_periodo                               CHAR(7);
DEFINE v_edad                                  SMALLINT;
DEFINE v_sexo                                  CHAR(1);
DEFINE _fecha_aniversario, v_fecha_cancelacion DATE;
DEFINE v_estatus_letra                         CHAR(10);

SET ISOLATION TO DIRTY READ; 

LET v_descr_cia = sp_sis01(a_cia);

CREATE TEMP TABLE tmp_contratos
            (cod_contrato       CHAR(5),
             no_poliza          CHAR(10),
			 no_endoso          CHAR(5),
			 cod_contratante    CHAR(10),
			 vigencia_inic		DATE,
			 vigencia_final		DATE,
			 suma_asegurada     DEC(16,2),
			 prima_suscrita     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2),
			 prima_contratos    DEC(16,2),
			 prima_facultativos DEC(16,2),
			 comision_fac       DEC(16,2),
			 impuesto_fac		DEC(16,2),
			 estatus			SMALLINT,
			 ano                CHAR(1),
			 PRIMARY KEY(no_poliza)) WITH NO LOG;

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 6;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_pro981i(a_cia,a_agencia, a_periodo1, a_periodo2, _cod_ramo);

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

		IF v_prima_suscrita = 0 THEN
			CONTINUE FOREACH;
		END IF

		SELECT vigencia_inic
		  INTO _vigencia_inic_pol
		  FROM emipomae
		 WHERE no_poliza = v_nopoliza;

		-- Informacion de Reaseguro para Sacar la Distribucion de
		-- los contratos

		IF _vigencia_inic < _vigencia_inic_pol  THEN
		   LET _vigencia_inic = _vigencia_inic_pol;
		END IF

		 SELECT ano,
		        vigencia_inic,
				vigencia_final,
				cod_contrato,
				estatus
		   INTO _ano,
				v_vigencia_inic,
				v_vigencia_final,
				_cod_contrato_salud,
				v_estatus
		   FROM tmp_vigencias
		  WHERE no_poliza = v_nopoliza
	    	AND vigencia_inic <= _vigencia_inic
			AND vigencia_final >= _vigencia_inic;

		IF _cod_contrato_salud IS NULL THEN
--		   SET DEBUG FILE TO "sp_pr98b.trc";
--		   trace on;
		   LET v_nopoliza = v_nopoliza;
		   LET v_vigencia_inic = v_vigencia_inic;
		   LET _no_endoso = _no_endoso;
		END IF

		FOREACH
		 SELECT	c.cod_contrato,
				c.suma_asegurada,
				c.prima,
				c.cod_cober_reas,
				c.no_unidad
		   INTO	_cod_contrato,
				_suma,
				_prima,
				_cod_cober_reas,
				_no_unidad
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

			LET _impuesto_fac = 0;	   
			LET _comision_fac = 0;
			LET _suma_facultativos = 0;
			LET _suma_contratos    = 0;
			LET _prima_contratos    = 0;
			LET _prima_facultativos = 0;
			LET _suma_retencion = 0;
			LET _prima_retencion = 0;

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

				SELECT porc_partic_reas,
				       porc_comis_fac,
					   porc_impuesto
				  INTO _porc_partic_reas,
					   _porc_comis_fac,  
					   _porc_impuesto  
				  FROM emifafac
				 WHERE no_poliza = v_nopoliza
				   AND no_endoso = _no_endoso 	   
				   AND cod_contrato = _cod_contrato
				   AND no_unidad = _no_unidad;

                LET _comision_fac = _prima_facultativos * _porc_partic_reas/100 * _porc_comis_fac/100;
				LET _impuesto_fac = _prima_facultativos * _porc_partic_reas/100 * _porc_impuesto/100;

			ELSE
				IF _es_terremoto = 1 THEN
					LET _suma_contratos    = 0;
				ELSE
					LET _suma_contratos    = _suma;
				END IF
				LET _prima_contratos    = _prima;
			END IF

	        LET v_prima_suscrita = _prima_retencion + _prima_contratos + _prima_facultativos;
	        LET v_suma_asegurada = _suma_retencion + _suma_contratos + _suma_facultativos; 
	         	
			BEGIN
				ON EXCEPTION IN(-239)
					UPDATE tmp_contratos
					   SET suma_asegurada     =  suma_asegurada    	+ v_suma_asegurada,
						   prima_suscrita     =   prima_suscrita    + v_prima_suscrita,
				           suma_contratos     =   suma_contratos    + _suma_contratos,
				           suma_facultativos  =   suma_facultativos + _suma_facultativos,
				           prima_contratos    =   prima_contratos   + _prima_contratos,
				           prima_facultativos =  prima_facultativos	+ _prima_facultativos,
						   comision_fac       =   comision_fac		+ _comision_fac,
						   impuesto_fac       =   impuesto_fac      + _impuesto_fac
					 WHERE no_poliza = v_nopoliza;

	        	END EXCEPTION

				INSERT INTO tmp_contratos
				VALUES (_cod_contrato_salud,
				        v_nopoliza,
				        _no_endoso,
						v_contratante,
						v_vigencia_inic,
						v_vigencia_final,
						v_suma_asegurada,
						v_prima_suscrita,
				        _suma_contratos, 
				        _suma_facultativos, 
				        _prima_contratos, 
				        _prima_facultativos,
						_comision_fac,
						_impuesto_fac,
						v_estatus,
						_ano
				        );
			END
		END FOREACH


  END FOREACH


 FOREACH
     
	 SELECT cod_contrato,
	        no_poliza,
			no_endoso,
			cod_contratante,
	        vigencia_inic,
			vigencia_final,
			suma_asegurada,
		    prima_suscrita,
	        suma_contratos,
			suma_facultativos,
			prima_contratos, 
			prima_facultativos,
			comision_fac,
			impuesto_fac,
			estatus,
			ano
	   INTO _cod_contrato_salud,
	        v_nopoliza,
			_no_endoso,
			v_contratante,
			v_vigencia_inic,
			v_vigencia_final,
			v_suma_asegurada,
			v_prima_suscrita,
	        _suma_contratos,
			_suma_facultativos,
			_prima_contratos, 
			_prima_facultativos,
			_comision_fac,
			_impuesto_fac,
			v_estatus,
			_ano
	   FROM tmp_contratos

   SELECT nombre,
          fecha_aniversario,
		  sexo
     INTO v_desc_cliente,
	      _fecha_aniversario,
		  v_sexo
     FROM cliclien 
    WHERE cod_cliente = v_contratante;

    LET v_edad = DATE(CURRENT) - _fecha_aniversario;
	LET v_edad = v_edad /365;

	 SELECT serie,
	        vigencia_inic,
			vigencia_final
	   INTO v_serie,
	        v_vigencia_inic_salud,
			v_vigencia_final_salud
	   FROM reacomae
	  WHERE cod_contrato = _cod_contrato_salud;

     SELECT no_documento,
			cod_subramo,
			nueva_renov,
			vigencia_inic,
			vigencia_final,
		    fecha_cancelacion,
			estatus_poliza
	   INTO v_documento,  
	        v_cod_subramo,
		    _nueva_renov,
		    v_vigencia_inic,
		    v_vigencia_final,
		    v_fecha_cancelacion,
		    v_estatus  
		FROM emipomae 
	   WHERE no_poliza = v_nopoliza;

	 SELECT no_factura,
	        periodo
	   INTO v_no_factura,
	        v_periodo
	   FROM endedmae
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = _no_endoso;   

     SELECT nombre
       INTO v_subramo
	   FROM prdsubra
	  WHERE cod_ramo = "019"
	    AND cod_subramo = v_cod_subramo;

     LET _comision = 0;
	 LET _porc_partic_agt = 0;
	 LET _porc_comis_agt = 0;

	 FOREACH
    	SELECT porc_partic_agt,
		       porc_comis_agt
		  INTO _porc_partic_agt,
		       _porc_comis_agt
		  FROM emipoagt
		 WHERE no_poliza = v_nopoliza

		LET _comision =  _comision + (v_prima_suscrita * _porc_partic_agt/100 * _porc_comis_agt/100);

	 END FOREACH

	 IF v_estatus = 1 THEN
	 	LET v_estatus_letra = 'VIGENTE';
	 ELIF v_estatus = 2 THEN
	 	LET v_estatus_letra = 'CANCELADA';
	 ELIF v_estatus = 3 THEN
	 	LET v_estatus_letra = 'VENCIDA';
	 ELSE
	 	LET v_estatus_letra = 'ANULADA';
     END IF

       RETURN v_descr_cia,			 --1
       		  _cod_ramo,			 --2
              v_desc_ramo,			 --3
              v_desc_cliente,		 --4
              v_documento,			 --5
			  v_no_factura,			 --6
              v_vigencia_inic,		 --7
              v_vigencia_final,		 --8
              v_prima_suscrita,		 --9
			  v_suma_asegurada,		 --10
              _comision,		     --11
              _suma_contratos,		 --12
              _suma_facultativos,	 --13
			  _prima_contratos, 	 --14
			  _prima_facultativos,	 --15
			  _comision_fac,		 --16
			  _impuesto_fac,		 --17
			  v_serie,				 --18
			  v_vigencia_inic_salud, --19
			  v_vigencia_final_salud,--20
              v_filtros,			 --21
              v_subramo,			 --22
              v_estatus_letra,		 --23
		      v_periodo,			 --24
			  v_edad,
			  v_sexo,
			  v_fecha_cancelacion
              WITH RESUME;

END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;
DROP TABLE tmp_vigencias;
END

END PROCEDURE;
