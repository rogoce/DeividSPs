-- Creacion de las letras de pago de las polizas por nueva ley de seguros
-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza 
-- modificado: 09/12/2013 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525c;

create procedure sp_pro525c()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_poliza		char(10);
define _dias_letra_dec	dec(16,2);
define _prima_bruta		dec(16,2);
define _monto_letra		dec(16,2);
define _mes_dec			dec(16,2);
define _resto           dec(16,2);
define _dias_vigencia	smallint;
define _letra_pagada	smallint;
define _mes_cancela		smallint;
define _ano_cancela		smallint;
define _mes_gracia		smallint;
define _ano_gracia		smallint;
define _mes_letra		smallint;
define _ano_letra		smallint;
define _no_pagos		smallint;
define _mes_int			smallint;
define _letra			smallint;
define _dias_letra		smallint;

define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_pro525b.trc";
--trace on;

foreach
	select distinct no_poliza
	  into _no_poliza
	  from emiletra
	 where pagada = 1
	
	call sp_pro525(_no_poliza) returning _error,_error_desc;
	
	if _error <> 0 then
		return _error,_error_desc;
	end if
end foreach

end

return 0, "Actualizacion Exitosa";
end procedure
