-- Procedimiento para actualizar el resultado del proceso electrónico en las tablas históricas
-- Creado    : 20/05/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob366;
create procedure sp_cob366(
a_fecha_desde	date,
a_fecha_hasta	date,
a_no_cuenta		varchar(19) default "%",
a_no_documento	char(20) default "%",
a_proceso		char(3))
returning	varchar(100)					as Pagador, 			--_nom_pagador
			char(20)						as Poliza,				--_no_documento,
			varchar(50)						as Banco,				--_nom_banco,
			varchar(19)						as Cuenta,				--_no_tarjeta,
			char(7)							as Fecha_Expiracion,	--_fecha_exp,
			dec(16,2)						as Monto_a_Descontar,	--_monto_descuento,
			varchar(50)						as Resultado,			--_motivo_rechazo,
			smallint						as Pronto_Pago,			--_pronto_pago,
			datetime year to fraction(5)	as Fecha_Creado,		--_fecha_creado,
			char(8)							as Usuario_Creo,		--_user_creo,
			datetime year to fraction(5)	as Fecha_Procesado,		--_fecha_procesado,
			char(8)							as Usuario_Proceso;		--_user_proceso;

define _nom_pagador			varchar(100);
define _error_desc			varchar(100);
define _motivo_rechazo		varchar(50);
define _nom_banco			varchar(50);
define _no_tarjeta			varchar(19);
define _no_cuenta			varchar(17);
define _no_documento		char(20);
define _user_proceso		char(8);
define _user_creo			char(8);
define _fecha_exp			char(7);
define _no_lote				char(5);
define _cod_banco			char(3);
define _monto_descuento		dec(16,2);
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _pronto_pago			smallint;
define _cnt_existe			smallint;
define _fecha_procesado		datetime year to fraction(5);
define _fecha_creado		datetime year to fraction(5);

--set debug file to "sp_cob363.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error_desc,'','','','',0.00,'',_error,current,'',current,'';
end exception 

if a_proceso = 'TCR' then

	if a_fecha_desde = '01/01/1900' then
		if a_no_documento <> '%' then
			select min(vigencia_inic)
			  into a_fecha_desde
			  from emipomae
			 where no_documento = a_no_documento;
		elif a_no_cuenta <> '%' then
			select min(date(date_added))
			  into a_fecha_desde
			  from cobtatrabk
			 where no_tarjeta like a_no_cuenta;			
		end if
	end if

	foreach
		select nombre,
			   no_tarjeta,
			   fecha_exp,
			   no_documento,
			   monto,
			   upper(motivo_rechazo),
			   pronto_pago,
			   date_added,
			   user_added,
			   date_procesado,
			   user_proceso
		  into _nom_pagador,
			   _no_tarjeta,
			   _fecha_exp,
			   _no_documento,
			   _monto_descuento,
			   _motivo_rechazo,
			   _pronto_pago,
			   _fecha_creado,
			   _user_creo,
			   _fecha_procesado,
			   _user_proceso
		  from cobtatrabk
		 where date(date_added) between a_fecha_desde and a_fecha_hasta
		   and no_tarjeta like a_no_cuenta
		   and no_documento like a_no_documento

		select count(*)
		  into _cnt_existe
		  from cobtahab
		 where no_tarjeta = _no_tarjeta;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe > 0 then
			select cod_banco
			  into _cod_banco
			  from cobtahab
			 where no_tarjeta = _no_tarjeta;
		else
			foreach
				select cod_banco
				  into _cod_banco
				  from cobcampl
				 where no_tarjeta = _no_tarjeta
				 order by fecha_cambio desc
				exit foreach;
			end foreach
		end if
		
		if _cod_banco is null then
			let _cod_banco = '';
		end if

		if _cod_banco <> '' then
			select nombre
			  into _nom_banco
			  from chqbanco
			 where cod_banco = _cod_banco;
		else
			let _nom_banco = 'NO DISPONIBLE';
		end if
		
		return	_nom_pagador,
				_no_documento,
				_nom_banco,
				_no_tarjeta,
				_fecha_exp,
				_monto_descuento,
				_motivo_rechazo,
				_pronto_pago,
				_fecha_creado,
				_user_creo,
				_fecha_procesado,
				_user_proceso with resume;
	end foreach;
elif a_proceso = 'ACH' then
	let _fecha_exp = '';

	if a_fecha_desde = '01/01/1900' then
		if a_no_documento <> '%' then
			select min(vigencia_inic)
			  into a_fecha_desde
			  from emipomae
			 where no_documento = a_no_documento;
		elif a_no_cuenta <> '%' then
			select min(date(date_added))
			  into a_fecha_desde
			  from cobcutmpbk
			 where no_cuenta like a_no_cuenta;
		end if
	end if

	let _pronto_pago = 0;

	foreach
		select nombre_pagador,
			   no_cuenta,
			   no_documento,
			   monto,
			   upper(motivo_rechazo),
			   date_added,
			   user_added,
			   date_procesado,
			   user_proceso
		  into _nom_pagador,
			   _no_cuenta,
			   _no_documento,
			   _monto_descuento,
			   _motivo_rechazo,
			   _fecha_creado,
			   _user_creo,
			   _fecha_procesado,
			   _user_proceso
		  from cobcutmpbk
		 where date(date_added) between a_fecha_desde and a_fecha_hasta
		   and no_cuenta like a_no_cuenta
		   and no_documento like a_no_documento

		select count(*)
		  into _cnt_existe
		  from cobcuhab
		 where no_cuenta = _no_cuenta;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe > 0 then
			select cod_banco
			  into _cod_banco
			  from cobcuhab
			 where no_cuenta = _no_cuenta;
		else
			foreach
				select cod_banco
				  into _cod_banco
				  from cobcampl
				 where no_cuenta = _no_cuenta
				 order by fecha_cambio desc
				exit foreach;
			end foreach
		end if
		
		if _cod_banco is null then
			let _cod_banco = '';
		end if

		if _cod_banco <> '' then
			select nombre
			  into _nom_banco
			  from chqbanco
			 where cod_banco = _cod_banco;
		else
			let _nom_banco = 'NO DISPONIBLE';
		end if
		
		return	_nom_pagador,
				_no_documento,
				_nom_banco,
				_no_cuenta,
				_fecha_exp,
				_monto_descuento,
				_motivo_rechazo,
				0,
				_fecha_creado,
				_user_creo,
				_fecha_procesado,
				_user_proceso with resume;
	end foreach;
end if

end
end procedure;