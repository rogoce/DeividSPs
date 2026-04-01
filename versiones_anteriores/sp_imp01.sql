-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
-- Modificado: 09/09/2002 - Autor: Armando Moreno impresion del no_motor,no_chasis del endoso actual
--
---- Copia del sp_pro44 para la impresion Autor: Federico Coronado
--  Adaptado para que el sistema lea desde las tablas de emision
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp01;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_imp01(a_poliza CHAR(10),  a_endoso CHAR(5), a_flota INT DEFAULT 0)
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
						CHAR(20),			 -- _reemplaza_poliza
						SMALLINT,
						char(10),            -- celular
						VARCHAR(10);         -- uso del auto   

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
DEFINE v_nuevo,_asientos,_se_imp_motor SMALLINT;

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
DEFINE _reemplaza_poliza char(20);
DEFINE _uso_auto         CHAR(1);            

SET ISOLATION TO DIRTY READ;

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
		prima_bruta	  	 DEC(16,2)
		) WITH NO LOG;

-- SET DEBUG FILE TO "sp_imp01.trc";      
--TRACE ON;                                                                     

let _reemplaza_poliza = "";

FOREACH	

 SELECT cod_asegurado,
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
   FROM emipouni
  WHERE no_poliza = a_poliza

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

	-- Lectura de Emipomae
	SELECT no_factura,
	       no_documento,
		   fecha_suscripcion,
		   vigencia_inic,
		   vigencia_final
	  INTO v_factura,
		   v_poliza,	
		   v_suscripcion,
		   v_vig_i_end,
		   v_vig_f_end
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura del Asegurado
	SELECT nombre,
	       cedula,
		   direccion_1,
		   direccion_cob,
		   telefono1,
		   telefono2,
		   fax,
		   apartado,
		   e_mail,
		   celular
	  INTO v_asegurado,
	       v_cedula,
	       v_direccion,
		   v_dir_cobro,
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

	-- Lectura del contratante
	SELECT cod_pagador,
		   nueva_renov,
		   leasing,
		   reemplaza_poliza
	  INTO _cod_contratante,
		   _nueva_renov,
		   _leasing,
		   _reemplaza_poliza
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
		SELECT direccion_1,
			   cedula,
			   telefono1,
			   telefono2,
			   fax,
			   apartado,
			   e_mail,
			   celular
		  INTO v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   v_email,
			   _celular
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		SELECT direccion_1
		  INTO v_direccion
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

--		LET _cod_contratante = _cod_cliente;

	    LET v_contratante = v_asegurado;

		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF
	END IF


	IF a_flota = 1 THEN

		{SELECT direccion_1,
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
		 WHERE cod_cliente = _cod_contratante;}
	    
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT nombre,
			   direccion_1,
			   direccion_cob,
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

	END IF

    -- Lectura Marca, modelo y tipo de auto
	
		SELECT no_motor,
		       uso_auto
		  INTO v_motor,
		       _uso_auto
		  FROM emiauto
		 WHERE no_poliza = _no_poliza
		   and no_unidad = v_unidad;

		let _asientos = null;
	    SELECT cod_marca,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo,
			   no_chasis,
			   capacidad
		INTO _cod_marca,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   v_chasis,
			   _asientos
		FROM emivehic
		WHERE no_motor = v_motor;
/*
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
*/
    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre,
	       cod_tipoauto
	  INTO v_modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo;
	
	Let _se_imp_motor = sp_sis508(_cod_modelo);	 --Para saber si se imprime en la factura el motor o no. 13/08/2018
	if _se_imp_motor = 1 then
	else
		let v_motor = "";
	end if

    SELECT nombre
	  INTO v_tipo
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;
	 
	if v_telefono1 = "" or v_telefono1 is null then
		let v_telefono1 = _celular;
	end if

    -- Lectura del Ramo y Subramo

    SELECT cod_ramo,
	       cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   vigencia_fin_pol,
		   no_documento
	  INTO _cod_ramo,
	       _cod_subramo,
		   v_vig_ini_pol,
		   v_vig_fin_pol,
		   _vigencia_fin_pol,
		   v_poliza
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	
	SELECT nombre
	  INTO v_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

   -- Busca el tipo de factura

      IF _nueva_renov = 'N' THEN
	    LET v_tipo_factura = 'NUEVA';
	  ELSE
	    LET v_tipo_factura = 'RENOVAR';
	  END IF;

		SELECT nombre
		INTO v_desc_factura
		FROM endtimov
		WHERE cod_endomov  = "011";	
		
   if _cod_ramo = '019' then
		if _vigencia_fin_pol is not null then

		  SELECT min(vigencia_inic)
			INTO v_vig_ini_pol
			FROM emipomae
		   WHERE no_documento = v_poliza;

			let v_vig_fin_pol = _vigencia_fin_pol;
		end if

		foreach
			select cod_asegurado
			  into _cod_cliente
			  from emipouni
			 where no_poliza = a_poliza

			SELECT nombre
			  INTO v_asegurado
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			exit foreach;
		end foreach
   end if

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

	RETURN v_contratante,     --0
		   v_asegurado,       --1
		   v_direccion,       --2
		   v_dir_cobro,       --3
		   v_dir_postal,      --4
		   v_email,           --5
		   v_telefono1,       --6
		   v_telefono2,       --7
		   v_fax,             --8
		   v_ramo,	          --9
		   v_subramo,        --10
		   v_suscripcion,    --11
		   v_vigen_ini,      --12
		   v_vigen_fin,      --13
		   v_suma_aseg,      --14
		   v_unidad,	     --15
		   v_poliza,	     --16
		   v_factura,        --17
		   v_prima,          --18
		   v_descuento,      --19
		   v_recargo,        --20
		   v_prima_neta,     --21
		   v_impuesto,	     --22
		   v_prima_bruta,    --23
		   v_motor,          --24
		   v_chasis,         --25
		   v_ano_auto,       --26
		   v_marca,          --27
	 	   v_modelo,         --28
		   v_placa,          --29
		   v_tipo,           --30
	 	   v_vig_ini_pol,    --31
	 	   v_vig_fin_pol,    --32
	 	   v_tipo_factura,   --33
		   v_desc_factura,   --34
	 	   v_fecha_letra,    --35
		   v_cedula,         --36
		   v_vig_i_end,      --37
		   v_vig_f_end,      --38
		   v_nuevo,          --39
		   _cod_cliente,     --40
		   _cod_contratante, --41
		   _reemplaza_poliza, --42
		   _asientos,
		   _celular,
		   (case when _uso_auto = 'P' then 'Particular' else 'Comercial' end)
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
