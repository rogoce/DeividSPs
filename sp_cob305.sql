-- Procedimiento para unificar el dia de cobros de las tablas cobruter1 y cobruter2
-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob305;

create procedure "informix".sp_cob305() returning smallint,
            char(100),
            smallint;


define _cod_pagador    	char(10); 
define _dia_cobros2		smallint;
define _dia_cobros1		smallint;
define _error_code		smallint;

--SET DEBUG FILE TO "sp_cob305.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Procesar los No Cobros de los Cobros Moviles',0;
END EXCEPTION 

foreach
	select cod_pagador,
		   dia_cobros1
	  into _cod_pagador,
		   _dia_cobros1
	  from cobruter1
	 where cod_cobrador in ('021','045','098')
	   and cod_pagador is not null


	foreach
		select dia_cobros1
		  into _dia_cobros2
		  from cobruter2
		 where cod_pagador = _cod_pagador

		if _dia_cobros1 <> _dia_cobros2 then
{			update cobruter2
			   set dia_cobros1 = _dia_cobros1,
				   dia_cobros2 = _dia_cobros1
			 where cod_pagador = _cod_pagador;	}
			return _dia_cobros1,
				   _cod_pagador,
				   _dia_cobros2 with resume;
--			exit foreach;
		end if
	end foreach
end foreach
end
end procedure	