-- Procedure que crea los Cheques de Devolucion de Prima por Poliza Cancelada - Perdida Total
-- 
-- Creado    : 28/03/2013 - Autor: Federico Coronado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che138_bk;		

create procedure "informix".sp_che138_bk(a_no_remesa char(10), a_saldo integer)
returning integer,
          char(100),
          char(10),
          char(50);

define _autorizado		smallint;
define _pagado			smallint;
define _en_firma 		smallint;
define _cobrado			smallint;
define _tipo_formato    smallint;
define _renglon_che		smallint;
define _error			integer;
define _error_isam		integer;
define _prima_neta      dec(16,2);
define _fecha_cobrado	date;
define _cod_ruta		char(3);
define _centro_costo	char(3);
define _error_desc		char(100);
define _origen_cheque	char(1);
define _periodo			char(7);
define _banco			char(3);
define _chequera		char(3);
define _tipo_requis		char(1);
define _cod_cliente		char(10);
define _cod_agente		char(3);
define _descripcion_suc char(30);
define _e_mail          char(50);
define _nombre			varchar(100);
define _no_documento	char(20);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, null, null;
end exception



--Banco y Chequera

let _origen_cheque = "6";	--> Devolucion de Prima perdida total
let _periodo       = sp_sis39(_fecha);

let _autorizado    = 1;
let _pagado	       = 0;
let _en_firma      = 4;

let _cobrado       = 0;
let _fecha_cobrado = null;

let _cod_ruta      = "001";
let _monto = a_saldo;
	
--Centro de costo
call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;	



 let _banco    	   = "001";
 let _chequera	   = "001";
 let _tipo_requis   = "C";
 let _cod_cliente   = null;
 let _cod_agente    = null;
 let _descripcion_suc = "";
 let _e_mail        = null;



	 select cod_contratante, no_documento, prima_neta
	   into _cod_cliente, _no_documento, _prima_neta
	   from emipomae
	  where no_poliza = _no_poliza;		   --> Buscando Contratante de la poliza

	 select nombre
	   into _nombre
	   from cliclien
	  where cod_cliente = _cod_cliente;


	if a_sucursal is not null then
		select descripcion
		  into _descripcion_suc
		 from insagen
		where codigo_agencia  = a_sucursal
		  and codigo_compania = '001';

		let _descripcion_suc = '-' || trim(_descripcion_suc);

	end if

	--No. Requisicion

 let _renglon_che = 0;
/*If _no_requis = null Then*/
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
	cod_ruta,
	en_firma
	)
	VALUES(
	_no_requis,
	_cod_cliente,
	_cod_agente,
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
	_cod_ruta,
	_en_firma
	);

	let _renglon_che = _renglon_che + 1;

	let _detalle     = "DEVOLUCION DE PRIMA X CANCELACION DE LA POLIZA" || trim(_no_documento);

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
/*
	let _renglon_che = _renglon_che + 1;
	let _detalle     = "APLICADO EN REMESA NO.: " || trim(a_no_remesa) || " RENGLON: " || _renglon_rem;

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
	let _detalle     = "POLIZA NO.: " || trim(_no_documento);

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
*/
	-- Cuentas del Cheque

	if _monto > 0 then
		let _debito  = _monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto * - 1;
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
	NULL,
	1,
	_centro_costo
	);
	
	INSERT INTO chqchpol(
	no_requis,
	no_documento,
	no_poliza,
	monto,
	prima_neta,
	flag_web_corr
	)
	VALUES(
	_no_requis,
	_no_documento,
	_no_poliza,
	_monto,
	_prima_neta,
	0
	);
/*else
 select max(renglon)
   into _renglon_che
   from chqchdes
  where no_requis = _no_requis;

   update chqchmae
      set monto = monto + _monto
	where no_requis = _no_requis;

	-- Cuentas del Cheque

	if _monto > 0 then
		let _debito  = _monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto * - 1;
	end if

   update chqchmae
      set debito  = debito + _debito,
	   	  credito = credito + _credito
	where no_requis = _no_requis
	  and renglon = 1;

	let _detalle     = "RENGLON: " || _renglon_rem || "POLIZA NO.: " || trim(_no_documento);
	let _renglon_che = _renglon_che + 1;

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

end if */
end
return 0, "Actualizacion Exitosa", _no_requis, _e_mail;
end procedure
