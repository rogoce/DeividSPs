-- Procedimiento que Genera la Remesa de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rem;

CREATE PROCEDURE "informix".sp_rem(
a_compania		CHAR(3),
a_sucursal		CHAR(3)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _flag,_flag2	    INTEGER;
DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_cte   	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _dia		      	INTEGER;  
define _banco           CHAR(3);
define _id_transaccion  integer;
define _id_usuario      integer;
define _id_turno        integer;
define _existe          integer;
define _id_detalle      integer;
define _id_det		    integer;
define _id_tipo_cuenta  integer;
define _id_tipo_cobro   integer;
define _id_banco        integer;
define _recibo          CHAR(10);
define _monto_total		DEC(16,2);
define _monto_trancobro DEC(16,2);
define _fecha_documento date;
define _num_doc 		varchar(30);
define _tipo_tarjeta    integer;
define _cod_banco       char(3);
define _secuencia       integer;
DEFINE _mensaje         CHAR(100);
define ld_fecha_hora	datetime year to fraction(5);
define _fecha_registro  datetime year to fraction(5);
define _id_cliente		char(30);
define ls_cod_cobrador  char(3);
define _dia_cobros1     smallint;
define _pago_fijo       smallint;
define _tipo_cliente    smallint;
define _cant_suspe		smallint;
define _cod_chequera    char(3);
define _cod_sucursal    char(3);
--define z				integer;

DEFINE _error_code      INTEGER;
define _error_isam		integer;
define _error_desc		char(50);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code, _error_isam, _error_desc 
 	RETURN _error_code, _error_desc, _error_desc;
END EXCEPTION           

LET _tipo_mov   = 'P';
LET _null       = NULL;
LET a_no_remesa = '1';  
let _existe     = 0;
let _fecha      = current;
let _periodo    = '';
let _error_code = 0;
let _cod_banco  = "";

	
	let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

	select cod_sucursal,
	       cod_banco,
		   cod_chequera,
		   cod_cobrador
	  into _cod_sucursal,
		   _banco,
	       _cod_chequera,
		   _cod_cobrador
	  from cobcobra
	 where cod_cobrador = "098";

	IF _banco IS NULL THEN
		RETURN 1, 'Se debe colocar el banco caja en Mantenimiento de Cobradores', '';
	END IF

	IF _cod_chequera IS NULL THEN
		RETURN 1, 'Se debe colocar la Chequera del banco caja en Mantenimiento de Cobradores', '';
	END IF


	SELECT fecha
	  INTO _fecha
	  FROM cobremae
	 WHERE no_remesa = a_no_remesa;
	
	IF _fecha IS NOT NULL THEN
		RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
	END IF

	-- Insertar el Maestro de Remesas

	INSERT INTO cobremae(
	no_remesa,
	cod_compania,
	cod_sucursal,
	cod_banco,
	cod_cobrador,
	recibi_de,
	tipo_remesa,
	fecha,
	comis_desc,
	contar_recibos,
	monto_chequeo,
	actualizado,
	periodo,
	user_added,
	date_added,
	user_posteo,
	date_posteo,
	cod_chequera)
	VALUES(
	a_no_remesa,
	a_compania,
	a_sucursal,
	_banco,
	_cod_cobrador,
	_null,
	'C',
	'14/03/2011',
	0,
	3,
	0.00,
	0,
	'2011-03',
	'KVALDES',
	'14/03/2011',
	'KVALDES',
	'14/03/2011',
	_cod_chequera
	);

return 0,a_no_remesa,a_no_remesa;

END 

END PROCEDURE;
