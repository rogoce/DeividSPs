-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro544('')
drop procedure sp_pro544;
create procedure sp_pro544(a_no_documento char(20))
returning	int,
			char(50);

define _error_desc			char(50);
define _no_poliza_c			char(10);
define _no_poliza			char(10);
define _monto_pendiente		dec(16,2);
define _letra_residuo		dec(16,2);
define _monto_residuo		dec(16,2);
define _monto_pagado		dec(16,2);
define _total_pen			dec(16,2);
define _monto_pen			dec(16,2);
define _monto_letra			dec(16,2);
define _monto_bruto			dec(16,2);
define _residuo				dec(16,2);
define _resto           	dec(16,2);
define _cnt_no_pagada		smallint;
define _letra_pagada		smallint;
define _no_letra_c			smallint;
define _ult_letra			smallint;
define _no_letra			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_venc			date;
define _fecha_vencimiento	date;

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
		   monto_pag,
		   fecha_vencimiento,
		   pagada
	  into _no_poliza_c,
		   _no_letra_c,
		   _letra_residuo,
		   _fecha_vencimiento,
		   _pagada
	  from emiletra
	 where no_documento = a_no_documento
	   and monto_pag > 0
	 order by fecha_vencimiento desc
--	   and monto_pen < 0

	select sum(monto_pen)
	  into _total_pen
	  from emiletra
	 where no_documento = a_no_documento
	   and fecha_vencimiento < _fecha_vencimiento;

	if _total_pen is null then
		let _total_pen = 0.00;
	end if

	if _total_pen >= 0.00 then
		exit foreach;
	end if

	if _letra_residuo > 0 then
		let _letra_residuo = _letra_residuo * -1;
	end if
	
	let _residuo = _letra_residuo;	
	let _monto_residuo = 0.00;

	foreach
		select no_poliza,
			   no_letra,
			   monto_pag,
			   monto_pen,
			   monto_letra,
			   fecha_vencimiento
		  into _no_poliza,
			   _no_letra,
			   _monto_pagado,
			   _monto_pendiente,
			   _monto_letra,
			   _fecha_venc
		  from emiletra
		 where no_documento = a_no_documento
		   and monto_pen > 0
		 order by fecha_vencimiento
	
		if _fecha_venc > _fecha_vencimiento then
			exit foreach;
		end if

		let _letra_pagada = 0;

		if abs(_residuo) >= _monto_pendiente then
			let _letra_pagada = 1;
			let _monto_pen = 0.00;
			let _monto_pagado = _monto_letra;
		else
			let _monto_pen = _monto_pendiente + _residuo;
			let _monto_pagado = _monto_pagado - _residuo;
		end if

		let _residuo = _residuo + _monto_pendiente;
		let _monto_residuo = _monto_residuo + _monto_pendiente;

		update emiletra
		   set pagada = _letra_pagada,
			   monto_pen = _monto_pen,
			   monto_pag = _monto_pagado
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
	       monto_pen = monto_pen + _monto_residuo,
		   pagada = 0
	 where no_poliza = _no_poliza_c
	   and no_letra = _no_letra_c;
	
	--return 0,'No_Poliza: ' || _no_poliza_c || '		no_documento: ' || a_no_documento with resume;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;