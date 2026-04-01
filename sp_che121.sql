-- Procedure que crea los Cheques de Pago a Proveedor de Vida individual.
-- 
-- Creado    : 07/01/2011 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_che121;		

create procedure "informix".sp_che121(a_compania char(3),a_sucursal char(3),a_cod_cliente char(10),a_monto dec(16,2))
returning integer,
          char(100);

define _doc_remesa		char(20);
define _cod_auxiliar	char(5);
define _renglon_rem		smallint;
define _cod_cliente		char(10);
define _nombre			varchar(100);
define _monto			dec(16,2);
define _fecha			date;
define _user_added      char(8);
define _user_posteo     char(8);

define _no_requis		char(10);
define _banco			char(3);
define _chequera		char(3);
define _origen_cheque	char(1);
define _periodo			char(7);
define _autorizado		smallint;
define _pagado			smallint;
define _cobrado			smallint;
define _fecha_cobrado	date;
define _tipo_requis		char(1);
define _cod_ruta		char(3);
define _centro_costo	char(3);
define _renglon_che		smallint;
define _no_recibo		char(10);
define _fecha_recibo	date;
define _debito			dec(16,2);
define _credito			dec(16,2);
define _detalle			char(100);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);
define _cantidad		integer;
define _ruc             varchar(30);
define _digito_ver             char(2);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


let _doc_remesa = sp_sis15('HODEVI');


--Banco y Chequera
let _banco    	   = "001";
let _chequera	   = "001";

let _origen_cheque = "1";	--Contabilidad
let _fecha         = CURRENT;
let _periodo       = sp_sis39(_fecha);

let _autorizado    = 1;
let _pagado	       = 0;

let _cobrado       = 0;
let _fecha_cobrado = null;

let _tipo_requis   = "C";
let _cod_ruta      = "001";
let _cod_auxiliar  = NULL;

select cedula,
       digito_ver
  into _ruc,
       _digito_ver
  from cliclien
 where cod_cliente = a_cod_cliente;

if _ruc is null then
	let _ruc = '';
end if
if _digito_ver is null then
	let _digito_ver = '';
end if
	
--Centro de costo
call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

--No. Requisicion
let _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	insert into chqchmae(
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
	tipo_requis,
	impreso_ok,
	centro_costo,
	cod_ruta
	)
	VALUES(
	_no_requis,
	a_cod_cliente,
	null,
	_banco,
	_chequera,
	null,
	a_compania,
	a_sucursal,
	_origen_cheque,
	0,
	_fecha,
	_fecha,
	_autorizado,
	_pagado,
	_nombre,
	_cobrado,
	_fecha_cobrado,
	0,
	NULL,
	NULL,
	_monto,
	_periodo,
	_user_added,
	_user_posteo,
	_tipo_requis,
	1,
	_centro_costo,
	_cod_ruta
	);

	let _renglon_che = 1;
	let _detalle     = "CANCELA LOS SIGUIENTES RECIBOS SEGUN DETALLE ADJUNTO";

	-- Descripcion del Cheque
	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	_no_requis,
	_renglon_che,
	_detalle
	);

	let _renglon_che = _renglon_che + 1;
	let _detalle     = "RUC: " || trim(_ruc) || " D.V. " || _digito_ver;

	-- Descripcion del Cheque
	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	_no_requis,
	_renglon_che,
	_detalle
	);

	-- Cuentas del Cheque

	if a_monto > 0 then
		let _debito  = a_monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = a_monto * - 1;
	end if

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito,
	cod_auxiliar,
	tipo,
	centro_costo
	)
	VALUES(
	_no_requis,
	1,
	_doc_remesa,
	_debito,
	_credito,
	_cod_auxiliar,
	1,
	_centro_costo
	);

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
