-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
-- Modificado: 09/09/2002 - Autor: Armando Moreno impresion del no_motor,no_chasis del endoso actual
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44z;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro44z(a_poliza CHAR(10), a_endoso CHAR(5))
			RETURNING   CHAR(100),			 --	v_contratante,
						CHAR(100),			 --	v_asegurado, 
	   					CHAR(50),			 --	v_direccion,
	   					CHAR(50),			 --	v_dir_cobro,
						CHAR(20),			 --	v_dir_postal,
						CHAR(50),			 -- v_email
						CHAR(10),			 --	v_telefono1, 
						CHAR(10),			 --	v_telefono2,	
						CHAR(10),			 --	v_fax,	
	   					CHAR(50),			 --	v_ramo,	
	   					CHAR(50),			 --	v_subramo,
						DATE,				 --	v_suscripcion,
						DATE,				 --	v_vigen_ini,
						DATE,				 --	v_vigen_fin,
						DEC(16,2),			 --	v_suma_aseg,
						CHAR(5),			 --	v_unidad,	
						CHAR(20),			 --	v_poliza,
						CHAR(10),			 --	v_factura,	
						DEC(16,2),			 --	v_prima,
						DEC(16,2),			 --	v_descuento,
						DEC(16,2),			 --	v_recargo,
						DEC(16,2),			 --	v_prima_neta, 
						DEC(16,2),			 --	v_impuesto,	
						DEC(16,2),			 --	v_prima_bruta,
						CHAR(30),			 --	v_motor, 
						CHAR(30),			 --	v_chasis,
						INT,				 --	v_ano_auto,
						CHAR(50),			 --	v_marca,	
						CHAR(50),			 --	v_modelo,
						CHAR(10),			 --	v_placa,
						CHAR(50),			 --	v_tipo,
						DATE,				 --	v_vig_ini_pol,
						DATE,				 --	v_vig_fin_pol,
						CHAR(10),			 --	v_tipo_factura,
						CHAR(50),			 --	v_desc_factura,
						CHAR(30),			 --	v_fecha_letra,
						CHAR(30),	   		 --	v_cedula
						DATE,				 -- v_vig_i_end
						DATE,				 -- v_vig_f_end
						SMALLINT,			 -- v_nuevo
						CHAR(10),			 -- _cod_cliente
						CHAR(10),			 -- _cod_contratante
						char(10);

DEFINE v_contratante   CHAR(100);
DEFINE v_asegurado     CHAR(100);
DEFINE v_direccion	   CHAR(50);
DEFINE v_dir_cobro     CHAR(50);
DEFINE v_dir_postal    CHAR(20);
DEFINE v_telefono1,_celular     CHAR(10);
DEFINE v_telefono2	   CHAR(10);
DEFINE v_fax		   CHAR(10);
DEFINE v_email         CHAR(50);
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_vigen_ini     DATE;
DEFINE v_vigen_fin	   DATE;
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_unidad		   CHAR(5);
DEFINE v_poliza		   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_prima		   DEC(16,2);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_recargo	   DEC(16,2);
DEFINE v_prima_neta    DEC(16,2);
DEFINE v_impuesto	   DEC(16,2);
DEFINE v_prima_bruta   DEC(16,2);
DEFINE v_motor         CHAR(30);
DEFINE v_chasis        CHAR(30);
DEFINE v_ano_auto      INT;
DEFINE v_marca		   CHAR(50);
DEFINE v_modelo        CHAR(50);
DEFINE v_placa         CHAR(10);
DEFINE v_tipo          CHAR(50);
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
DEFINE v_nuevo         SMALLINT;

DEFINE _tipo_mov         INT;
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
DEFINE _leasing          SMALLINT;
DEFINE _vigencia_fin_pol DATE;

SET ISOLATION TO DIRTY READ;

let v_nuevo = 0;
let v_motor = "";
let v_chasis = ""; 
let v_ano_auto = 0; 
let v_marca = "";
let v_modelo = "";
let v_placa = "";
let v_tipo = "";
let v_unidad = "";
let v_vigen_ini	= today;
let v_vigen_fin	= today;
--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD

	-- Lectura de Endedmae
	SELECT no_poliza,
	       no_factura,
	       no_documento,
		   fecha_emision,
		   cod_endomov,
		   vigencia_inic,
		   vigencia_final,
		   vigencia_inic_pol,
		   vigencia_final_pol,
		   suma_asegurada,
	       prima,
	 	   descuento,
	 	   recargo,
	 	   prima_neta, 
	 	   impuesto,
	 	   prima_bruta
	  INTO _no_poliza,
	       v_factura,
		   v_poliza,	
		   v_suscripcion,
		   _cod_endomov,
		   v_vig_i_end,
		   v_vig_f_end,
	       v_vig_ini_pol,
		   v_vig_fin_pol,
		   v_suma_aseg,
		   v_prima,
		   v_descuento,
		   v_recargo,
		   v_prima_neta,
		   v_impuesto,
		   v_prima_bruta
	  FROM endedmae
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso

	-- Lectura del Asegurado
	    
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT nombre,
			   direccion_1,
			   direccion_2,
			   cedula,
			   telefono1,
			   telefono2,
			   fax,
			   apartado,
			   e_mail,
			   celular
		  INTO v_asegurado,
			   v_direccion,
			   v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   v_email,
			   _celular
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF


    -- Lectura Marca, modelo y tipo de auto

 {   SELECT tipo_mov
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
	elif _tipo_mov = 4 then
	    SELECT no_motor
		  INTO v_motor
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

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

	elif _tipo_mov = 5 then

	    SELECT no_motor
		  INTO v_motor
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

		if v_motor is null then

		    SELECT no_motor
			  INTO v_motor
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = v_unidad;

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

--	     _tipo_mov = 5 then

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
  }
    -- Lectura del Ramo y Subramo

    SELECT cod_ramo,
	       cod_subramo,
		   nueva_renov,
		   cod_pagador
	  INTO _cod_ramo,
	       _cod_subramo,
		   _nueva_renov,
		   _cod_contratante
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

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
	         vigencia_final,
			 vigencia_fin_pol
		INTO v_vig_ini_pol,
			 v_vig_fin_pol,
			 _vigencia_fin_pol
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

      IF _nueva_renov = 'N' THEN
	    LET v_tipo_factura = 'NUEVA';
		if _cod_ramo = '019' then
			if _vigencia_fin_pol is not null then
				let v_vig_fin_pol = _vigencia_fin_pol;
			end if
		end if
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
		   v_email,
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
		   _celular
		   WITH RESUME; 

END FOREACH
END PROCEDURE
