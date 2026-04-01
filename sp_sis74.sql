drop procedure sp_sis74;

create procedure "informix".sp_sis74()
returning integer,
          char(100);

define _cod_cliente	char(10);
define _error		integer;

--begin work;

begin
on exception set _error
--	rollback work;
	return _error, "Error al actulizar los registros";
end exception


foreach
 select cod_cliente
   into _cod_cliente
   from asegac
  where accionista is null

	update emipomae
	   set cod_grupo       = "01003"
	 where cod_contratante = _cod_cliente;

	update cliclien
	   set cod_grupo   = "01003"
	 where cod_cliente = _cod_cliente;

end foreach

end

--rollback work;
return 0, "Actualizacion Exitosa";

end procedure