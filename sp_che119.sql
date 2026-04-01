-- Procedure que crea los Cheques de Devolucion de Prima en Suspenso.
-- 
-- Creado    : 20/08/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che119;
create procedure sp_che119(a_no_remesa char(10))
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

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);
define _cantidad		integer;
define _no_recibo2      char(10);
define _fecha_recibo2	date;
define _cnt             integer;
define _no_eval         char(10);
define _cod_suc         char(3);
define _descripcion_suc char(30);
define _doc_remesa2     char(30);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cod_auxiliar = "0127";
let _doc_remesa   = sp_sis15('CPDEVSUS');
let _no_recibo2   = null;

select count(*)
  into _cantidad
  from cobredet
 where no_remesa    = a_no_remesa
   and tipo_mov     = "M"
   and doc_remesa   = _doc_remesa
   and cod_auxiliar = _cod_auxiliar;  	

if _cantidad = 0 then
	return 0, "Actualizacion Exitosa";
end if

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
let _banco    	   = "001";
let _chequera	   = "001";

let _origen_cheque = "S";
let _periodo       = sp_sis39(_fecha);

let _autorizado    = 1;
let _pagado	       = 0;

let _cobrado       = 0;
let _fecha_cobrado = null;

let _tipo_requis   = "C";
let _cod_ruta      = "001";
let _cod_cliente   = null;
let _no_eval       = null;
let _cod_suc       = null;
let _descripcion_suc = "";
	
--Centro de costo
call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

foreach
	select	no_recibo,
			renglon,
			desc_remesa,
			monto,
			no_recibo2
	  into	_no_recibo,
			_renglon_rem,
			_nombre,
			_monto,
			_no_recibo2
	  from cobredet
	 where no_remesa    = a_no_remesa
	   and tipo_mov     = "M"
	   and doc_remesa   = _doc_remesa
	   and cod_auxiliar = _cod_auxiliar  	

	let _fecha_recibo  = null;
	let _fecha_recibo2 = null;

    select count(*)
	  into _cnt
	  from emievalu
	 where no_recibo = _no_recibo;

	if _cnt = 0 then
		foreach	
			select doc_remesa
			  into _doc_remesa2
			  from cobredet
			 where no_remesa    = a_no_remesa
	           and tipo_mov     = "A"
	   
		    select count(*)
			  into _cnt
			  from emievalu
			 where no_recibo = _doc_remesa2;
		
            if _cnt > 0 then		
				exit foreach;
			end if
	    end foreach
		
		if _cnt = 0 then
			let _cod_cliente = null;
		else
			foreach
				select cod_contratante,
					   no_evaluacion,
					   cod_sucursal
				  into _cod_cliente,
					   _no_eval,
					   _cod_suc
				  from emievalu
				 where no_recibo = _doc_remesa2

				select nombre
				  into _nombre
				  from cliclien
				 where cod_cliente = _cod_cliente;

				exit foreach;
			end foreach
			if _cod_suc is not null then
				select descripcion
				  into _descripcion_suc
				 from insagen
				where codigo_agencia  = _cod_suc
				  and codigo_compania = '001';

				let _descripcion_suc = '-' || trim(_descripcion_suc);
			end if		
		end if
	else
		foreach
			select cod_contratante,
			       no_evaluacion,
				   cod_sucursal
			  into _cod_cliente,
			       _no_eval,
				   _cod_suc
			  from emievalu
			 where no_recibo = _no_recibo

			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente;

			exit foreach;
		end foreach
		if _cod_suc is not null then
			select descripcion
			  into _descripcion_suc
			 from insagen
			where codigo_agencia  = _cod_suc
			  and codigo_compania = '001';

			let _descripcion_suc = '-' || trim(_descripcion_suc);

		end if
	end if

   foreach	
		select fecha
		  into _fecha_recibo
		  from cobredet
		 where no_recibo = _no_recibo
		   and tipo_mov  = "E"
		exit foreach;
   end foreach

   if _no_recibo2 is not null then
	   foreach	
		select fecha
		  into _fecha_recibo2
		  from cobredet
		 where no_recibo = _no_recibo2
		   and tipo_mov  = "E"
			exit foreach;
	   end foreach
	end if

	if _fecha_recibo is null then
		return 1, "No Existe Creacion Suspenso Recibo: " || _no_recibo || " Renglon: " || _renglon_rem;
	end if  

	if _nombre is null then
		return 1, "No Existe Cliente Para Devolucion, Renglon: " || _renglon_rem;
	end if  

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
	_cod_cliente,
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
	let _detalle     = "DEVOLUCION DE PRIMA EN SUSPENSO" || TRIM(_descripcion_suc);

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
	let _detalle     = "RECIBO: " || trim(_no_recibo) || " DEL: " || _fecha_recibo;
	let _detalle     = trim(_detalle);

  	if _no_recibo2 is not null and _fecha_recibo2 is not null then
		let _detalle = _detalle || " - RECIBO: " || trim(_no_recibo2) || " DEL: " || _fecha_recibo2;
  	end if

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
	_cod_auxiliar,
	1,
	_centro_costo
	);

	INSERT INTO chqctaux(
	no_requis,
	renglon,
	cuenta,
	cod_auxiliar,
	debito,
	credito,
	tipo,
	centro_costo
	)
	VALUES(
	_no_requis,
	1,
	_doc_remesa,
	_cod_auxiliar,
	_debito,
	_credito,
	1,
	_centro_costo
	);

end foreach
end
return 0, "Actualizacion Exitosa";
end procedure
