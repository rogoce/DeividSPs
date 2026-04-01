-- Procedimiento que Actualiza masivamente los número de recibos en caso de salto de secuencia
-- Creado    : 20/01/2017 - Autor: Román Gordón

drop procedure sp_sis447;
create procedure "informix".sp_sis447()
returning char(5);

define _valor			    smallint;
define _no_remesa		    char(10);
define _no_recibo		    char(10);
define _cnt					smallint;
define _error				integer;

set isolation to dirty read;

begin


foreach
	select no_remesa,
		   no_recibo
	  into _no_remesa,
		   _no_recibo
	  from tmp_recibos
	
	update cobredet
	   set no_recibo = _no_recibo
	 where no_remesa = _no_remesa;
	
end foreach;

end
end procedure;