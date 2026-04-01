-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44y;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro44y(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(255) DEFAULT '*')
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
						CHAR(10),			 -- _cod_operado
						CHAR(100),			 -- _operado nombre
						CHAR(30),           -- _cedula_2
						CHAR(10),
						CHAR(10),
						SMALLINT;

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
DEFINE v_nuevo,_se_imp_motor SMALLINT;

DEFINE _tipo              CHAR(1);
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
DEFINE _cod_operado      CHAR(10);
DEFINE _operado          CHAR(100);
DEFINE _leasing          SMALLINT;
DEFINE _cedula_2         CHAR(30);
DEFINE _uso_auto         CHAR(1);
DEFINE _asientos         SMALLINT;

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
		prima_bruta	  	 DEC(16,2),
		seleccionado     SMALLINT DEFAULT 1
		) WITH NO LOG;


-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

LET _cedula_2 = NULL;
LET _operado = NULL;
LET _cod_operado = NULL;

FOREACH	

-- Lectura de endeduni

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
		   apartado,
		   celular
	  INTO v_asegurado,
	       v_cedula,
	       v_direccion,
		   v_dir_cobro,
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_dir_postal,
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
{	    LET v_contratante = v_asegurado;
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

	    LET v_contratante = v_asegurado;}
		SELECT direccion_1,
			   cedula,
			   telefono1,
			   telefono2,
			   fax,
			   apartado,
			   celular
		  INTO v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   _celular
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		let _cod_operado = _cod_contratante;

		SELECT direccion_1
		  INTO v_direccion
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	    LET _operado         = v_contratante;
	    LET v_contratante    = v_asegurado;
		LET _cod_contratante = _cod_cliente;

		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF

		-- Lectura de la cedula del leasing

		SELECT cedula
		  INTO _cedula_2
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	END IF

    -- Lectura Marca, modelo y tipo de auto

    SELECT tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

    if _tipo_mov = 9 then
	    SELECT no_motor,
		       no_chasis,
			   uso_auto
		  INTO v_motor,
	           v_chasis,
			   _uso_auto
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

	    SELECT cod_marca,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo,
			   capacidad
		  INTO _cod_marca,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _asientos
		  FROM emivehic
		 WHERE no_motor = v_motor;
	elif _tipo_mov = 4 or
	     _tipo_mov = 5 then
	    SELECT no_motor,
		       uso_auto
		  INTO v_motor,
		       _uso_auto
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

	    SELECT cod_marca,
		       no_chasis,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo,
			   capacidad
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _asientos
		  FROM emivehic
		 WHERE no_motor = v_motor;
	else
		IF a_endoso = '00000' THEN
		    SELECT no_motor,
			       uso_auto
			  INTO v_motor,
			       _uso_auto
			  FROM endmoaut
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = '00000'
			   AND no_unidad = v_unidad;
        
			IF v_motor IS NULL THEN
			    SELECT no_motor,
				       uso_auto
				  INTO v_motor,
				       _uso_auto
				  FROM emiauto
				 WHERE no_poliza = _no_poliza
				   AND no_unidad = v_unidad;
			END IF
		ELSE
		    SELECT no_motor,
			       uso_auto
			  INTO v_motor,
			       _uso_auto
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = v_unidad;
		END IF

	    SELECT cod_marca,
		       no_chasis,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo,
			   capacidad
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _asientos
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
	   
	Let _se_imp_motor = sp_sis508(_cod_modelo);	 --Para saber si se imprime en la factura el motor o no. 13/08/2018
	if _se_imp_motor = 1 then
	else
		let v_motor = "";
	end if

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
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_ramo,	
		   v_subramo,    --10
		   v_suscripcion,
		   v_vigen_ini,
		   v_vigen_fin,
		   v_suma_aseg,
		   v_unidad,	
		   v_poliza,	
		   v_factura,
		   v_prima,
		   v_descuento,
		   v_recargo,    --20
		   v_prima_neta, 
		   v_impuesto,	
		   v_prima_bruta,
		   v_motor,
		   v_chasis, 
		   v_ano_auto, 
		   v_marca,
	 	   v_modelo,
		   v_placa,
		   v_tipo,        --30
	 	   v_vig_ini_pol,
	 	   v_vig_fin_pol,
	 	   v_tipo_factura,
		   v_desc_factura,
	 	   v_fecha_letra,
		   v_cedula,
		   v_vig_i_end,
		   v_vig_f_end,
		   v_nuevo,
		   _cod_cliente, --40
		   _cod_contratante,
		   _cod_operado,
		   _operado,
		   _cedula_2,
		   _celular,
		   (case when _uso_auto = 'P' then 'Particular' else 'Comercial' end),
		   _asientos
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
