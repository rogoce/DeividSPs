-- Procedure que Verifica los registros contables de Deivid Vs el Catalogo de SAC

-- Creado    : 25/10/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac23;

create procedure sp_sac23(a_cuenta_old char(25), a_cuenta_new char(25)) 
returning integer,
          char(50);

define _error	integer;

begin 
on exception set _error
	return _error, "Error de Actualizacion";
end exception

--{
update chqchcta
   set cuenta = a_cuenta_new
 where cuenta = a_cuenta_old;
--}

{
update cobredet
   set doc_remesa = a_cuenta_new
 where doc_remesa = a_cuenta_old;
}
{
update cobasien
   set cuenta = a_cuenta_new
 where cuenta = a_cuenta_old;
}
end

return 0, "Actualizacion Exitosa";

end procedure
