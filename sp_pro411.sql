-- Procedimiento adiciona a campo email en emiacre
-- Creado: 20/06/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro411()

drop procedure sp_pro411;
create procedure sp_pro411()
returning	integer,
			varchar(200);



define _error_desc		varchar(50);
define _cod_acreedor	char(5);
define _email           varchar(50) ;
define _error			integer;
define _error_isam		integer;

--set debug file to "sp_pro411.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc	
	return _error, _error_desc;
end exception

set isolation to dirty read;


foreach with hold
	select cod_acreedor ,email
	  into _cod_acreedor, _email
	  from acremail  
	 where renglon = 0
	 order by 2,1	

	
	update emiacre
	   set email = _email
	 where cod_acreedor = _cod_acreedor;

	return 0, 'Procesado: ' || trim(_cod_acreedor)||' '||_email with resume;

	
end foreach

return 0, "Actualizacion Exitosa";

end
end procedure;