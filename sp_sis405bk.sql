--  Procedimiento para determinar Monto pagado de una vigencia

-- Creado: 08/05/2013 - Autor: Armando Moreno M.

drop procedure sp_sis405bk;
create procedure sp_sis405bk(a_no_poliza char(10))
returning decimal(16,2),integer,integer;


define _no_documento     char(20);
define _saldo		     dec(16,2);
define _no_poliza        char(10);
define _no_pagos         smallint;
define _pagos            smallint;
define _prima_bruta      dec(16,2);
define _pagado           dec(16,2);
define _monto,_nueva_letra     dec(16,2);
define _cant_pag,_pagos_faltan smallint;
define _tipo_mov         	   char(1);
define _valor            dec(16,2);

set isolation to dirty read;

let _no_pagos     = 0;
let _prima_bruta  = 0;
let _saldo        = 0;
let _monto        = 0;
let _nueva_letra  = 0;

 select	no_documento,
		no_pagos,
		prima_bruta
   into	_no_documento,
		_no_pagos,
		_prima_bruta
   from	emipomae
  where no_poliza   = a_no_poliza
	and actualizado = 1;

let _cant_pag = 0;
let _pagado   = 0;
let _valor    = 0;

FOREACH	--Determinar cuantos pagos tiene en total

		SELECT d.monto,
		       d.tipo_mov
		  INTO _monto,
		       _tipo_mov
		  FROM cobredet d, cobremae m
		 WHERE d.actualizado  = 1
		   AND d.cod_compania = '001'
		   AND d.doc_remesa   = _no_documento
		   AND d.tipo_mov     IN ('P','N')
		   AND d.no_remesa    = m.no_remesa
		   AND d.no_poliza    = a_no_poliza
		   AND m.tipo_remesa  IN ('A', 'M', 'C')

	   {	if _tipo_mov = 'P' then
			let _cant_pag = _cant_pag + 1;
		elif _tipo_mov = 'N' then
			let _cant_pag = _cant_pag - 1;
		end if }

		LET _pagado = _pagado + _monto;
END FOREACH

let _saldo = _prima_bruta - _pagado;

let _valor = _pagado * _no_pagos;

let _cant_pag = round(_valor / _prima_bruta);

let _pagos_faltan = _no_pagos - _cant_pag;

if _pagos_faltan = 0 then
	let _pagos_faltan = _no_pagos;
end if

let _nueva_letra  = _saldo / _pagos_faltan;

return _nueva_letra,_cant_pag,_pagos_faltan;

end procedure