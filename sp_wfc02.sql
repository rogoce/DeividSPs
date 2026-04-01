
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_wfc02;
create procedure "informix".sp_wfc02(a_cod_marca char(5), a_suma dec(16,2), a_descuento dec(16,2))
returning smallint;

define _porc_b_exp_max  decimal(16,2);
define _suma_aseg_max	decimal(16,2);
define _retornar        smallint;

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;

let _porc_b_exp_max = 0;
let _suma_aseg_max  = 0;
let _retornar = 0;

foreach
	select porc_b_exp_max,
		   suma_aseg_max
	  into _porc_b_exp_max,
		   _suma_aseg_max
	  from emirecmar
	 where cod_marca     = a_cod_marca
end foreach

if _porc_b_exp_max > 0 and _suma_aseg_max > 0 then
	if a_descuento > _porc_b_exp_max and a_suma <= _suma_aseg_max then
		let _retornar = 1;
   	else
		let _retornar = 0;
	end if
end if


return _retornar;

end
end procedure
