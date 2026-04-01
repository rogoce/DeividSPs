-- procedimiento que verifica si existen endosos de perdida total
-- autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro532;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro532(a_no_tranrec char(10), a_flota INT DEFAULT 0)
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
						char(10),             -- no_poliza
						CHAR(5),			 --	v_unidad,	
						char(5),             --    v_endoso,
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
						CHAR(20);			 -- _reemplaza_poliza

DEFINE v_contratante   CHAR(100);
DEFINE v_asegurado     CHAR(100);
DEFINE v_direccion	   CHAR(50);
DEFINE v_dir_cobro     CHAR(50);
DEFINE v_dir_postal    CHAR(20);
DEFINE v_telefono1     CHAR(10);
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
DEFINE _reemplaza_poliza char(20);

define v_cantidad        integer;
define v_no_poliza	     char(10);
define v_no_endoso		 char(5);
define v_no_documento	 char(20);

SET ISOLATION TO DIRTY READ;

-- Crear la tabla
CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10), 
		cod_cliente	     CHAR(10), 
		vigen_ini        DATE,
		vigen_final      DATE,
		no_unidad        CHAR(5),
		no_endoso        char(5),
		suma_aseg		 DEC(16,2),
		prima			 DEC(16,2),
		descuento		 DEC(16,2),
		recargo		  	 DEC(16,2),
		prima_neta 	  	 DEC(16,2),
		impuesto		 DEC(16,2),
		prima_bruta	  	 DEC(16,2)
		) WITH NO LOG;

 --SET DEBUG FILE TO "sp_pro532.trc";      
 --TRACE ON;                                                                     

let _reemplaza_poliza = "";

  select b.no_poliza,
         b.no_documento
	into v_no_poliza,
		 v_no_documento
    from rectrmae a inner join recrcmae b on a.no_reclamo = b.no_reclamo
   where a.no_tranrec = a_no_tranrec
     and a.actualizado = 1;
		
	
		-- 008 cancelacion por perdida total
	
FOREACH
	
 select no_poliza,no_endoso
   into v_no_poliza, v_no_endoso
   from endedmae
  where no_documento = v_no_documento
    and cod_tipocan = '008' 
    and actualizado = 1

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
  WHERE no_poliza = v_no_poliza
    AND no_endoso = v_no_endoso;

	INSERT INTO tmp_arreglo(
	no_poliza,
	cod_cliente,
	vigen_ini,
	vigen_final,
	no_unidad,
	no_endoso,
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
	v_no_endoso,
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
		no_endoso,
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
		v_no_endoso,
		v_suma_aseg,
		v_prima,
		v_descuento,
		v_recargo,
		v_prima_neta,
		v_impuesto,
		v_prima_bruta
   FROM tmp_arreglo

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
	   AND no_endoso = v_no_endoso;

	-- Lectura del Asegurado
	SELECT nombre,
	       cedula,
		   direccion_1,
		   direccion_2,
		   telefono1,
		   telefono2,
		   fax,
		   apartado,
		   e_mail
	  INTO v_asegurado,
	       v_cedula,
	       v_direccion,
		   v_dir_cobro,
		   v_telefono1,
		   v_telefono2,
		   v_fax,
		   v_dir_postal,
		   v_email
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
			   e_mail
		  INTO v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   v_email
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		SELECT direccion_1
		  INTO v_direccion
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;
		 
		--LET _cod_operado = _cod_contratante;
        --LET _operado         = v_contratante;
	    LET v_contratante = v_asegurado;
		LET _cod_contratante = _cod_cliente;

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
			   direccion_2,
			   cedula,
			   telefono1,
			   telefono2,
			   fax,
			   apartado,
			   e_mail
		  INTO v_asegurado,
			   v_direccion,
			   v_dir_cobro,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fax,
			   v_dir_postal,
			   v_email
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
		   AND no_endoso = v_no_endoso
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
		   AND no_endoso = v_no_endoso
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
		   AND no_endoso = v_no_endoso
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
		IF v_no_endoso = '00000' THEN
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
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo;

    SELECT nombre
	  INTO v_tipo
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

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

   IF TRIM(v_no_endoso) = '00000' THEN

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

	RETURN v_contratante,      --1
		   v_asegurado,        --2
		   v_direccion,        --3
		   v_dir_cobro,        --4
		   v_dir_postal,       --5
		   v_email,            --6
		   v_telefono1,        --7
		   v_telefono2,        --8
		   v_fax,              --9
		   v_ramo,	          --10
		   v_subramo,         --11
		   v_suscripcion,     --12
		   v_vigen_ini,       --13
		   v_vigen_fin,       --14
		   v_suma_aseg,       --15
		   _no_poliza,        --16
		   v_unidad,          --17
		   v_no_endoso,       --18
		   v_poliza,	      --19
		   v_factura,         --20
		   v_prima,           --21
		   v_descuento,       --22
		   v_recargo,         --23
		   v_prima_neta,      --24
		   v_impuesto,	      --25
		   v_prima_bruta,     --26
		   v_motor,           --27
		   v_chasis,          --28
		   v_ano_auto,        --29
		   v_marca,           --30
	 	   v_modelo,          --31
		   v_placa,           --32
		   v_tipo,            --33
	 	   v_vig_ini_pol,     --34
	 	   v_vig_fin_pol,     --35
	  	   v_tipo_factura,    --36
		   v_desc_factura,    --37
	 	   v_fecha_letra,     --38
		   v_cedula,          --39
		   v_vig_i_end,       --40
		   v_vig_f_end,       --41
		   v_nuevo,           --42
		   _cod_cliente,      --43
		   _cod_contratante,  --44
		   _reemplaza_poliza  --45
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
