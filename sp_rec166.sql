-- Procedimiento que Carga de Informe de Abogado / Reclamos

-- 
-- Creado    : 16/07/2009 - Autor: ROBERTO SILVERA
-- Modificado: 16/07/2009 - Autor: ROBERTO SILVERA
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec166;

CREATE PROCEDURE "informix".sp_rec166(a_compania CHAR(3), a_agencia CHAR(3), a_abogado CHAR(255) DEFAULT "*", a_estatus CHAR(1) DEFAULT "A") 
			RETURNING   CHAR(100), --ASEGURADO
		    	        CHAR(20),  --NO DOCUMENTO
		            	CHAR(1),   --ESTATUS
						CHAR(50),  --NOMBRE ABOGADO
		               	CHAR(50),  --COMPANIA
						CHAR(50),  --CONDUCTORES
						CHAR(50),  --PARTE
						DATE,	   --FECHA AUDIENCIA
						SMALLINT;  --ESTATUS AUDIENCIA

DEFINE v_cod_abogado 	CHAR(3);
DEFINE v_estatus		CHAR(1);
DEFINE v_no_doc			CHAR(20);
DEFINE v_cod_aseg		CHAR(10);
DEFINE v_cod_cond		CHAR(10);
DEFINE v_parte			CHAR(10);
DEFINE v_fecha_audi		date;
DEFINE v_poliza			CHAR(10);
DEFINE v_reclamo		CHAR(10);
DEFINE v_compania_nombre     CHAR(50);
DEFINE _tipo            CHAR(1);
DEFINE v_estatus_au		SMALLINT;

DEFINE v_nom_abog		CHAR(50);
DEFINE v_asegurado		CHAR(100);
DEFINE v_cliente		CHAR(100);
DEFINE v_conductor		CHAR(100);


SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_nom_abog = "";
LET v_asegurado = "";
LET v_cliente = "";

--TODOS LOS ABOGADOS
IF a_abogado = "*" THEN
		FOREACH
		  SELECT recrcmae.cod_abogado,
				 recrcmae.estatus_reclamo,
				 recrcmae.numrecla,
				 recrcmae.cod_asegurado,
				 recrcmae.cod_conductor,
				 recrcmae.parte_policivo,
				 recrcmae.fecha_audiencia,
				 recrcmae.no_poliza,
				 recrcmae.no_reclamo,
				 recrcmae.estatus_audiencia
			INTO v_cod_abogado,
				v_estatus,
				v_no_doc,
				v_cod_aseg,
				v_cod_cond,
				v_parte,
				v_fecha_audi,
				v_poliza,
				v_reclamo,
				v_estatus_au
			FROM recrcmae

			--NOMBRE DEL ABOGADO
			SELECT recaboga.nombre_abogado
			  INTO v_nom_abog
			  FROM recaboga
			 WHERE recaboga.cod_abogado =  v_cod_abogado  ;

			 --NOMBRE DEL CLIENTE
			   SELECT cliclien.nombre
				INTO v_cliente
				FROM cliclien,   
					 emipomae  
			   WHERE ( cliclien.cod_cliente = emipomae.cod_contratante ) and  
					 ( ( emipomae.no_poliza = v_poliza ) )   ;

			--NOMBRE CONDUCTOR
			  SELECT cliclien.nombre
				INTO v_conductor
				FROM cliclien,   
					 recrcmae  
			   WHERE ( recrcmae.cod_conductor = cliclien.cod_cliente ) and  
					( ( recrcmae.no_reclamo = v_reclamo ) )   ;

			--TODAS
			IF a_estatus = "T" AND v_nom_abog <> "" THEN
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "A" AND v_estatus = "A" THEN --ABIERTOS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "C" AND v_estatus = "C" THEN --CERRADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "D" AND v_estatus = "D" THEN --DECLINADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

		END FOREACH

-- INCLUYE O EXCLUYE ABOGADOS
ELSE

	LET _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		FOREACH
		  SELECT recrcmae.cod_abogado,
				 recrcmae.estatus_reclamo, 
				 recrcmae.numrecla,   
				 recrcmae.cod_asegurado,
				 recrcmae.cod_conductor,
				 recrcmae.parte_policivo,
				 recrcmae.fecha_audiencia,
				 recrcmae.no_poliza,
				 recrcmae.no_reclamo,
				 recrcmae.estatus_audiencia
			INTO v_cod_abogado,
				v_estatus,
				v_no_doc,
				v_cod_aseg,
				v_cod_cond,
				v_parte,
				v_fecha_audi,
				v_poliza,
				v_reclamo,
				v_estatus_au
			FROM recrcmae
		   WHERE recrcmae.cod_abogado IN (SELECT codigo FROM tmp_codigos) 

		   --NOMBRE DEL ABOGADO
			SELECT recaboga.nombre_abogado
			  INTO v_nom_abog
			  FROM recaboga
			 WHERE recaboga.cod_abogado =  v_cod_abogado  ;

			 --NOMBRE DEL CLIENTE
			   SELECT cliclien.nombre
				INTO v_cliente
				FROM cliclien,   
					 emipomae  
			   WHERE ( cliclien.cod_cliente = emipomae.cod_contratante ) and  
					 ( ( emipomae.no_poliza = v_poliza ) )   ;

			--NOMBRE CONDUCTOR
			  SELECT cliclien.nombre
				INTO v_conductor
				FROM cliclien,   
					 recrcmae  
			   WHERE ( recrcmae.cod_conductor = cliclien.cod_cliente ) and  
					( ( recrcmae.no_reclamo = v_reclamo ) )   ;

			IF a_estatus = "T" AND v_nom_abog <> "" THEN --TODAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "A" AND v_estatus = "A" THEN --ABIERTOS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "C" AND v_estatus = "C" THEN --CERRADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "D" AND v_estatus = "D" THEN --DECLINADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

		END FOREACH

	ELSE -- (E) Excluir estos Registros

	FOREACH
		  SELECT recrcmae.cod_abogado,   
				 recrcmae.estatus_reclamo,   
				 recrcmae.numrecla,   
				 recrcmae.cod_asegurado,   
				 recrcmae.cod_conductor,   
				 recrcmae.parte_policivo,   
				 recrcmae.fecha_audiencia,
				 recrcmae.no_poliza,
				 recrcmae.no_reclamo,
				 recrcmae.estatus_audiencia
			INTO v_cod_abogado,
				v_estatus,
				v_no_doc,
				v_cod_aseg,
				v_cod_cond,
				v_parte,
				v_fecha_audi,
				v_poliza,
				v_reclamo,
				v_estatus_au
			FROM recrcmae
		   WHERE recrcmae.cod_abogado NOT IN (SELECT codigo FROM tmp_codigos) 

			--NOMBRE DEL ABOGADO
			SELECT recaboga.nombre_abogado  
			  INTO v_nom_abog
			  FROM recaboga  
			 WHERE recaboga.cod_abogado =  v_cod_abogado  ;

			 --NOMBRE DEL CLIENTE
			   SELECT cliclien.nombre
				INTO v_cliente
				FROM cliclien,
					 emipomae
			   WHERE ( cliclien.cod_cliente = emipomae.cod_contratante ) and
					 ( ( emipomae.no_poliza = v_poliza ) )   ;

			--NOMBRE CONDUCTOR
			  SELECT cliclien.nombre
				INTO v_conductor
				FROM cliclien,   
					 recrcmae  
			   WHERE ( recrcmae.cod_conductor = cliclien.cod_cliente ) and  
					( ( recrcmae.no_reclamo = v_reclamo ) )   ;

			IF a_estatus = "T" AND v_nom_abog <> "" THEN --TODAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "A" AND v_estatus = "A" THEN --ABIERTOS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "C" AND v_estatus = "C" THEN --CERRADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

			IF a_estatus = "D" AND v_estatus = "D" THEN --DECLINADAS
				RETURN v_cliente,
					v_no_doc,
					v_estatus,
					v_nom_abog,
					v_compania_nombre,
					v_conductor,
					v_parte,
					v_fecha_audi,
					v_estatus_au
				WITH RESUME;
			END IF

		END FOREACH

	END IF

	DROP TABLE tmp_codigos;

END IF

END PROCEDURE;