-- Procedimiento que hace calculos para la perdida total

-- Creado    : 12/11/2018 - Autor: Amado Perez  

drop procedure sp_rwf158;

create procedure sp_rwf158(a_no_reclamo char(10), a_depreciacion smallint) 
returning dec(16,2) as depre_anual,
		  dec(16,2) as depre_mensual,
		  dec(16,2) as depre_diario,
		  smallint as li_error,
		  varchar(100) as mensaje;

define _suma_asegurada 	dec(16,2);
define _dep_anual, _dep_mensual, _dep_diario, _perdida dec(16,2);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

select suma_asegurada
  into _suma_asegurada	   
  from recrcmae
 where no_reclamo = a_no_reclamo; 
 
 let _dep_anual = _suma_asegurada * a_depreciacion / 100;
 
 let _dep_mensual = _dep_anual / 12;

 let _dep_diario = _dep_mensual / 30;
  
return _dep_anual, 
       _dep_mensual,
	   _dep_diario,
	   0,
	   "Exitoso";

end procedure