-- Informaci¢n: para Panam  Asistencia Ramo Automovil -- Nuevo formato
-- Creado     : 02/10/2015 - Autor: Amado Perez
DROP PROCEDURE sp_pro404;
create procedure sp_pro404()
returning 
		  VARCHAR(20), -- 1. Cedula
		  VARCHAR(60), -- 2. Nombre del Titular
	      VARCHAR(25), -- 3. P¢liza
		  VARCHAR(10), -- 4. Unidad
		  VARCHAR(10), -- 5. Nro. Tarjeta 
		  CHAR(8),     -- 6. Fecha Nacio
		  VARCHAR(2),  -- 7.Edad
		  VARCHAR(150), --8. Ciudad
		  VARCHAR(50), -- 9. Correo del Agente
		  VARCHAR(10), -- 10. Telefono 
		  VARCHAR(25), -- 11. Marca
		  VARCHAR(25), -- 12. Modelo
		  VARCHAR(10), -- 13. Placa
		  VARCHAR(4),  -- 14. Año
		  VARCHAR(20), -- 15. Color
		  VARCHAR(30), -- 16. Chasis
		  VARCHAR(30), -- 17. Motor
		  VARCHAR(1),  -- 18. Uso Auto
		  VARCHAR(20),  -- 19. Asistencia
		  CHAR(8),     -- 20. Fecha In
		  CHAR(8),	   -- 21. Fecha Out
		  CHAR(8),     -- 22. Fecha de envio
		  VARCHAR(10), -- 23. Atributo1
		  VARCHAR(30), -- 24. Atributo2
		  VARCHAR(50), -- 25. Atributo3
		  VARCHAR(80), -- 26. Atributo4
		  VARCHAR(100), -- 27. Atributo5
		  VARCHAR(150), -- 28. Atributo6
		  char(3),     -- 29.
		  VARCHAR(50), -- 30.
		  char(5),     -- 31.
		  varchar(50); -- 32.

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
DEFINE v_asistencia     VARCHAR(20);
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
DEFINE _fecha_suspension DATE;
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
DEFINE v_edad,_pin      VARCHAR(4);
DEFINE v_edad_s,_naviera         INTEGER;
DEFINE _cod_tipoveh		CHAR(3);
DEFINE v_fecha_c        CHAR(10);
define _vig_no_poliza   varchar(10);
define _cod_grupo       varchar(5);
define _n_tipoveh,_n_producto  varchar(50);
DEFINE _vig_inic_pol    DATE;

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
	asistencia VARCHAR(20),
	vigencia_inic  VARCHAR(8), 
	vigencia_final VARCHAR(8),
    cod_tipoveh	   char(3),
	PRIMARY KEY (poliza, unidad)) WITH NO LOG; 
	
CREATE TEMP TABLE tmp_prod_exc (
	cod_producto CHAR(5),
	PRIMARY KEY (cod_producto)) WITH NO LOG;
		 
SET ISOLATION TO DIRTY READ;

let _fecha_hoy    = today;
LET v_fecha_c     = today;
let _naviera = 0;

-- Productos que se excluyen en el proceso -- Amado 22-11-2022
--cod_producto	nombre	
--04561			SOBAT BASICO PARTICULAR (B/.103.88)	
--04562			SOBAT BASICO COMERCIAL (B/. 103.88)	
--05769			SOBAT BASICO TALLER (B/.145.00)	
--07229			TALLER MOTOS PARTICULAR OPCION 1 (B/..80.00)	
--07285			TALLER MOTOS COMERCIAL OPCION 1 (B/.83.00)	
--01496 		SOBAT EXPRESS (PARTICULAR B/.159.00) -- Se usará otro tipo de validación -- ID de la solicitud	# 5085
--04486 		SOBAT EXPRESS (COMERCIAL B/.173.00) -- Se usará otro tipo de validación -- ID de la solicitud	# 5085
--08270 		SOBAT BASICO TALLER COMERCIAL (B/.145.00)

INSERT INTO tmp_prod_exc
SELECT cod_producto 
  FROM prdprod
 WHERE cod_producto in ('04561','04562','05769','07229','07285','08270'); --,'01496','04486'

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF
LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;
-- *** Automovil
-- *** Particular, Empresarial
FOREACH
  SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final,a.cod_subramo,a.cod_ramo,c.nombre,d.nombre,b.nombre,b.cedula,b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto,e.placa,e.no_motor,e.no_chasis,e.cod_color
	INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_subramo,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
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
	
	LET _pin = "";
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
	
	if _pin is null then
		let _pin = '';
	end if
	
	if _pin = '' then
		let v_asistencia = 'C';
	else
		let v_asistencia = trim(_pin);
	end if
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad
       and cod_cobertura in('01145','01315');	 
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if

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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	END
END FOREACH

-- *** Automovil
-- *** Comercial, Empresarial, Alquiler, Transporte Publico, Estado

FOREACH
	SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_subramo,a.cod_ramo,c.nombre,d.nombre,b.nombre, b.cedula,b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color,h.cod_cobertura
	  INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_subramo,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color,_cod_cobertura
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
	   AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
	   AND h.cod_cobertura in('00907', '01030', '01141')	--> Cobertura Asistencia Vial Limitada y Asistencia Vial
	   AND a.actualizado = 1
	   AND a.linea_rapida <> 1
	   AND a.estatus_poliza = 1)
	   
	IF _cod_cobertura = "01141" THEN  --> --ASISTENCIA VIAL
  		LET v_asistencia = "C";
	elif _cod_tipoveh in('010') then	--_cod_tipoveh in('025','042','035','008','009','010')
		let v_asistencia = 'EP';
  	ELSE
		LET v_asistencia = "L";
  	END IF
	
	let _pin = '';	
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
		
	if _pin is null then
		let _pin = '';
	end if
	
	if _pin = '' then
	else
	    if _cod_tipoveh in('010') then
			let _pin = 'RCEP';
		end if
		let v_asistencia = trim(_pin);
	end if
	if _cod_subramo = '005' then
		let v_asistencia = "TP";
	end if
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
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad
       and cod_cobertura in('01145','01315');	 
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if

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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	 
	END
END FOREACH
--****************************** EL SUBRAMO CERTIFICADO SE MUESTREN EN EL ARCHIVO LO CUAL SE GENERA PARA PANAMA ASISTENCIA F9 de Maryelys 13/05/2019
FOREACH
	SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_subramo,a.cod_ramo,c.nombre,d.nombre,b.nombre, b.cedula,b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color,h.cod_cobertura
	  INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_subramo,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color,_cod_cobertura
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
	   AND a.cod_subramo in ('016')
	   AND a.cod_tipoprod in ('001','005')
	   AND g.vigencia_inic <= date(current)
	   AND g.vigencia_final >= date(current)
	   AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
	   AND a.actualizado = 1
	   AND a.linea_rapida <> 1
	   AND a.estatus_poliza = 1)
	   
	IF _cod_cobertura = "01141" THEN  --> --ASISTENCIA VIAL
  		LET v_asistencia = "C";
	elif _cod_tipoveh in('010') then	--_cod_tipoveh in('025','042','035','008','009','010')
		let v_asistencia = 'EP';
  	ELSE
		LET v_asistencia = "L";
  	END IF
	let _pin = '';	
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
		
	if _pin is null then
		let _pin = '';
	end if
	
	if _pin = '' then
	else
	    if _cod_tipoveh in('010') then
			let _pin = 'RCEP';
		end if
		let v_asistencia = trim(_pin);
	end if
		if _cod_subramo = '005' then
		let v_asistencia = "TP";
	end if
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
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad	 
       and cod_cobertura in('01145','01315');	 
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	 
	END
END FOREACH
----------------------------MULTIPOLIZA RAMO 024
 --*** Soda 
-- *** Particular, Empresarial
FOREACH
  SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_ramo,c.nombre,d.nombre, b.nombre,b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.cod_producto,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color
	INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_cod_producto,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
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
	ELIF v_cod_producto = "04979" THEN
		LET v_asistencia = "ST";
	END IF
	let _pin = '';	
	
	let _pin = sp_super27(_no_poliza,v_no_unidad);
		
	if _pin is not null and trim(_pin) <> "" then
		let v_asistencia = trim(_pin);
	end if
		
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	END
END FOREACH
-- *** Soda RAMO MULTIPOLIZA
-- *** Transporte Publico
FOREACH
  SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_subramo,a.cod_ramo,c.nombre,d.nombre, b.nombre,b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.cod_producto,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color
	INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_subramo,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_cod_producto,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc) 
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1

	--LET v_asistencia = "L";
	LET v_asistencia = "S";

	IF v_cod_producto in("02494") THEN
	   	LET v_asistencia = "S";
	ELIF v_cod_producto = "04979" THEN
		LET v_asistencia = "ST";
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
		let _pin = '';	
	
	let _pin = sp_super27(_no_poliza,v_no_unidad);
		
	if _pin is not null and trim(_pin) <> "" then
		let v_asistencia = trim(_pin);
	end if

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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
		END
END FOREACH

FOREACH
  SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_ramo,c.nombre,d.nombre, b.nombre,b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.cod_producto,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color
	INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_cod_producto,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
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
	ELIF v_cod_producto = "04979" THEN
		LET v_asistencia = "ST";
	ELSE
	   	LET v_asistencia = "C";
	END IF
		let _pin = '';	
	
	let _pin = sp_super27(_no_poliza,v_no_unidad);
		
	if _pin is not null and trim(_pin) <> "" then
		let v_asistencia = trim(_pin);
	end if
	
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	END
END FOREACH
-- *** Soda
-- *** Comercial, Alquiler, Transporte Publico, Estado
FOREACH
  SELECT a.no_documento, a.no_poliza,a.vigencia_inic, a.vigencia_final, a.cod_subramo,a.cod_ramo,c.nombre,d.nombre, b.nombre,b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2,b.telefono1,b.telefono2,b.telefono3,b.celular,g.no_unidad,g.cod_producto,g.prima_bruta,f.uso_auto,f.cod_tipoveh,e.ano_auto, e.placa,e.no_motor,e.no_chasis,e.cod_color
	INTO v_poliza,_no_poliza,v_vigencia_inic,v_vigencia_final,_cod_subramo,_cod_ramo,v_marca,v_modelo,v_nombre,v_cedula,v_fecha_aniversario,_direccion_1,_direccion_2,_telefono1,_telefono2,_telefono3,_celular,v_no_unidad,v_cod_producto,v_prima_bruta,v_uso_auto,_cod_tipoveh,v_ano_auto,v_placa,v_no_motor,v_no_chasis,_cod_color
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc) 
	 AND a.actualizado = 1
	 AND a.estatus_poliza = 1)

	--LET v_asistencia = "L";
	LET v_asistencia = "S";
    IF v_cod_producto = "01738" THEN  --> Producto Taxi City va Completo o Ilimitada cambio por Sabish 02/01/2013 Amado
	   	LET v_asistencia = "C";	 
	   -- continue foreach;			 -- > Favor eliminar el producto 01738 de la ruta a panama asistencia por Sabish 15/05/2013 Amado, Edgar lo mando a activar 22/05/2013
	END IF
	
	IF v_cod_producto in("01496","01606","01961") THEN  --> Producto SODA EXPRESS, SE MARCA CON S EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S";
	ELIF v_cod_producto = "01492" THEN  --> Producto SODA EXPRESS +, SE MARCA CON S1 EN ASISTENCIA. ARMANDO 29/02/2016
	   	LET v_asistencia = "S1";
	ELIF v_cod_producto = "04979" THEN
		LET v_asistencia = "ST";

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
		let _pin = '';	
	
	let _pin = sp_super27(_no_poliza,v_no_unidad);
		
	if _pin is not null and trim(_pin) <> "" then
		let v_asistencia = trim(_pin);
	end if

	{IF v_asistencia in('010') then
		let v_asistencia = 'EP';
	END IF}
	--**************************************
	{if _cod_tipoveh = '003' then
		update emiauto
		   set uso_auto = 'C'
		 where no_poliza = _no_poliza
           and no_unidad = v_no_unidad
           and uso_auto = 'P';
		update endmoaut
		   set uso_auto = 'C'
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
           and no_unidad = v_no_unidad
           and uso_auto = 'P';		   		   
	end if}
	--***************************************
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
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
     AND (a.cod_ramo = '023' 
     AND a.cod_subramo = '004'
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc) 
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

		let v_asistencia = 'FC';

	let _pin = '';	
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
		
	if _pin is null then
		let _pin = '';
	end if
	
	if _pin = '' then
	else
		let v_asistencia = "F"||trim(_pin);
	end if
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad
       and cod_cobertura in('01145','01315');	 
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if 
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
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
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
	 AND h.cod_cobertura in ('01310','01341')	--> Cobertura Asistencia Vial limitada, Cobertura Asistencia Vial
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

    IF _cod_cobertura = "01341" THEN  --> 
		LET v_asistencia = "FC";
	ELIF _cod_tipoveh in('010') then
		let v_asistencia = 'FEP'; --let v_asistencia = 'FEP';
	ELSE	
		LET v_asistencia = "FL";
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
	
	let _pin = '';	
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
		
	if _pin is null then
		let _pin = '';
	end if	
	
	if _pin = '' then
	else
		if _cod_tipoveh in('010') then
			let _pin = 'RCEP';
		end if
		let v_asistencia = "F"||trim(_pin);
	end if
	if _cod_subramo = '005' then
		let v_asistencia = "TP";
	end if	
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad
       and cod_cobertura in('01145','01315');	 
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
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
     AND (a.cod_ramo = '023' 
	 AND a.no_documento in ('2317-00025-01','2317-00026-01','2317-00030-01','2317-00031-01')
	 AND a.cod_subramo in ('004','005','003','006')
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
	 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

	IF _cod_tipoveh in('010') then
		let v_asistencia = 'FEP'; --let v_asistencia = 'FEP';
	ELSE	
		LET v_asistencia = "FL";
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
	
	let _pin = '';	
	
	let _pin = sp_super21(_no_poliza,v_no_unidad);
		
	if _pin is null then
		let _pin = '';
	end if	
	
	if _pin = '' then
	else
		if _cod_tipoveh in('010') then
			let _pin = 'RCEP';
		end if
		let v_asistencia = "F"||trim(_pin);
	end if
	if _cod_subramo = '005' then
		let v_asistencia = "TP";
	end if	
	select count(*)
	  into _naviera
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad
       and cod_cobertura in('01145','01315');	 
	  
	if _naviera is null then	--segun correo Daivis 20 enero 2021
	    let _naviera = 0;
	end if
	if _naviera > 0 then
		let v_asistencia = trim(v_asistencia) || 'N';
	end if 
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
			SUBSTRING(v_vigencia_final from 1 for 2) || SUBSTRING(v_vigencia_final from 4 for 2) || SUBSTRING(v_vigencia_final from 7 for 4),
			_cod_tipoveh
			);
	
	END
END FOREACH
FOREACH WITH HOLD
	SELECT 	cedula,
			titular,
			poliza,
			unidad,
			tarjeta,
			fecha_aniversario,
			edad,
			direccion,
			e_mail,
			telefono,
			marca,
			modelo, 
			placa,	
			ano_auto,  -- Año
			color, --Color	
			no_chasis,
			no_motor,
			uso_auto,
			asistencia,
			vigencia_inic, 
			vigencia_final,
			cod_tipoveh
     INTO	v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			v_tarjeta, 
			v_fechaaniv,
			v_edad,
			v_direccion,
			v_e_mail,
			v_telefono,
			v_marca,
			v_modelo,
			v_placa,
			v_ano_auto,
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			v_fechain,
			v_fechaout,
			_cod_tipoveh
	FROM	tmp_anconvig
  ORDER BY 11, 12, 14
		

	let v_por_vencer = 0;
	let v_exigible = 0;  
	let v_corriente = 0; 
	let v_monto_30 = 0;  
	let v_monto_60 = 0;  
	let v_monto_90 = 0;  
	let v_saldo = 0;
	
	let _vig_no_poliza = sp_sis21(v_poliza);
	
	select cod_grupo,
	       vigencia_inic
	  into _cod_grupo,
	       _vig_inic_pol
	  from emipomae
	 where no_poliza = _vig_no_poliza;

	select fecha_suspension
	  into _fecha_suspension
	  from emipoliza
	 where no_documento = v_poliza;

	if _fecha_suspension < _fecha_hoy and v_poliza not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
	    if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982','78020','78032','78033','78034') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
		else
			continue foreach;
		end if
	end if

	select cod_producto 
	  into v_cod_producto 
	  from emipouni
	 where no_poliza = _vig_no_poliza
	   and no_unidad = v_no_unidad;

	select nombre into _n_producto from prdprod
	where cod_producto = v_cod_producto;
	if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
		continue foreach;
	end if

	if v_cod_producto in ('01496','04486') and _vig_inic_pol >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
		continue foreach;
	end if
	
--	if v_cod_producto in('05771', '05772','05773') then --'05971', Ya se setean en el sp_super27
--		let v_asistencia = 'ST';
--	end if
	
	{if _cod_grupo <> "1090" then
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
	else	
		let v_monto_60 = 0;
		let v_monto_90 = 0;
	end if	
	
  if (v_monto_60 + v_monto_90 > 0) and v_poliza not in ('0210-01288-01', '2315-000107-01', '0221-01883-01') then --Minsa y BHN -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
  	continue foreach;
  end if							   		}

	LET v_nombre = UPPER(v_nombre);
	LET v_nombre = REPLACE(v_nombre,"Á","A");
	LET v_nombre = REPLACE(v_nombre,"É","E");
	LET v_nombre = REPLACE(v_nombre,"Í","I");
	LET v_nombre = REPLACE(v_nombre,"Ó","O");
	LET v_nombre = REPLACE(v_nombre,"Ú","U");
	LET v_nombre = REPLACE(v_nombre,","," ");
	LET v_nombre = REPLACE(v_nombre,";"," ");
	LET v_nombre = REPLACE(v_nombre,"|"," ");
	LET v_nombre = REPLACE(v_nombre,"'"," ");
	LET v_nombre = REPLACE(v_nombre,"Ñ","N");
	LET v_nombre = REPLACE(v_nombre,"!'"," ");
	LET v_nombre = REPLACE(v_nombre,"$"," ");
	LET v_nombre = REPLACE(v_nombre,"%"," ");
	LET v_nombre = REPLACE(v_nombre,"&"," ");
	LET v_nombre = REPLACE(v_nombre,"^"," ");

	LET v_direccion = UPPER(v_direccion);
	LET v_direccion = REPLACE(v_direccion,"Á","A");
	LET v_direccion = REPLACE(v_direccion,"É","E");
	LET v_direccion = REPLACE(v_direccion,"Í","I");
	LET v_direccion = REPLACE(v_direccion,"Ó","O");
	LET v_direccion = REPLACE(v_direccion,"Ú","U");
	LET v_direccion = REPLACE(v_direccion,","," ");
	LET v_direccion = REPLACE(v_direccion,";"," ");
	LET v_direccion = REPLACE(v_direccion,"|"," ");
	LET v_direccion = REPLACE(v_direccion,"'"," ");
	LET v_direccion = REPLACE(v_direccion,"Ñ","N");
	LET v_direccion = REPLACE(v_direccion,"!'"," ");
	LET v_direccion = REPLACE(v_direccion,"$"," ");
	LET v_direccion = REPLACE(v_direccion,"%"," ");
	LET v_direccion = REPLACE(v_direccion,"&"," ");
	LET v_direccion = REPLACE(v_direccion,"^"," ");

	LET v_marca = UPPER(v_marca);
	LET v_marca = REPLACE(v_marca,"Á","A");
	LET v_marca = REPLACE(v_marca,"É","E");
	LET v_marca = REPLACE(v_marca,"Í","I");
	LET v_marca = REPLACE(v_marca,"Ó","O");
	LET v_marca = REPLACE(v_marca,"Ú","U");
	LET v_marca = REPLACE(v_marca,","," ");
	LET v_marca = REPLACE(v_marca,";"," ");
	LET v_marca = REPLACE(v_marca,"|"," ");
	LET v_marca = REPLACE(v_marca,"'"," ");
	LET v_marca = REPLACE(v_marca,"Ñ","N");
	LET v_marca = REPLACE(v_marca,"!'"," ");
	LET v_marca = REPLACE(v_marca,"$"," ");
	LET v_marca = REPLACE(v_marca,"%"," ");
	LET v_marca = REPLACE(v_marca,"&"," ");
	LET v_marca = REPLACE(v_marca,"^"," ");

	LET v_modelo = UPPER(v_modelo);
	LET v_modelo = REPLACE(v_modelo,"Á","A");
	LET v_modelo = REPLACE(v_modelo,"É","E");
	LET v_modelo = REPLACE(v_modelo,"Í","I");
	LET v_modelo = REPLACE(v_modelo,"Ó","O");
	LET v_modelo = REPLACE(v_modelo,"Ú","U");
	LET v_modelo = REPLACE(v_modelo,","," ");
	LET v_modelo = REPLACE(v_modelo,";"," ");
	LET v_modelo = REPLACE(v_modelo,"|"," ");
	LET v_modelo = REPLACE(v_modelo,"'"," ");
	LET v_modelo = REPLACE(v_modelo,"Ñ","N");
	LET v_modelo = REPLACE(v_modelo,"!'"," ");
	LET v_modelo = REPLACE(v_modelo,"$"," ");
	LET v_modelo = REPLACE(v_modelo,"%"," ");
	LET v_modelo = REPLACE(v_modelo,"&"," ");
	LET v_modelo = REPLACE(v_modelo,"^"," ");

	LET v_color = UPPER(v_color);
	LET v_color = REPLACE(v_color,"Á","A");
	LET v_color = REPLACE(v_color,"É","E");
	LET v_color = REPLACE(v_color,"Í","I");
	LET v_color = REPLACE(v_color,"Ó","O");
	LET v_color = REPLACE(v_color,"Ú","U");
	LET v_color = REPLACE(v_color,","," ");
	LET v_color = REPLACE(v_color,";"," ");
	LET v_color = REPLACE(v_color,"|"," ");
	LET v_color = REPLACE(v_color,"'"," ");
	LET v_color = REPLACE(v_color,"Ñ","N");
	LET v_color = REPLACE(v_color,"!'"," ");
	LET v_color = REPLACE(v_color,"$"," ");
	LET v_color = REPLACE(v_color,"%"," ");
	LET v_color = REPLACE(v_color,"&"," ");
	LET v_color = REPLACE(v_color,"^"," ");
	select nombre into _n_tipoveh from emitiveh
	where cod_tipoveh = _cod_tipoveh;
	
   RETURN   v_cedula, 
	        v_nombre,
			v_poliza,
			v_no_unidad,
			v_tarjeta, 		--5
			v_fechaaniv,	--6
			v_edad,			--7
			v_direccion,	--8
			v_e_mail,
			v_telefono,
			v_marca,
			v_modelo,
			v_placa,
			v_ano_auto,
			v_color,
			v_no_chasis,
			v_no_motor,
			v_uso_auto,
			v_asistencia,
			v_fechain,		--20
			v_fechaout, 	--21
			SUBSTRING(v_fecha_c from 1 for 2) || SUBSTRING(v_fecha_c from 4 for 2) || SUBSTRING(v_fecha_c from 7 for 4),
			"",
			"",
			"",
			"",
			"",
			"",
			_cod_tipoveh,
			_n_tipoveh,
			v_cod_producto,
			_n_producto
		   WITH RESUME;
END FOREACH 
DROP TABLE tmp_anconvig;
DROP TABLE tmp_prod_exc;
end procedure;