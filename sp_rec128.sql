-- Procedure que carga el auxiliar de los proveedores de reclamos

-- Creado:	03/10/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec128;

create procedure sp_rec128(a_periodo char(7))
returning integer,
          char(50);

define _no_tranrec		char(10);
define _pagado			smallint;
define _fecha_pagado	date;
define _anular_nt		char(10);
define _fecha_anulo		date;

define _periodo			char(7);

delete from rectraux where periodo = a_periodo;

foreach
 select no_tranrec,
        pagado,
		fecha_pagado,
		anular_nt,
		fecha_anulo
   into _no_tranrec,
        _pagado,
		_fecha_pagado,
		_anular_nt,
		_fecha_anulo
   from rectrmae
  where periodo      = a_periodo
    and actualizado  = 1 
	and cod_tipotran = "004"

	if _pagado = 1 then

		if _fecha_pagado is null then
			
			let _periodo = sp_sis39(_fecha_anulo);

			if _periodo > a_periodo then
				continue foreach;
			end if

		else

			let _periodo = sp_sis39(_fecha_pagado);

			if _periodo > a_periodo then
				continue foreach;
			end if

		end if
		
	end if

	insert into rectraux
	values (_no_tranrec, a_periodo, 1);

end foreach

return 0, "Actualizacion Exitosa";

end procedure