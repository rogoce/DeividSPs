-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44d_therefore;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro44d_therefore(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(255) DEFAULT '*')
returning   char(100),			 --	v_contratante,
			char(100),			 --	v_asegurado, 
			char(50),			 --	v_direccion,
			char(50),			 --	v_dir_cobro,
			char(20),			 --	v_dir_postal,
			char(10),			 --	v_telefono1, 
			char(10),			 --	v_telefono2,	
			char(10),			 --	v_fax,	
			char(50),			 --	v_ramo,	
			char(50),			 --	v_subramo,
			date,				 --	v_suscripcion,
			date,				 --	v_vigen_ini,
			date,				 --	v_vigen_fin,
			dec(16,2),			 --	v_suma_aseg,
			char(5),			 --	v_unidad,	
			char(20),			 --	v_poliza,
			char(10),			 --	v_factura,	
			dec(16,2),			 --	v_prima,
			dec(16,2),			 --	v_descuento,
			dec(16,2),			 --	v_recargo,
			dec(16,2),			 --	v_prima_neta, 
			dec(16,2),			 --	v_impuesto,	
			dec(16,2),			 --	v_prima_bruta,
			char(30),			 --	v_motor, 
			char(30),			 --	v_chasis,
			int,				 --	v_ano_auto,
			char(50),			 --	v_marca,	
			char(50),			 --	v_modelo,
			char(10),			 --	v_placa,
			char(50),			 --	v_tipo,
			date,				 --	v_vig_ini_pol,
			date,				 --	v_vig_fin_pol,
			char(10),			 --	v_tipo_factura,
			char(50),			 --	v_desc_factura,
			char(30),			 --	v_fecha_letra,
			char(30),	   		 --	v_cedula
			date,				 -- v_vig_i_end
			date,				 -- v_vig_f_end
			smallint,			 -- v_nuevo
			char(10),			 -- _cod_cliente
			char(10),			 -- _cod_contratante
			varchar(50);			 -- _key_therefore
	
define v_contratante   char(100);
define v_asegurado     char(100);
define v_direccion	   char(50);
define v_dir_cobro     char(50);
define v_dir_postal    char(20);
define v_telefono1     char(10);
define v_telefono2	   char(10);
define v_fax		   char(10);
define v_ramo		   char(50);
define v_subramo	   char(50);
define v_suscripcion   date;
define v_vigen_ini     date;
define v_vigen_fin	   date;
define v_suma_aseg	   dec(16,2);
define v_unidad		   char(5);
define v_poliza		   char(20);
define v_factura	   char(10);
define v_prima		   dec(16,2);
define v_descuento	   dec(16,2);
define v_recargo	   dec(16,2);
define v_prima_neta    dec(16,2);
define v_impuesto	   dec(16,2);
define v_prima_bruta   dec(16,2);
define v_motor         char(30);
define v_chasis        char(30);
define v_ano_auto      int;
define v_marca		   char(50);
define v_modelo        char(50);
define v_placa         char(10);
define v_tipo          char(50);
define v_vig_ini_pol   date;
define v_vig_fin_pol   date;
define v_tipo_factura  char(10);
define v_desc_factura  char(50);
define _key_therefore  varchar(50);
define v_fecha_letra   char(30);
define v_dia           char(2);
define v_ano           char(4);
define v_cedula        char(30);
define v_vig_i_end     date;
define v_vig_f_end	   date;
define v_nuevo         smallint;
define _error         smallint;

define _tipo              char(1);
define _tipo_mov         int;
define _no_poliza        char(10);
define _cod_cliente	     char(10);
define _cod_contratante  char(10);
define _cod_marca        char(5);
define _cod_modelo       char(5);
define _cod_ramo         char(3);
define _cod_subramo      char(3);
define _cod_tipoauto     char(3);
define _nueva_renov      char(1);
define _cod_endomov      char(3);
define _dia              char(2);
define _ano              char(4);
define _leasing          smallint;

set isolation to dirty read;

-- Crear la tabla

CREATE TEMP TABLE tmp_arreglo(
no_poliza        CHAR(10),
cod_cliente	     CHAR(10),
vigen_ini        DATE,
vigen_final      DATE,
no_unidad        CHAR(5),
suma_aseg		 DEC(16,2),
prima			 DEC(16,2),
descuento		 DEC(16,2),
recargo		  	 DEC(16,2),
prima_neta 	  	 DEC(16,2),
impuesto		 DEC(16,2),
prima_bruta	  	 DEC(16,2),
seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;


-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";
-- TRACE ON;                                                                     

-- Lectura de endeduni
FOREACH
	SELECT cod_cliente,
		   no_poliza,
		   vigencia_inic,
		   vigencia_final,
		no_unidad, 
		suma_asegurada,
		prima,	
		descuento,	
		recargo,	
		prima_neta,
		impuesto,
		prima_bruta
   INTO _cod_cliente,
		_no_poliza,
		v_vigen_ini,
		v_vigen_fin,
		v_unidad,
		v_suma_aseg,
		v_prima,
		v_descuento,
		v_recargo,
		v_prima_neta,
		v_impuesto,
		v_prima_bruta
   FROM endeduni
  WHERE no_poliza = a_poliza
    AND no_endoso = a_endoso

	INSERT INTO tmp_arreglo(
	no_poliza,
	cod_cliente,
	vigen_ini,
	vigen_final,
	no_unidad,
	suma_aseg,
	prima,
	descuento,
	recargo,
	prima_neta, 
	impuesto,	
	prima_bruta	
	)
	VALUES(
	_no_poliza,
	_cod_cliente,
	v_vigen_ini,
	v_vigen_fin,
	v_unidad,
	v_suma_aseg,
	v_prima,
	v_descuento,
	v_recargo,
	v_prima_neta,
	v_impuesto,
	v_prima_bruta
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
		vigen_final,
		no_unidad,
		suma_aseg,	
        prima,	
 		descuento,
 		recargo,
 		prima_neta, 
 		impuesto,	
 		prima_bruta	
   INTO _no_poliza,
        _cod_cliente,
		v_vigen_ini,
		v_vigen_fin,
		v_unidad,
		v_suma_aseg,
		v_prima,
		v_descuento,
		v_recargo,
		v_prima_neta,
		v_impuesto,
		v_prima_bruta
   FROM tmp_arreglo
  WHERE seleccionado = 1

	-- Lectura de Endedmae

	SELECT no_factura,
	       no_documento,
		   fecha_emision,
		   cod_endomov,
		   vigencia_inic,
		   vigencia_final,
		   vigencia_inic_pol,
		   vigencia_final_pol
	  INTO v_factura,
		   v_poliza,	
		   v_suscripcion,
		   _cod_endomov,
		   v_vig_i_end,
		   v_vig_f_end,
	       v_vig_ini_pol,
		   v_vig_fin_pol
	  FROM endedmae
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = a_endoso;

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

	IF v_dir_cobro = ' ' THEN
	   SELECT direccion_1
    	 INTO v_dir_cobro
	 	 FROM emidirco
	    WHERE no_poliza = _no_poliza;
	END IF
	
	call sp_therefore0(_no_poliza,a_endoso,v_unidad,_cod_cliente,'UNID') returning _error,_key_therefore;

	-- Lectura del contratante

	SELECT cod_pagador,
		   nueva_renov,
		   leasing
	  INTO _cod_contratante,
		   _nueva_renov,
		   _leasing
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

 -- Si la poliza es leasing

    IF _leasing IS NULL THEN
		LET _leasing = 0;
	END IF

    IF _leasing = 1 THEN
	    LET v_contratante = v_asegurado;
		SELECT direccion_1,
			   direccion_2,
			   cedula,
			   telefono1,
			   telefono2,
			   fax,
			   apartado
		  INTO v_direccion,
			   v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

--		LET _cod_contratante = _cod_cliente;
	    LET v_contratante = v_asegurado;
		
		call sp_therefore0(_no_poliza,a_endoso,v_unidad,v_contratante,'UNID') returning _error,_key_therefore;

		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF
	END IF

    -- Lectura Marca, modelo y tipo de auto

    SELECT tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

    if _tipo_mov = 9 then
	    SELECT no_motor,
		       no_chasis
		  INTO v_motor,
	           v_chasis
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

	    SELECT cod_marca,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo
		  INTO _cod_marca,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo
		  FROM emivehic
		 WHERE no_motor = v_motor;
	elif _tipo_mov = 4 or
	     _tipo_mov = 5 then
	    SELECT no_motor
		  INTO v_motor
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;
		   
			if v_motor is null or trim(v_motor) = "" then
				SELECT no_motor
				  INTO v_motor
				  FROM emiauto
				 WHERE no_poliza = _no_poliza
				   and no_unidad = v_unidad;
			end if

	    SELECT cod_marca,
		       no_chasis,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo
		  FROM emivehic
		 WHERE no_motor = v_motor;
	else
		IF a_endoso = '00000' THEN
		    SELECT no_motor
			  INTO v_motor
			  FROM endmoaut
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = '00000'
			   AND no_unidad = v_unidad;
        
			IF v_motor IS NULL THEN
			    SELECT no_motor
				  INTO v_motor
				  FROM emiauto
				 WHERE no_poliza = _no_poliza
				   AND no_unidad = v_unidad;
			END IF
		ELSE
		    SELECT no_motor
			  INTO v_motor
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = v_unidad;
		END IF

	    SELECT cod_marca,
		       no_chasis,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo
		  FROM emivehic
		 WHERE no_motor = v_motor;
    END IF


    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre,
	       cod_tipoauto
	  INTO v_modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

    SELECT nombre
	  INTO v_tipo
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

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
      if _cod_ramo = '019' then
	  else
		  SELECT vigencia_inic,
		         vigencia_final
			INTO v_vig_ini_pol,
				 v_vig_fin_pol
			FROM emipomae
		   WHERE no_poliza = _no_poliza;
	  end if

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
		   v_vigen_ini,
		   v_vigen_fin,
		   v_suma_aseg,
		   v_unidad,	
		   v_poliza,	
		   v_factura,
		   v_prima,
		   v_descuento,
		   v_recargo,
		   v_prima_neta, 
		   v_impuesto,	
		   v_prima_bruta,
		   v_motor,
		   v_chasis, 
		   v_ano_auto, 
		   v_marca,
	 	   v_modelo,
		   v_placa,
		   v_tipo,
	 	   v_vig_ini_pol,
	 	   v_vig_fin_pol,
	 	   v_tipo_factura,
		   v_desc_factura,
	 	   v_fecha_letra,
		   v_cedula,
		   v_vig_i_end,
		   v_vig_f_end,
		   v_nuevo,
		   _cod_cliente,
		   _cod_contratante,
		   _key_therefore
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
