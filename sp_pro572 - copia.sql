-- Informaci¢n: para Panam  Asistencia Ramo Automovil -- Nuevo formato
-- Creado     : 02/10/2015 - Autor: Amado Perez


DROP PROCEDURE sp_pro572;
create procedure sp_pro572()

returning 
	VARCHAR(60) as aseg_primer_nom, -- Obligatorio - No sera obligatorio en caso de empresa
	VARCHAR(60) as aseg_segundo_nom, -- No requerido
	VARCHAR(60) as aseg_primer_ape, -- Obligatorio - No sera obligatorio en caso de empresa
	VARCHAR(60) as aseg_segundo_ape, -- No requerido
	VARCHAR(1) as tipo_ident,  -- Obligatorio - Solo valores 1,2,3  1:Panameño, 2:Extranjero, 3:Empresa
	VARCHAR(60) as ident_persona, -- Obligatorio - Cedula formato Tribunal Electoral 8-888-88 sin ceros a la izquierda en cada seccion o N° de Pasaporte
	VARCHAR(250) as ruc, -- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	VARCHAR(250) as nombre_empresa, -- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	VARCHAR(10) as fecha_nacimiento,  -- Requerido - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	VARCHAR(1) as genero,   -- Requerido - Solo valores 1, 2 1:Masculino, 2:Femenino
	VARCHAR(255) as nacionalidad, -- Requerido - No acepta números
	VARCHAR(125) as provincia, -- Requerido - No acepta números
	VARCHAR(125) as distrito, -- No requerido - No acepta números
	VARCHAR(125) as corregimiento, -- Requerido - No acepta números
	VARCHAR(125) as poblado, -- No requerido - No acepta números
	VARCHAR(255) as domicilio, -- Obligatorio - No será obligatorio en caso tal ser una empresa
	VARCHAR(15) as telefono,  -- Obligatorio - Celular, Teléfono Residencial o de Trabajo. No se requiere en caso de Empresas
	VARCHAR(255) as email, -- Requerido - El sistema validará el formato del mismo, por ejemplo cuenta@loquesea.com
	VARCHAR(1) as tipo_poliza,   -- Requerido - Solo valores 1,2,3 1:Comercial, 2:Particular, 3:Transporte Público
	VARCHAR(60) as cupo,  -- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	VARCHAR(2) as asientos,   -- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	VARCHAR(60) as poliza,  -- Obligatorio
	VARCHAR(10) as inicio_poliza,  -- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	VARCHAR(10) as fin_poliza,  -- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	VARCHAR(65) as marca,  -- Obligatorio
	VARCHAR(65) as modelo,  -- Obligatorio
	VARCHAR(6) as placa,   -- Obligatorio - Se validará con web services de ATTT
	VARCHAR(60) as motor,  -- Obligatorio
	VARCHAR(25) as vin,  -- Obligatorio - Vehicle Information Number
	VARCHAR(4) as ano_auto;   -- Obligatorio

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
DEFINE v_fechain		 CHAR(10);
DEFINE v_fechaout		 CHAR(10);
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
DEFINE v_ruc            VARCHAR(250);
DEFINE v_e_mail         VARCHAR(50);

DEFINE v_no_motor       VARCHAR(20);
DEFINE v_no_chasis      VARCHAR(25);
DEFINE _cod_cobertura   CHAR(5);

DEFINE _cod_subramo     CHAR(3);
DEFINE v_prima_bruta    DEC(16,2);
DEFINE _cod_ramo        CHAR(3);
DEFINE v_ramo           VARCHAR(50);
DEFINE _subramo         VARCHAR(50);
DEFINE v_fecha_aniversario DATE;
DEFINE v_fecha_aniversario_c CHAR(10);
DEFINE v_fechaaniv		 CHAR(10);

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

DEFINE _aseg_primer_nom  VARCHAR(60);
DEFINE _aseg_segundo_nom VARCHAR(60);
DEFINE _aseg_primer_ape  VARCHAR(60);
DEFINE _aseg_segundo_ape VARCHAR(60);
DEFINE _sexo             VARCHAR(1);
DEFINE _cod_origen       CHAR(3);
DEFINE _tipo_persona     CHAR(1);
DEFINE _code_pais        CHAR(3);
DEFINE _code_provincia   CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg      CHAR(2);
DEFINE _code_ciudad      CHAR(2);
DEFINE _e_mail           VARCHAR(50);
DEFINE _capacidad        VARCHAR(2);
DEFINE _cupo             VARCHAR(255);
DEFINE _tipo_ident       VARCHAR(1);
DEFINE _pasaporte        SMALLINT;
DEFINE _nacionalidad     VARCHAR(255);
DEFINE _provincia        VARCHAR(255);
DEFINE _corregimiento    VARCHAR(255);
DEFINE _poblado          VARCHAR(255);
DEFINE _distrito         VARCHAR(255);
DEFINE _domicilio        VARCHAR(255);
DEFINE _tipo_poliza      VARCHAR(1);
DEFINE _vin              VARCHAR(25);
define _error            smallint; 

CREATE TEMP TABLE sobat (
	aseg_primer_nom	 VARCHAR(60), -- Obligatorio - No sera obligatorio en caso de empresa
	aseg_segundo_nom VARCHAR(60), -- No requerido
	aseg_primer_ape  VARCHAR(60), -- Obligatorio - No sera obligatorio en caso de empresa
	aseg_segundo_ape VARCHAR(60), -- No requerido
	tipo_ident       VARCHAR(1),  -- Obligatorio - Solo valores 1,2,3  1:Panameño, 2:Extranjero, 3:Empresa
	ident_persona    VARCHAR(60), -- Obligatorio - Cedula formato Tribunal Electoral 8-888-88 sin ceros a la izquierda en cada seccion o N° de Pasaporte
	ruc              VARCHAR(250), -- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	nombre_empresa   VARCHAR(250), -- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	fecha_nacimiento VARCHAR(10),  -- Requerido - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	genero           VARCHAR(1),   -- Requerido - Solo valores 1, 2 1:Masculino, 2:Femenino
	nacionalidad     VARCHAR(255), -- Requerido - No acepta números
	provincia        VARCHAR(125), -- Requerido - No acepta números
	distrito         VARCHAR(125), -- No requerido - No acepta números
	corregimiento    VARCHAR(125), -- Requerido - No acepta números
	poblado          VARCHAR(125), -- No requerido - No acepta números
	domicilio        VARCHAR(255), -- Obligatorio - No será obligatorio en caso tal ser una empresa
	telefono         VARCHAR(15),  -- Obligatorio - Celular, Teléfono Residencial o de Trabajo. No se requiere en caso de Empresas
	email            VARCHAR(255), -- Requerido - El sistema validará el formato del mismo, por ejemplo cuenta@loquesea.com
	tipo_poliza      VARCHAR(1),   -- Requerido - Solo valores 1,2,3 1:Comercial, 2:Particular, 3:Transporte Público
	cupo             VARCHAR(60),  -- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	asientos         VARCHAR(2),   -- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	poliza           VARCHAR(60),  -- Obligatorio
	inicio_poliza    VARCHAR(10),  -- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	fin_poliza       VARCHAR(10),  -- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	marca            VARCHAR(65),  -- Obligatorio
	modelo           VARCHAR(65),  -- Obligatorio
	placa            VARCHAR(6),   -- Obligatorio - Se validará con web services de ATTT
	motor            VARCHAR(60),  -- Obligatorio
	vin              VARCHAR(25),  -- Obligatorio - Vehicle Information Number
	ano_auto         VARCHAR(4),   -- Obligatorio
	unidad           VARCHAR(10),
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

BEGIN

ON EXCEPTION SET _error
	set debug file to "sp_pro572.trc";
	trace on;
	
	let v_poliza = v_poliza;
	let v_no_unidad = v_no_unidad;		
    RETURN v_poliza,v_no_unidad,'','','','','','','','','','','','','','','','','','','','','','','','','','','','';	
END EXCEPTION

--SET DEBUG FILE TO "sp_pro572.trc";
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
		 b.aseg_primer_nom,
		 b.aseg_segundo_nom,
		 b.aseg_primer_ape,
		 b.aseg_segundo_ape,
		 b.sexo,
		 b.cod_origen,
		 b.tipo_persona,
		 b.cedula,
		 b.cedula,
		 b.fecha_aniversario,
		 b.direccion_1,
		 b.direccion_2,
		 b.telefono1,
		 b.telefono2,
		 b.telefono3,
		 b.celular,
		 b.code_pais,
		 b.code_provincia,
		 b.code_distrito,
		 b.code_correg,
		 b.code_ciudad,
		 b.e_mail,
		 b.pasaporte,
         g.no_unidad,
		 g.prima_bruta,
         f.uso_auto,
		 f.cod_tipoveh,
  		 e.ano_auto,
  		 e.placa,
		 e.no_motor,
		 e.no_chasis,
		 e.cod_color,
		 e.capacidad,
		 e.cupo,
		 e.vin
	INTO v_poliza,
		 _no_poliza,
		 v_vigencia_inic,
		 v_vigencia_final,
		 _cod_subramo,
		 _cod_ramo,
		 v_marca,
		 v_modelo,
		 v_nombre,
		 _aseg_primer_nom,
		 _aseg_segundo_nom,
		 _aseg_primer_ape,
		 _aseg_segundo_ape,
		 _sexo,
		 _cod_origen,
		 _tipo_persona,
		 v_cedula,
		 v_ruc,
		 v_fecha_aniversario,
		 _direccion_1,
		 _direccion_2,
		 _telefono1,
		 _telefono2,
		 _telefono3,
		 _celular,
		 _code_pais,
		 _code_provincia,
		 _code_distrito,
		 _code_correg,
		 _code_ciudad,
		 _e_mail,
		 _pasaporte,
		 v_no_unidad,
		 v_prima_bruta,
		 v_uso_auto,
		 _cod_tipoveh,
		 v_ano_auto,
		 v_placa,
		 v_no_motor,
		 v_no_chasis,
		 _cod_color,
		 _capacidad,
		 _cupo,
		 _vin
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.cod_contratante = b.cod_cliente
     AND a.no_poliza = g.no_poliza
     AND g.no_poliza = f.no_poliza
     AND g.no_unidad = f.no_unidad
     AND f.no_motor = e.no_motor
     AND e.cod_marca = c.cod_marca
     AND e.cod_marca = d.cod_marca
     AND e.cod_modelo = d.cod_modelo
     AND (a.cod_ramo in ('002','020','023') 
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND a.actualizado = 1
     AND a.estatus_poliza = 1)
--	 and a.no_documento = '2017-01539-09'
	 
	IF _pasaporte = 1 THEN
		LET _tipo_ident = '2';
	ELSE
	    IF _tipo_persona = "J" OR _tipo_persona = "G" THEN
			LET _tipo_ident = '3';
			LET _aseg_primer_nom = NULL;
			LET _aseg_segundo_nom = NULL;
			LET _aseg_primer_ape = NULL;
			LET _aseg_segundo_ape = NULL;		
			LET v_cedula = NULL;
		ELSE
			LET _tipo_ident = '1';
			LET v_nombre = NULL;
			LET v_ruc = NULL;
		END IF
	END IF
	
	IF _sexo = 'M' THEN
		LET _sexo = '1';
	ELSE
	    LET _sexo = '2';
	END IF

	SELECT gentilicio
	  INTO _nacionalidad
	  FROM genpais
	 WHERE code_pais = _code_pais;

	SELECT nombre
	  INTO _provincia
	  FROM genprov
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia;
	 
 	SELECT nombre
	  INTO _distrito
	  FROM gendtto
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad = _code_ciudad
	   AND code_distrito = _code_distrito;
	   
 {	SELECT nombre
	  INTO _corregimiento
	  FROM gencorr
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad = _code_ciudad
	   AND code_distrito = _code_distrito
	   AND code_correg = _code_correg;
}
 	SELECT nombre
	  INTO _corregimiento
	  FROM gencorr
	 WHERE code_correg = _code_correg;
	   
   SELECT nombre
     INTO _subramo
	 FROM prdsubra
	WHERE cod_ramo = _cod_ramo
	  AND cod_subramo = _cod_subramo;
	  
   IF _subramo like "PAR%" THEN
      LET _tipo_poliza = '2';
   ELIF _subramo like "COM%" THEN
       LET _tipo_poliza = '1';
   ELIF _subramo like "TRA%" THEN
       LET _tipo_poliza = '1';
   ELIF _subramo like "EMP%" THEN
	IF v_uso_auto = 'P' THEN
       LET _tipo_poliza = '2';
    ELSE 
       LET _tipo_poliza = '1';
	END IF   	   
   ELSE
       LET _tipo_poliza = '1';
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
 {   LET v_edad = "00";
	
	IF v_fecha_aniversario IS NOT NULL THEN
		let v_edad_s = sp_sis78(v_fecha_aniversario, _fecha_hoy);
		IF v_edad_s < 100 and  v_edad_s > 0 THEN
			LET v_edad = v_edad_s;
		END IF
	END IF
}
	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = "";
	END IF
	
	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = "";
	END IF
	
	LET _domicilio = TRIM(_direccion_1) || " " || TRIM(_direccion_2);
	
	LET _domicilio = TRIM(_domicilio);
	
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
	
    LET v_fecha_aniversario_c = v_fecha_aniversario;

	BEGIN

	ON EXCEPTION IN (-239)
		CONTINUE FOREACH;
	END EXCEPTION
	
	INSERT INTO sobat 
	(aseg_primer_nom,	-- Obligatorio - No sera obligatorio en caso de empresa
	aseg_segundo_nom, 	-- No requerido
	aseg_primer_ape, 	-- Obligatorio - No sera obligatorio en caso de empresa
	aseg_segundo_ape, 	-- No requerido
	tipo_ident,  		-- Obligatorio - Solo valores 1,2,3  1:Panameño, 2:Extranjero, 3:Empresa
	ident_persona, 		-- Obligatorio - Cedula formato Tribunal Electoral 8-888-88 sin ceros a la izquierda en cada seccion o N° de Pasaporte
	ruc, 				-- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	nombre_empresa, 	-- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
	fecha_nacimiento,  	-- Requerido - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	genero,   			-- Requerido - Solo valores 1, 2 1:Masculino, 2:Femenino
	nacionalidad, 		-- Requerido - No acepta números
	provincia, 			-- Requerido - No acepta números
	distrito, 			-- No requerido - No acepta números
	corregimiento, 		-- Requerido - No acepta números
	poblado, 			-- No requerido - No acepta números
	domicilio, 			-- Obligatorio - No será obligatorio en caso tal ser una empresa
	telefono,  			-- Obligatorio - Celular, Teléfono Residencial o de Trabajo. No se requiere en caso de Empresas
	email, 				-- Requerido - El sistema validará el formato del mismo, por ejemplo cuenta@loquesea.com
	tipo_poliza,   		-- Requerido - Solo valores 1,2,3 1:Comercial, 2:Particular, 3:Transporte Público
	cupo,  				-- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	asientos,   		-- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
	poliza,  			-- Obligatorio
	inicio_poliza,  	-- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	fin_poliza,  		-- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
	marca,  			-- Obligatorio
	modelo,  			-- Obligatorio
	placa,   			-- Obligatorio - Se validará con web services de ATTT
	motor,  			-- Obligatorio
	vin,  				-- Obligatorio - Vehicle Information Number
	ano_auto,   		-- Obligatorio
	unidad)
	VALUES (_aseg_primer_nom, 
	        _aseg_segundo_nom,
			_aseg_primer_ape,
			_aseg_segundo_ape,
			_tipo_ident,
			v_cedula,
			v_ruc,
			v_nombre,
			SUBSTRING(v_fecha_aniversario_c	from 7 for 4) || "-" || SUBSTRING(v_fecha_aniversario_c from 4 for 2) || "-" || SUBSTRING(v_fecha_aniversario_c from 1 for 2),
			_sexo,
			_nacionalidad,
			_provincia,
			_distrito,
			_corregimiento,
			"",
			_domicilio,
			v_telefono,
			_e_mail,
			_tipo_poliza,
			_cupo,
			_capacidad,
			v_poliza,
			SUBSTRING(v_vigencia_inic from 7 for 4) || "-" || SUBSTRING(v_vigencia_inic from 4 for 2) || "-" || SUBSTRING(v_vigencia_inic from 1 for 2),
			SUBSTRING(v_vigencia_final from 7 for 4) || "-" || SUBSTRING(v_vigencia_final from 4 for 2) || "-" || SUBSTRING(v_vigencia_final from 1 for 2), 
			TRIM(v_marca),
			TRIM(v_modelo),
			v_placa,
			v_no_motor,
			_vin,
			v_ano_auto,
			v_no_unidad);
	END
END FOREACH

FOREACH WITH HOLD
	SELECT 	aseg_primer_nom,	-- Obligatorio - No sera obligatorio en caso de empresa
			aseg_segundo_nom, 	-- No requerido
			aseg_primer_ape, 	-- Obligatorio - No sera obligatorio en caso de empresa
			aseg_segundo_ape, 	-- No requerido
			tipo_ident,  		-- Obligatorio - Solo valores 1,2,3  1:Panameño, 2:Extranjero, 3:Empresa
			ident_persona, 		-- Obligatorio - Cedula formato Tribunal Electoral 8-888-88 sin ceros a la izquierda en cada seccion o N° de Pasaporte
			ruc, 				-- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
			nombre_empresa, 	-- Obligatorio - Es obligatorio en caso de tipo de identificacion 3
			fecha_nacimiento,  	-- Requerido - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
			genero,   			-- Requerido - Solo valores 1, 2 1:Masculino, 2:Femenino
			nacionalidad, 		-- Requerido - No acepta números
			provincia, 			-- Requerido - No acepta números
			distrito, 			-- No requerido - No acepta números
			corregimiento, 		-- Requerido - No acepta números
			poblado, 			-- No requerido - No acepta números
			domicilio, 			-- Obligatorio - No será obligatorio en caso tal ser una empresa
			telefono,  			-- Obligatorio - Celular, Teléfono Residencial o de Trabajo. No se requiere en caso de Empresas
			email, 				-- Requerido - El sistema validará el formato del mismo, por ejemplo cuenta@loquesea.com
			tipo_poliza,   		-- Requerido - Solo valores 1,2,3 1:Comercial, 2:Particular, 3:Transporte Público
			cupo,  				-- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
			asientos,   		-- Requerido - Requerido para tipo póliza 3 se debe colocar este valor
			poliza,  			-- Obligatorio
			inicio_poliza,  	-- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
			fin_poliza,  		-- Obligatorio - Formato: YYY-MM-DD (Año, mes y día) por ejemplo 1986-06-14
			marca,  			-- Obligatorio
			modelo,  			-- Obligatorio
			placa,   			-- Obligatorio - Se validará con web services de ATTT
			motor,  			-- Obligatorio
			vin,  				-- Obligatorio - Vehicle Information Number
			ano_auto   		-- Obligatorio
     INTO	_aseg_primer_nom, 
	        _aseg_segundo_nom,
			_aseg_primer_ape,
			_aseg_segundo_ape,
			_tipo_ident,
			v_cedula,
			v_ruc,
			v_nombre,
			v_fechaaniv,
			_sexo,
			_nacionalidad,
			_provincia,
			_distrito,
			_corregimiento,
			_poblado,
			_domicilio,
			v_telefono,
			_e_mail,
			_tipo_poliza,
			_cupo,
			_capacidad,
			v_poliza,
			v_fechain,
			v_fechaout, 
			v_marca,
			v_modelo,
			v_placa,
			v_no_motor,
			_vin,
			v_ano_auto
	   from sobat		

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

	LET _aseg_primer_nom = UPPER(_aseg_primer_nom);
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Á","A");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"É","E");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Í","I");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ó","O");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ú","U");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,","," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,";"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"|"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"'"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ñ","N");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"!'"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"$"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"%"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"&"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"^"," ");
	
	LET _aseg_segundo_nom = UPPER(_aseg_segundo_nom);
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Á","A");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"É","E");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Í","I");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ó","O");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ú","U");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,","," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,";"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"|"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"'"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ñ","N");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"!'"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"$"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"%"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"&"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"^"," ");
	
	LET _aseg_primer_ape = UPPER(_aseg_primer_ape);
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Á","A");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"É","E");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Í","I");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ó","O");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ú","U");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,","," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,";"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"|"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"'"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ñ","N");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"!'"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"$"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"%"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"&"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"^"," ");

	LET _aseg_segundo_ape = UPPER(_aseg_segundo_ape);
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Á","A");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"É","E");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Í","I");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ó","O");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ú","U");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,","," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,";"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"|"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"'"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ñ","N");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"!'"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"$"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"%"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"&"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"^"," ");

	LET _domicilio = UPPER(_domicilio);
	LET _domicilio = REPLACE(_domicilio,"Á","A");
	LET _domicilio = REPLACE(_domicilio,"É","E");
	LET _domicilio = REPLACE(_domicilio,"Í","I");
	LET _domicilio = REPLACE(_domicilio,"Ó","O");
	LET _domicilio = REPLACE(_domicilio,"Ú","U");
	LET _domicilio = REPLACE(_domicilio,","," ");
	LET _domicilio = REPLACE(_domicilio,";"," ");
	LET _domicilio = REPLACE(_domicilio,"|"," ");
	LET _domicilio = REPLACE(_domicilio,"'"," ");
	LET _domicilio = REPLACE(_domicilio,"Ñ","N");
	LET _domicilio = REPLACE(_domicilio,"!'"," ");
	LET _domicilio = REPLACE(_domicilio,"$"," ");
	LET _domicilio = REPLACE(_domicilio,"%"," ");
	LET _domicilio = REPLACE(_domicilio,"&"," ");
	LET _domicilio = REPLACE(_domicilio,"^"," ");

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
	
   RETURN   _aseg_primer_nom, 
	        _aseg_segundo_nom,
			_aseg_primer_ape,
			_aseg_segundo_ape,
			_tipo_ident,
			v_cedula,
			v_ruc,
			v_nombre,
			v_fechaaniv,
			_sexo,
			_nacionalidad,
			_provincia,
			_distrito,
			_corregimiento,
			_poblado,
			_domicilio,
			v_telefono,
			_e_mail,
			_tipo_poliza,
			_cupo,
			_capacidad,
			v_poliza,
			v_fechain,
			v_fechaout, 
			v_marca,
			v_modelo,
			v_placa,
			v_no_motor,
			_vin,
			v_ano_auto
		   WITH RESUME;
END FOREACH 

DROP TABLE sobat;

END

end procedure;