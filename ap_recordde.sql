-- Procedure que llena los nuevos campos en recordma

-- Creado    : 03/10/2014 - Autor: Amado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_recordde;

create procedure ap_recordde() returning integer,
            char(100);

define _no_orden		char(10);
define _renglon		    integer;
define _valor		    dec(16,2);
define _cantidad        integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_ttc11.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- 

let _valor = 0.00;
let _cantidad = 0;


foreach	with hold
 select a.no_orden,
        a.renglon,
        a.valor,
		a.cantidad
   into	_no_orden,	
        _renglon,	
		_valor,
		_cantidad		
   from	recordde a, recordma b
  where a.no_orden = b.no_orden
    and b.tipo_ord_comp = 'R'
	and b.fecha_orden >= '01-01-2013'
    and  b.fecha_orden < '31-12-2013'
    and a.cantidad > 1

	update recordde
	   set valor = _valor * _cantidad
	 where no_orden = _no_orden
	   and renglon  = _renglon;

    

end foreach

--}

end

return 0, "Actualizacion Exitosa";

end procedure
