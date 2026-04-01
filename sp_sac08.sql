-- Procedure que elimina las cuentas con guion del catalogo de Deivid

-- Creado    : 23/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


--drop procedure sp_sac08;

create procedure "informix".sp_sac08() 
returning char(25);

define _cuenta	char(25);
define _error	integer;

begin
on exception set _error
	return _cuenta;
end exception

foreach
 select cuenta
   into	_cuenta
   from cglctas
  where cuenta[4,4] = "-"
--	and cuenta[1,1]	= 1
  order by cuenta

--	return _cuenta with resume;

	delete from cglctas
	 where cuenta = _cuenta;

end foreach

end

return "Exito";

end procedure
