-- Sacar parametros para tarifa de la tabla prdcores
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_sis192;
create procedure "informix".sp_sis192(a_cobertura char(5), a_suma decimal(16,2))
returning dec(16,2),
		  char(5),
		  dec(16,2);

define _porc_ded,_valor decimal(16,2); 
define _cod_cobertura   char(5);

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;


let _porc_ded	   = 0;
let _cod_cobertura = "";
let _valor         = 0;

select porc_ded,
       cod_cobertura
  into _porc_ded,
       _cod_cobertura
  from prdcores
 where cod_cobertura = a_cobertura
   and a_suma between rango1 and rango2;

if _porc_ded > 0 then
	let _valor = a_suma * _porc_ded / 100;
end if

if _cod_cobertura is null then
	let _cod_cobertura  = "";
end if

return _valor,_cod_cobertura,_porc_ded;

end
end procedure
