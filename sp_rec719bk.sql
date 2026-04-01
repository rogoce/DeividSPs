-- Cartas de Perdida Total
-- Creado    : 03/01/2012 
-- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec719;
--DROP TABLE tmp_perdida;
CREATE PROCEDURE "informix".sp_rec719(a_poliza CHAR(10), a_endoso CHAR(5), a_flota INT DEFAULT 0)
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
	    	CHAR(20),	         -- _No_documento
	    	CHAR(50),		     -- _Nombre1
	    	CHAR(50),		     -- _Cargo1
			DEC(16,2),			 --	v_depresiacion  	
			DEC(16,2),			 --	v_deducible	   		
			DEC(16,2),			 --	v_salvamento		
			DEC(16,2),			 --	v_prima_pend		
			DEC(16,2),			 --	v_total		   		
			CHAR(100),			 -- v_a_favor_de		
			CHAR(100),			 -- v_cod_agente		
			CHAR(100),			 -- v_corredor	   		
			DATE,				 -- v_date_siniestro	
			CHAR(100),			 -- _tipo_siniestro 	
			CHAR(20),			 -- v_numrecla_doc			
			CHAR(10),			 -- v_reclamo			
			CHAR(50),			 -- Acredor hipotecario
			CHAR(50);			 -- Color

--DEFINE v_numrecla_doc  	 		 CHAR(20);
DEFINE v_Nombre1   	 		     CHAR(100);
DEFINE v_Cargo1   	 		     CHAR(100);	
DEFINE v_depresiacion  	 		 DEC(16,2);
DEFINE v_deducible	   	 		 DEC(16,2);
DEFINE v_salvamento	   	 		 DEC(16,2);
DEFINE v_prima_pend	   	 		 DEC(16,2);
DEFINE v_total		   	 		 DEC(16,2);
DEFINE v_a_favor_de	   	 		 CHAR(100);
DEFINE v_cod_agente	   	 		 CHAR(5);	
DEFINE v_corredor	   	 		 CHAR(100);
DEFINE v_date_siniestro  		 DATE;
DEFINE _tipo_siniestro   		 CHAR(100);
DEFINE v_numrecla_doc			 CHAR(20);	
DEFINE v_reclamo		 		 CHAR(10);
	
DEFINE v_contratante   	 		 CHAR(100);
DEFINE v_asegurado     	 		 CHAR(100);
DEFINE v_direccion	   	 		 CHAR(50);
DEFINE v_dir_cobro     	 		 CHAR(50);
DEFINE v_dir_postal    	 		 CHAR(20);
DEFINE v_telefono1     	 		 CHAR(10);
DEFINE v_telefono2	   	 		 CHAR(10);
DEFINE v_fax		   	 		 CHAR(10);
DEFINE v_email         	 		 CHAR(50);
DEFINE v_ramo		   	 		 CHAR(50);
DEFINE v_subramo	   	 		 CHAR(50);
DEFINE v_suscripcion   	 		 DATE;
DEFINE v_vigen_ini     	 		 DATE;
DEFINE v_vigen_fin	   	 		 DATE;
DEFINE v_suma_aseg	   	 		 DEC(16,2);
DEFINE v_unidad		   	 		 CHAR(5);
DEFINE v_poliza		   	 		 CHAR(20);
DEFINE v_factura	   	 		 CHAR(10);
DEFINE v_prima		   	 		 DEC(16,2);
DEFINE v_descuento	   	 		 DEC(16,2);
DEFINE v_recargo	   	 		 DEC(16,2);
DEFINE v_prima_neta    	 		 DEC(16,2);
DEFINE v_impuesto	   	 		 DEC(16,2);
DEFINE v_prima_bruta   	 		 DEC(16,2);
DEFINE v_motor         	 		 CHAR(30);
DEFINE v_chasis        	 		 CHAR(30);
DEFINE v_ano_auto      	 		 INT;
DEFINE v_marca		   	 		 CHAR(50);
DEFINE v_modelo        	 		 CHAR(50);
DEFINE v_placa         	 		 CHAR(10);
DEFINE v_tipo          	 		 CHAR(50);
DEFINE v_vig_ini_pol   	 		 DATE;
DEFINE v_vig_fin_pol   	 		 DATE;
DEFINE v_tipo_factura  	 		 CHAR(10);
DEFINE v_desc_factura  	 		 CHAR(50);
DEFINE v_fecha_letra   	 		 CHAR(30);
DEFINE v_dia           	 		 CHAR(2);
DEFINE v_ano           	 		 CHAR(4);
DEFINE v_cedula        	 		 CHAR(30);
DEFINE v_vig_i_end     	 		 DATE;
DEFINE v_vig_f_end	   	 		 DATE;
DEFINE v_nuevo         	 		 SMALLINT;

DEFINE _tipo_mov         		 INT;
DEFINE _no_poliza        		 CHAR(10);
DEFINE _cod_cliente	     		 CHAR(10);
DEFINE _cod_contratante  		 CHAR(10);
DEFINE _cod_marca        		 CHAR(5);
DEFINE _cod_modelo       		 CHAR(5);
DEFINE _cod_ramo         		 CHAR(3);
DEFINE _cod_subramo      		 CHAR(3);
DEFINE _cod_tipoauto     		 CHAR(3);
DEFINE _nueva_renov      		 CHAR(1);
DEFINE _cod_endomov      		 CHAR(3);
DEFINE _dia              		 CHAR(2);
DEFINE _ano              		 CHAR(4);
DEFINE _leasing          		 SMALLINT;
DEFINE _vigencia_fin_pol 		 DATE;
DEFINE _cod_acreedor			 CHAR(5);
DEFINE v_nombre_acreedor 		 CHAR(50);
DEFINE _cod_color				 CHAR(5);
DEFINE v_nombre_color			 CHAR(50);

SET ISOLATION TO DIRTY READ;

-- Crear la tabla
CREATE TEMP TABLE tmp_perdida(
		no_poliza        		 CHAR(10), 
		cod_cliente	     		 CHAR(10), 
		vigen_ini        		 DATE,
		vigen_final      		 DATE,
		no_unidad        		 CHAR(5),
		suma_aseg		 		 DEC(16,2),
		prima			 		 DEC(16,2),
		descuento		 		 DEC(16,2),
		recargo		  	 		 DEC(16,2),
		prima_neta 	  	 		 DEC(16,2),
		impuesto		 		 DEC(16,2),
		prima_bruta	  	 		 DEC(16,2)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_excel(
		AJUSTADOR				 CHAR(50),
		INICIALES				 CHAR(5),						
		ASEGURADO				 CHAR(100),						
		ACREEDOR_HIP			 CHAR(100),				
		CORREDOR				 CHAR(100),						
		POLIZA					 CHAR(20),
		RECLAMO					 CHAR(20),
		VIGENCIA_INCIAL			 DATE,
		VIGENCIA_FINAL			 DATE,
		F_SINIESTRO				 DATE,												
		SUMA_ASEGURADA			 DEC(16,2),
		DEDUCIBLE				 DEC(16,2),
		SALVAMENTO				 DEC(16,2),
		PRIMA_PEND				 DEC(16,2),
		PCTJ_DEP				 DEC(16,2),
		daa_MARCA				 CHAR(10),
		daa_MODELO				 CHAR(10),
		daa_TIPO				 CHAR(10),
		daa_AniO				  CHAR(10),
		daa_COLOR				 CHAR(10),
		daa_PLACA				 CHAR(10),
		daa_MOTOR				 CHAR(10),
		daa_CHASIS				 CHAR(10),							
		gst_PIEZAS				 CHAR(10),
		gst_CHAPISTERIA			 CHAR(10),
		gst_MECANICA			 CHAR(10),
		gst_A_A					 CHAR(10),
		gst_OTROS				 CHAR(10),
		gst_TOTAL				 CHAR(10),										
		FECHA_krt_pt			 CHAR(10),
		FIRMA2_krt_pt			 CHAR(10),
		CARGO2_krt_pt			 CHAR(10),
		TIPO_SINIESTRO			 CHAR(10),								
	    FECHA_krt_vch			 CHAR(10),
		FIRMA_vch				 CHAR(10),
		CARGO_vch				 CHAR(10),
		MUNICIPIO_vch			 CHAR(10),
		COMPRADOR_vch			 CHAR(10),		
		CED_COMPRADOR_vch		 CHAR(10),
		UBICACIoN_vch			 CHAR(10),
		FECHA_ech				 CHAR(10),
		Subgte_Automovil		 CHAR(10),
		fecha_actual			 CHAR(10)
		) WITH NO LOG;			 


--SET DEBUG FILE TO "sp_rec719.trc"; 
--TRACE ON; 

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

	INSERT INTO tmp_perdida(
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
   FROM tmp_perdida

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

	    LET v_contratante = v_asegurado;

		IF v_dir_cobro = ' ' THEN
		   SELECT direccion_1
	    	 INTO v_dir_cobro
		 	 FROM emidirco
		    WHERE no_poliza = _no_poliza;
		END IF
	END IF


	IF a_flota = 1 THEN
	    
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
		   AND no_endoso = a_endoso
		   AND no_unidad = v_unidad;

	    SELECT cod_marca,
		       cod_modelo,
			   placa,
			   ano_auto,
			   nuevo,
			   cod_color
		  INTO _cod_marca,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _cod_color
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
			   nuevo,
			   cod_color
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _cod_color
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
			   nuevo,
			   cod_color
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _cod_color
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
			   nuevo,
			   cod_color
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   _cod_color
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

   IF TRIM(a_endoso) = '00000' THEN

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
   LET v_date_siniestro = v_suscripcion;
   LET _cod_acreedor = "";	
   LET v_nombre_acreedor = "";
   LET v_cod_agente = "";
   LET v_corredor = "";
   LET v_reclamo  = "";
   LET v_numrecla_doc = "";
   LET _tipo_siniestro = 'Colision y Vuelco';
   LET v_a_favor_de = v_asegurado;
   LET v_total = 0;

   LET v_Nombre1   	  = "Sabish Castillo";
   LET v_Cargo1   	  = "Subgerente de Automovil";	
   LET v_depresiacion = 0;
   LET v_deducible 	  = 0;
   LET v_salvamento	  = 0;
   LET v_prima_pend	  = 0;
   LET v_total = v_suma_aseg+v_depresiacion+v_deducible+v_salvamento+v_prima_pend;


   foreach
	SELECT no_reclamo,
	       numrecla
	  INTO v_reclamo,
	       v_numrecla_doc
	  FROM recrcmae
	 WHERE no_poliza = v_poliza
     order by periodo desc
	  exit foreach;
	   end foreach

    IF v_reclamo IS NULL THEN
		LET v_reclamo = "";
	END IF

    IF v_numrecla_doc IS NULL THEN
		LET v_numrecla_doc = "";
	END IF

	SELECT fecha_siniestro
	  INTO v_date_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = v_reclamo;

   foreach
	select cod_acreedor
	  into _cod_acreedor
      from emipoacr
	 where no_poliza = v_poliza
	SELECT nombre
	  INTO v_nombre_acreedor
	  FROM cliclien
	 WHERE cod_cliente = _cod_acreedor;
	  exit foreach;
	   end foreach

    SELECT nombre
	  INTO v_nombre_color
	  FROM emicolor
	 WHERE cod_color = _cod_color;

	SELECT fecha_siniestro
	  INTO v_date_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = v_reclamo;

   foreach
	select cod_agente
	  into v_cod_agente
      from emipoagt
	 where no_poliza = a_poliza

	SELECT nombre
	  INTO v_corredor
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;
	  exit foreach;

	   end foreach

	RETURN v_contratante,		--			RETURNING   CHAR(100),			 --	v_contratante,
		   v_asegurado, 		--						CHAR(100),			 --	v_asegurado, 
		   v_direccion,			--	   					CHAR(50),			 --	v_direccion,
		   v_dir_cobro,			--	   					CHAR(50),			 --	v_dir_cobro,
		   v_dir_postal, 		--						CHAR(20),			 --	v_dir_postal,
		   v_email,				-- 					    CHAR(50),			 -- v_email
		   v_telefono1,			--						CHAR(10),			 --	v_telefono1, 
		   v_telefono2,			--						CHAR(10),			 --	v_telefono2,	
		   v_fax,				--						CHAR(10),			 --	v_fax,	
		   v_ramo,				--	   					CHAR(50),			 --	v_ramo,	
		   v_subramo,			--	   					CHAR(50),			 --	v_subramo,
		   v_suscripcion,		--						DATE,				 --	v_suscripcion,
		   v_vigen_ini,			--						DATE,				 --	v_vigen_ini,
		   v_vigen_fin,			--						DATE,				 --	v_vigen_fin,
		   v_suma_aseg,			--						DEC(16,2),			 --	v_suma_aseg,
		   v_unidad,			--						CHAR(5),			 --	v_unidad,	
		   v_poliza,			--						CHAR(20),			 --	v_poliza,
		   v_factura,			--						CHAR(10),			 --	v_factura,	
		   v_prima,				--						DEC(16,2),			 --	v_prima,
		   v_descuento,			--						DEC(16,2),			 --	v_descuento,
		   v_recargo,			--						DEC(16,2),			 --	v_recargo,
		   v_prima_neta, 		--						DEC(16,2),			 --	v_prima_neta, 
		   v_impuesto,			--						DEC(16,2),			 --	v_impuesto,	
		   v_prima_bruta,		--						DEC(16,2),			 --	v_prima_bruta,
		   v_motor,				--						CHAR(30),			 --	v_motor, 
		   v_chasis, 			--						CHAR(30),			 --	v_chasis,
		   v_ano_auto, 			--						INT,				 --	v_ano_auto,
		   v_marca,				--						CHAR(50),			 --	v_marca,	
	 	   v_modelo,			--						CHAR(50),			 --	v_modelo,
		   v_placa,				--						CHAR(10),			 --	v_placa,
		   v_tipo,				--						CHAR(50),			 --	v_tipo,
	 	   v_vig_ini_pol,		--						DATE,				 --	v_vig_ini_pol,
	 	   v_vig_fin_pol,		--						DATE,				 --	v_vig_fin_pol,
	 	   v_tipo_factura,		--						CHAR(10),			 --	v_tipo_factura,
		   v_desc_factura,		--						CHAR(50),			 --	v_desc_factura,
	 	   v_fecha_letra,		--						CHAR(30),			 --	v_fecha_letra,
		   v_cedula,			--						CHAR(30),	   		 --	v_cedula
		   v_vig_i_end,			-- 						DATE,				 -- v_vig_i_end
		   v_vig_f_end,			-- 						DATE,				 -- v_vig_f_end
		   v_nuevo,				-- 						SMALLINT,			 -- v_nuevo
		   _cod_cliente,		-- 						CHAR(10),			 v-- _cod_cliente
		   _cod_contratante,	-- 						CHAR(10),			 v-- _cod_contratante
		   v_numrecla_doc,      -- 				    	CHAR(20),	         v-- _No_documento
		   v_Nombre1,   	 	-- 				    	CHAR(50),		     v-- _Nombre1
		   v_Cargo1,   	 		-- 				    	CHAR(50),		     v-- _Cargo1
		   v_depresiacion,  	--						DEC(16,2),			 --	v_depresiacion  						 
		   v_deducible,	   	 	--						DEC(16,2),			 --	v_deducible	   						 
		   v_salvamento,	  	--						DEC(16,2),			 --	v_salvamento						   	 
		   v_prima_pend,	  	--						DEC(16,2),			 --	v_prima_pend						   	 
		   v_total,		   	 	--						DEC(16,2),			 --	v_total		   						 
		   v_a_favor_de,	  	-- 						CHAR(100),			 -- v_a_favor_de						   	 
		   v_cod_agente,	  	-- 						CHAR(100),			 -- v_cod_agente						   	 
		   v_corredor,	   	 	-- 						CHAR(100),			 -- v_corredor	   						 
		   v_date_siniestro,   	-- 						DATE,				 -- v_date_siniestro	                  
		   _tipo_siniestro,   	-- 						CHAR(100),			 v-- _tipo_siniestro 					  
		   v_numrecla_doc,		-- 						CHAR(20),			 -- v_numrecla_doc								 
		   v_reclamo,		 	-- 						CHAR(10),			 -- v_reclamo							 
		   v_nombre_acreedor,	--						CHAR(50);			 -- v_nombre_acreedor
		   v_nombre_color		--						CHAR(50);			 -- v_nombre_color
		   WITH RESUME;			--						

END FOREACH					
DROP TABLE tmp_perdida;	
DROP TABLE tmp_excel;		 
END PROCEDURE 



