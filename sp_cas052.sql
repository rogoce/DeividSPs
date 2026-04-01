-- reporte
-- Creado    : 06/08/2003 - Autor: Armando Moreno M.
-- Modificado: 06/08/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas052;

create procedure sp_cas052()
RETURNING   CHAR(3),  -- cod_cobrador
			CHAR(50), -- nombre_cobrador
			CHAR(10), -- pagador
			smallint; -- roll

define _nombre_cobrador char(50);
define _cod_cobrador char(3);
define _cod_pagador	 char(10);
define _roll,_cant		 smallint;

set isolation to dirty read;

foreach with hold
	select cod_cliente,
		   cod_cobrador
	  into _cod_pagador,
		   _cod_cobrador
      from cascliente

	 let _cant = 0;

	 select count(*)
	   into _cant
	   from cobcatmp3
	  where cod_pagador = _cod_pagador;

	 if _cant = 0 then

		 select nombre,
		        tipo_cobrador
		   into _nombre_cobrador,
		        _roll
		   from cobcobra
		  where cod_cobrador = _cod_cobrador;

		RETURN 	_cod_cobrador,
	 			_nombre_cobrador,
				_cod_pagador,
				_roll
	 	  		WITH RESUME;
	 else
		continue foreach;
	 end if

end foreach

end procedure
