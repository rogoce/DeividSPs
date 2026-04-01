-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud47;		

create procedure "informix".sp_aud47() 
returning char(20), date, date, dec(16,2), smallint; 

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
	return _numrecla, null, null, null, null;
end exception

--SET DEBUG FILE TO "sp_aud46.trc";
--trace on;


foreach
    select no_reclamo, numrecla, fecha_siniestro, fecha_reclamo, perd_total
      into _no_reclamo, _numrecla, _fecha_siniestro, _fecha_reclamo, _perd_total  
      from recrcmae
     where numrecla[1,2]   in ('02', '20)
       and actualizado = 1
       and fecha_reclamo = '21/01/2014'


	-- Pagos, Salvamentos, Recuperos y Deducibles

   let v_tot_pagos = 0;
   let v_incurrido = 0;
   foreach
	select cod_tipotran 
      into v_tipo
      from rectitra
     where tipo_transaccion  IN (4,5,6,7)

		select sum(x.monto) 
          into v_pagos
          from rectrmae x, recrcmae y
         where y.no_reclamo    = _no_reclamo
           and y.actualizado   = 1
           and x.no_reclamo    = y.no_reclamo
           and x.actualizado   = 1
           and x.cod_tipotran  = v_tipo;

		if v_pagos is null then
	        let v_pagos = 0;
	    end if

		let v_tot_pagos = v_tot_pagos + v_pagos;

   end foreach

	-- Variacion de Reserva

	select sum(x.variacion) 
	  into v_incurrido
      from rectrmae x, recrcmae y
     where y.no_reclamo  = _no_reclamo
       and y.actualizado = 1
       and x.no_reclamo  = y.no_reclamo
       and x.actualizado = 1;

	if v_incurrido is null then
		let v_incurrido = 0;
	end if

	-- Incurrido

	 let v_incurrido = v_incurrido + v_tot_pagos;

     return _numrecla, _fecha_siniestro, _fecha_reclamo, v_incurrido, _perd_total with resume; 

end foreach

end
end procedure

