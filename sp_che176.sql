-- Procedimiento que Genera el Cheque de Bono Ramo:019 Poliza Rezagada
-- Creado    : 05/04/2018 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_che176('001','001','02226','DEIVID','001','001','2017-10')

DROP PROCEDURE sp_che176;
CREATE PROCEDURE sp_che176(
a_compania       CHAR(3),
a_sucursal       CHAR(3),
a_cod_agente     CHAR(5),
a_usuario        CHAR(8),
a_banco			 CHAR(3),
a_chequera		 CHAR(3),
a_periodo        CHAR(7)
) RETURNING INTEGER; 

DEFINE _comision 		DEC(16,2);
DEFINE _no_requis		CHAR(10);
DEFINE _nombre      	CHAR(50);
DEFINE _descripcion 	CHAR(60);
DEFINE _tipo_agente 	CHAR(1);
DEFINE _tipo_pago   	SMALLINT;
DEFINE _tipo_requis 	CHAR(1);
define _cod_origen		char(3); 
DEFINE _banco       	CHAR(3);
DEFINE _banco_ach   	CHAR(3);
DEFINE _chequera    	CHAR(3);
define _autorizado  	smallint;
define _autorizado_por	char(8);
define _origen_cheque   CHAR(1);
define _nombre_mes      char(10);
define _error			integer;
define _error_desc		char(50);
define _cta_chequera    smallint;
define _enlace_cta      char(20);

-- SET DEBUG FILE TO "sp_che166.trc";  
-- TRACE ON;  

let _origen_cheque = 'I';       -- Bono Ramo:019 - Nuevas   Vida Invididual
let _error         = 0;

SELECT sum(monto_bono)
  INTO _comision
  FROM chqbono019
 WHERE cod_agente = a_cod_agente
   AND no_requis is null
   AND aplica     = 1
   and rezagada   = 1;

SELECT che_banco_ach 
  INTO _banco_ach 
  FROM parparam 
 WHERE cod_compania = a_compania;	

SELECT cod_origen,
	   cta_chequera
  INTO _cod_origen,
	   _cta_chequera
  FROM chqbanco
 WHERE cod_banco = a_banco;

	-- Numero Interno de Requisicion

	LET _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	if _no_requis = "" or _no_requis is null then
		return 1;
	end if

	SELECT nombre,
		   tipo_agente,
		   tipo_pago
	  INTO _nombre,
		   _tipo_agente,
		   _tipo_pago
	  FROM agtagent
	 WHERE cod_agente = a_cod_agente;
	
	let _nombre_mes = sp_sac18(a_periodo[6,7]);
	let _nombre_mes = trim(_nombre_mes);
	LET _descripcion = 'PAGO BONO VIDA IND.POL.REZAGADAS DE: ' || _nombre_mes || " DE " || a_periodo[1,4];
	
    if _tipo_pago = 1 THEN -- Pago por ACH

		LET _tipo_requis = "A";

		LET _banco = _banco_ach;

        SELECT cod_chequera
		  INTO _chequera
		  FROM chqchequ
		 WHERE cod_banco = _banco_ach
		   AND enlace_cat =  '03';

		LET _autorizado     = 1; 	
		LET _autorizado_por	= a_usuario;

	else -- Pago por Cheque

		LET _tipo_requis    = "C";
		LET _banco          = a_banco;
		LET _chequera       = a_chequera;
		LET _autorizado     = 0; 	
		LET _autorizado_por	= NULL;

	end if

	-- Encabezado del Cheque

	INSERT INTO chqchmae(
	no_requis,
	cod_cliente,
	cod_agente,
	cod_banco,
	cod_chequera,
	cuenta,
	cod_compania,
	cod_sucursal,
	origen_cheque,
	no_cheque,
	fecha_impresion,
	fecha_captura,
	autorizado,
	pagado,
	a_nombre_de,
	cobrado,
	fecha_cobrado,
	anulado,
	fecha_anulado,
	anulado_por,
	monto,
	periodo,
	user_added,
	autorizado_por,
	tipo_requis
	)
	VALUES(
	_no_requis,
	NULL,
	a_cod_agente,
	_banco,
	_chequera,
	NULL,
	a_compania,
	a_sucursal,
	_origen_cheque,
	0,
	CURRENT,
	CURRENT,
	_autorizado,
	0,
	_nombre,
	0,
	NULL,
	0,
	NULL,
	NULL,
	_comision,
	a_periodo,
	a_usuario,
	_autorizado_por,
	_tipo_requis
	);	 

	-- Descripcion del Cheque

	INSERT INTO chqchdes(no_requis,renglon,desc_cheque)
	              VALUES(_no_requis,1,_descripcion);	
	   
	-- se adiciona no_requis en detalle para controlar las rezagadas
	UPDATE chqbono019
	   SET no_requis   = _no_requis,
	       tipo_requis = _tipo_requis,
		   periodo_pago = a_periodo,
		   fecha_pagado = current
	 WHERE cod_agente  = a_cod_agente
	   AND no_requis   is null
	   AND aplica      = 1
	   and rezagada    = 1;	   	   

	-- Registros Contables de Cheques de Bono Ramo:019 - Nuevas

	call sp_par276(_no_requis, "I") returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if

RETURN 0;

END PROCEDURE;

	