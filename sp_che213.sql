-- Procedimiento que Marca los Cheques Manuales despues de 2 dias para que aparezcan en entrega de cheques.

-- Creado    : 26/06/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_che213;

create procedure "informix".sp_che213() 
returning integer, 
          char(50);

{
returning char(10),
          date,
          smallint,
          smallint,
          smallint,
          date;
}

define _no_requis		char(10);
define _fecha_impresion	date;
define _dia_semana		smallint;
define _dia_diferencia	smallint;
define _procesar		smallint;
define _fecha_calculo	date;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

end 

let _fecha_calculo = today;

foreach
 select no_requis,
        fecha_impresion
   into _no_requis,
        _fecha_impresion
   from chqchmae
  where pagado       = 1
    and anulado      = 0
    and tipo_requis  = "C"
    and wf_entregado = 0
    and en_firma     <> 2
--	and fecha_impresion >= "01/06/2013"
  order by fecha_impresion desc

	let _procesar       = 0;
	let _dia_semana     = weekday(_fecha_impresion);
	let _dia_diferencia = _fecha_calculo - _fecha_impresion;
	
	if _dia_semana = 4 or   -- Jueves
	   _dia_semana = 5 then -- Viernes

		if _dia_diferencia > 4 then
			let _procesar = 1;
		end if

	else

		if _dia_diferencia > 2 then
			let _procesar = 1;
		end if

	end if

	if _procesar = 1 then

		update chqchmae
		   set en_firma  = 2
		 where no_requis = _no_requis;

	end if

	{
	return _no_requis,
	       _fecha_impresion,
		   _dia_semana,
		   _dia_diferencia,
		   _procesar,
		   _fecha_calculo
		   with resume;
	}

end foreach

--return "0", null, 0, 0, 0, null;

return 0, "Actualizacion Exitosa";

end procedure

