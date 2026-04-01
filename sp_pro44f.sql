-- Procedimiento para imprimir la factura mensual de salud
--
-- Creado    : 22/02/2006 - Autor: Amado Perez Mendoza 
-- Modificado: 22/02/2006 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro44f;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE sp_pro44f()
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
						DEC(16,2),			 --	v_suma_aseg,
						CHAR(20),			 --	v_poliza,
						CHAR(10),			 --	v_factura,	
						DEC(16,2),			 --	v_prima,
						DEC(16,2),			 --	v_descuento,
						DEC(16,2),			 --	v_recargo,
						DEC(16,2),			 --	v_prima_neta, 
						DEC(16,2),			 --	v_impuesto,	
						DEC(16,2),			 --	v_prima_bruta,
						DATE,				 --	v_vig_ini_pol,
						DATE,				 --	v_vig_fin_pol,
						CHAR(10),			 --	v_tipo_factura,
						CHAR(50),			 --	v_desc_factura,
						CHAR(30),			 --	v_fecha_letra,
						CHAR(30),	   		 --	v_cedula
						DATE,				 -- v_vig_i_end
						DATE,				 -- v_vig_f_end
						CHAR(10),			 -- _cod_cliente
						CHAR(10),			 -- _cod_contratante
						CHAR(10),
						CHAR(5),
						CHAR(10),
						CHAR(4);
	
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
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_poliza		   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_prima		   DEC(16,2);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_recargo	   DEC(16,2);
DEFINE v_prima_neta    DEC(16,2);
DEFINE v_impuesto	   DEC(16,2);
DEFINE v_prima_bruta   DEC(16,2);
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
DEFINE v_mes           CHAR(10);
DEFINE v_ano2          CHAR(4);

DEFINE _doc_poliza		 CHAR(20);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _cod_endomov      CHAR(3);
DEFINE _dia              CHAR(2);
DEFINE _ano              CHAR(4);

DEFINE a_poliza          CHAR(10); 
DEFINE a_endoso          CHAR(5); 
DEFINE _no_factura       CHAR(10);
DEFINE _periodo          CHAR(7);
DEFINE _mes              SMALLINT;

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

 --SET DEBUG FILE TO "sp_pro44.trc";      
 --TRACE ON;                                                                     

FOREACH
 SELECT	doc_poliza, no_factura    
   INTO	_doc_poliza, _no_factura
   FROM tmp_certif
  GROUP BY doc_poliza, no_factura
  ORDER BY doc_poliza, no_factura

  FOREACH
	SELECT no_poliza,	
	       no_endoso
	  INTO a_poliza,	
		   a_endoso
	  FROM endedmae
	 WHERE no_factura = _no_factura
	 EXIT FOREACH;
  END FOREACH

	--Recorre la tabla temporal y asigna valores a variables de salida
	FOREACH 
		SELECT no_factura,
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
			   prima_bruta,
	       	   periodo
		  INTO v_factura,
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
			   v_prima_bruta,
			   _periodo
		  FROM endedmae
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso

		-- Lectura del contratante

		SELECT cod_pagador,
			   nueva_renov
		  INTO _cod_contratante,
			   _nueva_renov
		  FROM emipomae
		 WHERE no_poliza = a_poliza;

		SELECT nombre
		  INTO v_contratante
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		-- Lectura del Asegurado
	    
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = a_poliza;

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
		    WHERE no_poliza = a_poliza;
		END IF

	    -- Lectura del Ramo y Subramo

	    SELECT cod_ramo,
		       cod_subramo
		  INTO _cod_ramo,
		       _cod_subramo
		  FROM emipomae
	     WHERE no_poliza = a_poliza;

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
		   WHERE no_poliza = a_poliza;

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
	   LET _mes = _periodo[6,7];
       LET v_mes = sp_sac18(_mes);
	   LET v_ano2 = _periodo[1,4]; 

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
			   v_suma_aseg,
			   v_poliza,	
			   v_factura,
			   v_prima,
			   v_descuento,
			   v_recargo,
			   v_prima_neta, 
			   v_impuesto,	
			   v_prima_bruta,
		 	   v_vig_ini_pol,
		 	   v_vig_fin_pol,
		 	   v_tipo_factura,
			   v_desc_factura,
		 	   v_fecha_letra,
			   v_cedula,
			   v_vig_i_end,
			   v_vig_f_end,
			   _cod_cliente,
			   _cod_contratante,
			   a_poliza,
			   a_endoso,
			   v_mes,
			   v_ano2
			   WITH RESUME; 

	END FOREACH
END FOREACH
DROP TABLE tmp_arreglo;
END PROCEDURE
