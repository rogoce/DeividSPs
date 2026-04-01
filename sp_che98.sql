-- Procedimiento que Genera el Cheque de Bonificacion por rentabilidad
-- Creado    : 20/02/2009 - Autor: Henry Giron
-- Modificado: 20/02/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che98;

CREATE PROCEDURE sp_che98(
a_compania       CHAR(3),
a_sucursal       CHAR(3),
a_cod_agente     CHAR(5),
a_usuario        CHAR(8),
a_banco			 CHAR(3),
a_chequera		 CHAR(3),
a_periodo        CHAR(7)
) RETURNING INTEGER; 

DEFINE _comision 		DEC(16,2);
DEFINE _monto_banco		DEC(16,2);
DEFINE _no_requis		CHAR(10);
DEFINE _nombre      	CHAR(50);
DEFINE _periodo     	CHAR(7);
DEFINE _cod_ramo    	CHAR(3);
DEFINE _cod_subramo 	CHAR(3);
DEFINE _saldo       	DEC(16,2);
DEFINE _descripcion 	CHAR(60);
DEFINE _cuenta      	CHAR(25);
DEFINE _tipo_agente 	CHAR(1);
DEFINE _tipo_pago   	SMALLINT;
DEFINE _tipo_requis 	CHAR(1);
DEFINE _quincena    	CHAR(3);
DEFINE _fecha_letra 	CHAR(10);
define _cod_origen		char(3);
define _renglon			smallint;
DEFINE _ano         	CHAR(4);  
DEFINE _banco       	CHAR(3);
DEFINE _banco_ach   	CHAR(3);
DEFINE _chequera    	CHAR(3);
define _origen_banc		char(3);
define _autorizado  	smallint;
define _autorizado_por	char(8);
define _origen_cheque   CHAR(1);
DEFINE _alias     		CHAR(50);
define _nombre_mes      char(10);
define _error			integer;
define _error_desc		char(50);
define _cta_chequera    smallint;
define _enlace_cta      char(20);
define _fecha_ult_comis_orig date;
define _fecha_ult_comis      date;

-- SET DEBUG FILE TO "sp_che98.trc"; 
-- TRACE ON;                                                                

let _origen_cheque = 'D';
let _error         = 0;

SELECT SUM(comision)
  INTO _comision
  FROM chqrenta3
 WHERE cod_agente = a_cod_agente
   AND periodo    = a_periodo;

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
		   saldo,
		   tipo_agente,
		   tipo_pago,
		   alias	
	  INTO _nombre,
		   _saldo,
		   _tipo_agente,
		   _tipo_pago,
		   _alias
	  FROM agtagent
	 WHERE cod_agente = a_cod_agente;

--	let _nombre_mes = sp_sac18(a_periodo[6,7]);
--	let _nombre_mes = trim(_nombre_mes);
	LET _descripcion = 'PAGO DE BONIFICACION POR RENTABILIDAD DEL ' || a_periodo[1,4];

{    if a_cod_agente in('01428','00547','00031','00226','00008','01083','01360','00708','01837','00035','01001','00161','01318','01410','01440','01642','00413','00821','01852',
                       '00218','00133','00370','01300','00692','01397','00873','00698','00787','01801','00166','00270','00874','01435','00180','01508','00141','00875',
                       '00738','02040','00628') then
		LET _tipo_pago = 0;
	end if}

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

	LET _monto_banco = _comision;

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

	let _renglon = 0;

	UPDATE chqrenta3
	   SET no_requis   = _no_requis,
	       tipo_requis = _tipo_requis
	 WHERE cod_agente  = a_cod_agente
	   AND periodo     = a_periodo;

	-- Registros Contables de Cheques de Comisiones

	call sp_par276(_no_requis, "D") returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if
RETURN 0;
END PROCEDURE;