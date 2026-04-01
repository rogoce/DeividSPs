-- Procedure que Analiza los reclamos al cierre de diciembre y determina cuanto se pago de estos reclamos

-- Creado    : 18/11/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec239;

create procedure sp_rec239(a_periodo char(7))
returning char(3),
          char(50),
		  char(20),
		  dec(16,2),
		  integer,
		  dec(16,2),
		  integer;

define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva_bruta	dec(16,2);
define _monto_pagado	dec(16,2);
define _porc_coas    	dec(16,4);

define _casos_reclamos	integer;
define _casos_pagados	integer;

define _cod_ramo		char(3);
define _nombre_ramo		char(50);

define _filtro      	char(255);

set isolation to dirty read;

let _filtro = sp_rec02("001", "001", a_periodo);

delete from deivid_tmp:tmp_reserva_dic
 where periodo = a_periodo;
 
foreach
 select no_reclamo,
        numrecla,
	    reserva_bruto,
		cod_ramo,
		porc_partic_coas
   into _no_reclamo,
        _numrecla,
		_reserva_bruta,
		_cod_ramo,
		_porc_coas
   from tmp_sinis
  order by cod_ramo

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select sum(monto)
	  into _monto_pagado
	  from rectrmae
	 where periodo      > a_periodo
	   and actualizado  = 1
	   and cod_tipotran = "004" 	
	   and no_reclamo   = _no_reclamo;

	if _monto_pagado is null then
		let _monto_pagado = 0.00;
	end if
	
	let _monto_pagado = _monto_pagado / 100 * _porc_coas;
	 
	if _monto_pagado = 0.00 then
		let _casos_pagados = 0;
	else
		let _casos_pagados = 1;
	end if

	insert into deivid_tmp:tmp_reserva_dic
    values (a_periodo, _cod_ramo, _nombre_ramo, _numrecla, _reserva_bruta, 1, _monto_pagado, _casos_pagados);

	return _cod_ramo,
	       _nombre_ramo,
	       _numrecla,
		   _reserva_bruta,
	       1,
		   _monto_pagado,
		   _casos_pagados
		   with resume;
	         
end foreach

drop table tmp_sinis;

end procedure