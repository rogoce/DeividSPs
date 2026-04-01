-- Procedimiento para correccion de los registros de tmp_venc062010oct 
-- 
-- Creado     : 27/10/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par324;

create procedure "informix".sp_par324()
returning char(20),
          char(10),
		  dec(16,2);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_factura		char(10);
define _periodo			char(7);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;
define _cod_pagador		char(10);
define _user_added		char(8);

--set debug file to "sp_par324.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error_desc, _error, 0;
end exception

let _cantidad   = 0;
let _user_added = "GERENCIA";

foreach
 select poliza
   into _no_documento
   from deivid_tmp:tmp_venc062010oct
  where cancelada = 1
--    and poliza    = "1909-00212-01"  
--    and periodo   = "2009-12"
  order by poliza

	let _cantidad    = _cantidad + 1;
	let _no_poliza   = sp_sis21(_no_documento);
	let _prima_bruta = sp_cob174(_no_documento);

	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	{
	update cliclien 
	   set mala_referencia = 1, 
	       cod_mala_refe   = '001', 
	       desc_mala_ref   = "CANCELACION POR FALTA DE PAGO",
		   user_mala_refe  = _user_added
	 where cod_cliente     = _cod_pagador;
	}

	if _prima_bruta > 0.1 then

		return _no_documento,
		       _cod_pagador,
			   _prima_bruta
			   with resume;

	end if

--	if _cantidad >= 1 then
--		exit foreach;
--	end if

end foreach

end 

return "", "", 0; 

end procedure