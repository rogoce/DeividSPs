-- Procedimiento que Genera el Numero Externo de Emision de Reclamos
-- 
-- Creado    : 03/05/2004 - Autor: Amado Perez 
-- Modificado: 03/05/2004 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rwf11b;		

CREATE PROCEDURE "informix".sp_rwf11b(
a_compania   CHAR(3), 
a_sucursal   CHAR(3), 
a_no_reclamo CHAR(10),
a_no_poliza  CHAR(10))
RETURNING CHAR(18);

DEFINE _cont_sucursal SMALLINT;
DEFINE _cont_ramo     SMALLINT;
DEFINE _cont_subramo  SMALLINT;
DEFINE _cont_mes      SMALLINT;
DEFINE _cont_ano      SMALLINT;

DEFINE t_cod_sucursal CHAR(3); 
DEFINE t_cod_ramo     CHAR(3); 
DEFINE t_cod_subramo  CHAR(3); 
DEFINE t_mes          CHAR(2); 
DEFINE t_ano          CHAR(4); 

DEFINE _cod_sucursal  CHAR(3); 
DEFINE _cod_ramo      CHAR(3); 
DEFINE _cod_subramo   CHAR(3); 
DEFINE _mes           CHAR(2); 
DEFINE _ano           CHAR(4); 

DEFINE _no_rec_int    INTEGER; 
DEFINE _no_rec_char   CHAR(18);
DEFINE _cod_sucur_int INTEGER;

DEFINE _no_poliza     CHAR(10);
DEFINE _fecha_char    CHAR(10);
DEFINE _error         SMALLINT;

--SET ISOLATION TO DIRTY READ;

SET LOCK MODE TO WAIT 60;

 --SET DEBUG FILE TO "sp_rwf11.trc";      
 --TRACE ON;        

-- Seteos de Valores Iniciales

IF a_compania IS NULL OR trim(a_compania) = "" THEN
    LET _no_rec_char = 'ERROR'; 
	RETURN _no_rec_char; 
END IF

IF a_sucursal IS NULL OR trim(a_sucursal) = "" THEN
    LET _no_rec_char = 'ERROR'; 
	RETURN _no_rec_char; 
END IF

BEGIN

ON EXCEPTION SET _error 
 --	LET _no_rec_char = _error;
    LET _no_rec_char = 'ERROR'; 
	RETURN _no_rec_char; 
END EXCEPTION           

LET _fecha_char = TODAY;
LET _fecha_char = '17-03-2003';

SELECT cod_ramo,
       cod_subramo
  INTO _cod_ramo,
	   _cod_subramo	
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

-- Lectura de la Tabla que controla la forma 
-- de contar las transacciones

SELECT rec_cont_re_suc,
       rec_cont_re_ram,
	   rec_cont_re_sub,
	   rec_cont_re_mes,
	   rec_cont_re_ano
  INTO _cont_sucursal,
	   _cont_ramo,    
	   _cont_subramo, 
	   _cont_mes,     
	   _cont_ano     
  FROM parparam
 WHERE cod_compania = a_compania;

LET t_cod_sucursal  = '0'; 
LET t_cod_ramo      = '0'; 
LET t_cod_subramo   = '0'; 
LET t_mes           = '0'; 
LET t_ano           = '0'; 

IF _cont_sucursal = 1 THEN
	LET t_cod_sucursal = a_sucursal;
	IF t_cod_sucursal = '001' THEN
		LET t_cod_sucursal = '0';
	END IF		
END IF

IF _cont_ramo = 1 THEN
	LET t_cod_ramo = _cod_ramo;
END IF

IF _cont_subramo = 1 THEN
	LET t_cod_subramo = _cod_subramo;
END IF

IF _cont_mes = 1 THEN
	LET t_mes = _fecha_char[4,5];
END IF

IF _cont_ano = 1 THEN
	LET t_ano = _fecha_char[7,10];
END IF

-- Lectura de la tabla que tiene el ultimo numero
-- de la transaccion de reclamos

SELECT ult_no_reclamo
  INTO _no_rec_int
  FROM parconre
 WHERE cod_compania = a_compania
   AND cod_sucursal = t_cod_sucursal
   AND cod_ramo     = t_cod_ramo
   AND cod_subramo  = t_cod_subramo
   AND mes          = t_mes
   AND ano          = t_ano;

IF _no_rec_int IS NULL THEN
	
	LET _no_rec_int = 1;

	INSERT INTO parconre(
	cod_compania,
	cod_sucursal,
	cod_ramo,    
	cod_subramo, 
	mes,         
	ano,         	
	ult_no_reclamo
	)
	VALUES(
	a_compania,
	t_cod_sucursal,
	t_cod_ramo,
	t_cod_subramo,
	t_mes,
	t_ano,
	_no_rec_int
	);

ELSE

	LET _no_rec_int = _no_rec_int + 1;

	UPDATE parconre
	   SET ult_no_reclamo = _no_rec_int
	 WHERE cod_compania   = a_compania
	   AND cod_sucursal   = t_cod_sucursal
	   AND cod_ramo       = t_cod_ramo
	   AND cod_subramo    = t_cod_subramo
	   AND mes            = t_mes
	   AND ano            = t_ano; 

END IF

-- Armar el numero de Reclamos
-- de reclamos

LET _no_rec_char  = '00-0000-00000-00';
LET _cod_sucur_int = a_sucursal;

-- Ramo

LET _no_rec_char[1,2] = _cod_ramo[2,3];

-- Ano y Mes

LET _no_rec_char[4,5] =	_fecha_char[4,5];
LET _no_rec_char[6,7] =	_fecha_char[9,10];

-- Sucursal

IF _cod_sucur_int > 9 THEN
	LET _no_rec_char[15,16] = _cod_sucur_int;
ELSE
	LET _no_rec_char[16,16] = _cod_sucur_int;
END IF

-- Numero de reclamo

IF _no_rec_int > 9999  THEN
	LET _no_rec_char[9,13] = _no_rec_int;
ELIF _no_rec_int > 999 THEN
	LET _no_rec_char[10,13] = _no_rec_int;
ELIF _no_rec_int > 99  THEN
	LET _no_rec_char[11,13] = _no_rec_int;
ELIF _no_rec_int > 9   THEN
	LET _no_rec_char[12,13] = _no_rec_int;
ELSE
	LET _no_rec_char[13,13] = _no_rec_int;
END IF

RETURN _no_rec_char;

END

END PROCEDURE;
