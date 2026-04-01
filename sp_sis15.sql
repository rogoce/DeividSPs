-- Procedimiento que Genera el Numero de Cuenta

-- Creado    : 25/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

-- Los Tipos de Dato Explican que Informacion se Esta Enviando
-- con la Intercta

-- '01' - Polizas
-- '02' - Bancos
-- '03' - Corredor

-- Los Valore Posibles de las Interctas Son
--
-- PGCOMCO      GASTO DE COMISION DE CORREDORES                   
-- PGI1%A       IMPUESTO 1% DE AUTOMOVIL GASTO                    
-- PGI2%P       IMPUESTO 2% SOBRE PRIMA GASTO PARA EL GOBIERNO    
-- PGI5%B       IMPUESTO DE 5% PARA LOS BOMBEROS GASTO            
-- PIPSRA       PRIMA SUSCRITA REASEGURO ASUMIDO                  
-- PIPSSD       PRIMA SUSCRITA SEGURO DIRECTO                     
-- PP5%C        IMPUESTO 5% CLIENTE DE PRIMA POR PAGAR            
-- PPCOMXPCO    COMISION POR PAGAR CORREDORES                     
-- PPI1%A       IMPUESTO 1% DE AUTOMOVIL POR PAGAR                
-- PPI2%P       IMPUESTO 2% SOBRE PRIMA POR PAGAR DEL GOBIERNO    
-- PPI5%B       IMPUESTO 5% PARA LOS BOMBEROS POR BAGAR           
-- PPPDSD       PRIMA DIFERIDA SEGURO DIRECTO                     
-- SISAL        INGRESO POR SALVAMENTO                            
-- SIREC        INGRESO POR RECUPERO                              
-- CPCPES       CREAR PRIMA EN SUSTENSO                           
-- CPAPES       APLICAR PRIMA EN SUSPENSO                         
-- SGPDDSD      PAGO DE DEDUCIBLE SEGURO DIRECTO                  
-- SGPDDRA      PAGO DE DEDUCIBLE REASEGURO ASUMIDO               
-- SARXCC       RECLAMOS X COBRAR COASEGURADORES                  
-- BACHEBL      CHEQUERA BANCOS LOCALES                           
-- BACHEBE      CHEQUERA BANCOS EXTRANJEROS                       
-- BCXPP        CUENTAS POR PAGAR PROVEEDORES                     
-- PAPXCSD      PRIMAS POR COBRAR SEGURO DIRECTO                  
-- PAPXCRA		PRIMAS POR COBRAR REASEGURO ASUMIDO
-- PG5%C        IMPUESTO 5% DE PRIMA CLIENTE GASTO                
-- PACXCC       CUENTAS POR COBRAR EN COASEGURO                   
-- SGSINPAG     SINIESTROS PAGADOS                                
-- BCXPPV       POR PAGAR PROVEEDORES VIEJOS                      

DROP PROCEDURE sp_sis15;

CREATE PROCEDURE sp_sis15(
a_cod_intercta CHAR(10),
a_tipo_dato    CHAR(2)  DEFAULT '*',
a_codigo_ref   CHAR(50) DEFAULT '*',
a_codigo_ref2  CHAR(50)	DEFAULT '*',
a_codigo_ref3  CHAR(50)	DEFAULT '*',
a_codigo_ref4  CHAR(50)	DEFAULT '*',
a_codigo_ref5  CHAR(50)	DEFAULT '*'
) RETURNING CHAR(25);

DEFINE v_cuenta CHAR(25);

DEFINE _renglon		SMALLINT;
DEFINE _cod_enlace 	CHAR(2);
DEFINE _tamano		SMALLINT;
DEFINE _tipo_enlace CHAR(2);
DEFINE _enlace      CHAR(10);

-- Variables del Auxiliar

DEFINE _cod_banco    		CHAR(3);
DEFINE _cod_ramo     		CHAR(3);
DEFINE _cod_subramo  		CHAR(3);
DEFINE _cod_tiporamo 		CHAR(3);
DEFINE _cod_tipoprod 		CHAR(3);
DEFINE _cod_cliente  		CHAR(10);
DEFINE _cod_origen_poliza	CHAR(3);
DEFINE _cod_origen_asegur	CHAR(3);
DEFINE _cod_origen_cliente	CHAR(3);
define _cod_chequera		CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_sis15.trc";
--TRACE ON;

-- Se Determinan las Variables a Utilizar
-- para Cargar las subcuentas

IF a_tipo_dato = '01' THEN -- Polizas

	SELECT cod_ramo,
		   cod_subramo,
		   cod_tipoprod,
		   cod_contratante,
		   cod_origen
	  INTO _cod_ramo,
		   _cod_subramo,	
		   _cod_tipoprod,
		   _cod_cliente,
		   _cod_origen_poliza	
	  FROM emipomae
	 WHERE no_poliza = a_codigo_ref;

	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

ELIF  a_tipo_dato = '02' THEN -- Bancos
	
	SELECT cod_banco
	  INTO _cod_banco
	  FROM chqbanco
	 WHERE cod_banco = a_codigo_ref;

	if a_codigo_ref2 <> '*' then
		let _cod_chequera = trim(a_codigo_ref2);
	end if

ELIF  a_tipo_dato = '03' THEN -- No Lleva Enlace

	-- Sin programacion

ELIF  a_tipo_dato = '04' THEN -- Usar Referencias (Origen, Ramo, Subramo)

	let _cod_origen_poliza = trim(a_codigo_ref);
	let _cod_ramo          = trim(a_codigo_ref2);
	let _cod_subramo       = trim(a_codigo_ref3);

	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

ELIF  a_tipo_dato = '05' THEN -- Usar Referencias (Origen Aseguradora, Ramo, Subramo)

	let _cod_origen_asegur = trim(a_codigo_ref);
	let _cod_ramo          = trim(a_codigo_ref2);
	let _cod_subramo       = trim(a_codigo_ref3);

	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

END IF

-- Lectura de la Cuenta de Mayor

SELECT cuenta
  INTO v_cuenta
  FROM parintcu
 WHERE cod_intercta = a_cod_intercta;

-- Lectura de las Subcuentas 

FOREACH
 SELECT	cod_enlace,
		tamano,
		renglon
   INTO	_cod_enlace,
		_tamano,
		_renglon
   FROM	parinten
  WHERE	cod_intercta = a_cod_intercta
  order by renglon

	SELECT tipo_enlace
	  INTO _tipo_enlace
	  FROM parenla
	 WHERE cod_enlace = _cod_enlace;

	IF _tipo_enlace   = "01" THEN -- Aseguradora

	ELIF _tipo_enlace = "02" THEN -- Agente

	ELIF _tipo_enlace = "03" THEN -- Ramo
		
		SELECT enlace_cat
		  INTO _enlace
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "04" THEN -- Subramo

		SELECT enlace_cat
		  INTO _enlace
		  FROM prdsubra
		 WHERE cod_ramo    = _cod_ramo
		   AND cod_subramo = _cod_subramo;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "05" THEN -- Banco

		SELECT enlace_cat
		  INTO _enlace
		  FROM chqbanco
		 WHERE cod_banco = _cod_banco;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "06" THEN -- Sucursal Banco

	ELIF _tipo_enlace = "07" THEN -- Tipo de Ramo

		SELECT enlace_cat
		  INTO _enlace
		  FROM prdtiram
		 WHERE cod_tiporamo = _cod_tiporamo;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "08" THEN -- Tipo de Produccion

		SELECT enlace_cat
		  INTO _enlace
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "09" THEN -- Nacionalidad Aseguradora

		SELECT enlace_cat
		  INTO _enlace
		  FROM parorig
		 WHERE cod_origen = _cod_origen_asegur;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "10" THEN -- Nacionalidad Cliente

		SELECT cod_origen
		  INTO _cod_origen_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		SELECT enlace_cat
		  INTO _enlace
		  FROM parorig
		 WHERE cod_origen = _cod_origen_cliente;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "11" THEN -- Nacionalidad Agente

	ELIF _tipo_enlace = "12" THEN -- Nacionalidad Poliza

		SELECT enlace_cat
		  INTO _enlace
		  FROM parorig
		 WHERE cod_origen = _cod_origen_poliza;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF

	ELIF _tipo_enlace = "13" THEN -- Tipo de Cuenta (Banco)

	ELIF _tipo_enlace = "14" THEN -- Chequera del banco

		SELECT enlace_cat
		  INTO _enlace
		  FROM chqchequ
		 WHERE cod_banco    = _cod_banco
		   and cod_chequera = _cod_chequera;

		IF _enlace IS NOT NULL THEN
			LET v_cuenta = TRIM(v_cuenta) || TRIM(_enlace);
		END IF
		
	END IF

END FOREACH

RETURN v_cuenta;

END PROCEDURE;
