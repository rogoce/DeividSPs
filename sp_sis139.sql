-- Procedure que carga los registros para el WEB

-- Creado: 08/02/2007 - Autor: Demetrio Hurtado Almanza

drop procedure sp_sis139;

create procedure "informix".sp_sis139()
returning integer,
          char(20);

define _fecha		date;
define _ano			smallint;

define _no_reclamo	integer;
define _numrecla	char(20);

set isolation to dirty read;

let _fecha = today - 1;
let _ano   = year(_fecha);

select ult_no_reclamo
  into _no_reclamo
  from parconre
 where cod_compania = "001"
   and cod_sucursal = "010"
   and cod_ramo     = "018"
   and ano          = _ano; 

foreach
 select numrecla
   into _numrecla
   from recrcmae
  where cod_compania  = "001"
    and cod_sucursal  = "010"
	and numrecla[1,2] = "18"
	and actualizado   = 1
  order by numrecla desc
	exit foreach;
end foreach

return _no_reclamo, _numrecla;

end procedure