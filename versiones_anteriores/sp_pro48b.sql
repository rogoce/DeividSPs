-- Procedimiento para los Certificados de Salud
-- 
-- Creado    : 06/11/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 06/11/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro48b;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_pro48b(a_poliza CHAR(10), a_unidad CHAR(255) DEFAULT '*') 
			RETURNING   CHAR(100),			 --	v_contratante,
						CHAR(100),			 --	v_asegurado,  
						CHAR(30),            -- v_cedula,
						DATE,                -- v_fecha_nac,
	   					CHAR(50),			 --	v_ramo,		
	   					CHAR(50),			 --	v_subramo,	
						DATE,				 --	v_suscripcion,
						DATE,				 --	v_vigen_ini,  
						DEC(16,2),			 --	v_suma_aseg,	
						CHAR(20),			 --	v_documento,
						CHAR(5),             -- v_unidad		
						CHAR(10),			 -- _no_poliza
						CHAR(5);             -- cod_grupo
											 
DEFINE v_contratante   CHAR(100);			 
DEFINE v_asegurado     CHAR(100);
DEFINE v_cedula        CHAR(30);
DEFINE v_fecha_nac     DATE;
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_vigen_ini     DATE;
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_unidad        CHAR(5);
DEFINE v_documento	   CHAR(20);

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _cod_endomov      CHAR(3);
DEFINE _tipo             CHAR(1);
DEFINE _cod_grupo   	 CHAR(5);

-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),    
		cod_cliente      CHAR(10),  
		vigen_ini        DATE,
		suma_aseg		 DEC(16,2),
		no_unidad        CHAR(5),
		seleccionado     SMALLINT DEFAULT 1		
		) WITH NO LOG;   

SET ISOLATION TO DIRTY READ;
 LET _cod_grupo      = NULL;
FOREACH	
   
   SELECT cod_asegurado,
		  suma_asegurada,
		  vigencia_inic,
		  no_unidad
     INTO _cod_cliente,
		  v_suma_aseg,
		  v_vigen_ini,
		  v_unidad
	 FROM emipouni
	WHERE no_poliza = a_poliza
--	and activo = 1  --- SD#4260 JEPEREZ  

	INSERT INTO tmp_arreglo(
	no_poliza,    
	cod_cliente,	
	vigen_ini,   
	suma_aseg,	 
	no_unidad
	)
	VALUES(
	a_poliza,
	_cod_cliente,
	v_vigen_ini,
	v_suma_aseg,
	v_unidad
	);

END FOREACH;

IF a_unidad <> "*" THEN

	LET _tipo = sp_sis04(a_unidad);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_unidad NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_unidad IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,  
		cod_cliente,
		vigen_ini,  
		suma_aseg,	
		no_unidad
   INTO _no_poliza,
		_cod_cliente,
		v_vigen_ini,
		v_suma_aseg,
		v_unidad
   FROM tmp_arreglo
  WHERE seleccionado = 1

   -- Lectura de emipomae
      
   SELECT cod_contratante,
		  no_documento,
		  fecha_suscripcion,
		  cod_grupo
     INTO _cod_contratante,
		  v_documento,
		  v_suscripcion,
		  _cod_grupo
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	-- Lectura del contratante


	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	-- Lectura del Asegurado

	SELECT nombre,
		   cedula,
		   fecha_aniversario
	  INTO v_asegurado,
	       v_cedula,
		   v_fecha_nac
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    -- Lectura del Ramo y Subramo

    SELECT cod_ramo,
	       cod_subramo
	  INTO _cod_ramo,
	       _cod_subramo
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
	SELECT nombre
	  INTO v_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	RETURN v_contratante,
		   v_asegurado,  
		   v_cedula,
		   v_fecha_nac,
		   v_ramo,		
		   v_subramo,	
		   v_suscripcion,
		   v_vigen_ini,  
		   v_suma_aseg,	
		   v_documento,		
		   v_unidad,
		   a_poliza,
		   _cod_grupo
		   WITH RESUME;   	

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE