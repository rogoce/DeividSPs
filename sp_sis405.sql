--  Procedimiento para determinar Monto pagado de una vigencia
-- Creado: 08/05/2013 - Autor: Armando Moreno M.

drop procedure sp_sis405;
create procedure sp_sis405(a_no_poliza char(10))
returning decimal(16,2);


define _no_documento	char(20);
define _no_poliza		char(10);
define _tipo_mov		char(1);
define _prima_bruta		dec(16,2);
define _nueva_letra		dec(16,2);
define _pagado			dec(16,2);
define _monto			dec(16,2);
define _saldo			dec(16,2);
define _valor			dec(16,2);
define _pagos_faltan	smallint;
define _cant_pag		smallint;
define _no_pagos		smallint;
define _pagos			smallint;

set isolation to dirty read;

let _no_pagos     = 0;
let _prima_bruta  = 0;
let _saldo        = 0;
let _monto        = 0;
let _nueva_letra  = 0;

select no_documento,
	   no_pagos,
	   prima_bruta
  into _no_documento,
	   _no_pagos,
	   _prima_bruta
  from emipomae
 where no_poliza   = a_no_poliza
   and actualizado = 1;

let _cant_pag = 0;
let _pagado   = 0;
let _valor    = 0;

foreach	--determinar cuantos pagos tiene en total
	select d.monto,
		   d.tipo_mov
	  into _monto,
		   _tipo_mov
	  from cobredet d, cobremae m
	 where d.actualizado  = 1
	   and d.cod_compania = '001'
	   and d.doc_remesa   = _no_documento
	   and d.tipo_mov     in ('P','N')
	   and d.no_remesa    = m.no_remesa
	   and d.no_poliza    = a_no_poliza
	   and m.tipo_remesa  in ('A', 'M', 'C')
	let _pagado = _pagado + _monto;
end foreach

let _saldo = _prima_bruta - _pagado;

if _pagado = 0 then
else
	let _valor = _pagado * _no_pagos;
	let _cant_pag =  round(_valor / _prima_bruta);
end if

let _pagos_faltan = _no_pagos - _cant_pag;

if _pagos_faltan = 0 then
	let _pagos_faltan = _no_pagos;
end if

let _nueva_letra  = _saldo / _pagos_faltan;

return _nueva_letra;
end procedure