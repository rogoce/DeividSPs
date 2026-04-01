-- Procedimiento que Genera el Cheque de bonificacion de cobranza para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 19/01/2006 - Autor: Amado Perez 
--             cuando se genere la comision, en el detalle debe aparecer 
--             desde la ultima fecha de comision si esta es menor que la
--             fecha desde se este generando la comision 

-- Modificado: 17/03/2006 - Autor: Demetrio Hurtado Almanza
--             Se separa la creacion de los registros contables y se incluyo en una rutina aparte que es la
--             sp_par205, que es la crea los registros contables de cheques de comisiones
-- 					  
-- Modificado: 25/02/2008 - Autor: Amado Perez
--             Se modifica la 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che82;
CREATE PROCEDURE sp_che82(
a_compania       CHAR(3),
a_sucursal       CHAR(3),
a_cod_agente     CHAR(5),
a_usuario        CHAR(8),
a_banco			 CHAR(3),
a_chequera		 CHAR(3),
a_periodo        CHAR(7)
) RETURNING INTEGER; 

DEFINE _comision 		DEC(16,2);
DEFINE _comision2 		DEC(16,2);
DEFINE _monto_banco		DEC(16,2);
DEFINE _no_requis, _no_requis_c		CHAR(10);
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
define _comision_enero  DEC(16,2);
define _desde           char(7);
define _hasta           char(7);
define _es_mensual      smallint;
define _estatus_licencia char(1);

define _fecha_ult_comis_orig date;
define _fecha_ult_comis      date;
define _periodo_ano      char(4);
define _ult_per_boni     char(7);
define _periodo_min      char(7);

set isolation to dirty read;

-- SET DEBUG FILE TO "sp_che82.trc"; 
-- TRACE ON;                                                                

--BEGIN WORK;

let _origen_cheque  = '8';
let _error          = 0;
let _comision_enero = 0;
let _es_mensual     = 1;

select es_mensual,
       desde,
       hasta
  into _es_mensual,
       _desde,
	   _hasta
  from chqboagt
 where cod_agente = a_cod_agente;
 
SELECT estatus_licencia
  INTO _estatus_licencia
  FROM agtagent
 WHERE cod_agente = a_cod_agente;
 
select ult_per_boni
  into _ult_per_boni
  from parparam;
  
let _periodo_ano = _ult_per_boni[1,4];

if _es_mensual = 0 then			--No es tipo mensual

	if _hasta = a_periodo then	--Verifico si ya le debo pagar
		
		SELECT SUM(comision)
		  INTO _comision
		  FROM chqboni
		 WHERE cod_agente = a_cod_agente
		   AND periodo    >= _desde
		   AND periodo    <= a_periodo;

	else
		RETURN 0;
	end if

else
    let _periodo_min = null;
	
	select min(periodo)
	  into _periodo_min
	  from chqboni
	 where cod_agente = a_cod_agente
	   and no_requis is null
	   and periodo[1,4] = _periodo_ano;
	   
	if _periodo_min is null then
		let _periodo_min = a_periodo;
	end if
	
	SELECT SUM(comision)
	  INTO _comision
	  FROM chqboni
	 WHERE cod_agente = a_cod_agente
	   AND periodo    >= _periodo_min
	   AND periodo    <= a_periodo;
end if

--se incluyo esta parte para descontar a los corredores por duplicidad en la boni de enero 2010		Armando
-----------------------------------------
{SELECT SUM(saldo_act)
  INTO _comision_enero
  FROM chqbosal2
 WHERE cod_agente = a_cod_agente;

if _comision_enero is null then

	let _comision_enero = 0;

end if

let _comision = _comision - _comision_enero;

if _comision >= 0 then

	update chqbosal2
	   set saldo_act  = 0,
	       saldo_ant  = _comision_enero
	 WHERE cod_agente = a_cod_agente;

else

	let _comision = ABS(_comision);

	update chqbosal2
	   set saldo_act  = _comision,
	       saldo_ant  = _comision_enero
	 WHERE cod_agente = a_cod_agente;

	return 0;

end if}
-----------------------------------------
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

	let _nombre_mes = sp_sac18(a_periodo[6,7]);
	let _nombre_mes = trim(_nombre_mes);
	LET _descripcion = 'PAGO DE BONIFICACION DE COBRANZA DE: ' || _nombre_mes || " DEL " || a_periodo[1,4];


    IF _tipo_pago = 1 THEN -- Pago por ACH

		LET _tipo_requis = "A";

		LET _banco = _banco_ach;

        SELECT cod_chequera
		  INTO _chequera
		  FROM chqchequ
		 WHERE cod_banco  = _banco_ach
		   AND enlace_cat =  '03';

		LET _autorizado     = 1; 	
		LET _autorizado_por	= a_usuario;

	else -- Pago por Cheque

		LET _tipo_requis    = "C";
		LET _banco          = a_banco;
		LET _chequera       = a_chequera;
		LET _autorizado     = 0; 	
		LET _autorizado_por	= NULL;

	END IF

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

	INSERT INTO chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	VALUES(
	_no_requis,
	1,
	_descripcion
	);

	let _renglon = 0;

	if _es_mensual = 0 then			--No es tipo mensual

		UPDATE chqboni
		   SET no_requis   = _no_requis,
		       tipo_requis = _tipo_requis
		 WHERE cod_agente  = a_cod_agente
		   AND periodo     >= _desde
		   AND periodo     <= a_periodo;

	else

		UPDATE chqboni
		   SET no_requis   = _no_requis,
		       tipo_requis = _tipo_requis
		 WHERE cod_agente  = a_cod_agente
		   AND periodo    >= _periodo_min
		   AND periodo    <= a_periodo;

	end if

	-- Registros Contables de Cheques de Comisiones

	call sp_par276(_no_requis, "8") returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if

RETURN 0;

END PROCEDURE;