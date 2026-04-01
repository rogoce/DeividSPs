-- Procedimiento para los Certificados de Automovil
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
-- Modificado: 09/09/2002 - Autor: Armando Moreno impresion del no_motor,no_chasis del endoso actual
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44xls;
--DROP TABLE tmp_arregloxls;

CREATE PROCEDURE "informix".sp_pro44xls(a_poliza CHAR(10), a_endoso CHAR(5), a_flota INT DEFAULT 0)
			RETURNING   CHAR(50)     as desc_factura,
						CHAR(10)     as factura,
						CHAR(10)     as tipo_factura,
						CHAR(10)     as cod_contratante,
						CHAR(100)    as contratante,
						CHAR(10)     as cod_cliente,
						CHAR(100)    as asegurado,
						CHAR(30)     as cedula,
						CHAR(50)     as direccion,
						CHAR(50)     as e_mail,
						CHAR(50)     as dir_cobro,
						char(50)     as Acreedor_Hipotecario,
						CHAR(20)     as apartado,
						CHAR(10)     as telefono1,
						CHAR(10)     as telefono2,
						CHAR(10)     as fax,
						CHAR(15)     as codigo_super,
						CHAR(50)     as ramo,
						CHAR(50)     as subramo,
						DATE         as suscripcion,
						DATE         as vig_ini_pol,
						DATE         as vig_fin_pol,
						DATE         as vig_inicial,
						DATE         as vig_final,
						CHAR(30)     as fecha_letra,
						DATE         as fecha_endoso_i,
						DATE         as fecha_endoso_f,
						CHAR(50)     as modificacion,
						CHAR(20)     as reemplaza_poliza,
						CHAR(2)      as reclamo_si_no,
						CHAR(20)     as poliza,
						CHAR(5)      as no_unidad,
						CHAR(50)     as marca,
						CHAR(50)     as modelo,
						INT          as ano_tarifa,
						INT          as Anio_Auto,
						CHAR(10)     as placa,
						CHAR(10)     as Placa_Taxi,
						INT          as Cantidad_Pasajeros,
						CHAR(30)     as chasis,
						CHAR(30)     as motor, 
						CHAR(50)     as tipo,
						CHAR(50)     as tipo_vehiculo,
						CHAR(20)     as tipo_auto,
						INT          as Anios_Uso,
						SMALLINT     as nuevo,
						CHAR(5)      as Cod_Producto,
						char(50)     as Nombre_Producto,
						DEC(16,2)    as suma_aseg,
						CHAR(50)     as Coberturas,
						DEC(16,2)    as limite_1,
						DEC(16,2)    as limite_2,
						CHAR(50)     as deducible,
						DEC(16,2)    as va_Prima,
						DEC(16,2)    as prima,
						DEC(16,2)    as descuento,
						DEC(16,2)    as recargo,
						DEC(16,2)    as prima_neta, 
						DEC(16,2)    as impuesto,
						DEC(16,2)    as prima_bruta,
						CHAR(5)      as Cod_Producto_ren,
						char(50)     as Nombre_Producto_ren,
						DEC(16,2)    as suma_aseg_ren,
						DEC(16,2)    as depreciacion_ren,
						CHAR(50)     as Coberturas_ren,
						DEC(16,2)    as limite_1_ren,
						DEC(16,2)    as limite_2_ren,
						CHAR(50)     as deducible_ren,
						DEC(16,2)    as Prima_ren,
						DEC(16,2)    as descuento_ren,
						DEC(16,2)    as recargo_ren,
						DEC(16,2)    as prima_neta_ren, 
						DEC(16,2)    as impuesto_ren,
						DEC(16,2)    as prima_bruta_ren;

						
DEFINE va_reclamo	   CHAR(2);
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
DEFINE v_nuevo,_se_imp_motor SMALLINT;

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
define _codigo_super     char(15);
define _cod_producto     char(5);
DEFINE _cnt              SMALLINT;

DEFINE _cod_tipoveh      CHAR(3);
DEFINE _uso_auto         CHAR(1);
DEFINE _nom_tipo_veh     CHAR(50);
DEFINE _nom_uso_auto     CHAR(20);

DEFINE va_cod_cobertura   CHAR(5);	
DEFINE va_orden	          INT;
DEFINE va_Coberturas      CHAR(50);

DEFINE v_ano_act          INT;
DEFINE v_capacidad        INT;
			   
DEFINE va_Acreedor_Hipotecario char(50);
DEFINE va_Anio_Auto            INT;
DEFINE va_Anios_Uso            INT;
DEFINE va_Cantidad_Pasajeros   INT;

DEFINE va_Cod_Producto         CHAR(5);
DEFINE va_Nombre_Producto      char(50);
DEFINE va_Placa_Taxi           CHAR(10);

DEFINE _cod_ase         char(10);	
define _cod_acreedor    char(10);  	 
DEFINE va_deducible		 CHAR(50);
DEFINE va_prima		     DEC(16,2);
DEFINE va_limite_1	     DEC(16,2);
DEFINE va_limite_2	     DEC(16,2);
DEFINE va_modifico 	     CHAR(50);

DEFINE var_Coberturas      CHAR(50);
DEFINE var_Cod_Producto         CHAR(5);
DEFINE var_deducible		 CHAR(50);
DEFINE var_prima		     DEC(16,2);
DEFINE var_limite_1	     DEC(16,2);
DEFINE var_limite_2	     DEC(16,2);
DEFINE var_Nombre_Producto      char(50);	

DEFINE var_suma_aseg	   DEC(16,2);
DEFINE var_descuento	   DEC(16,2);
DEFINE var_recargo	   DEC(16,2);
DEFINE var_prima_neta    DEC(16,2);
DEFINE var_impuesto	   DEC(16,2);
DEFINE var_prima_bruta   DEC(16,2);	
DEFINE var_depreciacion_ren    DEC(16,2);

DEFINE _Factor_Vigencia_a    DEC(16,4);
DEFINE _Factor_Vigencia_b    DEC(16,4);
DEFINE _Factor_Vigencia      DEC(16,4);
DEFINE _porc_depreciacion    DEC(16,2);

define _cnt_unidad     int;


SET ISOLATION TO DIRTY READ;

-- Crear la tabla
CREATE TEMP TABLE tmp_arregloxls(
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

-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;                                                                     

let _reemplaza_poliza = "";
let _cnt = 0;

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
   FROM emipouni --endeduni
  WHERE no_poliza = a_poliza
    and activo = 1 
  --  AND no_endoso = a_endoso
	
	    let _cnt_unidad = 0;
	 select count(*)
       into _cnt_unidad	 
	   from emipouni   
	  where no_poliza = a_poliza
		and activo = 1 
		and no_unidad = v_unidad;
		
		if _cnt_unidad is null then
			let _cnt_unidad = 0;
		end if	
		
		if _cnt_unidad = 0 then
			continue foreach;		
		end if
		

	INSERT INTO tmp_arregloxls(
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
   FROM tmp_arregloxls
   order by no_unidad
   
   

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
			   capacidad,
			   placa_taxi
		  INTO _cod_marca,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   v_capacidad,
			   va_placa_taxi
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
			   capacidad,
			   placa_taxi
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   v_capacidad,
			   va_placa_taxi
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
			   capacidad,
			   placa_taxi
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   v_capacidad,
			   va_placa_taxi
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
			   capacidad,
			   placa_taxi
		  INTO _cod_marca,
	           v_chasis,
		       _cod_modelo,
			   v_placa,
			   v_ano_auto,
			   v_nuevo,
			   v_capacidad,
			   va_Placa_Taxi
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
   let _codigo_super = null;
   let _nom_tipo_veh = '';
   let _nom_uso_auto = '';
   
   foreach
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = a_poliza

		select codigo_super
		  into _codigo_super 
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		if _codigo_super is not null then
			exit foreach;
		end if	
	end foreach	  
	
	-- programacion MINSA, HGIRON: 30/10/17
	   let _cnt = 0;
	select count(*)
	  into _cnt
	  from tmp_end_xls 
	 where no_factura = v_factura
	   and referencia = 'MINSA1';

	   if _cnt is null then
		  let _cnt = 0;
	   end if	   
	   
	   if _cnt > 0 then
		select fecha2
		  into v_vig_fin_pol
		  from tmp_end_xls 
		 where no_factura = v_factura
		   and referencia = 'MINSA1';	   
	   end if
	   
	if v_poliza = '2018-05147-09'then
		let v_motor = "";
	end if
	if v_telefono1 = "" or v_telefono1 is null then
		let v_telefono1 = _celular;
	end if
	
    SELECT cod_tipoveh,
	  	   uso_auto
  	  INTO _cod_tipoveh,
		   _uso_auto	
      FROM emiauto
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = v_unidad;

	SELECT nombre  
	  INTO _nom_tipo_veh  
	  FROM emitiveh   
	 where cod_tipoveh = _cod_tipoveh;
	
	IF _uso_auto = 'P' THEN
		LET _nom_uso_auto = 'PARTICULAR';
	ELSE
		LET _nom_uso_auto = 'COMERCIAL';
	END IF;

	-- Datos del acreedor de la poliza	
	let _cod_acreedor = null;

	foreach
	 select	cod_acreedor
	   into	_cod_acreedor
	   from emipoacr
	  where	no_poliza = _no_poliza

		 if _cod_acreedor is not null then

			select nombre
			  into va_Acreedor_Hipotecario
			  from emiacre
			 where cod_acreedor = _cod_acreedor;

			exit foreach;
		end if
	end foreach


	if _cod_acreedor is null then
	   if _leasing = 1 then	--La poliza es leasing
			foreach
				select cod_asegurado
				  into _cod_ase
				  from emipouni
				 where no_poliza = _no_poliza
				
				select nombre
				  into va_Acreedor_Hipotecario
				  from cliclien
				 where cod_cliente = _cod_ase;
				 
				let _cod_acreedor = _cod_ase;  
			end foreach
	   else
		LET _cod_acreedor = '';
		LET va_Acreedor_Hipotecario = '';
	   end if	
	end if
	
  SELECT ano_tarifa  
    INTO va_Anio_Auto
    FROM emiautor  
   WHERE emiautor.no_poliza = a_poliza 
     AND emiautor.no_unidad = v_unidad;    
	 
	 if va_Anio_Auto is null then
	    let va_Anio_Auto = 0;
	 end if
	 
	 let v_ano_act = YEAR(v_suscripcion);
	 let va_Anios_Uso = v_ano_act - v_ano_auto;
	 
	 if va_Anios_Uso is null then
	    let va_Anios_Uso = 0;
	 end if
	 
	 if v_capacidad is null then
	    let v_capacidad = 0;
	 end if
	 
	 let va_Cantidad_Pasajeros = v_capacidad;
	 
	select cod_producto
	  into va_Cod_Producto
	  from emipouni
	 where no_poliza = a_poliza
	   and no_unidad = v_unidad; 

	select codigo_super, 
	       nombre
	  into _codigo_super,
           va_Nombre_Producto	  
	  from prdprod
	 where cod_producto = va_Cod_Producto;
	 
	if _codigo_super is null then
	    let _codigo_super = '';
	 end if
	if va_Nombre_Producto is null then
	    let va_Nombre_Producto = '';
	 end if	 
	 
	-- if _tipo_mov = 6 then --modificacion de unidades

	   let _cnt_unidad = 0;
	   let va_Modifico = '';
	{SELECT count(*)
	  INTO _cnt_unidad	 
	  FROM endmoaut
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = a_endoso
	   AND no_unidad = v_unidad;}

	select count(*)
	 into _cnt_unidad
	 from endmoaut  a,endedmae b
	where a.no_poliza = b.no_poliza
	  and a.no_poliza = _no_poliza
	  and no_unidad = v_unidad
	  and b.actualizado = 1
	  and b.cod_endomov in ('004','005','006')
	  and b.fecha_emision between v_vig_ini_pol and v_vig_fin_pol;	   

	if _cnt_unidad is null then
		let _cnt_unidad = 0;
	end if	

	if _cnt_unidad = 0 then
		let va_Modifico = '';	
	else	
		let va_Modifico = 'MODIFICACION DE UNIDAD';	   
	end if			   

	-- end if	
	   let _cnt_unidad = 0;
	   let va_reclamo = 'NO';	
	   
	  select count( distinct no_reclamo)
	   into _cnt_unidad
	   from recrcmae
	  where	actualizado  = 1
		and no_documento = v_poliza
	    and no_unidad = v_unidad;	 
		
		if _cnt_unidad is null then
			let _cnt_unidad = 0;
		end if	

		if _cnt_unidad = 0 then
			let va_reclamo = 'NO';	
		else	
			let va_reclamo = 'SI';	   
		end if					    
				
	select cod_producto,impuesto_r,suma_aseg,vigencia_inic,vigencia_final,porc_depreciacion
	  into var_Cod_Producto, var_impuesto,var_suma_aseg,v_vig_i_end,v_vig_f_end,_porc_depreciacion
	  FROM emireaut
       WHERE no_poliza = _no_poliza  
	   and no_unidad = v_unidad
	   and estatus_ren = '1';	   
	  
   SELECT sum(descuento_o),
         sum(recargo_o),
         sum(prima_neta_o),
		 sum(prima_o)
	into var_descuento,
		 var_recargo,
		 var_prima_neta, 			 	
		 var_prima_bruta
    FROM emireau1
   WHERE emireau1.no_poliza = _no_poliza  
     and no_unidad = v_unidad;
	 
	 let var_prima_bruta = var_prima_neta + var_impuesto;

	select trim(nombre)
	  into var_Nombre_Producto	  
	  from prdprod
	 where cod_producto = var_Cod_Producto;
	 

	if var_Cod_Producto is null then
	    let var_Cod_Producto = '';
	 end if		
	if var_Nombre_Producto is null then
	    let var_Nombre_Producto = '';
	 end if	
{
     select porc_depre 
	   into _porc_depreciacion	  
	   from emidepre
      where uso_auto = _uso_auto
	    and va_Anios_Uso between ano_desde and ano_hasta;
	 
	 
let _Factor_Vigencia_a =	v_vig_fin_pol - v_vigen_ini;
let _Factor_Vigencia_b =	v_vig_fin_pol - v_vig_ini_pol;

let _Factor_Vigencia =	_Factor_Vigencia_a / _Factor_Vigencia_b;
}
let _Factor_Vigencia = 1;
let var_depreciacion_ren =	_Factor_Vigencia * _porc_depreciacion;


	FOREACH	
	 SELECT orden,
			cod_cobertura,
			deducible_3 ,
			limite_1_3,
			limite_2_3,
			deducible_o,
			limite_1_o,
			limite_2_o,
			SUM(prima_anual_3) prima_3,
			SUM(prima_anual_o) prima_o ,
   			SUM(prima_neta_3) prima_neta_3,
			SUM(prima_neta_o) prima_neta_o,
      		SUM(descuento_3) descuento_3,
			SUM(descuento_o) descuento_o
	   INTO va_orden ,
			va_cod_cobertura,
			va_deducible,
			va_limite_1,
			va_limite_2,
			var_deducible,
			var_limite_1,
			var_limite_2,
            va_prima,			
			var_prima,
			v_prima_neta,
			var_prima_neta,
			v_descuento,
			var_descuento
	  FROM emireau2
	 WHERE no_poliza = a_poliza 
       and no_unidad = v_unidad
  GROUP BY orden, 
		    cod_cobertura,
			deducible_3,
			limite_1_3,
			limite_2_3,
            deducible_o,
			limite_1_o,
			limite_2_o
			
			
		SELECT nombre 
		  INTO va_Coberturas
		  FROM prdcober
		 WHERE cod_cobertura = va_cod_cobertura;
		 
		 let var_Coberturas = va_Coberturas;
		 
		RETURN  v_desc_factura,
				v_factura,
				v_tipo_factura,
				_cod_contratante,
				v_contratante, 
				_cod_cliente,
				v_asegurado, 
				v_cedula,
				v_direccion,
				v_email,
				v_dir_cobro,
				va_Acreedor_Hipotecario,
				v_dir_postal, 
				v_telefono1,
				v_telefono2,
				v_fax,
				_codigo_super,
				v_ramo,
				v_subramo,
				v_suscripcion,
				v_vig_ini_pol,
				v_vig_fin_pol,
				v_vigen_ini,
				v_vigen_fin,
				v_fecha_letra,
				v_vig_i_end,
				v_vig_f_end,
				va_Modifico,
				_reemplaza_poliza,
				va_reclamo,				
				v_poliza,
				v_unidad,
				v_marca,
				v_modelo,
				v_ano_auto, 
				va_Anio_Auto,
				v_placa,
				va_Placa_Taxi,
				va_Cantidad_Pasajeros,
				v_chasis, 
				v_motor,
				v_tipo,
				_nom_tipo_veh,
				_nom_uso_auto,
				va_Anios_Uso,
				v_nuevo,
				va_Cod_Producto,
				va_Nombre_Producto,
				v_suma_aseg,
				va_Coberturas,
				va_limite_1,
				va_limite_2,
				va_deducible,
				va_Prima,
				v_prima,
				v_descuento,
				v_recargo,
				v_prima_neta, 
				v_impuesto,
				v_prima_bruta,
				var_Cod_Producto,
				var_Nombre_Producto,
				var_suma_aseg,
				var_depreciacion_ren,
				var_Coberturas,
				var_limite_1,
				var_limite_2,
				var_deducible,
				var_Prima,
				var_descuento,
				var_recargo,
				var_prima_neta, 
				var_impuesto,
				var_prima_bruta
		   WITH RESUME; 

			   
	END FOREACH
		

--,va_Tipo_Vehiculo,va_Uso_Auto
END FOREACH
DROP TABLE tmp_arregloxls;

END PROCEDURE
