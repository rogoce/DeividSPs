-- Sacar parametros para tarifa de la tabla emirecmar
--
-- creado    : 24/03/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_wfc01;
create procedure "informix".sp_wfc01(a_cod_marca char(5), a_cod_cober char(5), a_suma decimal(16,2), a_deducible dec(16,2))
returning dec(16,2),
		  char(5),
		  dec(16,2);


define _porc_ded 		decimal(16,2); 
define _cod_cobertura   char(5);
define _cod_marca       char(5);
define _no_motor        char(30);
define _porc_b_exp_max  decimal(16,2);
define _suma_aseg_max	decimal(16,2);
define _valor           decimal(16,2);

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;


let _porc_ded	    = 0;
let _cod_cobertura  = "";
let _porc_b_exp_max = 0;
let _suma_aseg_max  = 0;

call sp_sis192(a_cod_cober, a_suma) returning _valor, _cod_cobertura, _porc_ded; 

if _valor = 0.00 then 
	select porc_ded,
	       cod_cobertura,
		   porc_b_exp_max,
		   suma_aseg_max
	  into _porc_ded,
	       _cod_cobertura,
		   _porc_b_exp_max,
		   _suma_aseg_max
	  from emirecmar
	 where cod_marca     = a_cod_marca
	   and cod_cobertura = a_cod_cober;

	if _porc_ded is null then
		let _porc_ded = 0;
	end if

	if _cod_cobertura is null then
		let _cod_cobertura  = "";
	end if

	if _porc_ded > 0 then
		let a_deducible = a_deducible + a_deducible * _porc_ded / 100;
	end if
else
	let a_deducible = _valor;
end if

return a_deducible, _cod_cobertura, _porc_ded;

end
end procedure
