-- Validacion tipo de pago ACH solo Numeros 0471015167857
-- Creado    : 21/09/2022 - HGIRON
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par378;
create procedure "informix".sp_par378(a_tipo_pago integer, a_valor char(17))
returning smallint;

define i,j integer;
define _cant integer;
define _char1 char(1);

set isolation to dirty read;
--set debug file to "sp_par378.trc"; 
--trace on;
let a_valor = trim(a_valor);
let j = 1;
let _cant   = length(trim(a_valor));

if a_tipo_pago = 1 then
  for i = 1 to _cant
		let _char1  = a_valor[1,1];
		LET a_valor = a_valor[2,17];
		if j <= _cant then
			if _char1 not between "0" and "9" then
				return 1;
			end if
		end if
		let j = j + 1;
  end for
end if

return 0;

end procedure
