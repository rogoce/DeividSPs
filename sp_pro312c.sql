-- Informaci¢n: para Panam  Asistencia Ramo Automovil 
-- Creado     : 16/07/2008 - Autor: Amado Perez
-- Modificacion: 22/16/2011	- Autor: Amado Perez - Se agregaron dos campos cod_agente y cedula o ruc en la salida.
-- Se hizo un backup sp_pro312bk2 donde estan los cambios que se hicieron anteriormente en caso de que se implemente la busqueda de la asistencia a traves de los productos.
-- Modificacion: 11/10/2012 - Autor: Amado Perez - Nueva carga de Panama Asistencia solicitud de Sabish Castillo, se hizo un backup del original en sp_pro312_viejo

DROP PROCEDURE sp_pro312c;

create procedure sp_pro312c()

returning CHAR(30),    -- 1. Nombre del Titular
		  CHAR(20),    -- 2. Ciudad
	      CHAR(14),	   -- 3. P¢liza
		  CHAR(8),	   -- 4. Placa
		  CHAR(30),	   -- 5. Vehiculo
	   	  SMALLINT,	   -- 6. Compania
		  CHAR(8),     -- 7. Fecha In
		  CHAR(8),	   -- 8. Fecha Out
		  CHAR(10),	   -- 9. Unidad
		  CHAR(1),     --10. Uso Auto
		  CHAR(1),     --11. Asistencia
		  VARCHAR(50), --12. Correo Agente
		  VARCHAR(30), --13. Cedula
		  CHAR(30),	   --14. Motor
		  CHAR(30),	   --15. Chasis
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2);

DEFINE v_nombre			 CHAR(30);
DEFINE v_poliza			 CHAR(14);
DEFINE v_marca			 VARCHAR(50);
DEFINE v_modelo			 VARCHAR(50);
DEFINE v_ano_auto		 CHAR(10);
DEFINE v_placa			 CHAR(10);
DEFINE v_vigencia_inic	 CHAR(10);
DEFINE v_vigencia_final	 CHAR(10);
DEFINE v_no_unidad		 CHAR(10);
DEFINE v_uso_auto	 	 CHAR(1);

DEFINE v_titular		 CHAR(30);
DEFINE v_vehiculo		 CHAR(30);
DEFINE v_compania		 SMALLINT;
DEFINE v_fechain		 CHAR(8);
DEFINE v_fechaout		 CHAR(8);
DEFINE v_unidad			 CHAR(10);

DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_saldo			DEC(16,2);
DEFINE _total_mor		DEC(16,2);

DEFINE _fecha_hoy		DATE;
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
define _fecha_ult_dia   DATE;
DEFINE _no_poliza		CHAR(10);

DEFINE _compania		CHAR(3);
DEFINE _agencia			CHAR(3);
define v_cod_producto   CHAR(5);
DEFINE v_asistencia     CHAR(1);
DEFINE v_cod_agente		CHAR(5);
DEFINE v_cedula  		VARCHAR(30);
DEFINE v_e_mail         VARCHAR(50);

DEFINE v_no_motor       CHAR(30);
DEFINE v_no_chasis      CHAR(30);

DEFINE _nueva_renov     CHAR(1);

DEFINE _cod_ramo        CHAR(3);

DEFINE _cod_subramo     CHAR(3);
define _cod_formapag    CHAR(3);

CREATE TEMP TABLE tmp_anconvig (
	titular    CHAR(30),
	poliza	   CHAR(14),
	placa	   CHAR(8),	
	vehiculo   CHAR(30),
	compania   SMALLINT,
	fechain	   CHAR(8), 
	fechaout   CHAR(8),	
	unidad	   CHAR(10),
	uso_auto   CHAR(1),
	asistencia CHAR(1),
	e_mail     VARCHAR(50),
	cedula     VARCHAR(30),
	no_motor   CHAR(30),
	no_chasis  CHAR(30),
	nueva_renov CHAR(1),
	cod_formapag CHAR(3),
	PRIMARY KEY (poliza, unidad)) WITH NO LOG; 
	 
SET ISOLATION TO DIRTY READ;

let _fecha_hoy    = today;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF
LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

--SET DEBUG FILE TO "sp_pro312.trc";
--TRACE ON;

-- *** Automovil
-- *** Particular, Empresarial

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.nueva_renov,
		 a.cod_formapag,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
         g.no_unidad,
         f.uso_auto,
  		 e.ano_auto,
  		 e.placa,
		 e.no_motor,
		 e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _nueva_renov,
		 _cod_formapag,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_no_unidad,
		 v_uso_auto,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.cod_contratante = b.cod_cliente
     AND a.no_poliza = g.no_poliza
     AND g.no_poliza = f.no_poliza
     AND g.no_unidad = f.no_unidad
     AND f.no_motor = e.no_motor
     AND e.cod_marca = c.cod_marca
     AND e.cod_marca = d.cod_marca
     AND e.cod_modelo = d.cod_modelo
     AND (a.cod_ramo = '002' 
     AND a.cod_subramo in ('001','012') 
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND f.cod_tipoveh = '005' --> Vehiculos Livianos Coupe
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;



	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic 				from 7	for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(					v_vigencia_final from 7for 4),
			v_no_unidad,
			v_uso_auto,
			"C",v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);


	END

END FOREACH

-- *** Automovil
-- *** Comercial, Empresarial, Alquiler, Transporte Publico, Estado

FOREACH
	SELECT a.no_documento, 
	       a.no_poliza,
           a.vigencia_inic, 
           a.vigencia_final, 
		   a.cod_subramo,
		   a.nueva_renov,
		   a.cod_formapag,
	       c.nombre,
           d.nombre,
           b.nombre, 
		   b.cedula,
           g.no_unidad,
           f.uso_auto,
           e.ano_auto, 
           e.placa,
		   e.no_motor,
		   e.no_chasis
	  INTO v_poliza,
	       _no_poliza,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _cod_subramo,
		   _nueva_renov,
		   _cod_formapag,
		   v_marca,
		   v_modelo,
		   v_nombre,
		   v_cedula,
		   v_no_unidad,
		   v_uso_auto,
		   v_ano_auto,
		   v_placa,
		   v_no_motor,
		   v_no_chasis
	  FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h
     WHERE a.cod_contratante = b.cod_cliente
       AND a.no_poliza = g.no_poliza
	   AND g.no_poliza = f.no_poliza
	   AND g.no_unidad = f.no_unidad
	   AND f.no_motor = e.no_motor
	   AND e.cod_marca = c.cod_marca
	   AND e.cod_marca = d.cod_marca
	   AND e.cod_modelo = d.cod_modelo
	   AND g.no_poliza = h.no_poliza
	   AND g.no_unidad = h.no_unidad  
	   AND (a.cod_ramo = '002'
	   AND a.cod_subramo in ('002','012','004','005','003')
	   AND a.cod_tipoprod in ('001','005')
	   AND g.vigencia_inic <= date(current)
	   AND g.vigencia_final >= date(current)
	   AND h.cod_cobertura in('00907', '01030')	--> Cobertura Asistencia Vial
	   AND a.actualizado = 1
	   AND a.linea_rapida <> 1
	   AND a.estatus_poliza = 1)

  --  IF _cod_subramo = "004" THEN  --> Alquiler va Completo o Ilimitada cambio por Sabish 02/01/2013 Amado
  --		LET v_asistencia = "C";
  --	ELSE
		LET v_asistencia = "L";
  --	END IF

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION
	
    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

		
	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 				7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final 				from 7 for 4),
			v_no_unidad,
			v_uso_auto,
			v_asistencia,v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);

	END

END FOREACH


-- *** Soda 
-- *** Particular, Empresarial

FOREACH
  SELECT a.no_documento, 
         a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final, 
		 a.nueva_renov,
		 a.cod_formapag,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
         g.no_unidad,
		 g.cod_producto,
         f.uso_auto,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _nueva_renov,
		 _cod_formapag,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_no_unidad,
		 v_cod_producto,
		 v_uso_auto,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.cod_contratante = b.cod_cliente
	 AND a.no_poliza = g.no_poliza
	 AND g.no_poliza = f.no_poliza
	 AND g.no_unidad = f.no_unidad
	 AND f.no_motor = e.no_motor
	 AND e.cod_marca = c.cod_marca
	 AND e.cod_marca = d.cod_marca
	 AND e.cod_modelo = d.cod_modelo
	 AND (((a.cod_ramo = '002'
	 AND a.linea_rapida = 1)
	  OR a.cod_ramo = '020')
     AND a.cod_subramo in ('001','012')
	 AND a.cod_tipoprod in ('001','005')
	 AND g.vigencia_inic <= date(current)
	 AND g.vigencia_final >= date(current)
     AND f.cod_tipoveh = '005' --> Vehiculos Livianos Coupe
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION
		CONTINUE FOREACH;
	END EXCEPTION

    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	

	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic from 				7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final 				from 7 for 4),
			v_no_unidad,
			v_uso_auto,
			'C',v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);

	
	END

END FOREACH

-- *** Soda
-- *** Comercial, Alquiler, Transporte Publico, Estado

FOREACH
  SELECT a.no_documento, 
         a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final, 
  	     a.cod_subramo,
		 a.nueva_renov,
		 a.cod_formapag,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
         g.no_unidad,
		 g.cod_producto,
         f.uso_auto,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
	     _cod_subramo,
		 _nueva_renov,
		 _cod_formapag,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_no_unidad,
		 v_cod_producto,
		 v_uso_auto,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e 
   WHERE a.cod_contratante = b.cod_cliente
	 AND a.no_poliza = g.no_poliza
	 AND g.no_poliza = f.no_poliza
	 AND g.no_unidad = f.no_unidad
	 AND f.no_motor = e.no_motor
	 AND e.cod_marca = d.cod_marca
	 AND e.cod_modelo = d.cod_modelo
	 AND e.cod_marca = c.cod_marca
	 AND (((a.cod_ramo = '002'
	 AND a.linea_rapida = 1)
	  OR a.cod_ramo = '020')
	 AND a.cod_subramo in ('002','004','005','003','012')
	 AND a.cod_tipoprod in ('001','005')
	 AND g.vigencia_inic <= date(current)
	 AND g.vigencia_final >= date(current)
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1)

 --   IF _cod_subramo = "004" THEN  --> Alquiler va Completo o Ilimitada cambio por Sabish 02/01/2013 Amado
 --		LET v_asistencia = "C";
 --	ELSE
		LET v_asistencia = "L";
 --	END IF

    IF v_cod_producto = "01738" THEN  --> Producto Taxi City va Completo o Ilimitada cambio por Sabish 02/01/2013 Amado
	   	LET v_asistencia = "C";	 
	   -- continue foreach;			 -- > Favor eliminar el producto 01738 de la ruta a panama asistencia por Sabish 15/05/2013 Amado, Edgar lo mando a activar 22/05/2013
	END IF

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION
	
    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic 					from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(					v_vigencia_final from 7 for 4),
			v_no_unidad,
			v_uso_auto,
			v_asistencia,v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);


		END


END FOREACH

-- Automovil Flota

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.nueva_renov,
		 a.cod_formapag,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
         g.no_unidad,
         f.uso_auto,
  		 e.ano_auto,
  		 e.placa,
	     e.no_motor,
	     e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _nueva_renov,
		 _cod_formapag,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_no_unidad,
		 v_uso_auto,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.cod_contratante = b.cod_cliente
     AND a.no_poliza = g.no_poliza
     AND g.no_poliza = f.no_poliza
     AND g.no_unidad = f.no_unidad
     AND f.no_motor = e.no_motor
     AND e.cod_marca = c.cod_marca
     AND e.cod_marca = d.cod_marca
     AND e.cod_modelo = d.cod_modelo
     AND (a.cod_ramo = '023' 
     AND a.cod_subramo = '004'
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND f.cod_tipoveh = '005' --> Vehiculos Livianos Coupe
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
	 AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;



	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic 				from 7	for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(					v_vigencia_final from 7for 4),
			v_no_unidad,
			v_uso_auto,
			"C",v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);


	END

END FOREACH

-- Automovil Flota -- Empresarial, Transporte publico

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.nueva_renov,
		 a.cod_formapag,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
         g.no_unidad,
		 g.cod_producto,
         f.uso_auto,
  		 e.ano_auto,
  		 e.placa,
	     e.no_motor,
	     e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _nueva_renov,
		 _cod_formapag,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_no_unidad,
		 v_cod_producto,
		 v_uso_auto,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h
   WHERE a.cod_contratante = b.cod_cliente
     AND a.no_poliza = g.no_poliza
     AND g.no_poliza = f.no_poliza
     AND g.no_unidad = f.no_unidad
     AND f.no_motor = e.no_motor
     AND e.cod_marca = c.cod_marca
     AND e.cod_marca = d.cod_marca
     AND e.cod_modelo = d.cod_modelo
	 AND g.no_poliza = h.no_poliza
	 AND g.no_unidad = h.no_unidad  
     AND (a.cod_ramo = '023' 
	 AND a.cod_subramo in ('004','005','003','006')
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
	 AND h.cod_cobertura = '01310'	--> Cobertura Asistencia Vial
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
	 AND a.estatus_poliza = 1)

--    IF v_cod_producto = "02063" THEN  --> 
--		LET v_asistencia = "C";
--	ELSE
		LET v_asistencia = "L";
--	END IF


    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION

    FOREACH
		SELECT cod_agente
		  INTO v_cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;								
	END FOREACH

    SELECT email_reclamo
	  INTO v_e_mail
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;


	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
			v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
			3,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic 				from 7	for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(					v_vigencia_final from 7for 4),
			v_no_unidad,
			v_uso_auto,
			v_asistencia,v_e_mail,v_cedula,v_no_motor,v_no_chasis,_nueva_renov,_cod_formapag);


	END

END FOREACH


FOREACH WITH HOLD
	SELECT titular,
		   poliza,
		   placa,
		   vehiculo,
		   compania,
		   fechain,
		   fechaout,
		   unidad,
		   uso_auto,
		   asistencia,
		   e_mail,
		   cedula,
		   no_motor,
		   no_chasis,
		   nueva_renov,
		   cod_formapag
	  INTO v_titular,
		   v_poliza,
		   v_placa,
		   v_vehiculo,
		   v_compania,
		   v_fechain,	
		   v_fechaout,
		   v_unidad,	
		   v_uso_auto,
		   v_asistencia,
		   v_e_mail,
		   v_cedula,
		   v_no_motor,
		   v_no_chasis,
		   _nueva_renov,
		   _cod_formapag
	  FROM tmp_anconvig
  ORDER BY 4

  foreach
    select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_documento = v_poliza
	
	exit foreach;
  end foreach

	let v_por_vencer = 0;
	let v_exigible = 0;  
	let v_corriente = 0; 
	let v_monto_30 = 0;  
	let v_monto_60 = 0;  
	let v_monto_90 = 0;  
	let v_saldo = 0;

  if _cod_ramo <> '023' then
	CALL sp_cob33(
	"001",
	"001",
	v_poliza,
	_periodo,
	current
	) RETURNING v_por_vencer,	   
			    v_exigible,  	   
			    v_corriente, 	   
			    v_monto_30,  	   
			    v_monto_60,  	   
			    v_monto_90,  	   
				v_saldo;
				
  if v_monto_60 + v_monto_90 > 0 and _cod_formapag <> '008' then
  	continue foreach;
  end if
  
  if (v_monto_30 + v_monto_60 + v_monto_90 > 0) and _nueva_renov = 'N' and _cod_formapag <> '008' then							   		
  	continue foreach;
  end if
 end if

   RETURN  v_titular, 
           "",
		   v_poliza,	
		   v_placa,	
		   v_vehiculo,
		   v_compania,
		   v_fechain,	
		   v_fechaout,
		   v_unidad,	
		   v_uso_auto,
		   v_asistencia,
		   v_e_mail,
		   v_cedula,
		   v_no_motor,
		   v_no_chasis,
		   v_corriente,
		   v_monto_30,
		   v_monto_60,
		   v_monto_90,
		   v_saldo
		   WITH RESUME;
END FOREACH 

DROP TABLE tmp_anconvig;

end procedure;