-- Informes de Detalle de Produccion por Grupo

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo

--DROP procedure sp_pro131a;

CREATE procedure "informix".sp_pro131a(
a_compania     CHAR(03),
a_agencia      CHAR(03),
a_periodo1     CHAR(07),
a_periodo2     CHAR(07),
a_codsucursal  CHAR(255) DEFAULT "*",
a_codgrupo     CHAR(255) DEFAULT "*",
a_codagente    CHAR(255) DEFAULT "*",
a_codusuario   CHAR(255) DEFAULT "*",
a_codramo      CHAR(255) DEFAULT "*",
a_reaseguro    CHAR(255) DEFAULT "*",
a_tipopol      CHAR(1)   DEFAULT "1"
) RETURNING    CHAR(255);

DEFINE v_nopoliza,v_nofactura          CHAR(10);
DEFINE v_nodocumento                   CHAR(20);
DEFINE v_noendoso                      CHAR(5);
DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_tipoprod,v_cod_subramo CHAR(03);
DEFINE v_cod_agente,v_cod_grupo        CHAR(5);
DEFINE v_cod_usuario                   CHAR(8);
DEFINE v_porc_comis,_porc_partic_agt                    DEC(5,2);
DEFINE v_cod_contratante               CHAR(10);
DEFINE v_prima_suscrita,v_prima_neta,v_suma_asegurada,_tot_prima_sus   DECIMAL(16,2);
DEFINE v_comision                      DECIMAL(9,2);
DEFINE v_desc_nombre                   CHAR(35);
DEFINE v_desc_grupo                    CHAR(50);
DEFINE v_filtros                       CHAR(255);
DEFINE _tipo                           CHAR(01);
DEFINE v_estatus,_no_reno,_por_certificado  SMALLINT;
DEFINE v_forma_pago                    CHAR(3);
DEFINE v_cant_pagos                    SMALLINT;
DEFINE v_descr_cia                     CHAR(50);
DEFINE s_tipopro                       CHAR(03);
DEFINE _tipo_produccion                CHAR(01);
DEFINE v_vigencia_inic                 DATE;
DEFINE v_vigencia_final                DATE;
DEFINE _nueva_renov                    CHAR(1);
DEFINE _estado,_declarativa,_es_decla  SMALLINT;
DEFINE _cod_tipocan					   char(3);
define _porc_partic					   dec(16,4);
		
SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_det
               (cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_agente       CHAR(5),
                cod_usuario      CHAR(8),
                cod_ramo         CHAR(3),
				cod_subramo      CHAR(3),
                cod_tipoprod     CHAR(3),
				tipo_produccion  CHAR(01),
                no_poliza        CHAR(10),
                no_endoso        CHAR(5),
                no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                estatus          SMALLINT,
                forma_pago       CHAR(03),
                cant_pagos       SMALLINT,
                suma_asegurada   DEC(16,2),
                prima            DEC(16,2),
				prima_neta       DEC(16,2),
                comision         DEC(9,2),
				vigencia_inic    DATE,
				nueva_renov		 CHAR(1),
                seleccionado     SMALLINT DEFAULT 1,
                estado           SMALLINT DEFAULT 0,
                declarativa      SMALLINT DEFAULT 0,
				cod_tipocan      CHAR(3)
                ) WITH NO LOG;

      CREATE INDEX id1_temp_det ON temp_det(cod_sucursal);
      CREATE INDEX id2_temp_det ON temp_det(cod_grupo);
      CREATE INDEX id3_temp_det ON temp_det(cod_agente);
      CREATE INDEX id4_temp_det ON temp_det(cod_usuario);
      CREATE INDEX id5_temp_det ON temp_det(cod_ramo);
      CREATE INDEX id6_temp_det ON temp_det(cod_tipoprod);
	  CREATE INDEX id7_temp_det ON temp_det(cod_contratante);

      LET s_tipopro         = NULL;
      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_agente      = NULL;
      LET v_cod_contratante = NULL;
      LET v_forma_pago      = " ";
      LET v_cant_pagos      = 0;

      LET v_descr_cia = sp_sis01(a_compania);

      FOREACH
         SELECT no_poliza,
         		no_endoso,
                no_factura,
                prima_suscrita,
                prima_neta,
                suma_asegurada,
         		user_added,
                vigencia_inic,
				cod_tipocan
           INTO v_nopoliza,
           		v_noendoso,
           		v_nofactura,
                v_prima_suscrita,
                v_prima_neta,
                v_suma_asegurada,
				v_cod_usuario,
                v_vigencia_inic,
				_cod_tipocan
           FROM endedmae
          WHERE (periodo    >= a_periodo1
            AND periodo     <= a_periodo2)
			AND actualizado  = 1
			AND cod_compania = a_compania

		 SELECT y.cod_grupo,
		 		y.cod_ramo,
		 		y.cod_formapag,
                y.no_pagos,
                y.estatus_poliza,
                y.no_documento,
                y.cod_tipoprod,
                y.cod_contratante,
                y.sucursal_origen,
                y.nueva_renov,
                y.cod_subramo,
				y.declarativa,
				y.no_renovar,
				y.por_certificado,
				vigencia_final
           INTO v_cod_grupo,
           		v_cod_ramo,
           		v_forma_pago,
                v_cant_pagos,
                v_estatus,
                v_nodocumento,
                v_cod_tipoprod,
                v_cod_contratante,
                v_cod_sucursal,
                _nueva_renov,
                v_cod_subramo,
				_declarativa,
				_no_reno,
				_por_certificado,
				v_vigencia_final
           FROM emipomae y, prdramo p
          WHERE y.cod_ramo     = p.cod_ramo
          	AND	y.no_poliza    = v_nopoliza
            AND y.cod_compania = a_compania
            AND y.actualizado  = 1
            AND p.ramo_sis     = 4; --transporte

         IF v_cod_ramo IS NULL OR
            v_cod_ramo = " "   THEN
            CONTINUE FOREACH;
         END IF;

         SELECT tipo_produccion
           INTO _tipo_produccion
           FROM emitipro
          WHERE cod_tipoprod = v_cod_tipoprod;

		 if v_cod_grupo = "00000" then  --estado
			let _estado = 1;
		 else
			let _estado = 0;
		 end if

		 if _declarativa = 1 then  --es declarativa

			let _es_decla = 1;

		 elif _por_certificado = 1 or _no_reno = 1 then  --es por certificado

			let _es_decla = 2;
		 else

			let _es_decla = 0;

			if v_noendoso       = "00000" and 
			   v_prima_suscrita = 0.00    then
				let _es_decla = 3;
			end if

			if _es_decla = 0            and
			   v_vigencia_final is null then
				let _es_decla = 3;
			end if
			    
		 end if


		if v_cod_tipoprod = "001" then

			select porc_partic_coas
			  into _porc_partic
			  from emicoama
			 where no_poliza    = v_nopoliza
			   and cod_coasegur = "036";

			let v_suma_asegurada = v_suma_asegurada * _porc_partic / 100;


		end if

         FOREACH
            SELECT cod_agente,
            	   porc_comis_agt,
				   porc_partic_agt
              INTO v_cod_agente,
              	   v_porc_comis,
				   _porc_partic_agt
              FROM emipoagt
             WHERE no_poliza = v_nopoliza

			 IF v_porc_comis IS NULL THEN
	            LET v_porc_comis = 0.00;
	         END IF

            LET _tot_prima_sus = v_prima_suscrita * _porc_partic_agt / 100;
            LET v_comision     = _tot_prima_sus   * v_porc_comis / 100;

           INSERT INTO temp_det
                  VALUES(v_cod_sucursal,
                         v_cod_grupo,
                         v_cod_agente,
                         v_cod_usuario,
                         v_cod_ramo,
						 v_cod_subramo,
                         v_cod_tipoprod,
						 _tipo_produccion,
                         v_nopoliza,
                         v_noendoso,
                         v_nofactura,
                         v_nodocumento,
                         v_cod_contratante,
                         v_estatus,
                         v_forma_pago,
                         v_cant_pagos,
                         v_suma_asegurada,
                         _tot_prima_sus,
						 v_prima_neta,
                         v_comision,
						 v_vigencia_inic,
						 _nueva_renov,
                         1,
                         _estado,
                         _es_decla,
                         _cod_tipocan
                         );
         END FOREACH;

      	LET v_forma_pago      = " ";
      	LET v_cant_pagos      = 0;
      	LET _es_decla         = 0;
	  	LET v_suma_asegurada  = 0;

      END FOREACH

-- Procesos v_filtros
      LET v_filtros ="";

--Filtro por Sucursal
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Agente
      IF a_codagente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agente "||TRIM(a_codagente);
         LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Usuario
      IF a_codusuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_codusuario);
         LET _tipo = sp_sis04(a_codusuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registroo

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
	  END IF

--Filtro por Reaseguro
	  IF a_reaseguro = "*" THEN
		 LET v_filtros = TRIM(v_filtros) || " Con Reaseguro Asumido ";
	  END IF
	     
   	  IF a_reaseguro <> "*" THEN
	  
      	LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

     	IF _tipo <> "E" THEN -- Incluir los Registros


	       LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
	       UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

    	ELSE		        -- Excluir estos Registros

	       LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
	       UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

     	END IF

     	DROP TABLE tmp_codigos;

      END IF

--Filtro por Tipo de Poliza
	IF a_tipopol <> '1' THEN

      IF a_tipopol = '2' THEN

	       LET v_filtros = TRIM(v_filtros) || " Polizas Nuevas ";
		   UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND nueva_renov NOT IN ('N');

    	   UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso NOT IN ('00000');


	  ELIF a_tipopol = '3' THEN
	    
	       LET v_filtros = TRIM(v_filtros) || " Polizas Renovadas ";
		   UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND nueva_renov NOT IN ('R');

    	   UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso NOT IN ('00000');

	  ELSE
	     
	       LET v_filtros = TRIM(v_filtros) || " Polizas Endosos ";
		   UPDATE temp_det
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso IN ('00000');
	  END IF
	END IF
	     
    RETURN v_filtros;
   
END PROCEDURE;
