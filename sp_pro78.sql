-- Procedimiento para los Certificados de Colectivo de Vida
-- 
-- Creado    : 06/11/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 16/08/2001 - Autor: Armando Moreno.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro78;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_pro78(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(255) DEFAULT '*') 
			RETURNING   CHAR(100),			 --	v_contratante,
						CHAR(100),			 --	v_asegurado,  
						DATE,                -- v_fecha_nac,
	   					CHAR(50),			 --	v_ramo,		
	   					CHAR(50),			 --	v_subramo,	
						DATE,				 --	v_suscripcion,
						DATE,				 --	v_vigen_ini,  
						DEC(16,2),			 --	v_suma_aseg,	
						CHAR(20),			 --	v_documento,
						CHAR(5),             -- v_unidad
						CHAR(10),			 -- a_poliza
						DEC(16,2),           -- suma aseg adicional
						CHAR(30),			 -- a_poliza
						char(30),			 -- ipnumber
						date;                --vigen_final
																	 
DEFINE v_contratante   CHAR(100);			 
DEFINE v_asegurado     CHAR(100);
DEFINE v_fecha_nac     DATE;			 
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_vigen_ini     DATE;
DEFINE v_vigen_final   DATE;
DEFINE v_suma_aseg,v_suma_aseg_adi DEC(16,2);
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
DEFINE _cedula		     CHAR(30);
define _ip_number		 char(30);

-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),    
		cod_cliente      CHAR(10),  
		vigen_ini        DATE,
		vigen_final		 DATE,
		suma_aseg		 DEC(16,2),
		unidad        	 CHAR(5),
		suma_aseg_adi    DEC(16,2),
		seleccionado     SMALLINT DEFAULT 1
		) WITH NO LOG;   

FOREACH	
   
   SELECT cod_cliente,
		  suma_asegurada,
		  vigencia_inic,
		  vigencia_final,
		  no_unidad,
		  suma_aseg_adic
     INTO _cod_cliente,
		  v_suma_aseg,
		  v_vigen_ini,
		  v_vigen_final,
		  v_unidad,
		  v_suma_aseg_adi
	 FROM endeduni
	WHERE no_poliza = a_poliza
	  AND no_endoso = a_endoso

	IF v_suma_aseg_adi IS NULL THEN
		LET v_suma_aseg_adi = 0.00;
	END IF

	LET v_suma_aseg =  v_suma_aseg - v_suma_aseg_adi;

	INSERT INTO tmp_arreglo(
	no_poliza,    
	cod_cliente,	
	vigen_ini,
    vigen_final,
	suma_aseg,
	unidad,
	suma_aseg_adi
	)
	VALUES(
	a_poliza,
	_cod_cliente,
	v_vigen_ini,
	v_vigen_final,
	v_suma_aseg,
	v_unidad,
	v_suma_aseg_adi
	);

END FOREACH;

IF a_unidad <> "*" THEN

	LET _tipo = sp_sis04(a_unidad);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND unidad NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND unidad IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,  
		cod_cliente,
		vigen_ini,
		vigen_final,		
		suma_aseg,	
		unidad,
		suma_aseg_adi
   INTO _no_poliza,
		_cod_cliente,
		v_vigen_ini,
		v_vigen_final,
		v_suma_aseg,
		v_unidad,
		v_suma_aseg_adi
   FROM tmp_arreglo
  WHERE seleccionado = 1

   -- Lectura de emipomae
      
   SELECT cod_contratante,
		  no_documento
     INTO _cod_contratante,
		  v_documento
     FROM emipomae
    WHERE no_poliza = _no_poliza;

   SELECT fecha_emision
     INTO v_suscripcion
	 FROM endedmae
	WHERE no_poliza = _no_poliza
	  AND no_endoso = a_endoso;

	-- Lectura del contratante


	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	-- Lectura del Asegurado

	SELECT nombre,
		   fecha_aniversario,
		   cedula,
		   ip_number
	  INTO v_asegurado,
		   v_fecha_nac,
		   _cedula,
		   _ip_number
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
		   v_fecha_nac,
		   v_ramo,		
		   v_subramo,	
		   v_suscripcion,
		   v_vigen_ini,  
		   v_suma_aseg,	
		   v_documento,		
		   v_unidad,
		   a_poliza,
		   v_suma_aseg_adi,
		   _cedula,
		   _ip_number,
		   v_vigen_final
		   WITH RESUME;   	

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE