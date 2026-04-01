-- Carta de Aviso de Cancelacion desde callcenter

-- Creado    : 06/01/2004 - Autor: Armando Moreno M.
-- Modificado: 06/01/2004

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE "informix".sp_cob20b;

CREATE PROCEDURE "informix".sp_cob20b(
a_cod_cobrador  CHAR(3), 
a_fecha         DATE,    
a_fecha_vence   DATE,    
a_nombre_firma1 CHAR(50),
a_nombre_firma2 CHAR(50),
a_cargo1        CHAR(50),
a_cargo2        CHAR(50))

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
		  CHAR(20);		 -- cedula o ruc del cliente
		  			  		         
DEFINE _no_poliza  		  CHAR(10);
DEFINE _telefono  		  CHAR(10);
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

SET ISOLATION TO DIRTY READ;

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
	cedula	        CHAR(20)
	) WITH NO LOG;   

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

	-- Actualizacion de Polizas

	   {UPDATE emipomae 
		   SET emipomae.carta_aviso_canc = 1,
			   emipomae.fecha_aviso_canc = a_fecha
		 WHERE emipomae.no_poliza        = _no_poliza;}

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
	 	_cedula
		WITH RESUME;

END FOREACH

DROP TABLE tmp_carta;

END PROCEDURE;