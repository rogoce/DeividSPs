-- Carta de Aviso de Cancelacion

-- Creado    : 02/10/2000 - Autor: Marquelda Valdelamar
-- Modificado: 06/11/2000
-- Modificado: 06/14/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/08/2004 - Autor: Armando Moreno argumento de callcenter
-- Modificado: 24/02/2005 --Autor: Armando Moreno tipo agente = especial no salga el nombre del corredor
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE "informix".sp_co20;

CREATE PROCEDURE "informix".sp_co20(
a_cod_cobrador  CHAR(3),
a_fecha         DATE,
a_tipo_aviso    INTEGER,
a_fecha_vence   DATE,
a_nombre_firma1 CHAR(50),
a_nombre_firma2 CHAR(50),
a_cargo1        CHAR(50),
a_cargo2        CHAR(50),
a_callcenter    INTEGER,
a_usuario1,     CHAR(10),
a_usuario2,     CHAR(10))

RETURNING CHAR(20),	     -- No_documento
		  CHAR(50),	     -- Nombre del cliente
		  CHAR(50),      -- Nombre del Acreedor
		  CHAR(50),	     -- Direccion_1
		  CHAR(50),	     -- Direccion_2
		  CHAR(20),      -- Apartado
		  DATE, 	     -- Vigencia Inicial
		  DATE, 	     -- Vigencia Final
		  DECIMAL(16,2), -- Saldo
		  DECIMAL(16,2), -- Prima
		  DECIMAL(16,2), -- exigible
		  DATE,   		 -- Fecha
		  DATE,          -- Fecha Vence
		  CHAR(50),      -- Nombre del Agente
		  CHAR(50),		 -- Nombre1
		  CHAR(50),		 -- Nombre2
		  CHAR(50),		 -- Cargo1
		  CHAR(50),		 -- Cargo2
		  CHAR(10),      -- telefono
		  CHAR(50),      -- nombre del ramo
		  CHAR(50),      -- nombre del subramo
		  CHAR(50),      -- direccion de cobros
		  CHAR(50),		 -- direccion de cobros 2
		  CHAR(20),		 -- cedula o ruc del cliente
		  CHAR(10),		 --	telefono1 del cliente
		  CHAR(10);		 --	telefono2 del cliente
		  			  		         
DEFINE _no_poliza  		  CHAR(10);
DEFINE _telefono  		  CHAR(10);
DEFINE _cod_cliente		  CHAR(10);
DEFINE _nombre_cliente    CHAR(50);
DEFINE _nombre_corredor   CHAR(50);
DEFINE _nombre_acreedor   CHAR(50);
DEFINE _direccion1		  CHAR(50);
DEFINE _direccion2        CHAR(50);
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final	  DATE;
DEFINE _cod_contratante   CHAR(10);
DEFINE _saldo	          DEC(16,2);
DEFINE _prima	          DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_subramo       CHAR(3);
DEFINE _nombre_subramo    CHAR(50);
DEFINE _nombre_ramo		  CHAR(50);
DEFINE _fecha_aviso       DATE;
DEFINE _apartado          CHAR(20);
DEFINE _ano               SMALLINT;
DEFINE _direccion_1_cob	  CHAR(50);
DEFINE _direccion_2_cob   CHAR(50);
DEFINE _cedula            CHAR(20);
DEFINE _cobra_poliza      CHAR(1);
DEFINE _cod_agente        CHAR(5);
DEFINE _tipo_agt		  CHAR(1);
DEFINE _telefono1  		  CHAR(10);
DEFINE _telefono2  		  CHAR(10);

CREATE TEMP TABLE tmp_carta(
	no_documento    CHAR(20),
	nombre_corredor CHAR(50),
	nombre_cliente  CHAR(50),
	nombre_acreedor CHAR(50),
	direccion1      CHAR(50),
	direccion2      CHAR(50),
	apartado        CHAR(20),
	vigencia_inic   DATE,
	vigencia_final  DATE,
	saldo		    DECIMAL(16,2),
	prima		    DECIMAL(16,2),
	exigible	    DECIMAL(16,2),
	ano             SMALLINT,
	telefono        CHAR(10),
	cod_cobrador    CHAR(3),
	nombre_ramo     CHAR(50),
	nombre_subramo  CHAR(50),
	direccion_1_cob CHAR(50),
	direccion_2_cob CHAR(50),
	cedula	        CHAR(20),
	telefono1       CHAR(10),
	telefono2       CHAR(10)
	) WITH NO LOG;   

SET ISOLATION TO DIRTY READ;

if a_callcenter = 0 then	--ejecutivas
FOREACH
 SELECT no_poliza,
        saldo,
		prima,
		exigible,
		nombre_agente,
		nombre_acreedor,
		ano,
		cod_agente
   INTO _no_poliza,
        _saldo,
		_prima,
		_exigible,
		_nombre_corredor,
		_nombre_acreedor,
		_ano,
		_cod_agente
   FROM cobaviso
  WHERE cod_cobrador = a_cod_cobrador 
    AND imprimir     = "1"
    AND impreso      = 0      	   	
    AND tipo_aviso   = a_tipo_aviso

 SELECT tipo_agente
   INTO _tipo_agt
   FROM agtagent
  WHERE cod_agente = _cod_agente;

 if _tipo_agt = "E" then
	let _nombre_corredor = " ";
 end if

	-- Actualiza la tabla de Avisos

    UPDATE cobaviso
  	   SET impreso   = 1
 	 WHERE no_poliza = _no_poliza;

	-- Actualizacion de Polizas

	IF   a_tipo_aviso = 4 THEN -- Carta de Recorderis

		UPDATE emipomae 
		   SET emipomae.carta_recorderis = 1,
			   emipomae.fecha_recorderis = a_fecha
		 WHERE emipomae.no_poliza        = _no_poliza;

	ELIF a_tipo_aviso = 1 THEN -- Aviso de Cancelacion

		UPDATE emipomae 
		   SET emipomae.carta_aviso_canc = 1,
			   emipomae.fecha_aviso_canc = a_fecha
		 WHERE emipomae.no_poliza        = _no_poliza;

	ELIF a_tipo_aviso = 2 THEN -- Carta de Prima Ganada

		UPDATE emipomae 
		   SET emipomae.carta_prima_gan	= 1,
			   emipomae.fecha_prima_gan = a_fecha
		 WHERE emipomae.no_poliza       = _no_poliza;

	ELSE                       -- Carta de Vencida con Saldo

		UPDATE emipomae 
		   SET emipomae.carta_vencida_sal = 1,
			   emipomae.fecha_vencida_sal = a_fecha
		 WHERE emipomae.no_poliza         = _no_poliza;
	END IF		

   --Seleccion de Campos de tabla de polizas

	SELECT vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   no_documento,
		   cod_ramo,
		   cod_subramo
      INTO _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante,
		   _no_documento,
		   _cod_ramo,
		   _cod_subramo
	 FROM emipomae
    WHERE no_poliza = _no_poliza;

    -- Ramo y Subramo
    SELECT nombre
	  INTO _nombre_ramo
      FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO _nombre_subramo
      FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	  -- Datos del Cobrador
    SELECT fecha_aviso,
		   cod_cobrador,
		   telefono
	  INTO _fecha_aviso,
	       _cod_cobrador,
		   _telefono
	 FROM  cobcobra
	 WHERE cod_cobrador = a_cod_cobrador;      	   	

	  -- Seleccion de Datos del Cliente
	SELECT nombre, 
	       direccion_1, 
	       direccion_2,
		   apartado,
		   cedula,
		   telefono1, 
		   telefono2 
	  INTO _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _apartado,
		   _cedula,
		   _telefono1, 
		   _telefono2 
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	 -- Direccion de Cobros
	SELECT direccion_1, 
	       direccion_2
	  INTO _direccion_1_cob,
		   _direccion_2_cob
	  FROM emidirco
	 WHERE no_poliza = _no_poliza;

	  --Insercion de Datos en la tabla Temporal

	 INSERT INTO tmp_carta(
	 no_documento,
	 nombre_corredor,
	 nombre_cliente,
	 nombre_acreedor,
	 direccion1,
	 direccion2,
	 apartado,
	 vigencia_inic,
	 vigencia_final,
	 saldo,
	 prima,
	 exigible,
	 ano,
	 telefono,
	 cod_cobrador,
	 nombre_ramo,
	 nombre_subramo,
	 direccion_1_cob,
	 direccion_2_cob,
	 cedula,
	 telefono1, 
	 telefono2 
	 )
	 VALUES(
	 _no_documento,
	 _nombre_corredor,
	 _nombre_cliente,
	 _nombre_acreedor,
	 _direccion1,
	 _direccion2,
	 _apartado,
	 _vigencia_inic,
	 _vigencia_final,
	 _saldo,
	 _prima,
	 _exigible,
	 _ano,
	 _telefono,
	 a_cod_cobrador,
	 _nombre_ramo,
	 _nombre_subramo,
	 _direccion_1_cob,
	 _direccion_2_cob,
	 _cedula,
	 _telefono1, 
	 _telefono2 
	 );

END FOREACH

else						--**************callcenter**************

FOREACH
 SELECT no_poliza,
        saldo,
		prima,
		exigible,
		nombre_agente,
		nombre_acreedor,
		ano,
		cod_cobrador,
		cobra_poliza,
		cod_cliente,
		cod_agente
   INTO _no_poliza,
        _saldo,
		_prima,
		_exigible,
		_nombre_corredor,
		_nombre_acreedor,
		_ano,
		a_cod_cobrador,
		_cobra_poliza,
		_cod_cliente,
		_cod_agente
   FROM cobaviso
  WHERE imprimir   = "1"
    AND impreso    = 0      	   	
    AND tipo_aviso = a_tipo_aviso

	if _cobra_poliza <> "E" then
		continue foreach;
	end if

 SELECT tipo_agente
   INTO _tipo_agt
   FROM agtagent
  WHERE cod_agente = _cod_agente;

 if _tipo_agt = "E" then
	let _nombre_corredor = " ";
 end if

	-- Actualiza la tabla de Avisos

    UPDATE cobaviso
  	   SET impreso   = 1
 	 WHERE no_poliza = _no_poliza;

	-- Actualizacion de Polizas

	IF   a_tipo_aviso = 4 THEN -- Carta de Recorderis

		UPDATE emipomae 
		   SET emipomae.carta_recorderis = 1,
			   emipomae.fecha_recorderis = a_fecha
		 WHERE emipomae.no_poliza        = _no_poliza;

	ELIF a_tipo_aviso = 1 THEN -- Aviso de Cancelacion

		UPDATE emipomae 
		   SET emipomae.carta_aviso_canc = 1,
			   emipomae.fecha_aviso_canc = a_fecha
		 WHERE emipomae.no_poliza        = _no_poliza;

	ELIF a_tipo_aviso = 2 THEN -- Carta de Prima Ganada

		UPDATE emipomae 
		   SET emipomae.carta_prima_gan	= 1,
			   emipomae.fecha_prima_gan = a_fecha
		 WHERE emipomae.no_poliza       = _no_poliza;

	ELSE                       -- Carta de Vencida con Saldo

		UPDATE emipomae 
		   SET emipomae.carta_vencida_sal = 1,
			   emipomae.fecha_vencida_sal = a_fecha
		 WHERE emipomae.no_poliza         = _no_poliza;
	END IF		

   --Seleccion de Campos de tabla de polizas

	SELECT vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   no_documento,
		   cod_ramo,
		   cod_subramo
      INTO _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante,
		   _no_documento,
		   _cod_ramo,
		   _cod_subramo
	 FROM emipomae
    WHERE no_poliza = _no_poliza;

    -- Ramo y Subramo
    SELECT nombre
	  INTO _nombre_ramo
      FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO _nombre_subramo
      FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	  -- Datos del Cobrador
    SELECT fecha_aviso,
		   cod_cobrador,
		   telefono
	  INTO _fecha_aviso,
	       _cod_cobrador,
		   _telefono
	 FROM  cobcobra
	 WHERE cod_cobrador = a_cod_cobrador;      	   	

	  -- Seleccion de Datos del Cliente
	SELECT nombre, 
	       direccion_1, 
	       direccion_2,
		   apartado,
		   cedula,
		   telefono1,
		   telefono2 
	  INTO _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _apartado,
		   _cedula,
		   _telefono1,
		   _telefono2 
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	if _telefono1 is null then
		SELECT telefono1
		  INTO _telefono1
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;
	end if
	if _telefono2 is null then
		SELECT telefono2
		  INTO _telefono2
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;
	end if

	 -- Direccion de Cobros

	SELECT direccion_1, 
	       direccion_2
	  INTO _direccion_1_cob,
		   _direccion_2_cob
	  FROM emidirco
	 WHERE no_poliza = _no_poliza;

	  --Insercion de Datos en la tabla Temporal

	 INSERT INTO tmp_carta(
	 no_documento,
	 nombre_corredor,
	 nombre_cliente,
	 nombre_acreedor,
	 direccion1,
	 direccion2,
	 apartado,
	 vigencia_inic,
	 vigencia_final,
	 saldo,
	 prima,
	 exigible,
	 ano,
	 telefono,
	 cod_cobrador,
	 nombre_ramo,
	 nombre_subramo,
	 direccion_1_cob,
	 direccion_2_cob,
	 cedula,
	 telefono1,
	 telefono2 
	 )
	 VALUES(
	 _no_documento,
	 _nombre_corredor,
	 _nombre_cliente,
	 _nombre_acreedor,
	 _direccion1,
	 _direccion2,
	 _apartado,
	 _vigencia_inic,
	 _vigencia_final,
	 _saldo,
	 _prima,
	 _exigible,
	 _ano,
	 _telefono,
	 a_cod_cobrador,
	 _nombre_ramo,
	 _nombre_subramo,
	 _direccion_1_cob,
	 _direccion_2_cob,
	 _cedula,
	 _telefono1,
	 _telefono2 
	 );

END FOREACH
end if
FOREACH WITH HOLD
   SELECT  	no_documento,
			nombre_corredor,
			nombre_cliente,
			nombre_acreedor,
			direccion1,
			direccion2,
			apartado,
			vigencia_inic,
			vigencia_final,
			saldo,
			prima,
			exigible,
			ano,
			telefono,
			cod_cobrador,
			nombre_ramo,
			nombre_subramo,
			direccion_1_cob,
	 		direccion_2_cob,
	 		cedula,
			telefono1,
			telefono2 
	INTO    _no_documento,
			_nombre_corredor,
			_nombre_cliente,
			_nombre_acreedor,
			_direccion1,
			_direccion2,
			_apartado,
			_vigencia_inic,
			_vigencia_final,
			_saldo,
			_prima,
			_exigible,
			_ano,
			_telefono,
			a_cod_cobrador,
			_nombre_ramo,
			_nombre_subramo,
			_direccion_1_cob,
			_direccion_2_cob,
	 		_cedula,
			_telefono1,
			_telefono2 
     FROM   tmp_carta
  ORDER BY  cod_cobrador, ano, nombre_corredor, nombre_cliente, no_documento

		RETURN 
		_no_documento,
		_nombre_cliente,
		_nombre_acreedor,
		_direccion1,
		_direccion2,
		_apartado,
		_vigencia_inic,
		_vigencia_final,
		_saldo,
		_prima,
		_exigible,
		a_fecha,
		a_fecha_vence,
		_nombre_corredor,
    	a_nombre_firma1, 
  		a_nombre_firma2, 
		a_cargo1,        
		a_cargo2,
		_telefono,
		_nombre_ramo,
		_nombre_subramo,
		_direccion_1_cob,
		_direccion_2_cob,
	 	_cedula,
		_telefono1,
		_telefono2 
		WITH RESUME;

END FOREACH

DROP TABLE tmp_carta;

END PROCEDURE;
