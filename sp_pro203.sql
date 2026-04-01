-- Procedimiento que Genera la Remesa para aplicar la prima en suspenso y generar la requis para el cheque de devolucion de primas.

-- Creado    : 29/12/2010 - Autor: Armando Moreno M.
-- Modificado: 29/12/2010 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro203;

CREATE PROCEDURE "informix".sp_pro203(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_no_recibo     CHAR(30),
a_no_recibo2    CHAR(30)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza,_no_recibo10    	CHAR(10); 
DEFINE _doc_remesa	 	CHAR(30);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _dia		      	INTEGER;
DEFINE _cod_chequera    char(3);  
DEFINE _cod_banco       char(3);
DEFINE _recibi_de  		char(50);
DEFINE _fecha_recibo    date;
DEFINE _cod_auxiliar    char(5);
DEFINE _mensaje         CHAR(100);

DEFINE _monto2          DEC(16,2);
DEFINE _nombre_cliente2	CHAR(50);
DEFINE _fecha_recibo2   DATE;
DEFINE _doc_remesa2 	CHAR(30);
DEFINE _descripcion2   	CHAR(100);
DEFINE a_monto          DEC(16,2);
define _recibo_tmp      char(20);

--SET DEBUG FILE TO "sp_pro203.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Aplicacion de prima', '';         
END EXCEPTION           

let _monto  = 0;
let _monto2 = 0;
let a_monto = 0;

CALL sp_sis138(a_no_recibo) RETURNING _nombre_cliente, _monto, _renglon, _fecha_recibo,_doc_remesa;

if _nombre_cliente is null then
   foreach
	   select nombre into _nombre_cliente from emievalu where no_recibo = a_no_recibo

	   exit foreach;
   end foreach
end if

if _renglon = 1 then
	RETURN 1, 'No se encontro la prima en suspenso.', '';
end if

if a_no_recibo2 is not null then	--Pago Adicional que hizo el cliente por algun recargo etc.
	CALL sp_sis138(a_no_recibo2) RETURNING _nombre_cliente2, _monto2, _renglon, _fecha_recibo2,_doc_remesa2;
	if _renglon = 1 then
		let _monto2 = 0;
	end if
	if _nombre_cliente2 is null then
	   foreach
		   select nombre into _nombre_cliente2 from emievalu where no_recibo2 = a_no_recibo2

		   exit foreach;
	   end foreach

	end if
end if

LET _tipo_mov     = 'A'; 
LET _null         = NULL;
LET a_no_remesa   = '1';
LET _descripcion  = "";
LET _descripcion2 = "";

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	

LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

select valor_parametro
  into _cod_banco
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_caja';

let _cod_banco    = trim(_cod_banco);
let _cod_chequera = "023";
let _recibi_de    = "APLICACION EN SUSPENSO";

select doc_remesa,no_recibo
  into _doc_remesa,_no_recibo10
  from cobredet
 where doc_remesa = a_no_recibo
   and tipo_mov  = "E"
   and monto     = _monto;

-- Para los casos en que el numero de recibo sea el numero
-- del documento de la prima en suspenso

if _doc_remesa is null then	
	let _recibo_tmp = null;

	select no_recibo
	  into _recibo_tmp
	  from cobredet
	 where doc_remesa = a_no_recibo
	   and tipo_mov   = "E";

	-- Invertir los Valores

	if _recibo_tmp is not null then
		let _doc_remesa = a_no_recibo;
		let a_no_recibo = _recibo_tmp;			
	end if 
end if


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
cod_chequera
)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
_cod_banco,
_null,
_recibi_de,
'C',
_fecha,
0,
2,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha,
_cod_chequera
);

LET _descripcion = TRIM(_nombre_cliente);
LET _renglon = 0;
LET _renglon = _renglon + 1;
LET a_monto  = _monto * -1;

-- Detalle de la Remesa
INSERT INTO cobredet(
no_remesa,
renglon,
cod_compania,
cod_sucursal,
no_recibo,
doc_remesa,
tipo_mov,
monto,
prima_neta,
impuesto,
monto_descontado,
comis_desc,
desc_remesa,
saldo,
periodo,
fecha,
actualizado,
no_poliza
)
VALUES(
a_no_remesa,
_renglon,
a_compania,
a_sucursal,
_no_recibo10,--a_no_recibo,
_doc_remesa,
_tipo_mov,
a_monto,
0,
0,
0,
0,
_descripcion,
0,
_periodo,
_fecha,
0,
null
);

LET _renglon   = _renglon + 1;

if _monto2 > 0 then
	LET _descripcion2 = TRIM(_nombre_cliente2);
	LET a_monto       = _monto2 * -1;

	-- Detalle de la Remesa
	INSERT INTO cobredet(
	no_remesa,
	renglon,
	cod_compania,
	cod_sucursal,
	no_recibo,
	doc_remesa,
	tipo_mov,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	comis_desc,
	desc_remesa,
	saldo,
	periodo,
	fecha,
	actualizado,
	no_poliza
	)
	VALUES(
	a_no_remesa,
	_renglon,
	a_compania,
	a_sucursal,
	a_no_recibo2,
	_doc_remesa2,
	_tipo_mov,
	a_monto,
	0,
	0,
	0,
	0,
	_descripcion2,
	0,
	_periodo,
	_fecha,
	0,
	null
	);

	LET _renglon = _renglon + 1;

end if

let _cod_auxiliar = "0127";
let _doc_remesa   = sp_sis15('CPDEVSUS');

INSERT INTO cobredet(
no_remesa,
renglon,
cod_compania,
cod_sucursal,
no_recibo,
doc_remesa,
tipo_mov,
monto,
prima_neta,
impuesto,
monto_descontado,
comis_desc,
desc_remesa,
saldo,
periodo,
fecha,
actualizado,
no_poliza,
no_recibo2,
cod_auxiliar
)
VALUES(
a_no_remesa,
_renglon,
a_compania,
a_sucursal,
_no_recibo10,--a_no_recibo,
_doc_remesa,
"M",
_monto + _monto2,
0,
0,
0,
0,
_descripcion,
0,
_periodo,
_fecha,
0,
null,
a_no_recibo2,
_cod_auxiliar
);

--Actualizacion de Remesa
call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

if _error_code <> 0 then
	return _error_code, _mensaje, a_no_remesa;
end if

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;
