-- Procedimiento para la inserción inicial de registros a las campañas de la nueva ley de seguros (Proceso de Primera Letra)
-- Creado    : 08/04/2015 - Autor: Román Gordón
-- Modificado: COpia para llevar el controld e carga VOCEM
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob414;
create procedure sp_cob414(a_fecha_desde date, a_dias_vencida smallint)
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(19);
define _cod_campana			char(10);
define _cod_cliente			char(10);
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _error_isam			integer;
define _error				integer;

--set debug file to "sp_cob356.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	drop table if exists tmp_cascliente;
	drop table if exists tmp_caspoliza;
	return _error,_error_desc;
end exception  

select date(valor_parametro)
  into a_fecha_desde
  from inspaag
 where codigo_parametro = 'fecha_inic_anula';

let a_dias_vencida = 30;

call sp_cob356(a_fecha_desde,a_dias_vencida) returning _error, _error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if

foreach
	select cod_campana,
		   cod_cliente
	  into _cod_campana,
		   _cod_cliente
	  from tmp_cascliente

	select count(*)
	  into _cnt_cascliente
	  from cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	if _cnt_cascliente is null then
		let _cnt_cascliente = 0;
	end if
	
	if _cnt_cascliente = 0 then
		insert into cascliente
		select *
		  from tmp_cascliente
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;
	end if
	
	foreach
		select no_documento
		  into _no_documento
		  from tmp_caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente

		select count(*)
		  into _cnt_caspoliza
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente
		   and no_documento = _no_documento;

		if _cnt_caspoliza is null then
			let _cnt_caspoliza = 0;
		end if
		
		if _cnt_caspoliza > 0 then
			continue foreach;
		end if

		insert into caspoliza
		select no_documento,
			   cod_cliente,
			   dia_cobros1,
			   dia_cobros2,
			   a_pagar,
			   tipo_mov,
			   cod_campana
		  from tmp_caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente
		   and no_documento = _no_documento;
	end foreach
end foreach

drop table if exists tmp_cascliente;
drop table if exists tmp_caspoliza;

return 0,'Actualización Exitosa';
end
end procedure;