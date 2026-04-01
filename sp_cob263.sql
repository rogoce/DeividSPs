-- Proceso que determina cuantos se han efectuado a una poliza en la vigencia actual
-- Creado por :     Roman Gordon	27/01/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob263;

Create Procedure "informix".sp_cob263(a_no_documento char(20))
Returning	smallint;	-- motivo de rechzazo

			
Define _cantidad_pagos	smallint;
Define _no_poliza		char(10);


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_co51c.trc";
--trace on;

Let _no_poliza = sp_sis21(a_no_documento);

Select count(*)
  into _cantidad_pagos
  from cobredet
 where no_poliza   = _no_poliza
   and actualizado = 1
   and tipo_mov = 'P';

return _cantidad_pagos;
end procedure


   
