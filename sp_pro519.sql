-- Procedimiento que genera el cambio de plan de pagos (proceso de nueva ley de seguros )
-- 
-- Creado     : 08/01/2013 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro519;

create procedure sp_pro519(
a_no_poliza		char(10),
a_usuario		char(8),
a_saldo			dec(16,2),
a_compania		char(3),
a_sucursal		char(3),
a_cod_formpag	char(3))
returning		integer,
				char(50);

define _descripcion		char(50);
define _error_desc		char(50);
define _no_cambio		char(6);
define _endoso_char		char(5);
define _no_unidad		char(5);
define _null			char(1);
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_cob253.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _null= null;  -- Para campos null

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
no_unidad
)
select no_documento,
	   _no_cambio,
	   no_poliza,
	   a_cod_formpag,
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

update emipomae 
   set cod_formapag = a_cod_formpag
 where no_poliza    = a_no_poliza;

call sp_sis23(
a_compania,
a_sucursal,
a_no_poliza,
a_usuario,
1,
_no_cambio
) returning _error,
		    _endoso_char, 
		    _no_unidad;

if _error <> 0 then
	return _error, "Error eliminando tarjetas";
end if

call sp_sis31(
a_compania,
a_sucursal,
a_no_poliza,
a_usuario,
1,
_no_cambio
) returning _error,
		    _endoso_char, 
		    _no_unidad;

if _error <> 0 then
	return _error, "Error eliminando cuentas";
end if

end

return 0, "Actualizacion Exitosa";
end procedure 