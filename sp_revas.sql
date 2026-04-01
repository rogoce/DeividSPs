-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_revas;
create procedure "informix".sp_revas()
returning integer, 
          char(100);
		  	
define _no_poliza		char(10);
define _contador		smallint;
define _tipo_registro	smallint;

define _error,_res_notrx integer;
define _error_isam		integer;
define _error_desc		char(50);
define _periodo         char(7);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
	select distinct res_notrx
	  into _res_notrx
	  from cglresumen
	 where res_comprobante = 'REA021911'
	   and res_cuenta = '231020203'
	 order by res_notrx
	 
	 call sp_sac77(_res_notrx) returning _error, _error_desc;

end foreach	 


{foreach
	select distinct no_poliza
	  into _no_poliza
	from endedmae
	where actualizado = 1
	  and sac_asientos = 2
	  and periodo = '2019-02'
	  and no_poliza in(
	select no_poliza from deivid_tmp:fac_asi)

	update sac999:reacomp
	   set sac_asientos = 0
	 where periodo = '2019-02'
	   and no_poliza = _no_poliza;
	
end foreach}
end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
