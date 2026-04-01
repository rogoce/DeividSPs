-- Procedimiento para la aplicacion de la nueva ley	de seguros - Cobranza Legal
-- Creado    : 04/01/2013 - Autor: Amado Perez
-- Modficado : 29/08/2013 - Autor: Demetrio Hurtado Almanza

drop procedure sp_pro517;

create procedure sp_pro517(a_no_poliza char(10),a_no_endoso char(5))
returning	smallint,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _no_factura		char(10);
define _user_added		char(8);
define _periodo			char(7);
define _no_endoso		char(5);
define _cod_tipocalc	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _prima_bruta		dec(16,2);
define v_saldo			dec(16,2);
define _error_isam		integer;
define _error			integer;
define _fecha			date;

--set debug file to "sp_pro517.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha = current;

select no_documento,
       no_factura,
	   periodo,
	   user_added,
	   cod_endomov,
	   cod_tipocalc,
	   cod_sucursal,
	   cod_tipocan
  into _no_documento,
       _no_factura,
	   _periodo,
	   _user_added,
	   _cod_endomov,
	   _cod_tipocalc,
	   _cod_sucursal,
	   _cod_tipocan
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cod_endomov  = "002" and  -- Cancelacion de Poliza
   _cod_tipocan	 = "001" and  -- Falta de Pago
   _cod_tipocalc = "001" then -- Prorrata

	-- Procesos de Cobros Legales Version 2
	-- 29/08/2013
	-- Demetrio Hurtado
--elif a_no_poliza = '947036' and a_no_endoso = '00003' then
else
	return 0, "No es cancelacion a prorrata por falta de pago";
end if

select cod_compania
  into _cod_compania
  from emipomae
 where no_poliza = a_no_poliza;

call sp_cob115b(_cod_compania,"",_no_documento,"") returning v_saldo;

if v_saldo <= 0 then
	Return 0, "Poliza con saldo menor o igual a 0";
end if

set lock mode to wait;

-- Insertando en la tabla cobranza externa

delete from coboutleg 
 where no_documento = _no_documento;

insert into coboutleg(
		no_documento,
		fecha,
		no_poliza,
		prima,
		pagos,
		saldo,
		cod_abogado)
values(	_no_documento, 
		_fecha,
		a_no_poliza,
		v_saldo,
		0,
		v_saldo,
		"001"); -- Por defecto ASEGURADORA ANCON -- tabla recaboga

set isolation to dirty read;

-- Creacion del endoso de cancelacion por saldo
call sp_pro518(a_no_poliza,_user_added,v_saldo,_cod_sucursal,_cod_tipocan) returning _error,_error_desc,_no_endoso;

if _error <> 0 then
	return _error, _error_desc;
end if
/*
-- Insertando cambio de plan de pago
call sp_pro519(
a_no_poliza,
_user_added,
v_saldo,
_cod_compania,
_cod_sucursal,
'087')
returning	_error,
			_error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if*/
end

return 0,'aplicacion de nueva ley exitoso';

end procedure 