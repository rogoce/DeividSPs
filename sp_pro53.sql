-- Procedimiento para los endosos descriptivos
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 26/06/2001 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro53;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro53(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5))
			RETURNING   CHAR(100),			 --	v_contratante,
						CHAR(100),			 --	v_asegurado, 
	   					CHAR(50),			 --	v_direccion,
	   					CHAR(50),			 --	v_dir_cobro,
						CHAR(20),			 --	v_dir_postal,
						CHAR(10),			 --	v_telefono1, 
						CHAR(10),			 --	v_telefono2,	
						CHAR(10),			 --	v_fax,	
	   					CHAR(50),			 --	v_ramo,	
	   					CHAR(50),			 --	v_subramo,
						DATE,				 --	v_suscripcion,
						DEC(16,2),			 --	v_suma_aseg,
						CHAR(20),			 --	v_poliza,
						CHAR(10),			 --	v_factura,	
						DATE,				 --	v_vig_ini_pol,
						DATE,				 --	v_vig_fin_pol,
						CHAR(10),			 --	v_tipo_factura,
						CHAR(50),			 --	v_desc_factura,
						CHAR(30),			 --	v_fecha_letra,
						CHAR(30),	   		 --	v_cedula
						DATE,				 -- v_vig_i_end
						DATE,				 -- v_vig_f_end
						CHAR(10),			 -- _cod_cliente
						CHAR(10);			 -- _cod_contratante
	
DEFINE v_contratante   CHAR(100);
DEFINE v_asegurado     CHAR(100);
DEFINE v_direccion	   CHAR(50);
DEFINE v_dir_cobro     CHAR(50);
DEFINE v_dir_postal    CHAR(20);
DEFINE v_telefono1     CHAR(10);
DEFINE v_telefono2	   CHAR(10);
DEFINE v_fax		   CHAR(10);
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_poliza		   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_vig_ini_pol   DATE;
DEFINE v_vig_fin_pol   DATE;
DEFINE v_tipo_factura  CHAR(10);
DEFINE v_desc_factura  CHAR(50);
DEFINE v_fecha_letra   CHAR(30);
DEFINE v_dia           CHAR(2);
DEFINE v_ano           CHAR(4);
DEFINE v_cedula        CHAR(30);
DEFINE v_vig_i_end     DATE;
DEFINE v_vig_f_end	   DATE;


DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_modelo       CHAR(5);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_tipoauto     CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _cod_endomov      CHAR(3);
DEFINE _dia              CHAR(2);
DEFINE _ano              CHAR(4);

SET ISOLATION TO DIRTY READ;

let _no_poliza = a_poliza;
-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10), 
		cod_cliente	     CHAR(10), 
		vigen_ini        DATE,
		vigen_final      DATE,
		suma_aseg		 DEC(16,2),
		cod_contratante  CHAR(10),
		vig_ini_pol		 DATE,
		vig_fin_pol		 DATE,
		nueva_renov		 CHAR(1)
		) WITH NO LOG;


-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

FOREACH	

	-- Lectura de Endedmae y Emipomae

	SELECT x.no_factura,
	       x.no_documento,
		   x.fecha_emision,
		   x.cod_endomov,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.suma_asegurada,
		   y.cod_pagador,
		   x.vigencia_inic_pol,
		   x.vigencia_final_pol,
		   y.nueva_renov
	  INTO v_factura,
		   v_poliza,	
		   v_suscripcion,
		   _cod_endomov,
		   v_vig_i_end,
		   v_vig_f_end,
		   v_suma_aseg,
		   _cod_contratante,
		   v_vig_ini_pol,
		   v_vig_fin_pol,
		   _nueva_renov
	  FROM endedmae x, emipomae y 
	 WHERE y.no_poliza = x.no_poliza
	   AND x.no_poliza = a_poliza
	   AND x.no_endoso = a_endoso

	-- Lectura de endeduni

	 SELECT cod_cliente
	   INTO _cod_cliente
	   FROM endeduni
	  WHERE no_poliza = a_poliza
	    AND no_endoso = a_endoso
		AND no_unidad = a_unidad;


	INSERT INTO tmp_arreglo(
	no_poliza,
	cod_cliente,
	vigen_ini,
	vigen_final,
	suma_aseg,
	cod_contratante,
	vig_ini_pol,		
	vig_fin_pol,		
	nueva_renov
	)
	VALUES(
	_no_poliza,
	_cod_cliente,
	v_vig_i_end,
	v_vig_f_end,
	v_suma_aseg,
	_cod_contratante,
	v_vig_ini_pol,
	v_vig_fin_pol,
	_nueva_renov
	);

END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza, 
		cod_cliente,
		vigen_ini,
		vigen_final,
		suma_aseg,	
		cod_contratante,
		vig_ini_pol,	
		vig_fin_pol,	
		nueva_renov	
   INTO _no_poliza,
        _cod_cliente,
		v_vig_i_end,
		v_vig_f_end,
		v_suma_aseg,
		_cod_contratante,
		v_vig_ini_pol,
		v_vig_fin_pol,
		_nueva_renov
   FROM tmp_arreglo


	-- Lectura del Asegurado

	SELECT nombre,
	       cedula,
		   direccion_1,
		   direccion_2,
		   telefono1,
		   telefono2,
		   fax,
		   apartado
	  INTO v_asegurado,
	       v_cedula,
	       v_direccion,
		   v_dir_cobro,
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_dir_postal
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	-- Lectura del contratante

	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;


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

   -- Busca el tipo de factura

   IF TRIM(a_endoso) = '00000' THEN

	  SELECT vigencia_inic,
	         vigencia_final
		INTO v_vig_ini_pol,
			 v_vig_fin_pol
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

      IF _nueva_renov = 'N' THEN
	    LET v_tipo_factura = 'NUEVA';
	  ELSE
	    LET v_tipo_factura = 'RENOVAR';
	  END IF;
   ELSE
      LET v_tipo_factura = 'ENDOSO';
   END IF;

   SELECT nombre
     INTO v_desc_factura
	 FROM endtimov
    WHERE cod_endomov = _cod_endomov;


   IF MONTH(v_suscripcion) = 1 THEN
      LET v_fecha_letra = 'enero';
   ELIF MONTH(v_suscripcion) = 2 THEN
      LET v_fecha_letra = 'febrero';
   ELIF MONTH(v_suscripcion) = 3 THEN
      LET v_fecha_letra = 'marzo';
   ELIF MONTH(v_suscripcion) = 4 THEN
      LET v_fecha_letra = 'abril';
   ELIF MONTH(v_suscripcion) = 5 THEN
      LET v_fecha_letra = 'mayo';
   ELIF MONTH(v_suscripcion) = 6 THEN
      LET v_fecha_letra = 'junio';
   ELIF MONTH(v_suscripcion) = 7 THEN
      LET v_fecha_letra = 'julio';
   ELIF MONTH(v_suscripcion) = 8 THEN
      LET v_fecha_letra = 'agosto';
   ELIF MONTH(v_suscripcion) = 9 THEN
      LET v_fecha_letra = 'septiembre';
   ELIF MONTH(v_suscripcion) = 10 THEN
      LET v_fecha_letra = 'octubre';
   ELIF MONTH(v_suscripcion) = 11 THEN
      LET v_fecha_letra = 'noviembre';
   ELIF MONTH(v_suscripcion) = 12 THEN
      LET v_fecha_letra = 'diciembre';
   END IF

   LET v_dia = DAY(v_suscripcion);
   LET v_ano = YEAR(v_suscripcion);
   LET v_fecha_letra = TRIM(v_dia)||' de '||TRIM(v_fecha_letra)||' de '||TRIM(v_ano);

	RETURN v_contratante,
		   v_asegurado, 
		   v_direccion,
		   v_dir_cobro,
		   v_dir_postal, 
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_ramo,	
		   v_subramo,
		   v_suscripcion,
		   v_suma_aseg,
		   v_poliza,	
		   v_factura,
	 	   v_vig_ini_pol,
	 	   v_vig_fin_pol,
	 	   v_tipo_factura,
		   v_desc_factura,
	 	   v_fecha_letra,
		   v_cedula,
		   v_vig_i_end,
		   v_vig_f_end,
		   _cod_cliente,
		   _cod_contratante
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
