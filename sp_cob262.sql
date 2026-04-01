-- Proceso que determina cuantos pagos se han efectuado a una poliza en la vigencia actual
-- Creado por :     Roman Gordon	27/01/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob262;

Create Procedure "informix".sp_cob262(a_no_documento char(20))
Returning	char(3);	-- cod_pagos

			
Define _cantidad_pagos	smallint;
Define _no_poliza		char(10);
Define _cod_pagos		char(3);


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

let _cantidad_pagos = _cantidad_pagos + 1;

if _cantidad_pagos < 10 then
	let _cod_pagos = '00' || _cantidad_pagos;
else
	let _cod_pagos = '0' || _cantidad_pagos;
end if

return _cod_pagos;
end procedure


   
