-- Actualizar las notas de Polizas Vencidas y Canceladas

-- Creado    : 05/02/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis177;

create procedure "informix".sp_sis177()
returning smallint, char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _estatus_poliza	smallint;

foreach
 select no_documento
   into _no_documento
   from eminotas
  where procesado = 0
--    and no_documento = "0101-00338-01"
  group by 1
  order by 1

	let _no_poliza = sp_sis21(_no_documento);
	
	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;
	  	
	if _estatus_poliza in (2,3) then -- Cancelada o Vencida

		--{
		update eminotas
		   set procesado    = 1,
		       user_proceso = "informix",
			   date_proceso = today
		 where no_documento = _no_documento
		   and procesado    = 0;
		--}

--		return _estatus_poliza, _no_documento || " " || _vigencia_final with resume;

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure