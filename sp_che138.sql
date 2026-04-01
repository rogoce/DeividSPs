-- Procedure que crea los Cheques de Devolucion de Prima por Poliza Cancelada - Nueva Ley de Seguro.
-- 
-- Creado    : 20/08/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che138;		

create procedure "informix".sp_che138(a_no_remesa char(10), a_renglon integer)
returning integer,
          char(100),
          char(10),
          varchar(50);

define _doc_remesa		char(20);
define _cod_auxiliar	char(5);
define _renglon_rem		smallint;
define _cod_cliente		char(10);
define _nombre			varchar(100);
define _monto			dec(16,2);
define _fecha			date;
define _user_added      char(8);
define _user_posteo     char(8);
define _no_documento	char(20);

define _no_requis		char(10);
define a_compania       char(3);
define a_sucursal		char(3);
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
define _detalle			varchar(100);
define _no_poliza		char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);
define _cantidad		integer;
define _fecha_recibo2	date;
define _cnt             integer;
define _no_eval         char(10);
define _cod_suc         char(3);
define _descripcion_suc char(30);
define _en_firma 		smallint;
define _comis_desc     	smallint;
define _monto_descontado dec(16,2);
define _tipo_formato    smallint;
define _cod_agente		char(5);
define _cntrem          integer;
define _e_mail          varchar(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, null, null;
end exception

let _doc_remesa   = sp_sis15('PCANDEVPR'); 
let _no_recibo    = null;
let _cnt          = 0;
let _cntrem       = 0;
let _no_requis	  = null;

{
select count(*)
  into _cantidad
  from cobredet
 where no_remesa    = a_no_remesa
   and tipo_mov     = "P";  	

if _cantidad = 0 then

	return 0, "Actualizacion Exitosa";

end if
}

select cod_compania,
       cod_sucursal,
	   date_posteo,
	   user_posteo,
	   user_added
  into a_compania,
       a_sucursal,
	   _fecha,
	   _user_posteo,
	   _user_added
  from cobremae
 where no_remesa = a_no_remesa;

--Banco y Chequera

let _origen_cheque = "K";	--> Devolucion de Prima
let _periodo       = sp_sis39(_fecha);

let _autorizado    = 1;
let _pagado	       = 0;
let _en_firma      = 4;

let _cobrado       = 0;
let _fecha_cobrado = null;

let _cod_ruta         = "001";
	
--Centro de costo
call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;	

foreach
 select	no_recibo,
        renglon,
		doc_remesa,
		desc_remesa,
		monto,
		no_poliza,
		comis_desc,
		monto_descontado
   into	_no_recibo,
        _renglon_rem,
		_no_documento,
		_nombre,
		_monto,
		_no_poliza,
		_comis_desc,
		_monto_descontado
   from cobredet
  where no_remesa    = a_no_remesa
    and renglon      = a_renglon

 let _banco    	   = "001";
 let _chequera	   = "001";
 let _tipo_requis   = "C";
 let _cod_cliente   = null;
 let _cod_agente    = null;
 let _descripcion_suc = "";
 let _e_mail        = null;

 if _comis_desc = 1 then
	let _monto = _monto - _monto_descontado;
 end if

 -- Verificando si viene de corredor (pagos electronicos)

 let _tipo_formato = 0;

 select count(*)
   into _cnt
   from cobpaex0
  where no_remesa_ancon = a_no_remesa;

 if _cnt = 1 then
	select tipo_formato, cod_agente
	  into _tipo_formato, _cod_agente
	  from cobpaex0
	 where no_remesa_ancon = a_no_remesa;
 end if

 if _tipo_formato = 1 then --> pago de tipo corredor
	 select nombre, e_mail
	   into _nombre, _e_mail
	   from agtagent
	  where cod_agente = _cod_agente;

    -- Verificando para unificar los montos para sacar uno solo cheque
    select count(*)
	  into _cntrem
	  from cobdevleg
	 where no_remesa = a_no_remesa;

	if _cntrem > 0 then
	    foreach
			select no_requis 
			  into _no_requis
			  from cobdevleg
		     where no_remesa = a_no_remesa
            if _no_requis = '' then
				let _no_requis = null;
			end if
            exit foreach;
		end foreach
	end if
 else
	let _cod_agente = null;
	 select cod_contratante
	   into _cod_cliente
	   from emipomae
	  where no_poliza = _no_poliza;		   --> Buscando Contratante de la poliza

	 select nombre
	   into _nombre
	   from cliclien
	  where cod_cliente = _cod_cliente;

 	 call sp_rec183('001', _cod_cliente, _banco, _chequera) returning _banco, _chequera, _tipo_requis;
 end if



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

If _no_requis is null Then
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

	let _detalle     = "DEVOLUCION DE PRIMA X CANCELACION" || TRIM(_descripcion_suc);

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
else
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

   update chqchcta
      set debito  = debito + _debito,
	   	  credito = credito + _credito
	where no_requis = _no_requis
	  and renglon = 1;

	let _detalle     = "RENGLON: " || _renglon_rem || " POLIZA NO.: " || trim(_no_documento);
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

end if 
end foreach
end

return 0, "Actualizacion Exitosa", _no_requis, _e_mail;

end procedure
