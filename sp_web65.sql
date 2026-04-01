-- Procedimiento que Genera el Numero de Poliza (Documento)
-- 
-- Creado    : 16/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/11/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web65;		

CREATE PROCEDURE "informix".sp_web65(
a_compania  CHAR(3),
a_sucursal  CHAR(3),
a_ano CHAR(4),
a_cod_ramo char(3),
a_cod_subramo char(3)
) RETURNING CHAR(20);

DEFINE _cont_sucursal SMALLINT;
DEFINE _cont_ramo     SMALLINT;
DEFINE _cont_subramo  SMALLINT;
DEFINE _cont_ano      SMALLINT;

DEFINE t_cod_sucursal CHAR(3); 
DEFINE t_cod_ramo     CHAR(3); 
DEFINE t_cod_subramo  CHAR(3); 
DEFINE t_ano          CHAR(4); 

DEFINE _cod_sucursal  CHAR(3); 

DEFINE _no_tran_int   INTEGER; 
DEFINE _no_tran_char  CHAR(20);
DEFINE _cod_sucur_int INTEGER;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_sis14.trc";
--trace on;

-- Seteos de Valores Iniciales
set isolation to dirty read;

-- Lectura de la Tabla que controla la forma 
-- de contar las polizas

SELECT emi_cont_po_suc,
       emi_cont_po_ram,
	   emi_cont_po_sub,
	   emi_cont_po_ano
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

-- Si es ramo Salud y el subramo Plan Dental habilitamos la busqueda por el subramo
IF a_cod_ramo = "018" AND a_cod_subramo = "015" THEN
	LET _cont_subramo = 1;
END IF

IF _cont_sucursal = 1 THEN
	LET t_cod_sucursal = a_sucursal;
END IF

IF _cont_ramo = 1 THEN
	LET t_cod_ramo = a_cod_ramo;
END IF

IF _cont_subramo = 1 THEN
	LET t_cod_subramo = a_cod_subramo;
END IF

IF _cont_ano = 1 THEN
	LET t_ano = a_ano;
END IF

-- Lectura de la tabla que tiene el ultimo numero
-- de poliza

set lock mode to wait;

SELECT ult_no_poliza
  INTO _no_tran_int
  FROM parconpo
 WHERE cod_compania = a_compania
   AND cod_sucursal = t_cod_sucursal
   AND cod_ramo     = t_cod_ramo
   AND cod_subramo  = t_cod_subramo
   AND ano          = t_ano;


IF _no_tran_int IS NULL THEN
	
	LET _no_tran_int = 1;

	INSERT INTO parconpo(
	cod_compania,
	cod_sucursal,
	cod_ramo,    
	cod_subramo, 
	ano,         	
	ult_no_poliza
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

	UPDATE parconpo
	   SET ult_no_poliza  = _no_tran_int
	 WHERE cod_compania   = a_compania
	   AND cod_sucursal   = t_cod_sucursal
	   AND cod_ramo       = t_cod_ramo
	   AND cod_subramo    = t_cod_subramo
	   AND ano            = t_ano;

END IF

set isolation to dirty read;

-- Armar el numero de poliza

IF a_cod_ramo = "018" AND a_cod_subramo = "015" THEN
	LET _no_tran_char  = '0000-80000-00';
ELSE
	LET _no_tran_char  = '0000-00000-00';
END IF

LET _cod_sucur_int = a_sucursal;

-- Ramo/Ano

LET _no_tran_char[1,2] = t_cod_ramo[2,3];
LET _no_tran_char[3,4] = t_ano[3,4];

-- Numero de la Poliza

IF _no_tran_int > 9999  THEN
	LET _no_tran_char[6,10] = _no_tran_int;
ELIF _no_tran_int > 999 THEN
	LET _no_tran_char[7,10] = _no_tran_int;
ELIF _no_tran_int > 99  THEN
	LET _no_tran_char[8,10] = _no_tran_int;
ELIF _no_tran_int > 9   THEN
	LET _no_tran_char[9,10] = _no_tran_int;
ELSE
	LET _no_tran_char[10,10] = _no_tran_int;
END IF

-- Sucursal

IF _cod_sucur_int > 9 THEN
	LET _no_tran_char[12,13] = _cod_sucur_int;
ELSE
	LET _no_tran_char[13,13] = _cod_sucur_int;
END IF

RETURN _no_tran_char;

END PROCEDURE;