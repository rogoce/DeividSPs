-- Informaci¢n: para Panam  Asistencia Ramo Automovil -- Nuevo formato
-- Creado     : 02/10/2015 - Autor: Amado Perez

DROP PROCEDURE sp_super12;
create procedure sp_super12()
returning char(25),date,date,varchar(100),char(30),smallint,date, decimal(16,2),decimal(16,2);

DEFINE v_nombre			 VARCHAR(60);
DEFINE v_poliza			 VARCHAR(25);
DEFINE v_marca			 VARCHAR(25);
DEFINE v_modelo			 VARCHAR(25);
DEFINE v_ano_auto		 VARCHAR(4);
DEFINE v_placa			 VARCHAR(10);
DEFINE v_vigencia_inic	 CHAR(10);
DEFINE v_vigencia_final	 CHAR(10);
DEFINE v_no_unidad		 VARCHAR(10);
DEFINE v_uso_auto	 	 VARCHAR(1);
define _vig_ini          date;
define _vig_fin          date;
DEFINE v_titular		 VARCHAR(60);
DEFINE v_vehiculo		 CHAR(30);
DEFINE v_compania		 SMALLINT;
DEFINE v_fechain		 CHAR(8);
DEFINE v_fechaout		 CHAR(8);
DEFINE v_unidad			 VARCHAR(10);
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
DEFINE v_asistencia     VARCHAR(2);
DEFINE v_cod_agente		CHAR(5);
DEFINE v_cedula  		VARCHAR(20);
DEFINE v_e_mail         VARCHAR(50);
DEFINE v_no_motor       VARCHAR(20);
DEFINE v_no_chasis      VARCHAR(25);
DEFINE _cod_cobertura   CHAR(5);
DEFINE _cod_subramo     CHAR(3);
DEFINE v_prima_bruta    DEC(16,2);
DEFINE _cod_ramo        CHAR(3);
DEFINE v_ramo           VARCHAR(50);
DEFINE v_fecha_aniversario DATE;
DEFINE v_fecha_aniversario_c CHAR(10);
DEFINE v_fechaaniv		 CHAR(8);
DEFINE v_tarjeta        VARCHAR(10);
DEFINE _direccion_1     VARCHAR(50);
DEFINE _direccion_2     VARCHAR(50);
DEFINE v_direccion      VARCHAR(150);
DEFINE _telefono1       VARCHAR(10);
DEFINE _telefono2       VARCHAR(10);
DEFINE _telefono3       VARCHAR(10);
DEFINE _celular         VARCHAR(10);
DEFINE v_telefono       VARCHAR(10);
DEFINE _cod_color       CHAR(3);
DEFINE v_color          VARCHAR(20);
DEFINE v_edad           VARCHAR(2);
DEFINE v_edad_s         INTEGER;
DEFINE _cod_tipoveh		CHAR(3);
DEFINE v_fecha_c        CHAR(10);
define _vig_no_poliza   varchar(10);
define _cod_grupo       varchar(5);
define _n_producto,_n_subramo varchar(50);
define _numrecla        char(18);
define _cod_asegurado   char(10);
define _fecha_reclamo   date;
define _fecha_siniestro date;
define _cod_producto    char(5);
define _n_asegurado     char(75);
define v_filtros        varchar(255);
define v_asegurado      varchar(100);
define _no_documento    char(25);
define _no_motor        char(30);
define _ano_auto        smallint;
define _fecha_suscripcion date;
define _cnt              integer;
define _temp_poliza      char(10);
define v_contratante     char(10);
define v_suma_asegurada  dec(16,2);
define _no_unidad        char(5);

CREATE TEMP TABLE tmp_anconvig (
	cedula     VARCHAR(20),
	titular    VARCHAR(60),
	poliza	   VARCHAR(25),
	unidad	   VARCHAR(10),
	tarjeta    VARCHAR(10),
	fecha_aniversario VARCHAR(8),
	edad        VARCHAR(2),
	direccion   VARCHAR(150),
	e_mail     VARCHAR(50),
	telefono   VARCHAR(10),
	marca      VARCHAR(25),
	modelo     VARCHAR(25), 
	placa	   VARCHAR(10),	
	ano_auto   VARCHAR(4),  -- Año
	color      VARCHAR(20), --Color	
	no_chasis  VARCHAR(25),
	no_motor   VARCHAR(20),
	uso_auto   VARCHAR(1),
	asistencia VARCHAR(2),
	vigencia_inic  VARCHAR(8), 
	vigencia_final VARCHAR(8),	
	PRIMARY KEY (poliza, unidad)) WITH NO LOG; 
	 
SET ISOLATION TO DIRTY READ;

let _fecha_hoy    = today;
LET v_fecha_c     = today;

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
		 a.cod_ramo,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
  		 e.ano_auto,
  		 e.placa,
		 e.no_motor,
		 e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
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

    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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
	
    LET v_fecha_aniversario_c = v_fecha_aniversario;

	--if _cod_tipoveh in('025','042','035','008','009','010') then
	--	let v_asistencia = 'EP';
	--else
		let v_asistencia = 'C';
	--end if

	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2)	|| SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,	--"C",
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);

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
		   a.cod_ramo,
	       c.nombre,
           d.nombre,
           b.nombre, 
		   b.cedula,
		   b.fecha_aniversario,
		   b.direccion_1,
		   b.direccion_2,
		   b.telefono1,
		   b.telefono2,
		   b.telefono3,
		   b.celular,
           g.no_unidad,
		   g.prima_bruta,
           f.uso_auto,
		   f.cod_tipoveh,
           e.ano_auto, 
           e.placa,
		   e.no_motor,
		   e.no_chasis,
		   e.cod_color,
		   h.cod_cobertura
	  INTO v_poliza,
	       _no_poliza,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _cod_subramo,
		   _cod_ramo,
		   v_marca,
		   v_modelo,
		   v_nombre,
		   v_cedula,
		   v_fecha_aniversario,
		   _direccion_1,
		   _direccion_2,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular,
		   v_no_unidad,
		   v_prima_bruta,
		   v_uso_auto,
		   _cod_tipoveh,
		   v_ano_auto,
		   v_placa,
		   v_no_motor,
		   v_no_chasis,
		   _cod_color,
		   _cod_cobertura
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
	   AND a.cod_subramo in ('002','012','004','005','003','016')
	   AND a.cod_tipoprod in ('001','005')
	   AND g.vigencia_inic <= date(current)
	   AND g.vigencia_final >= date(current)
	   AND h.cod_cobertura in('00907', '01030', '01141')	--> Cobertura Asistencia Vial Limitada y Asistencia Vial
	   AND a.actualizado = 1
	   AND a.linea_rapida <> 1
	   AND a.estatus_poliza = 1)
	   
	IF _cod_cobertura = "01141" THEN  --> 
  		LET v_asistencia = "C";
	elif _cod_tipoveh in('010') then	--_cod_tipoveh in('025','042','035','008','009','010')
		let v_asistencia = 'EP';
  	ELSE
		LET v_asistencia = "L";
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF
	
    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui

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

    LET v_fecha_aniversario_c = v_fecha_aniversario;	
	 
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	 
	END

END FOREACH

----------------------------MULTIPOLIZA RAMO 024
 --*** Soda 
-- *** Particular, Empresarial

FOREACH
  SELECT a.no_documento, 
         a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final, 
		 a.cod_ramo,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.cod_contratante = b.cod_cliente
	 AND a.no_poliza = g.no_poliza
	 AND g.no_poliza = f.no_poliza
	 AND g.no_unidad = f.no_unidad
	 AND f.no_motor = e.no_motor
	 AND e.cod_marca = c.cod_marca
	 AND e.cod_marca = d.cod_marca
	 AND e.cod_modelo = d.cod_modelo
	 AND a.cod_ramo = '024'
	 AND g.cod_ramo = '020'
     AND a.cod_subramo in ('001')
	 AND a.cod_tipoprod in ('001','005')
	 AND g.vigencia_inic <= date(current)
	 AND g.vigencia_final >= date(current)
     AND f.cod_tipoveh = '005' --> Vehiculos Livianos Coupe
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;

	IF v_cod_producto = "02520" THEN
	   	LET v_asistencia = "S1";
	ELIF v_cod_producto = "02521" THEN
		LET v_asistencia = "L";
	END IF
	
	--IF _cod_tipoveh in('025','042','035','008','009','010') then
	--	let v_asistencia = 'EP';
	--END IF
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,	--'C',
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	 	
	END

END FOREACH

-- *** Soda RAMO MULTIPOLIZA
-- *** Transporte Publico

FOREACH
  SELECT a.no_documento, 
         a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final, 
  	     a.cod_subramo,
 		 a.cod_ramo,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
	     _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e 
   WHERE a.cod_contratante = b.cod_cliente
	 AND a.no_poliza = g.no_poliza
	 AND g.no_poliza = f.no_poliza
	 AND g.no_unidad = f.no_unidad
	 AND f.no_motor = e.no_motor
	 AND e.cod_marca = d.cod_marca
	 AND e.cod_modelo = d.cod_modelo
	 AND e.cod_marca = c.cod_marca
	 AND a.cod_ramo = '024'
	 AND g.cod_ramo = '020'
	 AND a.cod_subramo in ('003')
	 AND a.cod_tipoprod in ('001','005')
	 AND g.vigencia_inic <= date(current)
	 AND g.vigencia_final >= date(current)
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1

	LET v_asistencia = "L";

	IF v_cod_producto in("02494") THEN
	   	LET v_asistencia = "S";
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;

	IF _cod_tipoveh in('010') then
		let v_asistencia = 'EP';
	END IF

	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
		END
END FOREACH
----------------------------
-- *** Soda 
-- *** Particular, Empresarial

--SET DEBUG FILE TO "sp_pro404.trc";
--TRACE ON;

FOREACH
  SELECT a.no_documento, 
         a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final, 
		 a.cod_ramo,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;

	IF v_cod_producto in("01496","01606","01961") THEN  --> Producto SODA EXPRESS, SE MARCA CON S EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S";
	ELIF v_cod_producto = "01492" THEN  --> Producto SODA EXPRESS +, SE MARCA CON S1 EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S1";
	ELSE
	   	LET v_asistencia = "C";
	END IF
	
	--IF _cod_tipoveh in('025','042','035','008','009','010') then
	--	let v_asistencia = 'EP';
	--END IF
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,	--'C',
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	 	
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
 		 a.cod_ramo,
         c.nombre,
  		 d.nombre, 
         b.nombre,
         b.cedula, 
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
         e.ano_auto, 
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
	     _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
         v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
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
	IF v_cod_producto in("01496","01606","01961") THEN  --> Producto SODA EXPRESS, SE MARCA CON S EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S";
	ELIF v_cod_producto = "01492" THEN  --> Producto SODA EXPRESS +, SE MARCA CON S1 EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S1";
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;

	IF _cod_tipoveh in('010') then
		let v_asistencia = 'EP';
	END IF

	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	 

		END
END FOREACH

-- Automovil Flota

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.cod_ramo,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
  		 e.ano_auto,
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;

	--if _cod_tipoveh in('025','042','035','008','009','010') then
	--	let v_asistencia = 'EP';
	--else
		let v_asistencia = 'C';
	--end if	
	 
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,--'C',
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);

	END

END FOREACH

-- Automovil Flota -- Empresarial, Transporte publico - cobertura limitada 01310

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.cod_ramo,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
  		 e.ano_auto,
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color,
		 h.cod_cobertura
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color,
		 _cod_cobertura
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
	 AND h.cod_cobertura in ('01310','01341')	--> Cobertura Asistencia Vial limitada, Cobertura Asistencia Vial
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

    IF _cod_cobertura = "01341" THEN  --> 
		LET v_asistencia = "C";
	ELIF _cod_tipoveh in('010') then
		let v_asistencia = 'EP';
	ELSE	
		LET v_asistencia = "L";
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;	
	 
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	

	END
END FOREACH

-- Automovil Flota -- •	2317-00025-01, •	2317-00026-01, •	2317-00030-01, •	2317-00031-01 Marielys 05-04-2017

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
         a.vigencia_inic, 
         a.vigencia_final,
		 a.cod_subramo,
		 a.cod_ramo,
         c.nombre,
  		 d.nombre,
  		 b.nombre,
		 b.cedula,
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
         g.no_unidad,
		 g.cod_producto,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
  		 e.ano_auto,
  		 e.placa,
	     e.no_motor,
	     e.no_chasis,
		 e.cod_color
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 v_cedula,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 v_no_unidad,
		 v_cod_producto,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color
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
	 AND a.no_documento in ('2317-00025-01','2317-00026-01','2317-00030-01','2317-00031-01')
	 AND a.cod_subramo in ('004','005','003','006')
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

	IF _cod_tipoveh in('010') then
		let v_asistencia = 'EP';
	ELSE	
		LET v_asistencia = "L";
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
    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_no_chasis IS NULL THEN
		LET v_no_chasis = "";
	END IF

    -- Nueva Informacion	
    LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET v_direccion = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET v_direccion = TRIM(v_direccion);
	
	IF _telefono1 IS NOT NULL AND TRIM(_telefono1) <> "" AND TRIM(_telefono1) <> "000-0000" THEN
		LET v_telefono = _telefono1;
	ELIF _telefono2 IS NOT NULL AND TRIM(_telefono2) <> "" AND TRIM(_telefono2) <> "000-0000" THEN
		LET v_telefono = _telefono2;
	ELIF _telefono3 IS NOT NULL AND TRIM(_telefono3) <> "" AND TRIM(_telefono3) <> "000-0000" THEN
		LET v_telefono = _telefono3;
	ELIF _celular IS NOT NULL AND TRIM(_celular) <> "" AND TRIM(_celular) <> "000-0000" THEN
		LET v_telefono = _celular;
	ELSE
		LET v_telefono = "";
	END IF
	
	IF _cod_color IS NOT NULL AND TRIM(_cod_color) <> "" THEN
		SELECT nombre
		  INTO v_color
		  FROM emicolor
		 WHERE cod_color = _cod_color;
	END IF
	
	-- Hasta aqui
	
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

    LET v_fecha_aniversario_c = v_fecha_aniversario;	
	 
	INSERT INTO tmp_anconvig
	VALUES (v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			"", 
			SUBSTRING(v_fecha_aniversario_c from 1 for 2) || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || SUBSTRING(v_fecha_aniversario_c	from 7 for 4),
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			TRIM(v_ano_auto),
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			SUBSTRING(v_vigencia_inic from 1 for 2)	|| SUBSTRING(v_vigencia_inic from 4 for 2) || SUBSTRING(v_vigencia_inic	from 7 for 4),
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4)
			);
	

	END
END FOREACH
--busca polizas vigentes automovil
call sp_pro03('001','001','22/06/2017','002,020,023;') returning v_filtros;

foreach
    select no_documento
	  into _no_documento
	  from temp_perfil
	 where seleccionado = 1
	 order by no_documento
	 
	--busca si la poliza vigente esta en la tabla de panama asistencia.
	select count(*)
	  into _cnt
	  from tmp_anconvig
	 where poliza = _no_documento;
    
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
	   continue foreach;
	end if 
	
		foreach
			select y.cod_contratante,
				   y.vigencia_inic,
				   y.vigencia_final,
				   y.suma_asegurada,
				   y.prima_bruta,
				   y.no_poliza
			  into v_contratante,
				   _vig_ini,
				   _vig_fin,
				   v_suma_asegurada,
				   v_prima_bruta,
				   _temp_poliza
			  from temp_perfil y
			 where y.seleccionado = 1
			   and y.no_documento = _no_documento
			   
			select fecha_suscripcion
              into _fecha_suscripcion
              from emipomae
             where no_poliza = _temp_poliza;
			 
			select nombre
			  into v_asegurado
			  from cliclien
			 where cod_cliente = v_contratante;
			 
			foreach
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = _temp_poliza

				select no_motor
				  into _no_motor
				  from emiauto
				 where no_poliza = _temp_poliza
                   and no_unidad = _no_unidad;
				   
				select ano_auto
				  into _ano_auto
				  from emivehic
				 where no_motor = _no_motor;

				return _no_documento, _vig_ini, _vig_fin, v_asegurado, _no_motor, _ano_auto, _fecha_suscripcion, v_prima_bruta, v_suma_asegurada with resume;

			end foreach
		end foreach	 
end foreach
{FOREACH WITH HOLD
	SELECT 	poliza
      INTO	v_poliza
	  FROM	tmp_anconvig
	 GROUP BY poliza
	 ORDER BY poliza
    
  foreach
	select numrecla,
		   no_motor,
		   no_unidad,
		   cod_asegurado,
		   fecha_reclamo,
		   fecha_siniestro,
		   periodo,
		   no_poliza
	  into _numrecla,
		   v_no_motor,
		   v_unidad,
		   _cod_asegurado,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _periodo,
		   _no_poliza
	  from recrcmae
	 where no_documento = v_poliza
	   and actualizado = 1
	   and periodo >= "2016-03"
	   and periodo <= "2017-03"
	   
	select cod_producto
      into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = v_unidad;
	   
	if _cod_producto is null then
		select cod_producto
		  into _cod_producto
	      from endeduni
	     where no_poliza = _no_poliza
		   and no_endoso = '00000'
	       and no_unidad = v_unidad;
		   
		if _cod_producto is null then
		  foreach	
			select cod_producto
			  into _cod_producto
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_unidad = v_unidad
			exit foreach;
		  end foreach
		end if
	end if
	   
	let _n_producto = "";
	   select nombre,
	       cod_ramo,
	       cod_subramo
      into _n_producto,
	       _cod_ramo,
	       _cod_subramo
	  from prdprod
	 where cod_producto = _cod_producto;
	 
	let _n_subramo  = "";
	select nombre into _n_subramo from prdsubra where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
	select nombre into _n_asegurado from cliclien where cod_cliente = _cod_asegurado;
	return _n_asegurado,v_poliza,v_unidad,_fecha_reclamo,v_no_motor,_periodo,_fecha_siniestro,_numrecla,_n_producto,_n_subramo with resume;

	end foreach
		
END FOREACH
}
end procedure;