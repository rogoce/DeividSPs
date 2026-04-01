--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_sis193;
create procedure sp_sis193(a_no_poliza char(10), a_unidad char(5), a_cod_cober char(5))
returning char(5),
		  dec(16,2),
		  decimal(16,2),
		  decimal(16,2);


define _porc_ded 		decimal(16,2); 
define _cod_cobertura   char(5);
define _cod_marca       char(5);
define _no_motor        char(30);
define _porc_b_exp_max  decimal(16,2);
define _suma_aseg_max	decimal(16,2);

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;


let _porc_ded	    = 0;
let _cod_cobertura  = "";
let _porc_b_exp_max = 0;
let _suma_aseg_max  = 0;


select no_motor
  into _no_motor
  from emiauto
 where no_poliza = a_no_poliza
   and no_unidad = a_unidad;

select cod_marca
  into _cod_marca
  from emivehic
 where no_motor = _no_motor;


select porc_ded,
       cod_cobertura,
	   porc_b_exp_max,
	   suma_aseg_max
  into _porc_ded,
       _cod_cobertura,
	   _porc_b_exp_max,
	   _suma_aseg_max
  from emirecmar
 where cod_marca     = _cod_marca
   and cod_cobertura = a_cod_cober;

if _porc_ded is null then
	let _porc_ded = 0;
end if

if _cod_cobertura is null then
	let _cod_cobertura  = "";
end if

return _cod_cobertura,_porc_ded,_porc_b_exp_max,_suma_aseg_max;

end
end procedure
