-- Procedimiento que Genera el Numero de Factura
-- 
-- Creado    : 17/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/10/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis14;		

CREATE PROCEDURE sp_sis14(a_compania CHAR(3), a_sucursal CHAR(3), a_no_poliza CHAR(10))
RETURNING CHAR(10);

DEFINE _cont_sucursal SMALLINT;
DEFINE _cont_ramo     SMALLINT;
DEFINE _cont_subramo  SMALLINT;
DEFINE _cont_ano      SMALLINT;

DEFINE t_cod_sucursal CHAR(3); 
DEFINE t_cod_ramo     CHAR(3); 
DEFINE t_cod_subramo  CHAR(3); 
DEFINE t_ano          CHAR(4); 

DEFINE _cod_sucursal  CHAR(3); 
DEFINE _cod_ramo      CHAR(3); 
DEFINE _cod_subramo   CHAR(3); 
DEFINE _ano           CHAR(4); 

DEFINE _no_tran_int   INTEGER; 
DEFINE _no_tran_char  CHAR(10);
DEFINE _cod_sucur_int INTEGER;

DEFINE _fecha_char    CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_sis14.trc";
--trace on;

-- Seteos de Valores Iniciales

LET _fecha_char = TODAY;

SELECT cod_ramo,
       cod_subramo
  INTO _cod_ramo,
	   _cod_subramo	
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

-- Lectura de la Tabla que controla la forma 
-- de contar las transacciones

SELECT emi_cont_fa_suc,
       emi_cont_fa_ram,
	   emi_cont_fa_sub,
	   emi_cont_fa_ano
  INTO _cont_sucursal,
	   _cont_ramo,    
	   _cont_subramo, 
	   _cont_ano     
  FROM parparam
 WHERE cod_compania = a_compania;

LET t_cod_sucursal  = 0; 
LET t_cod_ramo      = 0; 
LET t_cod_subramo   = 0; 
LET t_ano           = 0; 

IF _cont_sucursal = 1 THEN
	LET t_cod_sucursal = a_sucursal;
END IF

IF _cont_ramo = 1 THEN
	LET t_cod_ramo = _cod_ramo;
END IF

IF _cont_subramo = 1 THEN
	LET t_cod_subramo = _cod_subramo;
END IF

IF _cont_ano = 1 THEN
	LET t_ano = _fecha_char[7,10];
END IF

-- Lectura de la tabla que tiene el ultimo numero
-- de factura

SELECT ult_no_factura
  INTO _no_tran_int
  FROM parconfa
 WHERE cod_compania = a_compania
   AND cod_sucursal = t_cod_sucursal
   AND cod_ramo     = t_cod_ramo
   AND cod_subramo  = t_cod_subramo
   AND ano          = t_ano;

IF _no_tran_int IS NULL THEN
	
	LET _no_tran_int = 1;

	INSERT INTO parconfa(
	cod_compania,
	cod_sucursal,
	cod_ramo,    
	cod_subramo, 
	ano,         	
	ult_no_factura
	)
	VALUES(
	a_compania,
	t_cod_sucursal,
	t_cod_ramo,
	t_cod_subramo,
	t_ano,
	_no_tran_int
	);

ELSE

	LET _no_tran_int = _no_tran_int + 1;

	UPDATE parconfa
	   SET ult_no_factura = _no_tran_int
	 WHERE cod_compania   = a_compania
	   AND cod_sucursal   = t_cod_sucursal
	   AND cod_ramo       = t_cod_ramo
	   AND cod_subramo    = t_cod_subramo
	   AND ano            = t_ano;

END IF

-- Armar el numero de factura

LET _no_tran_char  = '00-0000000';
LET _cod_sucur_int = a_sucursal;

-- Sucursal

IF _cod_sucur_int > 9 THEN
	LET _no_tran_char[1,2] = _cod_sucur_int;
ELSE
	LET _no_tran_char[2,2] = _cod_sucur_int;
END IF

-- Numero de Transaccion

IF _no_tran_int > 9999  THEN
	LET _no_tran_char[4,10] = _no_tran_int;
ELIF _no_tran_int > 999 THEN
	LET _no_tran_char[5,10] = _no_tran_int;
ELIF _no_tran_int > 99  THEN
	LET _no_tran_char[6,10] = _no_tran_int;
ELIF _no_tran_int > 9   THEN
	LET _no_tran_char[7,10] = _no_tran_int;
ELSE
	LET _no_tran_char[8,10] = _no_tran_int;
END IF

RETURN _no_tran_char;

END PROCEDURE;
