--drop procedure sp_sis502;
create procedure 'informix'.sp_sis502(a_cod_producto char(10))
returning char(3);

define _cod_ramo            char(3);

begin

set isolation to dirty read;
let _cod_ramo = '';

foreach
		select cod_ramo
		  into _cod_ramo
		  from reacobre
		 where cod_cober_reas in(select c.cod_cober_reas from prdcobpd p, prdcober c, reacobre u
		 where p.cod_cobertura = c.cod_cobertura
		   and c.cod_cober_reas = u.cod_cober_reas
		   and p.cod_producto = a_cod_producto)
		exit foreach;
end foreach

return _cod_ramo;

end
end procedure;