-- Procedimiento que Busca en rectrcon, para ver si hay algun concepto que genere nombre para el acrredor

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE sp_rec198;

CREATE PROCEDURE sp_rec198(a_no_tranrec	char(10))
returning smallint;

define _cod_concepto	char(3);
define _agrega_acreedor smallint;

SET ISOLATION TO DIRTY READ;

let _agrega_acreedor = 0;

foreach
	select cod_concepto
	  into _cod_concepto
	  from rectrcon
	 where no_tranrec = a_no_tranrec
	   and monto > 0

	select agrega_acreedor
	  into _agrega_acreedor
	  from recconce
	 where cod_concepto = _cod_concepto;

	if _agrega_acreedor = 1 then	--Debe llevar el nombre del acreedor
		exit foreach;
	end if

end foreach

return _agrega_acreedor;

END PROCEDURE
