-- Procedimiento que genera el cambio de plan de pagos 
-- 
-- Creado     : 08/01/2013 - Autor: Amado Perez M.
--execute procedure sp_pro531('1916073','DEIVID',0.00,'001','001','008')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro531a;

create procedure sp_pro531a()
returning	integer,
            char(50);

define _descripcion		char(50);
define _error_desc		char(50);
define _no_poliza		char(10);
define _no_cambio		char(6);
define _endoso_char		char(5);     
define _no_unidad		char(5);     
define _null			char(1);
define _cod_formapago   char(3);
define v_saldo          dec(16,2);
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_pro531a.trc";

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

foreach
	select no_poliza
	  into _no_poliza
	  from emipomae emi
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 where grp.nombre like '%SERAF%'
	   and vigencia_inic >= '01/07/2023'
	   and no_pagos <> 12
	   and actualizado = 1
	   and emi.estatus_poliza = 1
	
	update emipomae
	   set no_pagos = 12
	 where no_poliza = _no_poliza;
	
	update endedmae
	   set no_pagos = 12
	 where no_poliza = _no_poliza;
	
	call sp_pro530(_no_poliza) returning _error,_error_desc;
end foreach
end

return 0, "Actualizacion Exitosa";
end procedure