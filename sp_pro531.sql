-- Procedimiento que genera el cambio de plan de pagos 
-- 
-- Creado     : 08/01/2013 - Autor: Amado Perez M.
--execute procedure sp_pro531('1916073','DEIVID',0.00,'001','001','008')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro531;

create procedure sp_pro531(
a_no_poliza		char(10),
a_usuario		char(8),
a_saldo         dec(16,2),
a_compania      char(3),
a_sucursal     	char(3),
a_cod_formapago	char(3))
returning	integer,
            char(50);

define _descripcion		char(50);
define _error_desc		char(50);
define _no_cambio		char(6);
define _endoso_char		char(5);     
define _no_unidad		char(5);     
define _null			char(1);
define _cod_formapago   char(3);
define v_saldo          dec(16,2);
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_pro531.trc";

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _null = null;  -- Para campos null
let _no_cambio = sp_sis13("001", "COB", "02", "par_plan_pago");  -- Crear en parcont

insert into cobcampl(
		no_documento,
		no_cambio,
		no_poliza,
		cod_formapag,
		cod_perpago,
		no_pagos,
		fecha_primer_pago,
		fecha_cambio,
		actualizado,
		saldo,
		no_factura,
		tiene_impuesto,
		user_added,
		cod_pagador,
		no_tarjeta,
		fecha_exp,
		cod_banco,
		monto_visa,
		periodo_tar,
		tipo_tarjeta,
		no_cuenta,
		tipo_cuenta,
		no_unidad)
select	no_documento,
		_no_cambio,
		no_poliza,
		a_cod_formapago,
		cod_perpago,
		no_pagos,
		fecha_primer_pago,
		today,
		1,
		a_saldo,
		no_factura,
		tiene_impuesto,
		a_usuario,
		_null,
		_null,
		_null,
		_null,
		_null,
		_null,
		_null,
		_null,
		_null,
		_null
  from emipomae
 where no_poliza = a_no_poliza;

select cod_formapag
  into _cod_formapago
  from emipomae
 where no_poliza = a_no_poliza;

update emipomae 
   set cod_formapag = a_cod_formapago
 where no_poliza    = a_no_poliza;
 
if _cod_formapago = '005' then
	-- eliminacion del la forma de pago ach
	call sp_sis31(
				a_compania,
				a_sucursal,
				a_no_poliza,
				a_usuario,
				1,
				_no_cambio)
	returning	_error,_endoso_char,_no_unidad;

	if _error <> 0 then
		return _error, "error eliminando de ach";
	end if
elif _cod_formapago = '003' then
	--eliminacion de forma de pago tarjeta de credito
	call sp_sis23(
	a_compania,
	a_sucursal,
	a_no_poliza,
	a_usuario,
	1,
	_no_cambio)
	returning _error,_endoso_char,_no_unidad;

	if _error <> 0 then
		return _error, "error eliminando tarjetas";
	end if
end if
end

return 0, "Actualizacion Exitosa";
end procedure