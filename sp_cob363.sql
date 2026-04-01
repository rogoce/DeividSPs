-- Procedimiento para actualizar el resultado del proceso electrónico en las tablas históricas
-- Creado    : 20/05/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob363;
create procedure sp_cob363(a_no_remesa char(10))
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _motivo_rechazo		varchar(50);
define _no_documento		char(20);
define _user_added			char(8);
define _no_lote				char(5);
define _cod_chequera		char(3);
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _procesar			smallint;
define _rechazado			smallint;
define _fecha_actual		datetime year to fraction(5);

--set debug file to "sp_cob363.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception 

let _fecha_actual = current;

select user_added,
	   cod_chequera
  into _user_added,
	   _cod_chequera
  from cobremae
 where no_remesa = a_no_remesa;

if _cod_chequera not in ('029','031','030') then
	let _error_desc = 'La Remesa: '|| trim(a_no_remesa) || ' no es una remesa Electrónica';
	return 0,_error_desc;
end if

--Chequera de ACH
if _cod_chequera = '030' then
	foreach
		select no_lote,
			   no_tran,
			   rechazado,
			   no_documento,
			   motivo
		  into _no_lote,
			   _renglon,
			   _rechazado,
			   _no_documento,
			   _motivo_rechazo
		  from cobcutmp

		if _rechazado = 0 then
			let _motivo_rechazo = 'Pago Aprobado';
		end if

		update cobcutmpbk
		   set rechazado = _rechazado,
			   motivo_rechazo = _motivo_rechazo,
			   procesado = 1,
			   user_proceso = _user_added,
			   date_procesado = _fecha_actual
		 where no_lote = _no_lote
		   and no_tran = _renglon
		   and no_documento = _no_documento
		   and procesado = 0;
	end foreach;
else
	foreach
		select no_lote,
			   renglon,
			   procesar,
			   motivo_rechazo,
			   no_documento
		  into _no_lote,
			   _renglon,
			   _procesar,
			   _motivo_rechazo,
			   _no_documento
		  from cobtatra

		if _procesar = 1 then
			let _motivo_rechazo = 'Pago Aprobado';
		end if

		update cobtatrabk
		   set procesar = _procesar,
			   motivo_rechazo = _motivo_rechazo,
			   procesado = 1,
			   user_proceso = _user_added,
			   date_procesado = _fecha_actual
		 where no_lote = _no_lote
		   and renglon = _renglon
		   and no_documento = _no_documento
		   and procesado = 0;
	end foreach
end if

return 0,'Actualización Exitosa';
end
end procedure;