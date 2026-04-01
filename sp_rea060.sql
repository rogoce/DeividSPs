-- Procedure que Genera el movimiento para cuadrar la 2550101

drop procedure sp_rea060;

create procedure "informix".sp_rea060()
returning integer,
          char(50);
		  
define _periodo			char(7);
define _cod_compania	char(3);

define _error			integer;
define _error_desc		char(50);

return 0, "Suspendido a Solicitud de Jorge Contreras";

let _cod_compania = "001";

select par_periodo_act
  into _periodo
  from parparam
 where cod_compania = _cod_compania;
 
call sp_rea24(_cod_compania, "001", _periodo) returning _error, _error_desc;

return _error, _error_desc;

end procedure
