-- Creado    : 15/10/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/10/2003 - Autor: Demetrio Hurtado Almanza

drop procedure sp_cob127;

create procedure "informix".sp_cob127(
a_no_remesa	char(10)
) returning integer,
            char(100);

define _error		integer;
define _cantidad	integer;
define _actualizado	smallint;
define _tipo_remesa char(1);
define _no_recibo	char(10);

--set debug file to "sp_cob127.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Eliminar Remesa";
end exception

select actualizado,
       tipo_remesa
  into _actualizado,
       _tipo_remesa
  from cobremae
 where no_remesa = a_no_remesa;

if _actualizado = 1 then
	return 1, "Esta Remesa esta Actualizada";
end if

let _no_recibo = null;
let _cantidad  = 1;

delete from cobreagt where no_remesa = a_no_remesa;
delete from cobasiau where no_remesa = a_no_remesa;
delete from cobasien where no_remesa = a_no_remesa;
delete from cobredet where no_remesa = a_no_remesa;
delete from cobrepag where no_remesa = a_no_remesa;
delete from cobremae where no_remesa = a_no_remesa;

return 0, "Actualizacion Exitosa " || _cantidad;

end

end procedure