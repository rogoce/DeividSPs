-- Deterioro de Cartera NIIF
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

--drop procedure sp_niif06;
create procedure "informix".sp_niif06(a_periodo char(7) default '*')
returning char(7);

define _fecha         date;
define _mes			  smallint;
define _ano			  smallint;
define _mes_char	  char(2);

begin

set isolation to dirty read;

let _fecha           = current;

let _ano = year(_fecha);
let _mes = month(_fecha);
if _mes < 10 then
	let _mes_char = "0" || _mes;
else
    let _mes_char = _mes;
end if

if a_periodo = '*' then
	let a_periodo = _ano || '-' || _mes_char;
end if

return a_periodo;

end
end procedure