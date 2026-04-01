-- Creado    : 21/08/2014 - Autor: Armando Moreno M.
-- Reporte para verificar letras de Tarjetas de credito diferentes


drop procedure sp_par352;

create procedure "informix".sp_par352()
returning char(20),
          char(17),
		  varchar(100),
          dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  smallint;

define _nombre          varchar(100);
define _no_documento	char(20);
define _no_cuenta		char(17);
define _no_poliza       char(10);
define _monto			dec(16,2);
define _prima_bruta_e	dec(16,2);
define _prima_bruta		dec(16,2);
define _dif_letra		dec(16,2);
define _cnt_cuenta		smallint;
define _no_pagos    	smallint;
define _dia             smallint;
define v_fecha          date;

let _monto       = 0;
let _prima_bruta = 0;
let _dia         = 0;

foreach
	select prima_bruta,
	       no_pagos,
		   no_documento,
		   no_poliza
	  into _prima_bruta,
	       _no_pagos,
		   _no_documento,
		   _no_poliza
	  from endedmae
	 where actualizado = 1
	   and cod_endomov = '014'
	   and periodo = '2014-09'
	   and cod_formapag = '005'
	
	let _cnt_cuenta = 0;
	
	select count(*)
	  into _cnt_cuenta
	  from cobcutas
	 where no_documento = _no_documento;
	
	if _cnt_cuenta is null or _cnt_cuenta = 0 then
		continue foreach;
	end if
	
	select prima_bruta
	  into _prima_bruta_e
	  from emipomae
	 where no_poliza = _no_poliza;

	select monto,
			nombre,
			no_cuenta,
			dia
	   into _monto,
			_nombre,
			_no_cuenta,
			_dia
	   from cobcutas
	  where no_documento = _no_documento;

	let _dif_letra = 0.00;
	let _dif_letra = _prima_bruta - _monto;
	
	if abs(_dif_letra) <> 0.00 then
		return _no_documento,_no_cuenta,_nombre,_monto,_prima_bruta,_prima_bruta_e,_no_pagos with resume;
		{update cobcutas
		   set monto = _prima_bruta
		 where no_documento = _no_documento;}
	end if
end foreach
end procedure 