-- Carta declarativa de salud

-- Creado    : 26/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE "informix".sp_cob135;

CREATE PROCEDURE "informix".sp_cob135(
a_ano		    CHAR(4),
a_nombre_firma1 CHAR(50),
a_cargo1        CHAR(50))

RETURNING CHAR(20),	     -- No_documento
		  CHAR(100),     -- Pagador
		  DATE, 	     -- Vigencia Inicial
		  DATE, 	     -- Vigencia Final
		  DECIMAL(16,2), -- Saldo
		  CHAR(50),		 -- Nombre1
		  CHAR(50),		 -- Cargo1
		  CHAR(20),		 -- cedula o ruc del cliente
		  CHAR(100), 	 -- Asegurado
		  SMALLINT;		 -- FLAG
		  			  		         
DEFINE _no_poliza  		  CHAR(10);
DEFINE _nombre_cliente    CHAR(100);
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final	  DATE;
DEFINE _cod_contratante   CHAR(10);
DEFINE _saldo	          DEC(16,2);
DEFINE _cedula            CHAR(20);
DEFINE _flag              smallint;

SET ISOLATION TO DIRTY READ;

let _flag = 0;

FOREACH
 SELECT no_poliza,
        saldo,
		prima,
		exigible,
		nombre_agente,
		nombre_acreedor,
		ano
   INTO _no_poliza,
        _saldo,
		_prima,
		_exigible,
		_nombre_corredor,
		_nombre_acreedor,
		_ano
   FROM cobaviso
  WHERE cod_cobrador = a_cod_cobrador 
    AND imprimir     = "1"
    AND impreso      = 0      	   	
    AND tipo_aviso   = a_tipo_aviso

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
    SELECT nombre,
		   ramo_sis	
	  INTO _nombre_ramo,
		   _ramo_sis
      FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	if _ramo_sis <> 5 then
		let _flag = 1;
	end if

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
		   cedula
	  INTO _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _apartado,
		   _cedula
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
	 cedula
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
	 _cedula
	 );

END FOREACH

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
	 		cedula
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
	 		_cedula
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
		_flag
		WITH RESUME;

END FOREACH

DROP TABLE tmp_carta;

END PROCEDURE;