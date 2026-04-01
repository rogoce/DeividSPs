-- Carta de Cancelacion de poliza
-- Creado  : 28/01/2015  Autor: Jaime Chevalier
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE sp_cob_carta_cancel;

CREATE PROCEDURE sp_cob_carta_cancel(a_poliza CHAR(10))
RETURNING  CHAR(20),     	--No_Documento
           CHAR(50),     	--Nombre cliente
           CHAR(50),     	--Direccion1
           CHAR(50),     	--Direccion2
           CHAR(20),     	--Apartado
           CHAR(50),     	--Nombre ramo
           CHAR(50),     	--Nombre subramo	
           CHAR(10),     	--Telefono1		   
           CHAR(10),     	--Telefono2
		   CHAR(50),     	--Email
		   DECIMAL(16,2), 	--Monto pendiente
		   DECIMAL(16,2), 	--prima
		   DATE,          	--Vigencia inicial
		   DATE,          	--Vigencia final
           CHAR(50),        --Nombre corredor
		   CHAR(255);       --Nombre acreedor
		   
		   
DEFINE _cod_contratante   CHAR(10);
DEFINE _no_documento      CHAR(20);
DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_subramo       CHAR(3);
DEFINE _nombre_subramo    CHAR(50);
DEFINE _nombre_ramo		  CHAR(50);
DEFINE _nombre_cliente    CHAR(50);
DEFINE _direccion1		  CHAR(50);
DEFINE _direccion2        CHAR(50);
DEFINE _telefono1  		  CHAR(10);
DEFINE _telefono2  		  CHAR(10);
DEFINE _apartado          CHAR(20);
DEFINE _e_mail  		  CHAR(50);
DEFINE _cod_agente        CHAR(5);
DEFINE _nombre_corredor   CHAR(50);
DEFINE _cod_acreedor      CHAR(5);
DEFINE _nombre_acreedor   CHAR(255);
DEFINE _monto_pend        DECIMAL(16,2);
DEFINE _prima             DECIMAL(16,2);

DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final	  DATE;

CREATE TEMP TABLE tmp_carta(
	no_documento    CHAR(20),
	nombre_cliente  CHAR(50),
	direccion1      CHAR(50),
	direccion2      CHAR(50),
	apartado        CHAR(20),
	nombre_ramo     CHAR(50),
	nombre_subramo  CHAR(50),
	telefono1       CHAR(10),
	telefono2       CHAR(10),
	e_mail          CHAR(50),
	monto_pend      DECIMAL(16,2),
	prima           DECIMAL(16,2),
	vigencia_inic   DATE,
	vigencia_final  DATE,
	nombre_corredor CHAR(50),
	nombre_acreedor CHAR(255)
	) WITH NO LOG;

FOREACH
    -- Busca los datos del cliente
	SELECT  cod_contratante,
			no_documento,
			cod_ramo,
			cod_subramo,
			vigencia_inic,
			vigencia_final
	  INTO  _cod_contratante,
			_no_documento,
			_cod_ramo,
			_cod_subramo,
			_vigencia_inic,
			_vigencia_final
	 FROM emipomae
	WHERE no_poliza = a_poliza

	SELECT nombre,
 		   direccion_1,
		   direccion_2,
		   apartado,
		   telefono1,
		   telefono2,
		   e_mail
	  INTO _nombre_cliente,
		   _direccion1,
		   _direccion2,
		   _apartado,
		   _telefono1,
		   _telefono2,
		   _e_mail
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;
  
	  --Busca el nombre del ramo
	  SELECT nombre
		INTO _nombre_ramo
		FROM prdramo
	   WHERE cod_ramo = _cod_ramo;

	  --Busca el nombre del subramo
	  SELECT nombre
		INTO _nombre_subramo
		FROM prdsubra
	   WHERE cod_ramo    = _cod_ramo
		 AND cod_subramo = _cod_subramo;
		
	  SELECT cod_agente
	    INTO _cod_agente
        FROM emipoagt
       WHERE no_poliza = a_poliza;
	   
	   SELECT nombre 
	     INTO _nombre_corredor
	   FROM agtagent
       WHERE cod_agente = _cod_agente;
	
	--  Busca el Acreedor 	 
	  SELECT cod_acreedor 
	    INTO _cod_acreedor 
	   FROM  emipoacr
       WHERE no_poliza  = a_poliza;

     SELECT nombre
	   INTO _nombre_acreedor
       FROM emiacre
      WHERE cod_acreedor = _cod_acreedor;

	  SELECT SUM (monto_pen)
		INTO _monto_pend
		FROM emiletra
		WHERE no_poliza = a_poliza
		and pagada = 0
		and periodo_gracia < today;
		
	   SELECT SUM (monto_letra)
		 INTO _prima
		 FROM emiletra
		WHERE no_poliza = a_poliza;
		
	INSERT INTO tmp_carta(
		 no_documento,
		 nombre_cliente,
		 direccion1,
		 direccion2,
		 apartado,
		 nombre_ramo,
		 nombre_subramo,
		 telefono1,
		 telefono2,
		 e_mail,
		 monto_pend,
		 prima,
		 vigencia_inic,
		 vigencia_final,
		 nombre_corredor,
		 nombre_acreedor)
	 VALUES(
		 _no_documento,
		 _nombre_cliente,
		 _direccion1,
		 _direccion2,
		 _apartado,
		 _nombre_ramo,
		 _nombre_subramo,
		 _telefono1,
		 _telefono2,
		 _e_mail,
		 _monto_pend,
		 _prima,
		 _vigencia_inic,
		 _vigencia_final,
		 _nombre_corredor,
		 _nombre_acreedor);		
END FOREACH

FOREACH WITH HOLD
	SELECT  no_documento,
			nombre_cliente,
			direccion1,
			direccion2,
			apartado,
			nombre_ramo,
			nombre_subramo,
			telefono1,
			telefono2,
			e_mail,
			monto_pend,
			prima,
			vigencia_inic,
			vigencia_final,
			nombre_corredor,
			nombre_acreedor
	INTO    _no_documento,
			_nombre_cliente,
			_direccion1,
			_direccion2,
			_apartado,
			_nombre_ramo,
			_nombre_subramo,
			_telefono1,
			_telefono2,
			_e_mail,
			_monto_pend,
			_prima,
			_vigencia_inic,
			_vigencia_final,
			_nombre_corredor,
			_nombre_acreedor
     FROM   tmp_carta
	 
    RETURN
		_no_documento,
		_nombre_cliente,
		_direccion1,
		_direccion2,
		_apartado,
		_nombre_ramo,
		_nombre_subramo,	
		_telefono1,
		_telefono2,
		_e_mail,
		_monto_pend,
		_prima,
		_vigencia_inic,
		_vigencia_final,
		_nombre_corredor,
		_nombre_acreedor
	WITH RESUME;
	
END FOREACH
DROP TABLE tmp_carta;
END PROCEDURE;