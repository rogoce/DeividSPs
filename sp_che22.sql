-- Impresion del Cheque	- Prueba de Impresion sin actualizacion
--
-- Creado    : 15/10/2003 - Autor: Demetrio Hurtado ALmanza 
-- Modificado: 15/10/2003 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_che22;

CREATE PROCEDURE "informix".sp_che22(a_no_requis CHAR(10)
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
			CHAR(10);

DEFINE v_a_nombre_de  	CHAR(50);     
DEFINE v_monto        	DECIMAL(16,2);
DEFINE v_monto_letras 	CHAR(250);    
DEFINE _no_requis     	CHAR(10);
DEFINE _no_cheque     	INTEGER;

define a_compania	  	char(3);
define a_agencia		char(3);
define a_usuario		char(8);
define a_cod_banco		char(3);
define a_cod_chequera	char(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che01.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

-- Inicio de la Impresion de Cheques

FOREACH 
 SELECT a_nombre_de,
		monto,
		no_requis,
		no_cheque,
		cod_compania,
		cod_sucursal,
		user_added,
		cod_banco,
		cod_chequera		
   INTO v_a_nombre_de,
		v_monto,
		_no_requis,
		_no_cheque,
		a_compania,	 
		a_agencia,		
		a_usuario,		
		a_cod_banco,		
		a_cod_chequera
   FROM chqchmae
  WHERE no_requis = a_no_requis

	LET v_monto_letras = sp_sis11(v_monto);
	
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
			_no_requis
			WITH RESUME;

END FOREACH

END PROCEDURE;
