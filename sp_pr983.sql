DROP procedure sp_pr983;

CREATE procedure "informix".sp_pr983(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
RETURNING CHAR(50), 	 --1 cia
		  CHAR(03),		 --2 cod_ramo
		  CHAR(50),		 --3 descr. ramo
		  CHAR(50),		 --4 descr. cliente
          CHAR(20),		 --5 poliza
		  CHAR(10),      --6 factura
          DATE,			 --7 vig ini
          DATE,			 --8 vig fin
          DECIMAL(16,2), --9 prima suscrita
          DECIMAL(16,2), --10 suma asegurada
          DECIMAL(16,2), --11 suma asegurada
          DECIMAL(16,2), --12 suma asegurada
          DECIMAL(16,2), --13 suma asegurada-
          DECIMAL(16,2), --14 prima
          DECIMAL(16,2), --15 prima
          DECIMAL(16,2), --16 prima
		  SMALLINT,		 --17
		  DATE,			 --18
		  DATE,			 --19
          CHAR(255),     --20 v_filtros
          CHAR(50),	     --21 subramo
		  SMALLINT,	     --22 estatus poliza
		  CHAR(1),		 --23 movimiento
		  SMALLINT,		 --24 unidades
		  SMALLINT,		 --25 polizas
		  CHAR(50),		 --26 polizas
		  CHAR(5);	     --27 polizas

----------------------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS COLECTIVO DE VIDA     ---
---  Creado el 13 de Julio 2008, Henry Giron                 ---
---  Ref. Power Builder - d_prod_sp_pr983_dw1	             ---
----------------------------------------------------------------
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
DEFINE _no_endoso, s_no_endoso                 CHAR(5);
DEFINE _cod_contrato, _cod_contrato_salud 	   CHAR(5);
DEFINE _tipo_contrato, _es_terremoto, v_serie, _ano,v_estatus  SMALLINT;
DEFINE _suma, _prima 		  			 	   DEC(16,2);
DEFINE _suma_retencion,	   _prima_retencion    DEC(16,2);
DEFINE _suma_contratos,	   _prima_contratos    DEC(16,2);
DEFINE _suma_facultativos, _prima_facultativos DEC(16,2);
DEFINE _cod_cober_reas,v_cod_subramo           CHAR(3);
DEFINE _porc_prima                             DEC(9,2);
DEFINE _front,_unidad,_xpoliza                 smallint;
DEFINE _nombre_contrato  					   CHAR(50);
define _serie			 					   smallint;
	
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
			 PRIMARY KEY(cod_contrato,no_poliza,no_endoso)) WITH NO LOG;

--set debug file to "sp_pr983.trc";
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
-- WHERE no_documento <> '1605-00002-03';

        
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
						''
				        );
			END
		END FOREACH


  END FOREACH

LET _xpoliza = 0;

select  count(distinct no_poliza)
into _xpoliza
from tmp_contratos 
where suma_asegurada > 0;


 FOREACH     
	 SELECT cod_contrato,
	        no_poliza,
			no_endoso,
			cod_contratante,
	        vigencia_inic,
			vigencia_final,
			suma_asegurada,
		    prima_suscrita,
	        suma_retencion,
	        suma_contratos,
			suma_facultativos,
			prima_retencion, 
			prima_contratos, 
			prima_facultativos,
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
	        _suma_retencion,
	        _suma_contratos,
			_suma_facultativos,
			_prima_retencion, 
			_prima_contratos, 
			_prima_facultativos,
			v_estatus,
			_ano
	   FROM tmp_contratos
	  ORDER BY cod_contrato
        LET _nombre_contrato = '';

--		IF  v_suma_asegurada <= 0 THEN	  -- se inhabilito porque no toma en cuenta los endosos modificados
--		CONTINUE FOREACH;
--		END IF

	   LET _unidad = 0;

      select count(*)
	  into _unidad
	  from emipouni
	 where no_poliza = v_nopoliza
       and suma_asegurada > 0    
       and activo = 1;


   SELECT b.nombre
     INTO v_desc_cliente
     FROM cliclien b
    WHERE b.cod_cliente = v_contratante;

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
			estatus_poliza
	   INTO v_documento,  
	        v_cod_subramo,
		    _nueva_renov,
		    v_vigencia_inic,
		    v_vigencia_final,
		    v_estatus  
		FROM emipomae 
	   WHERE no_poliza = v_nopoliza;

	 SELECT no_factura,
	        cod_endomov
	   INTO v_no_factura,
	        v_cod_endomov
	   FROM endedmae
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = _no_endoso;   

     IF v_cod_endomov = '011' AND  _nueva_renov = 'N' THEN		--poliza original
		IF _ano = 1 THEN
		   LET v_movimiento = '1'; --Nueva
		ELSE
		   LET v_movimiento = '2'; --Renovacion
		END IF
	 ELIF v_cod_endomov = '011' AND  _nueva_renov = 'R' THEN	--poliza original
		LET v_movimiento = '2';	--Renovacion
	 ELIF v_cod_endomov = '002'	THEN							--cancelacion
		LET v_movimiento = '4';	--Cancelacion
	 ELIF v_cod_endomov = '006'	THEN							--modificacion 
		IF _ano = 1 THEN
		   LET v_movimiento = '3'; --Endoso
		ELSE
			LET v_movimiento = '2';	--Renovacion
		END IF
	 ELSE
		LET v_movimiento = '3';	--Endoso
	 END IF

     SELECT nombre
       INTO v_subramo
	   FROM prdsubra
	  WHERE cod_ramo = "016"
	    AND cod_subramo = v_cod_subramo;

		SELECT  nombre, serie
		  INTO _nombre_contrato, _serie
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato_salud;

	    LET _nombre_contrato = trim(_nombre_contrato) ;


--	   LET v_suma_asegurada = _suma_retencion + _suma_contratos + _suma_facultativos;

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
              _suma_retencion,		 --11
              _suma_contratos,		 --12
              _suma_facultativos,	 --13
			  _prima_retencion, 	 --14
			  _prima_contratos, 	 --15
			  _prima_facultativos,	 --16
			  v_serie,				 --17
			  v_vigencia_inic_salud, --18
			  v_vigencia_final_salud,--19
              v_filtros,			 --20
              v_subramo,			 
              v_estatus,
		      v_movimiento,
			  _unidad,
			  _xpoliza,
			  _nombre_contrato,
			  _cod_contrato_salud
              WITH RESUME;

END FOREACH

DROP TABLE temp_perfil;
DROP TABLE tmp_contratos;
END

END PROCEDURE;
