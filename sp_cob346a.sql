-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob346a;
create procedure sp_cob346a(a_no_documento char(20))
returning	int,
			char(50);

define _error_desc		char(50);
define _no_poliza_c		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
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
define _no_letra_c		smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_remesa	date;
define _fecha_pago		date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob346a.trc";
--trace on;

foreach
	select no_poliza,
		   no_letra,
		   monto_pen,
		   fecha_pago
	  into _no_poliza_c,
		   _no_letra_c,
		   _letra_residuo,
		   _fecha_remesa
	  from emiletra
	 where no_documento = a_no_documento
	   and monto_pen < 0
	 order by vigencia_inic

	select no_documento
	  into a_no_documento
	  from emipomae
	 where no_poliza = _no_poliza_c;

	let _residuo = _letra_residuo;

	select count(*)
	  into _cnt_no_pagada
	  from emiletra
	 where no_documento = a_no_documento
	   and monto_pen > 0;

	if _cnt_no_pagada is null then
		let _cnt_no_pagada = 0;
	end if

	if _cnt_no_pagada = 0 then
		continue foreach;
	end if

	let _monto_residuo = 0.00;

	{select max(no_remesa)
	  into _no_remesa
	  from cobredet
	 where doc_remesa = a_no_documento
	   and actualizado = 1;

	select fecha
	  into _fecha_remesa
	  from cobremae
	 where no_remesa = _no_remesa;}

	foreach
		select l.no_poliza,
			   l.no_letra,
			   l.monto_pag,
			   l.monto_pen,
			   l.monto_letra
		  into _no_poliza,
			   _no_letra,
			   _monto_pagado,
			   _monto_pendiente,
			   _monto_letra
		  from emiletra l, emipomae e
		 where l.no_poliza = e.no_poliza
		   and l.no_documento = a_no_documento
		   and l.monto_pen > 0
		 order by e.vigencia_inic,l.fecha_vencimiento

		let _letra_pagada = 0;
		let _fecha_pago = null;

		if abs(_residuo) >= _monto_pendiente then
			let _letra_pagada = 1;
			let _monto_pen = 0.00;
			let _monto_pagado = _monto_letra;
			let _fecha_pago = _fecha_remesa;
		else
			let _monto_pen = _monto_pendiente + _residuo;
			let _monto_pagado = _monto_pagado - _residuo;
		end if

		let _residuo = _residuo + _monto_pendiente;
		let _monto_residuo = _monto_residuo + _monto_pendiente;

		update emiletra
		   set pagada = _letra_pagada,
			   monto_pen = _monto_pen,
			   monto_pag = _monto_pagado,
			   fecha_pago = _fecha_pago
		 where no_poliza = _no_poliza
		   and no_letra = _no_letra;

		if _residuo >= 0 then
			let _monto_residuo = _monto_residuo - _residuo;
			exit foreach;
		elif _residuo = 0 then
			exit foreach;
		end if
	end foreach

	update emiletra
	   set monto_pag = monto_pag - _monto_residuo,
	       monto_pen = monto_pen + _monto_residuo
	 where no_poliza = _no_poliza_c
	   and no_letra = _no_letra_c;
	
	--return 0,'No_Poliza: ' || _no_poliza_c || '		no_documento: ' || a_no_documento with resume;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;