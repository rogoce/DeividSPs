DROP procedure sp_pr984;

CREATE procedure "informix".sp_pr984(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING   CHAR(3),
			CHAR(100),
            CHAR(5),
            CHAR(50),
			CHAR(10),
			CHAR(20),
			CHAR(50),
			CHAR(45),
			DEC(16,2),
			DEC(16,2),
			CHAR(5),
			CHAR(50),
			CHAR(10),
		    DATE,			
		    DATE;	     

----------------------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS COLECTIVO DE VIDA     ---
---  EN BASE A PRIMA COBRADA                                 ---
---  Creado el 21 de Julio 2009, Henry Giron                 ---
---  Ref. Power Builder - dw_proxx				             ---
----------------------------------------------------------------
 BEGIN

DEFINE v_nopoliza,v_contratante, v_no_factura,_no_poliza,_no_remesa  CHAR(10);
DEFINE v_documento                       	              CHAR(20);
DEFINE v_codsucursal, v_cod_endomov,_cod_compania         CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final				      DATE;
DEFINE v_vigencia_inic_salud,v_vigencia_final_salud       DATE;
DEFINE _vigencia_inic,_vigencia_inic_pol,a_hasta,a_desde  DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 	              DECIMAL(16,2);
DEFINE v_prima_asegurada 					              DECIMAL(16,2);
DEFINE v_desc_cliente                    	              CHAR(45);
DEFINE v_descr_cia, v_desc_ramo,v_subramo,_nombre         CHAR(50);
DEFINE v_movimiento, _nueva_renov                         CHAR(1);
DEFINE v_filtros                         	              CHAR(100);
DEFINE _tipo                             	              CHAR(1);
DEFINE _cod_ramo						 	              CHAR(255);
DEFINE _no_endoso, s_no_endoso, a_agente                  CHAR(5);
DEFINE _cod_contrato, _cod_contrato_salud 	              CHAR(5);
DEFINE _tipo_contrato,_es_terremoto, v_serie,_ano,_unidad SMALLINT;
DEFINE _suma, _prima 		  			 	              DEC(16,2);
DEFINE _suma_retencion,_prima_retencion,v_prima_cobrada   DEC(16,2);
DEFINE _suma_contratos,_prima_contratos,v_prima_neta      DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos            DEC(16,2);
DEFINE _cod_cober_reas,v_cod_subramo                      CHAR(3);
DEFINE _porc_prima                                        DEC(9,2);
DEFINE _front,_xpoliza,v_estatus,_renglon,_cod_corr       SMALLINT;
DEFINE _hasta        			                          CHAR(7);
DEFINE _mes_char						                  CHAR(2);
DEFINE _ano_char  						                  CHAR(4);
DEFINE _porc_partic_coas				                  DEC(7,4);
DEFINE _nombre_contrato  					              CHAR(50);
define _serie			 					              smallint;


--LET a_desde = '01/01/2008';	
--LET a_hasta = '30/05/2008';
--LET a_hasta = '30/06/2009' ;	
	
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
             suma_retencion     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2),
			 prima_retencion    DEC(16,2),
			 prima_contratos    DEC(16,2),
			 prima_facultativos DEC(16,2),
			 estatus			SMALLINT,
			 ano                CHAR(1),
	     	 seleccionado       SMALLINT  DEFAULT 1 NOT NULL,
			 PRIMARY KEY(cod_contrato,no_poliza,no_endoso)) WITH NO LOG;


CREATE TEMP TABLE tmp_pago
            (cia                CHAR(3),
			 cia_des            CHAR(100),
             agente             CHAR(5),
             nombre             CHAR(50),
			 no_poliza          CHAR(10),
			 documento          CHAR(20),
			 subramo            CHAR(50),
			 cliente			CHAR(45),
			 prima_neta         DEC(16,2),
			 prima_cobrada      DEC(16,2),
			 cod_contrato       CHAR(5),
			 nombre_contrato  	CHAR(50),
			 cod_contratante    CHAR(10),
	     	 seleccionado       SMALLINT  DEFAULT 1 NOT NULL,
			 PRIMARY KEY(cia,cod_contrato,cod_contratante,no_poliza)) WITH NO LOG;



--set debug file to "sp_pr984.trc";
--trace on;


LET _cod_ramo = '016';     --  Informe para colectivo de Vida

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

LET v_filtros = sp_pro981(a_cia,a_agencia, a_periodo1, a_periodo2, _cod_ramo);

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

--UPDATE temp_perfil
--   SET seleccionado = 0
--WHERE no_documento <> '1605-00002-03';

        
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

		FOREACH
		 SELECT	c.cod_contrato,
				c.suma_asegurada,
				c.prima,
				c.cod_cober_reas,
                c.porc_partic_prima
		   INTO	_cod_contrato,
				_suma,
				_prima,
				_cod_cober_reas	, _porc_prima
		   FROM emifacon c, endedmae e
		  WHERE	c.no_poliza   = v_nopoliza
		    AND c.no_poliza   = e.no_poliza
			AND c.no_endoso   = e.no_endoso
			AND e.no_endoso   = _no_endoso
			AND e.actualizado = 1

			SELECT tipo_contrato , fronting, nombre, serie 
			  INTO _tipo_contrato , _front ,_nombre_contrato, _serie 
			  FROM reacomae 
			 WHERE cod_contrato = _cod_contrato; 

	        SELECT es_terremoto
			  INTO _es_terremoto
			  FROM reacobre
			 WHERE cod_cober_reas = _cod_cober_reas;

		    LET _nombre_contrato = trim(_nombre_contrato); --|| " - " || _serie;


			LET _suma_retencion    = 0;
			LET _suma_facultativos = 0;
			LET _suma_contratos    = 0;
			LET _prima_retencion    = 0;
			LET _prima_contratos    = 0;
			LET _prima_facultativos = 0;

			if _porc_prima <> 100 or _tipo_contrato <> 1 then
				continue FOREACH;
			end if


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

	        LET v_prima_suscrita = _prima_retencion + _prima_contratos + _prima_facultativos;
	        LET v_suma_asegurada = _suma_retencion + _suma_contratos + _suma_facultativos; 

--			IF  v_suma_asegurada <= 0 THEN
--			CONTINUE FOREACH;
--			END IF

			LET s_no_endoso = _no_endoso;			
	         	
			BEGIN
				ON EXCEPTION IN(-239)
					UPDATE tmp_contratos
					   SET suma_asegurada     =  suma_asegurada    	+ v_suma_asegurada,
						   prima_suscrita     =   prima_suscrita    + v_prima_suscrita,
				           suma_retencion     =   suma_retencion    + _suma_retencion,
				           suma_contratos     =   suma_contratos    + _suma_contratos,
				           suma_facultativos  =   suma_facultativos + _suma_facultativos,
				           prima_retencion    =   prima_retencion   + _prima_retencion,
				           prima_contratos    =   prima_contratos   + _prima_contratos,
				           prima_facultativos =  prima_facultativos	+ _prima_facultativos
					 WHERE cod_contrato = _cod_contrato
					   AND no_poliza = v_nopoliza
					   AND no_endoso = _no_endoso;

	        	END EXCEPTION

				INSERT INTO tmp_contratos
				VALUES (_cod_contrato,
				        v_nopoliza,
				        _no_endoso,
						v_contratante,
						_vigencia_inic,
						current,
						v_suma_asegurada,
						v_prima_suscrita,
				        _suma_retencion, 
				        _suma_contratos, 
				        _suma_facultativos, 
				        _prima_retencion, 
				        _prima_contratos, 
				        _prima_facultativos,
						'',
						'',
						1
				        );
			END
		END FOREACH
  END FOREACH

--UPDATE tmp_contratos
--       SET seleccionado = 0
--     WHERE seleccionado = 1
--       AND suma_asegurada <= 0 ;	 -- se inhabilito para tomar en cuenta los endosos de modificacion.

FOREACH     
	 SELECT distinct cod_contrato,
	        no_poliza,
   		    cod_contratante
	   INTO _cod_contrato,
	        v_nopoliza,
			v_contratante
	   FROM tmp_contratos
      WHERE seleccionado = 1
	  ORDER BY cod_contrato,no_poliza

		SELECT b.nombre
		 INTO v_desc_cliente
		 FROM cliclien b
		WHERE b.cod_cliente = v_contratante;

		SELECT no_documento, 
			   cod_subramo 
		INTO v_documento,  
		     v_cod_subramo 
		FROM emipomae 
		WHERE no_poliza = v_nopoliza;

		SELECT nombre
		INTO v_subramo
		FROM prdsubra
		WHERE cod_ramo = "016"
		AND cod_subramo = v_cod_subramo;

		SELECT tipo_contrato , fronting, nombre, serie 
		INTO _tipo_contrato, _front, _nombre_contrato, _serie 
		FROM reacomae 
		WHERE cod_contrato = _cod_contrato; 

	    LET _nombre_contrato = trim(_nombre_contrato); --|| " - " || _serie;

		FOREACH
			   SELECT d.cod_compania,
		          	  d.no_poliza,
		         	  d.no_remesa,
					  d.renglon,	     
					  d.monto,
					  d.prima_neta
			     INTO _cod_compania,
		           	  _no_poliza,
					  _no_remesa,
					  _renglon,			 
			          v_prima_cobrada,
					  v_prima_neta
			     FROM cobredet d, cobremae m 
			    WHERE d.periodo      >= a_periodo1
				  AND d.periodo      <= a_periodo2
			      AND d.actualizado  = 1
		  		  AND d.renglon      <> 0
				  AND d.cod_compania = a_cia
				  AND d.no_poliza    = v_nopoliza
			      AND d.tipo_mov     IN ('P','N')
			      AND d.no_remesa    = m.no_remesa
			      AND m.tipo_remesa  IN ('A', 'M', 'C')

				-- BETWEEN a_desde AND a_hasta

				SELECT count(*)
				  INTO _cod_corr
				  FROM cobreagt
				 WHERE no_remesa  = _no_remesa
				   AND renglon    = _renglon;

				IF _cod_corr = 0 THEN
				   CONTINUE FOREACH;
				END IF


				FOREACH
				 Select cod_agente
				   Into a_agente
				   From cobreagt
				  Where no_remesa = _no_remesa
				    And renglon   = _renglon
				  EXIT FOREACH;
				END FOREACH	


				SELECT nombre
			      INTO _nombre
			      FROM agtagent    
			     WHERE cod_agente   = a_agente
			       AND cod_compania = a_cia;
				
				IF _nombre IS NULL OR _nombre = " " THEN
		           CONTINUE FOREACH;
		        END IF

				SELECT porc_partic_coas
				INTO _porc_partic_coas 
				FROM emicoama
				WHERE no_poliza    = v_nopoliza
				 AND cod_coasegur = "036";

				if _porc_partic_coas is null then
					let _porc_partic_coas = 100;
				end if

				IF v_prima_neta IS NULL  THEN
		           LET v_prima_neta = 0 ;
		        END IF

				IF  v_prima_cobrada	IS NULL  THEN
		           LET  v_prima_cobrada = 0 ;
		        END IF

				let v_prima_neta = v_prima_neta * _porc_partic_coas / 100;
				let v_prima_cobrada = v_prima_cobrada * _porc_partic_coas / 100;

				BEGIN
					ON EXCEPTION IN(-239)
						UPDATE tmp_pago
						   SET prima_neta     =  prima_neta    	+ v_prima_neta,
							   prima_cobrada  =  prima_cobrada  + v_prima_cobrada
						 WHERE cia = _cod_compania
						   AND no_poliza = _no_poliza
						   AND cod_contratante = v_contratante
						   AND cod_contrato = _cod_contrato;

					END EXCEPTION

					INSERT INTO tmp_pago
					VALUES (_cod_compania,
					        v_descr_cia,
					        a_agente,
							_nombre,
							_no_poliza,
							v_documento,
							v_subramo,
							v_desc_cliente,
							v_prima_neta,
							v_prima_cobrada,
							_cod_contrato,
							_nombre_contrato,
							v_contratante,
							1
					        );
				END
	END FOREACH
END FOREACH

 FOREACH     
	 SELECT cia,
			 cia_des,
             agente,
             nombre,
			 no_poliza,
			 documento,
			 subramo,
			 cliente,
			 prima_neta,
			 prima_cobrada,
			 cod_contrato,
             nombre_contrato,
			 cod_contratante
	   INTO a_cia,
			 v_descr_cia,
             a_agente,
             _nombre,
             v_nopoliza,
			 v_documento,
			 v_subramo,
			 v_desc_cliente,
			 v_prima_neta,
			 v_prima_cobrada,
			 _cod_contrato,
			 _nombre_contrato,
			 v_contratante
	   FROM tmp_pago
      WHERE seleccionado = 1
	  ORDER BY cia,agente


     SELECT vigencia_inic,
			vigencia_final
	   INTO v_vigencia_inic,
		    v_vigencia_final
		FROM emipomae 
	   WHERE no_poliza = v_nopoliza;


       RETURN a_cia,			--1
			 v_descr_cia,		--2
             a_agente,			--3
             _nombre,			--4
             v_nopoliza,		--5
			 v_documento,		--6
			 v_subramo,			--7
			 v_desc_cliente,	--8
			 v_prima_neta,		--9
			 v_prima_cobrada,	--10
			 _cod_contrato,		--11
			 _nombre_contrato,	--12
			 v_contratante,		--13
			 v_vigencia_inic,   --14
		     v_vigencia_final	--15
             WITH RESUME;


END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;
DROP TABLE tmp_pago;

END

END PROCEDURE;	 