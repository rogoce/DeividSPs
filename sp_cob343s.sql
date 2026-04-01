-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob343;

create procedure sp_cob343(a_no_remesa char(10))
returning	int,
			char(50);

define _error_desc		char(50);
define _no_poliza		char(10);
define _monto_pendiente	dec(16,2);
define _letra_residuo	dec(16,2);
define _monto_residuo	dec(16,2);
define _monto_pagado	dec(16,2);
define _monto_pen		dec(16,2);
define _monto_letra		dec(16,2);
define _monto_bruto		dec(16,2);
define _residuo			dec(16,2);
define _resto           dec(16,2);
define _cnt_no_pagada	smallint;
define _letra_pagada	smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob343.trc";
--trace on;

foreach
	select no_poliza,
		   monto
	  into _no_poliza,
		   _monto_bruto
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov in ('P','N','X')

	let _residuo = _monto_bruto;

	foreach
		select no_letra,
			   monto_letra,
			   monto_pen,
			   monto_pag
		  into _no_letra,
			   _monto_letra,
			   _monto_pendiente,
			   _monto_pagado
		  from emiletra
		 where no_poliza = _no_poliza
		   and pagada = 0
		 order by no_letra

		let _letra_pagada = 0;

		if _residuo >= _monto_pendiente then
			let _letra_pagada = 1;
			let _monto_pen = 0.00;
			let _monto_pagado = _monto_letra;
		else
			let _monto_pen = _monto_pendiente - _residuo;
			let _monto_pagado = _monto_pagado + _residuo;
		end if

		let _residuo = _residuo - _monto_pendiente;

		update emiletra
		   set pagada = _letra_pagada,
			   monto_pen = _monto_pen,
			   monto_pag = _monto_pagado
		 where no_poliza = _no_poliza
		   and no_letra = _no_letra;
		   
		if _residuo <= 0 then
			exit foreach;
		end if
	end foreach
end foreach

return 0,'Actualización Exitosa';
end
end procedure;