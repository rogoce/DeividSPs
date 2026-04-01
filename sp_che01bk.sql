-- Impresion del Cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che01bk;

CREATE PROCEDURE "informix".sp_che01bk(
a_compania		CHAR(3), 
a_agencia 		CHAR(3), 
a_usuario 		CHAR(8), 
a_cod_banco 	CHAR(3), 
a_cod_chequera	CHAR(3), 
a_no_requis 	CHAR(10) DEFAULT '*'
) RETURNING DATE,
			CHAR(100),
		    DECIMAL(16,2), 
			CHAR(250),
		    DATE,
			INTEGER,
			CHAR(3),
			CHAR(3),
			CHAR(8),
			CHAR(3),
			CHAR(3),
			CHAR(10),
			CHAR(8),
			CHAR(8);

DEFINE v_a_nombre_de  CHAR(50);     
DEFINE v_monto        DECIMAL(16,2);
DEFINE v_monto_letras CHAR(250);    
DEFINE _no_requis     CHAR(10);
DEFINE _no_cheque,_no_cheque2     INTEGER;
DEFINE _origen_cheque CHAR(1);
DEFINE _transaccion	  CHAR(10);
DEFINE _cod_origen    CHAR(3);
DEFINE _enlace_cta    CHAR(20);
DEFINE _renglon		  SMALLINT;
DEFINE _cuenta		  CHAR(25);
define _periodo		  char(7);
define _mes_char      CHAR(2);
define _ano_char	  CHAR(4);
define _user_added	  char(8);
define _aut_workflow_user char(8);

--SET DEBUG FILE TO "sp_che01.trc";
--TRACE ON;

-- Lectura del Numero de Cheque
set isolation to dirty read;

IF  MONTH(today) < 10 THEN
	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF

LET _ano_char = YEAR(today);
LET _periodo  = _ano_char || "-" || _mes_char;

let _no_cheque2 = null;

SELECT cont_no_cheque
  INTO _no_cheque
  FROM chqchequ
 WHERE cod_banco    = a_cod_banco
   AND cod_chequera = a_cod_chequera;

IF _no_cheque IS NULL THEN
	LET _no_cheque = 0;
END IF

-- Lectura del Origen del Banco para el Enlace de Cuentas
  	
SELECT cod_origen
  INTO _cod_origen
  FROM chqbanco
 WHERE cod_banco = a_cod_banco;

-- Inicio de la Impresion de Cheques

FOREACH 
 SELECT a_nombre_de,
		monto,
		no_requis,
		origen_cheque,
		user_added,
		aut_workflow_user
   INTO v_a_nombre_de,
		v_monto,
		_no_requis,
		_origen_cheque,
		_user_added,
  		_aut_workflow_user
   FROM chqchmae
  WHERE cod_compania   = a_compania
	AND autorizado     = 1
	AND autorizado_por = a_usuario
	AND cod_banco      = a_cod_banco
	AND cod_chequera   = a_cod_chequera
	AND tipo_requis    = "C"
	AND no_requis      MATCHES a_no_requis
  ORDER BY no_requis 
  
	select no_cheque
	  into _no_cheque2
	  from chqchmae
	 where no_requis = _no_requis;

	if _no_cheque2 IS NOT NULL and _no_cheque2 <> 0 then
		LET _no_cheque2 = _no_cheque2 - 1;
		LET _no_cheque  = _no_cheque2;
	end if

	LET _no_cheque = _no_cheque + 1;

	LET v_monto_letras = sp_sis11(v_monto);

	-- Datos del Cheque

	RETURN  TODAY, 
			v_a_nombre_de,
			v_monto, 
			v_monto_letras,      
			TODAY,
			_no_cheque,
			a_compania, 
			a_agencia, 
			a_usuario, 
			a_cod_banco, 
			a_cod_chequera, 
			_no_requis,
			_user_added,
			_aut_workflow_user
			WITH RESUME;

END FOREACH


END PROCEDURE;
