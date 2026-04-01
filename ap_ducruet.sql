-- Procedimiento para la aplicacion de la nueva ley	de seguros

-- Creado    : 04/01/2013 - Autor: Amado Perez
drop procedure ap_ducruet;

create procedure ap_ducruet()
returning smallint,
          char(250);

define _error					int;
define _error_isam				int;
define _prima_bruta         	dec(16,2);
define _no_documento			char(20);
define _no_factura				char(10);
define _error_desc				varchar(200);
define _periodo                 char(7);
define _fecha       			date;
define _cod_compania, _cod_sucursal	char(3);
define v_saldo                  dec(16,2);
define _user_added 				char(8);
define _no_endoso               char(5);
define _cod_endomov				char(3);
define _cod_tipocalc			char(3);
define _tipo_mov                smallint;
define _no_poliza               char(10);
define _cod_abogado             char(3);
define _cod_formapag        	char(3);
define _saldo					dec(16,2);
define _null			        char(1);
define _no_cambio		        char(6);


--set debug file to "ap_ducruet.trc";
--trace on;

begin work;

set isolation to dirty read;


begin 
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc;
end exception

let _fecha = current;

FOREACH	with hold
	select no_poliza,
		   no_documento
	  into _no_poliza,
		   _no_documento
	  from tmpducruet
	 where no_poliza[1,5] <> "ERROR" and procesado = 0

CALL sp_cob115b(
"001",
"",
_no_documento,
""
) RETURNING _saldo;


let _null		  = null;  -- Para campos null

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
select 
no_documento,
_no_cambio,
no_poliza,
"092",
cod_perpago,
no_pagos,
fecha_primer_pago,
today,
1,
_saldo,
no_factura,
tiene_impuesto,
"JMILLER",
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
where no_poliza = _no_poliza;

Update emipomae 
   Set cod_formapag = "092"
 Where no_poliza    = _no_poliza;

{CALL sp_sis23(
a_compania,
a_sucursal,
a_no_poliza,
a_usuario,
1,
_no_cambio
) RETURNING _error,
		    _endoso_char, 
		    _no_unidad;

if _error <> 0 then
	rollback work;
	return _error, "Error eliminando tarjetas";
end if
}

update tmpducruet
  set procesado = 1
where no_poliza = _no_poliza;


END FOREACH

end

commit work;

return 0,'aplicacion de ducruet';

end procedure


