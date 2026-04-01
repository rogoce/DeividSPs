-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob343sim;

create procedure sp_cob343sim()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_remesa		char(10);
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob343sim.trc";
--trace on;

foreach
	select distinct d.no_remesa
	  into _no_remesa
	  from cobremae m, cobredet d, emiletra e
	 where m.no_remesa = d.no_remesa
	   and d.no_poliza = e.no_poliza
	   and m.periodo between '2014-01' and '2014-06'
	   and m.tipo_remesa in ('A','M','C','J','H')
	   and m.actualizado = 1

	call sp_cob343(_no_remesa) returning _error,_error_desc;
	
	if _error <> 0 then	
		return _error,_error_desc;
	end if
end foreach

{
select max(no_letra),
	   count(*)
  into _ult_letra,
	   _cnt_no_pagada
  from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0;

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
			   _monto_letra
			   _monto_pendiente,
			   _monto_pagado
		  from emiletra
		 where no_poliza = _no_poliza
		   and pagada = 0

		let _letra_pagada = 0;

		if _residuo > _monto_pendiente then
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
	end foreach
end foreach}

return 0,'Actualización Exitosa';

end
end procedure;