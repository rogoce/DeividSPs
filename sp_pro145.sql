-- Modificado: 28/08/2001. Lic. Marquelda Valdelamar, para incluir el filtro de cliente y poliza
-- Modificado: 20/12/2002. Lic. Armando Moreno M. Arreglando el reporte totalmente.

DROP procedure sp_pro145;
CREATE procedure "informix".sp_pro145(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_contrato VARCHAR(255) DEFAULT"*",a_reaseguro CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

 RETURNING CHAR(10),CHAR(45),CHAR(3),CHAR(50),
           CHAR(10),CHAR(20),CHAR(35),DEC(16,2),
           DEC(16,2),DEC(16,2),DEC(16,2),VARCHAR(255),
           VARCHAR(255),INT,DEC(5,2),SMALLINT,VARCHAR(50),VARCHAR(255),SMALLINT,DATE,DATE;

--------------------------------------------
---  DETALLE DE PRODUCCION POR CONTRATO ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro33
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,v_no_unidad          CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_subramo,
             v_cod_tipoprod                  CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo,v_cod_acreedor   CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_porc_comis                    DEC(5,2);
      DEFINE v_cod_contrato,v_cod_contratante,w_cod_contrato, _cod_cliente  CHAR(10);
      DEFINE v_prima,_prima_sus, v_suma, v_suma_asegurada  DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_contrato                 CHAR(45);
      DEFINE v_desc_subramo                  CHAR(25);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_acreedor                 CHAR(30);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo,_tipo_produccion,v_tipo_contrato   CHAR(01);
      DEFINE v_descr_cia                     VARCHAR(50);
      DEFINE s_tipopro                       CHAR(03);
	  DEFINE _tipo_contrato, _orden_comp     smallint;
	  DEFINE _fecha				             DATE;
	  DEFINE v_sum_asegurados, _cont_edad, _edad  INTEGER;
	  DEFINE _sum_edad						 INTEGER;
	  DEFINE _cod_cobertura                  CHAR(5);
	  DEFINE _orden, _longitud, _tipo_fac, _serie SMALLINT;
	  DEFINE _cobertura                      VARCHAR(50);
	  DEFINE v_cobertura, v_cobertura2       VARCHAR(255);
	  DEFINE v_prom_edad                     DEC(5,2);
	  DEFINE _separador, _nueva_renov        CHAR(1);
	  DEFINE _cod_endomov                    CHAR(3);
	  DEFINE v_vigencia_inic, v_vigencia_final DATE;

      CREATE TEMP TABLE temp_detalle
               (cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_agente       CHAR(5),
                cod_usuario      CHAR(8),
                cod_contrato     CHAR(5),
                cod_ramo         CHAR(3),
                cod_subramo      CHAR(3),
                cod_tipoprod     CHAR(3),
				tipo_contrato    CHAR(1),
				tipo_produccion  CHAR(1),
				no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                cod_acreedor     CHAR(05),
                prima            DEC(16,2),
				suma			 DEC(16,2),
                comision         DEC(9,2),
				prima_sus        DEC(16,2),
				suma_asegurada   DEC(16,2),
				edad             INT,
				cont_edad        INT,
				cont_asegurados  INT DEFAULT 1,
				no_poliza        CHAR(10),
				no_unidad        CHAR(5),
				no_endoso        CHAR(5),
				tipo_fac         SMALLINT,
                seleccionado     SMALLINT DEFAULT 1);

      CREATE INDEX id1_temp_detalle ON temp_detalle(cod_sucursal);
      CREATE INDEX id2_temp_detalle ON temp_detalle(cod_grupo);
      CREATE INDEX id3_temp_detalle ON temp_detalle(cod_agente);
      CREATE INDEX id4_temp_detalle ON temp_detalle(cod_usuario);
      CREATE INDEX id5_temp_detalle ON temp_detalle(cod_ramo);
	  CREATE INDEX id6_temp_detalle ON temp_detalle(tipo_produccion);

      CREATE TEMP TABLE temp_detalle2
               (cod_contrato     CHAR(5),
                cod_ramo         CHAR(3),
				no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                prima            DEC(16,2),
				suma			 DEC(16,2),
				prima_sus        DEC(16,2),
				suma_asegurada   DEC(16,2),
				edad             INT,
				cont_edad        INT,
				cont_asegurados  INT DEFAULT 1,
				no_poliza        CHAR(10),
				no_endoso        CHAR(5),
				tipo_fac         SMALLINT,
                PRIMARY KEY (cod_contrato,no_poliza,no_endoso));

      CREATE TEMP TABLE temp_cobert
	           (no_poliza        CHAR(10),
			    no_endoso        CHAR(5),
			    cod_cobertura    CHAR(5),
				orden            SMALLINT,
				PRIMARY KEY (no_poliza,no_endoso,cod_cobertura,orden));

      LET s_tipopro        = NULL;
      LET v_desc_ramo      = NULL;
      LET v_cod_agente     = NULL;
      LET v_prima          = 0;
      LET _prima_sus       = 0;
      LET v_porc_comis     = 0;
	  LET v_cod_acreedor   = " ";

      LET v_descr_cia = sp_sis01(a_compania);

--SET DEBUG FILE TO "sp_pro145";
--TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH WITH HOLD
         SELECT a.no_poliza,
         		a.no_endoso,
         		a.cod_sucursal,
         		a.no_factura,
				a.prima_suscrita,
				a.suma_asegurada,
				a.cod_endomov
           INTO v_nopoliza,
           		v_noendoso,
           		v_cod_sucursal,
           		v_nofactura,
				_prima_sus,
				v_suma_asegurada,
				_cod_endomov
		   FROM endedmae a
          WHERE a.cod_compania = a_compania
            AND a.actualizado  = 1
            AND a.periodo >= a_periodo1
            AND a.periodo <= a_periodo2
			AND a.no_documento[1,2]	= '16'

         SELECT y.cod_grupo,
         		y.cod_ramo,
         		y.cod_subramo,
         		y.user_added,
                y.no_documento,
                y.cod_tipoprod,
                y.cod_contratante,
				y.nueva_renov
           INTO v_cod_grupo,
           		v_cod_ramo,
           		v_cod_subramo,
           		v_cod_usuario,
                v_nodocumento,
                v_cod_tipoprod,
                v_cod_contratante,
				_nueva_renov
           FROM emipomae y
          WHERE y.no_poliza    = v_nopoliza
            AND y.cod_compania = a_compania;

         IF v_cod_ramo IS NULL OR
            v_cod_ramo = " "   THEN
            CONTINUE FOREACH;
         END IF;

		 IF _cod_endomov = '011' THEN
			IF _nueva_renov = 'N' THEN
			   LET _tipo_fac = 1;
			ELSE 
			   LET _tipo_fac = 2;
			END IF
		 ELIF _cod_endomov = '002' THEN	   
		    LET _tipo_fac = 4;
		 ELSE
			LET _tipo_fac = 3;
		 END IF

		 SELECT tipo_produccion
	       INTO _tipo_produccion
		   FROM emitipro
		  WHERE cod_tipoprod = v_cod_tipoprod;

         FOREACH
           SELECT cod_agente,
           		  porc_comis_agt
             INTO v_cod_agente,
             	  v_porc_comis
             FROM emipoagt
            WHERE no_poliza = v_nopoliza

           IF v_cod_agente IS NULL THEN
              CONTINUE FOREACH;
           ELSE
              EXIT FOREACH;
           END IF
         END FOREACH;

		LET v_comision = (_prima_sus * v_porc_comis)/100;

         FOREACH
            SELECT no_unidad,
            	   cod_contrato,
            	   prima,
				   suma_asegurada
              INTO v_no_unidad,
              	   v_cod_contrato,
              	   v_prima,
				   v_suma
              FROM emifacon
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso
   			   AND prima <> 0

             SELECT tipo_contrato
               INTO _tipo_contrato
               FROM reacomae
              WHERE cod_contrato = v_cod_contrato;
			    --AND tipo_contrato <> 1;

			IF _tipo_contrato = 1 THEN
			 CONTINUE FOREACH;
			END IF
               
			SELECT cod_cliente
			  INTO _cod_cliente
			  FROM endeduni
			 WHERE no_poliza = v_nopoliza
			   AND no_endoso = v_noendoso
			   AND no_unidad = v_no_unidad;

            LET _fecha = NULL; 
			LET _edad = 0;

			SELECT fecha_aniversario
			  INTO _fecha
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			IF _fecha IS NOT NULL OR _fecha <> '' THEN
				LET _edad = YEAR(TODAY) - YEAR(_fecha);

				IF MONTH(TODAY) < MONTH(_fecha) THEN
					LET _edad = _edad - 1;
				ELIF MONTH(_fecha) = MONTH(TODAY) THEN
					IF DAY(TODAY) < DAY(_fecha) THEN
						LET _edad = _edad - 1;
					END IF
				END IF
				LET _cont_edad = 1;
			ELSE
				LET _cont_edad = 0;
			END IF

            LET v_tipo_contrato = _tipo_contrato; 

			LET v_cod_acreedor = '';

			FOREACH
             SELECT cod_acreedor
               INTO v_cod_acreedor
               FROM emipoacr
              WHERE no_poliza = v_nopoliza
                AND no_unidad = v_no_unidad
			 EXIT FOREACH;
            END FOREACH; 

		    FOREACH
		     SELECT cod_cobertura,
			        orden
			   INTO _cod_cobertura,
			        _orden
			   FROM endedcob
			  WHERE no_poliza = v_nopoliza
			    AND no_endoso = v_noendoso
				AND no_unidad = v_no_unidad

				BEGIN
					ON EXCEPTION IN(-239, -268)
					END EXCEPTION
				  	INSERT INTO temp_cobert(
					   no_poliza,    
					   no_endoso,
					   cod_cobertura,
					   orden        
					   )
				  	   VALUES(
				  	   v_nopoliza,
					   v_noendoso,
				  	   _cod_cobertura,
					   _orden
				  	   );
				END

			END FOREACH

            INSERT INTO temp_detalle
                  VALUES(v_cod_sucursal,
                         v_cod_grupo,
                         v_cod_agente,
                         v_cod_usuario,
                         v_cod_contrato,
                         v_cod_ramo,
                         v_cod_subramo,
                         v_cod_tipoprod,
						 v_tipo_contrato,
						 _tipo_produccion,
                         v_nofactura,
                         v_nodocumento,
                         v_cod_contratante,
                         v_cod_acreedor,
                         v_prima,
						 v_suma,
                         v_comision,
						 _prima_sus,
						 v_suma_asegurada,
						 _edad,
						 _cont_edad,
						 1,
						 v_nopoliza,
						 v_no_unidad,
						 v_noendoso,
						 _tipo_fac,
                         1);
         END FOREACH
END FOREACH
           -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codagente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agente "||TRIM(a_codagente);
         LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codusuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_codusuario);
         LET _tipo = sp_sis04(a_codusuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	  IF a_reaseguro = "*" THEN
	     LET v_filtros = TRIM(v_filtros) || " Con Reaseguro Asumido ";
	  END IF

		IF a_reaseguro <> "*" THEN

			LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

			IF _tipo <> "E" THEN -- Incluir los Registros

			    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
				UPDATE temp_detalle
				   SET seleccionado = 0
				 WHERE seleccionado = 1
				   AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

			ELSE		        -- Excluir estos Registros

			    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
				UPDATE temp_detalle
				   SET seleccionado = 0
				 WHERE seleccionado = 1
				   AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

			END IF
			DROP TABLE tmp_codigos;

		END IF

	  IF a_contrato <> "*" THEN
	   	LET _tipo = sp_sis04(TRIM(a_contrato));
	   	 -- Separa los Valores del String en una tabla de codigos

	    IF _tipo <> "E" THEN -- Incluir los Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_contrato NOT IN (SELECT codigo FROM tmp_codigos);

     	ELSE		        -- (E) Excluir estos Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_contrato IN (SELECT codigo FROM tmp_codigos);

	    END IF
	    DROP TABLE tmp_codigos;
	   END IF

--Filtro de Poliza
	  IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--       
FOREACH
 SELECT x.cod_contrato,
 		x.cod_ramo,
 		x.no_factura,
 		x.no_documento,
        x.cod_subramo,
        x.cod_contratante,
        x.cod_acreedor,
        x.prima,
        x.suma,
		x.prima_sus,
		x.suma_asegurada, 
		x.edad,           
		x.cont_edad,      
		x.cont_asegurados,
		x.no_poliza,
		x.no_unidad,
		x.no_endoso,
		x.tipo_fac      
   INTO v_cod_contrato,
   		v_cod_ramo,
   		v_nofactura,
        v_nodocumento,
        v_cod_subramo,
        v_cod_contratante,
        v_cod_acreedor,
        v_prima,
		v_suma,
		_prima_sus,
		v_suma_asegurada,
		_edad,
		_cont_edad,
		v_sum_asegurados,
		v_nopoliza,
		v_no_unidad,
		v_noendoso,
		_tipo_fac
   FROM temp_detalle x
  WHERE x.seleccionado = 1
  ORDER BY x.cod_ramo, x.no_factura

	BEGIN
		ON EXCEPTION IN(-239, -268)
		 UPDATE temp_detalle2
		    SET prima = prima + v_prima,
		    	suma = suma + v_suma,
		    	edad = edad + _edad,
		    	cont_edad = cont_edad + _cont_edad,
		    	cont_asegurados = cont_asegurados + 1
		  WHERE cod_contrato = v_cod_contrato
		    AND no_poliza = v_nopoliza
		    AND no_endoso = v_noendoso;
		END EXCEPTION
	  	INSERT INTO temp_detalle2(
		   cod_contrato,   
		   cod_ramo,       
		   no_factura,     
		   no_documento,   
		   cod_contratante,
		   prima,          
		   suma,			
		   prima_sus,      
		   suma_asegurada, 
		   edad,           
		   cont_edad,      
		   cont_asegurados,
		   no_poliza,
		   no_endoso,
		   tipo_fac
		   )
	  	   VALUES(
		   v_cod_contrato,
		   v_cod_ramo,
		   v_nofactura,
		   v_nodocumento,
		   v_cod_contratante,
		   v_prima,
		   v_suma,
		   _prima_sus,
		   v_suma_asegurada,
		   _edad,
		   _cont_edad,
		   1,
		   v_nopoliza,
		   v_noendoso,
		   _tipo_fac
		   );
	END
END FOREACH



FOREACH
    SELECT cod_contrato,   
		   cod_ramo,       
		   no_factura,     
		   no_documento,   
		   cod_contratante,
		   prima,          
		   suma,			
		   prima_sus,      
		   suma_asegurada, 
		   edad,           
		   cont_edad,      
		   cont_asegurados,
		   no_poliza,
		   no_endoso,
		   tipo_fac
      INTO v_cod_contrato,
		   v_cod_ramo,
		   v_nofactura,
		   v_nodocumento,
		   v_cod_contratante,
		   v_prima,
		   v_suma,
		   _prima_sus,
		   v_suma_asegurada,
		   _edad,
		   _cont_edad,
		   v_sum_asegurados,
		   v_nopoliza,
		   v_noendoso,
		   _tipo_fac
	  FROM temp_detalle2

	 SELECT vigencia_inic,
	        vigencia_final
	   INTO v_vigencia_inic,
	       	v_vigencia_final
	   FROM endedmae
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = v_noendoso;

     SELECT nombre
       INTO v_desc_ramo
       FROM prdramo
      WHERE cod_ramo = v_cod_ramo;

     SELECT nombre
       INTO v_desc_nombre
       FROM cliclien
      WHERE cod_cliente = v_cod_contratante;

     SELECT nombre,
	        serie
       INTO v_desc_contrato,
	        _serie
       FROM reacomae
      WHERE cod_contrato = v_cod_contrato;

	 IF  _cont_edad > 0 THEN
	 	LET v_prom_edad = _edad / _cont_edad;
	 ELSE
		LET v_prom_edad = 0;
	 END IF

	 LET v_cobertura = '';
	 LET v_cobertura2 = '';

     SELECT MAX(orden)
	   INTO _orden_comp
	   FROM temp_cobert
	  WHERE no_poliza = v_nopoliza
	    AND no_endoso = v_noendoso;

     FOREACH
	     SELECT cod_cobertura,
		        orden
		   INTO _cod_cobertura,
		        _orden
		   FROM temp_cobert
		  WHERE no_poliza = v_nopoliza
		    AND no_endoso = v_noendoso
		 ORDER BY orden

		 SELECT nombre
		   INTO _cobertura
		   FROM prdcober
		  WHERE cod_cobertura = _cod_cobertura;  

		 IF _orden <> _orden_comp THEN
		   LET _separador = ',';
         ELSE 
		   LET _separador = '';
		 END IF

		 LET _longitud = LENGTH(TRIM(v_cobertura))+LENGTH(Trim(_cobertura) || Trim(_separador));

		 IF _longitud < 255 THEN
         	LET v_cobertura = Trim(v_cobertura) || Trim(_cobertura) || Trim(_separador);
		 ELSE
		    LET v_cobertura2 = Trim(v_cobertura2) || Trim(_cobertura) || Trim(_separador);
		 END IF
		   
	 END FOREACH

     RETURN v_cod_contrato,
     		v_desc_contrato,
     		v_cod_ramo,
     		v_desc_ramo,
            v_nofactura,
            v_nodocumento,
            v_desc_nombre,
            _prima_sus,
			v_suma_asegurada,
            v_prima,
			v_suma,
			Trim(v_cobertura),
			Trim(v_cobertura2),
			v_sum_asegurados,
			v_prom_edad,
			_tipo_fac,
            v_descr_cia,
	        v_filtros,
	        _serie,
	        v_vigencia_inic,
	        v_vigencia_final  
	   WITH RESUME;

      END FOREACH

   DROP TABLE temp_detalle;
   DROP TABLE temp_detalle2;
   DROP TABLE temp_cobert;
   END
END PROCEDURE;
