-- Procedimiento que carga los datos para el reporte de cobros
 
-- Creado     :	20/03/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rep04;		

create procedure "informix".sp_rep04(a_fecha_inicio date, a_fecha_final date)
returning varchar(20), 
          varchar(50),
          varchar(30),
          dec(10,2),
		  dec(10,2),
		  integer;
		  
		  
define _cod_agente    			varchar(10);
define _nombre_agente  			varchar(50);
define _no_documento            varchar(20);
define _cod_formapag            char(3);
define _nombre_pagos            varchar(30);
define _prima_suscrita          dec(10,2);
define _no_pagos                integer;
define _saldo                   dec(10,2);

let _nombre_agente = '';

foreach
	select e.no_documento, 
	       t.cod_agente, 
		   e.cod_formapag, 
		   e.prima_suscrita, 
		   e.no_pagos
	  into _no_documento,
	       _cod_agente,
		   _cod_formapag,
		   _prima_suscrita,
		   _no_pagos
	  from emipomae e, emipoagt t
     where e.no_poliza     	   = t.no_poliza
       and e.cod_compania      = '001'
       and e.actualizado       = 1
       and e.nueva_renov       = "N"
       and e.fecha_suscripcion >= a_fecha_inicio
       and e.fecha_suscripcion <= a_fecha_final
  group by e.no_documento, t.cod_agente,e.cod_formapag,e.prima_suscrita, e.no_pagos
  order by e.no_documento
  
  select nombre
    into _nombre_agente
	from agtagent
   where cod_agente = _cod_agente;
	
select nombre
  into _nombre_pagos
  from cobforpa
 where cod_formapag = _cod_formapag;
	
-- buscando el saldo de la poliza  
call sp_cob174(_no_documento)RETURNING _saldo;
				
return _no_documento,
       _nombre_agente,
	   _nombre_pagos,
	   _prima_suscrita,
	   _saldo,
	   _no_pagos
	   with resume;
end foreach
end procedure