-- Procedimiento para las Facturas de Salud
-- 
-- Creado    : 01/11/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 01/11/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro47;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_pro47(a_poliza CHAR(10), a_flota INT DEFAULT 0) 
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
						DATE,				 --	v_vigen_ini,  
						DEC(16,2),			 --	v_suma_aseg,	
						CHAR(20),			 --	v_poliza,		
						CHAR(10),			 --	v_factura,	
						DEC(16,2),			 --	v_prima,		
						CHAR(10),			 --	v_tipo_factura,
						CHAR(30),			 --	v_fecha_letra,
						CHAR(5),			 -- v_unidad
						CHAR(10);
											 
DEFINE v_contratante   CHAR(100);			 
DEFINE v_asegurado     CHAR(100);			 
DEFINE v_direccion	   CHAR(50);
DEFINE v_dir_cobro     CHAR(50);
DEFINE v_dir_postal    CHAR(20);
DEFINE v_telefono1,_celular     CHAR(10);
DEFINE v_telefono2	   CHAR(10);
DEFINE v_fax		   CHAR(10);
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_vigen_ini     DATE;
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_poliza		   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_prima		   DEC(16,2);
DEFINE v_tipo_factura  CHAR(10);
DEFINE v_desc_factura  CHAR(50); 
DEFINE v_fecha_letra   CHAR(30);
DEFINE v_dia           CHAR(2);
DEFINE v_ano           CHAR(4);
DEFINE v_unidad        CHAR(5);


DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _cod_endomov      CHAR(3);

-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),    
		cod_cliente      CHAR(10),  
		vigen_ini        DATE,
		suma_aseg		 DEC(16,2),
		prima			 DEC(16,2),
		unidad        	 CHAR(5)
		) WITH NO LOG;   

SET ISOLATION TO DIRTY READ;

FOREACH	
   
   SELECT cod_asegurado,
		  suma_asegurada,
		  prima,
		  vigencia_inic,
		  no_unidad
     INTO _cod_cliente,
		  v_suma_aseg,
		  v_prima,
		  v_vigen_ini,
		  v_unidad
	 FROM emipouni
	WHERE no_poliza = a_poliza


	INSERT INTO tmp_arreglo(
	no_poliza,    
	cod_cliente,	
	vigen_ini,   
	suma_aseg,	 
	prima,
	unidad
	)
	VALUES(
	a_poliza,
	_cod_cliente,
	v_vigen_ini,
	v_suma_aseg,
    v_prima,
	v_unidad
	);

END FOREACH;

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,  
		cod_cliente,
		vigen_ini,  
		suma_aseg,	
		prima,
		unidad
   INTO _no_poliza,
		_cod_cliente,
		v_vigen_ini,
		v_suma_aseg,
        v_prima,
		v_unidad
   FROM tmp_arreglo

   -- Lectura de emipomae
      
   SELECT cod_pagador,
	      nueva_renov,
		  no_factura,
		  no_documento,
		  fecha_suscripcion
     INTO _cod_contratante,
	      _nueva_renov,
		  v_factura,
		  v_poliza,
		  v_suscripcion
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	-- Lectura del contratante


	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;



	-- Lectura del Asegurado

	SELECT nombre,
		   direccion_1,
		   telefono1,
		   telefono2,
		   fax,
		   apartado,
		   celular
	  INTO v_asegurado,
	       v_direccion,
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_dir_postal,
		   _celular
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT direccion_1
	  INTO v_dir_cobro
	  FROM emidirco
	 WHERE no_poliza = _no_poliza;

	IF a_flota = 1 THEN
		SELECT direccion_1,
			   direccion_2,
			   nombre,
			   telefono1,
			   telefono2,
			   fax,
			   apartado,
			   celular
		  INTO v_direccion,
			   v_dir_cobro,
			   v_asegurado,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   _celular
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;
	    
		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF
	END IF

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

   IF _nueva_renov = 'N' THEN
      LET v_tipo_factura = 'NUEVA';
   ELSE
      LET v_tipo_factura = 'RENOVAR';
   END IF;

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
   {
    if v_telefono1 = "" or v_telefono1 is null then
		let v_telefono1 = _celular;
	end if
	}

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
		   v_vigen_ini,  
		   v_suma_aseg,	
		   v_poliza,		
		   v_factura,	
		   v_prima,		
		   v_tipo_factura,
		   v_fecha_letra,
		   v_unidad,
		   _celular
		   WITH RESUME;   	

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE