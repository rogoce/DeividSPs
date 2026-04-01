-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud48;		

create procedure "informix".sp_aud48() 
returning char(20), dec(16,2); 

define _no_reclamo          char(10);
define _numrecla            char(20);
define _fecha_siniestro, _fecha_reclamo  date;
define _perd_total          smallint;
define v_tot_pagos, v_pagos, v_incurrido dec(16,2);
define v_tipo               char(3);

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_desc, null;
end exception

--SET DEBUG FILE TO "sp_aud46.trc";
--trace on;


	-- Pagos, Salvamentos, Recuperos y Deducibles

   let v_tot_pagos = 0;
   let v_incurrido = 0;
   foreach with hold
		select sum(x.monto), x.numrecla 
          into v_pagos, _numrecla
          from rectrmae x
         where x.numrecla[1,2]   in ('02','20')
		   and x.fecha         = '21/01/2014'
           and x.actualizado   = 1
           and x.cod_tipotran  in ('004','005','006','007')
        group by x.numrecla

		let v_tot_pagos = 0;

		if v_pagos is null then
	        let v_pagos = 0;
	    end if

		let v_tot_pagos = v_tot_pagos + v_pagos;

	-- Variacion de Reserva

	select sum(x.variacion) 
	  into v_incurrido
      from rectrmae x
     where x.numrecla  = _numrecla
	   and x.fecha     = '21/01/2014'
       and x.actualizado = 1;

	if v_incurrido is null then
		let v_incurrido = 0;
	end if

	-- Incurrido

	 let v_incurrido = v_incurrido + v_tot_pagos;

     return _numrecla, v_incurrido with resume; 

end foreach

end
end procedure

