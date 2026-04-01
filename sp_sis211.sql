-- Procedimiento que determina las variables para el descuento por siniestralidad

-- Tarifas Agosto 2015

drop procedure sp_sis211;
create procedure sp_sis211(
a_no_documento		char(20)
) returning char(10);

define _no_poliza			char(10);
define _fecha_proceso		date;
define _vigencia_inic		date;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

let _fecha_proceso = today;

-- Numero de Siniestros Ultima Vigencia

--let _no_poliza = sp_sis21(a_no_documento);

foreach
	select no_poliza,
		   vigencia_inic
	  into _no_poliza,
		   _vigencia_inic
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado  = 1
	 order by vigencia_final
	 
	if _vigencia_inic <= _fecha_proceso then
		exit foreach;
	end if
end foreach


return _no_poliza;
		   
end procedure

