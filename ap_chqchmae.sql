-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE ap_chqchmae;

CREATE PROCEDURE "informix".ap_chqchmae()
returning char(10) as Requisicion,
		  dec(16,2) as Monto,
		  dec(16,2) as Monto_Rec,
		  smallint as Pagado;


define _no_requis	char(10);
define _monto dec(16,2);
define _monto_rec dec(16,2);
define _pagado smallint;

define _no_reclamo       char(10);

SET ISOLATION TO DIRTY READ;


FOREACH
 SELECT no_requis,
        monto,
		pagado
   INTO _no_requis,
        _monto,
		_pagado
   FROM chqchmae
  WHERE fecha_captura >= '01/01/2018'
    and anulado = 0
	and origen_cheque = '3'
  
 SELECT sum(monto)
   INTO _monto_rec
   FROM chqchrec
  WHERE no_requis = _no_requis;
 
 if _monto <> _monto_rec then
 
   return _no_requis,
          _monto,
		  _monto_rec,
          _pagado  WITH RESUME;
 end if  
end foreach

END PROCEDURE
