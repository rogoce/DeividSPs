drop procedure sp_cambio_formapag;

create procedure sp_cambio_formapag()
returning integer;

define _dia_cobros1		integer;
define _dia_cobros2		integer;
define v_documento		char(20);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_tipoprod	char(3);
define _cod_formapag	char(3);
define _fecha_1_pago	date;
define _dia_temporal	smallint;
define _estatus_poliza	smallint;
define _error			smallint;
define _tipo_forma      smallint;
define _no_documento	char(20);

--set debug file to "sp_cas027.trc";
--trace on;

set isolation to dirty read;

foreach
	select no_documento
	  into _no_documento
	  from emifacsa
	 where user_added = 'RGORDON'

	let _no_poliza = sp_sis21(_no_documento);

	select cod_pagador
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;
   --	call sp_cas027(_no_documento,_cod_cliente) returning _error; esto es solo para pasar a forma de pago ANC
   --	if _error = 0 then
	     --	else
		update emipomae
		   set cobra_poliza = "3",
		       cod_formapag = "008"
	     where no_poliza    = _no_poliza;
		 delete from emifacsa where no_documento = _no_documento and user_added = 'RGORDON';

--	end if
end foreach
end procedure 