-- Ajuste de las letras de pago de las polizas por nueva ley de seguros cuando la poliza recibe un endoso
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro541a;

create procedure sp_pro541a()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _monto_pendiente	dec(16,2);
define _letra_residuo	dec(16,2);
define _monto_residuo	dec(16,2);
define _monto_pagado	dec(16,2);
define _prima_bruta		dec(16,2);
define _nuevo_monto		dec(16,2);
define _resto           dec(16,2);
define _cnt_no_pagada	smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_pro541.trc";
--trace on;

foreach
	select distinct no_poliza
	  into _no_poliza
	  from emiletra

	select count(*)
	  into _cnt_no_pagada
	  from emiletra
	 where no_poliza = _no_poliza
	   and pagada = 0;
	
	if _cnt_no_pagada is null then
		let _cnt_no_pagada = 0;
	end if
	
	if _cnt_no_pagada = 0 then
		continue foreach;
	end if
	
	foreach
		select no_endoso
		  into _no_endoso
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso <> '00000'
		   and prima_bruta <> 0
		   and periodo = '2014-01'

		call sp_pro541(_no_poliza,_no_endoso) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if
	end foreach
end foreach
end

return 0,'Actualización Exitosa';
end procedure;