-- Carta de Aviso de Cancelacion Automatica 
-- Creado  : 19/08/2010  Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE sp_cob750;
CREATE PROCEDURE sp_cob750(a_aviso CHAR(15), a_poliza CHAR(10),a_nombre_firma1 CHAR(50),a_nombre_firma2 CHAR(50),a_cargo1 CHAR(50),a_cargo2 CHAR(50),a_callcenter INTEGER,a_usuario1 CHAR(10),a_usuario2 CHAR(10))
RETURNING CHAR(20),	      -- No_documento
		  CHAR(100),	  -- Nombre del cliente
		  CHAR(255),      -- Nombre del Acreedor
		  CHAR(50),	      -- Direccion_1
		  CHAR(50),	      -- Direccion_2
		  CHAR(20),       -- Apartado
		  DATE, 	      -- Vigencia Inicial
		  DATE, 	      -- Vigencia Final
		  DECIMAL(16,2),  -- Saldo
		  DECIMAL(16,2),  -- Prima
		  DECIMAL(16,2),  -- exigible
		  DATE,   		  -- Fecha
		  DATE,           -- Fecha Vence
		  CHAR(50),       -- Nombre del Agente
		  CHAR(50),		  -- Nombre1
		  CHAR(50),		  -- Nombre2
		  CHAR(50),		  -- Cargo1
		  CHAR(50),		  -- Cargo2
		  CHAR(10),       -- telefono
		  CHAR(50),       -- nombre del ramo
		  CHAR(50),       -- nombre del subramo
		  CHAR(50),       -- direccion de cobros
		  CHAR(50),		  -- direccion de cobros 2
		  CHAR(20),		  -- cedula o ruc del cliente
		  CHAR(10),		  --   telefono1 del cliente
		  CHAR(10),		  --   telefono2 del cliente
		  CHAR(10),		  -- Usuario 1
		  CHAR(10),		  -- Usuario 2
		  CHAR(50),		  -- Nombre_zona 
		  CHAR(50),		  -- Nombre_forpag 
		  CHAR(50),       -- Email
		  CHAR(50),       --Nombre estafeta
          CHAR(4),CHAR(50);   --Cod Estafeta
		  
DEFINE _no_poliza  		  CHAR(10);
DEFINE _telefono  		  CHAR(10);
DEFINE _cod_cliente		  CHAR(10);
DEFINE _nombre_cliente    CHAR(50);
DEFINE _nombre_corredor   CHAR(50);
DEFINE _nombre_acreedor   CHAR(255);
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
DEFINE _n_acreedor		  CHAR(255);
define _nn_acree          CHAR(50);
define _nn                INTEGER;
define _cade              CHAR(1);
DEFINE _leasing           SMALLINT;
DEFINE _fecha_can         DATE;
DEFINE _fecha             DATE;
DEFINE _fecha_vence       DATE;
DEFINE _nombre_zona       CHAR(50);
DEFINE _nombre_forpag     CHAR(50);
DEFINE _cod_formapag      CHAR(3);
DEFINE _e_mail  		  CHAR(50);

DEFINE _fecha_actual	   date;
DEFINE _mes_char		   char(2);
DEFINE _ano_char		   char(4);
DEFINE _periodo_c		   CHAR(7);
DEFINE _saldo_c   		   DECIMAL(16,2);
DEFINE _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);
DEFINE _cod_estafeta       CHAR(4);
DEFINE _nombre_estafeta    CHAR(50);
DEFINE _cadena_fecha       CHAR(50);

let _nombre_acreedor = "";
let _n_acreedor      = "";
let _nn_acree        = "";
let _cod_formapag    = "";
let _cadena_fecha    = "";


CREATE TEMP TABLE tmp_carta(
	no_documento    CHAR(20),
	nombre_corredor CHAR(50),	
	nombre_cliente  CHAR(50),
	nombre_acreedor CHAR(255),
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
	telefono2       CHAR(10),
	nombre_zona     CHAR(50),
	nombre_forpag   CHAR(50),
	e_mail          CHAR(50),
	nombre_estafeta CHAR(50),
	cod_estafeta    CHAR(4)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

let _fecha_actual = sp_sis26() ;
 
IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

 
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
		cod_contratante,
		cod_agente,
		fecha_proceso,
		fecha_vence,
		cod_formapag  
   INTO _no_poliza,
        _saldo,
		_prima,
		_exigible,
		_nombre_corredor,
		_nombre_acreedor,
		_ano,
		_cod_cobrador,
		_cobra_poliza,
		_cod_cliente,
		_cod_agente,
		_fecha,
		_fecha_can,
		_cod_formapag  
   FROM avisocanc
  WHERE no_aviso  = a_aviso
    AND no_poliza = a_poliza
	AND impreso    = 0

   {	 if _cobra_poliza <> "E" then
		continue foreach;
	end if}
	
	if _saldo <= 0 then   -- Adicionado por Henry solicitud de usuario: ENILDA 02/07/2016 
		continue foreach;
	end if

 SELECT tipo_agente
   INTO _tipo_agt
   FROM agtagent
  WHERE cod_agente = _cod_agente;

     if _tipo_agt = "E" then
	    let _nombre_corredor = " ";
    end if

   --Seleccion de Campos de tabla de polizas

	SELECT vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   no_documento,
		   cod_ramo,
		   cod_subramo,
		   leasing
      INTO _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante,
		   _no_documento,
		   _cod_ramo,
		   _cod_subramo,
		   _leasing
	 FROM emipomae
    WHERE no_poliza = _no_poliza;

	let _n_acreedor = '';

		select count(distinct n.nombre)
		  into _nn
		  from emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza;

	if _nn > 1 then
		let _cade = ", ";
	else
		let _cade = "";
	end if

	foreach
		select distinct n.nombre
		  into _nn_acree
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza

		let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

	end foreach

	if _nn > 1 then
	   let _n_acreedor[1,1] = "";
	end if

    if _n_acreedor is null or trim(_n_acreedor) = "" then
		let _n_acreedor = '';
	end if

    if _leasing = 1 then   -- Cuando la poliza es leasing el acreedor se busca en la unidad Caso 06731
			select count(distinct n.nombre)
			  into _nn
			  from  emipouni e, cliclien n
			 where e.cod_asegurado = n.cod_cliente
			   and e.no_poliza = _no_poliza;

		if _nn > 1 then
			let _cade = ", ";
		else
			let _cade = "";
		end if

		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipouni e, cliclien n
			 where e.cod_asegurado = n.cod_cliente
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if
	end if

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
	 WHERE cod_cobrador = _cod_cobrador;

	  -- Seleccion de Datos del Cliente
	SELECT nombre,
	       direccion_1,
	       direccion_2,
		   apartado,
		   cedula,
		   telefono1,
		   telefono2,
		   e_mail
	  INTO _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _apartado,
		   _cedula,
		   _telefono1,
		   _telefono2,
		   _e_mail
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
	
	--Buscar el codigo de estafeta
	SELECT cod_estafeta 
	  INTO _cod_estafeta
	  FROM cliclien 
	 WHERE cod_cliente = _cod_contratante;
	 
	 SELECT nombre 
	   INTO _nombre_estafeta
	   FROM cobestafeta
      WHERE cod_estafeta = _cod_estafeta;
	
	 -- Direccion de Cobros

	SELECT direccion_1,
	       direccion_2
	  INTO _direccion_1_cob,
		   _direccion_2_cob
	  FROM emidirco
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_zona
	  FROM cobcobra 
	 WHERE cod_cobrador = _cod_cobrador;

    SELECT nombre
      INTO _nombre_forpag
      FROM cobforpa 
     WHERE cod_formapag = _cod_formapag;

   	  CALL sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
		   RETURNING _por_vencer_c,	   
		   _exigible_c,	   
		   _corriente_c,	   
		   _dias_30_c,	   
		   _dias_60_c,	   
		   _dias_90_c,	   
		   _dias_120_c,	   
		   _dias_150_c,	   
		   _dias_180_c,	   
		   _saldo_c;	   

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
	 telefono2,
	 nombre_zona,
	 nombre_forpag,
     e_mail,
     nombre_estafeta,
     cod_estafeta	 )
	 VALUES(
	 _no_documento,
	 _nombre_corredor,
	 _nombre_cliente,
	 _n_acreedor,
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
	 _cod_cobrador,
	 _nombre_ramo,
	 _nombre_subramo,
	 _direccion_1_cob,
	 _direccion_2_cob,
	 _cedula,
	 _telefono1,
	 _telefono2,
	 _nombre_zona,
	 _nombre_forpag,
	 _e_mail,
     _nombre_estafeta,
     _cod_estafeta	 );

	{
	-- Actualiza la tabla de Avisos

    UPDATE avisocanc
  	   SET impreso   = 1
 	 WHERE no_aviso  = a_aviso
 	   AND no_poliza = a_poliza;

	-- Actualizacion de Polizas                            --  Aviso de Cancelacion
		UPDATE emipomae
		   SET emipomae.carta_aviso_canc = 1,
			   emipomae.fecha_aviso_canc = _fecha_can	   --  Fecha de Hoy
		 WHERE emipomae.no_poliza        = a_poliza;
		 }

		LET _fecha_vence =  _fecha_can;

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
	 		cedula,
			telefono1,
			telefono2,
			nombre_zona,
	        nombre_forpag,
			e_mail,
			nombre_estafeta,
			_cod_estafeta
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
			_cod_cobrador,
			_nombre_ramo,
			_nombre_subramo,
			_direccion_1_cob,
			_direccion_2_cob,
	 		_cedula,
			_telefono1,
			_telefono2,
			_nombre_zona,
	        _nombre_forpag,
			_e_mail,
            _nombre_estafeta,
            _cod_estafeta			
     FROM   tmp_carta
  ORDER BY  cod_cobrador, ano, nombre_corredor, nombre_cliente, no_documento

		 let _nombre_acreedor = trim(_nombre_acreedor);
         let _cadena_fecha = sp_cob774(_fecha);
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
		_fecha,
		_fecha_vence,
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
		_telefono2,
		a_usuario1,
		a_usuario2,
		_nombre_zona,
        _nombre_forpag,
		_e_mail,
		_nombre_estafeta,
		_cod_estafeta, _cadena_fecha
		WITH RESUME;

END FOREACH

DROP TABLE tmp_carta;

END PROCEDURE
