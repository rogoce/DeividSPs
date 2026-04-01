-- procedimiento que busca una factura en emipomae
-- creado    : 18/08/2011 - autor: armando moreno
-- modificado: 18/08/2011 - autor: armando moreno
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob285;
create procedure "informix".sp_cob285(
a_no_poliza		char(10),
a_no_factura	char(10),
a_opcion        smallint
) returning integer,
            char(100),
            char(10);

define _error_code      integer;
define _cnt		      	integer;  

--set debug file to "sp_cob285.trc"; 
--trace on;                                                                

set isolation to dirty read;

begin
on exception set _error_code 
 	return _error_code, 'Error al Buscar la factura, intente nuevamente...', '';
end exception           

if a_opcion = 1 then
	select count(*)
	  into _cnt
	  from emipomae
	 where no_poliza  = a_no_poliza
	   and no_factura = a_no_factura;
else
	select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza  = a_no_poliza
	   and no_factura = a_no_factura;
end if

return _cnt, 'Exito en la busqueda','';

end
end procedure;
end procedure;