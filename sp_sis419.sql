--- Verificar si algun vehiculo esta bloqueado para enviar el error
--- Creado 26/08/2014 por Armando Moreno

drop procedure sp_sis419;

create procedure sp_sis419(a_poliza char(10))
returning integer;

begin


define _cod_ramo    	char(3);
define _no_unidad       char(5);
define _no_motor        char(30);
define _ramo_sis        smallint;
define _bloqueado       smallint;



--SET DEBUG FILE TO "sp_sis419.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;


select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis <> 1 then
	return 0;
end if

let _no_motor = null;
let _bloqueado = 0;

foreach

	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_poliza

	select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = a_poliza
	   and no_unidad = _no_unidad;

	select bloqueado
	  into _bloqueado
	  from emivehic
	 where no_motor = _no_motor;

	 
	if _bloqueado = 1 then  --Vehiculo bloqueado, no se puede emitir, renovar etc.
		return 1;
	end if

end foreach

end 
return 0;

end procedure;
