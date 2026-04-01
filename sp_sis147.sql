-- Procedimiento que devuelve el periodo anterior dado el periodo actual
--
-- Creado    : 02/03/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis147;

create procedure "informix".sp_sis147(a_periodo char(7)) 
returning char(7);

define _mes    		 smallint;
define _ano    	     smallint;
define _periodo_ant  char(7);

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];

if _mes = 1 then
   let _mes = 12;
   let _ano = _ano - 1;
else
   let _mes = _mes -1;
end if

if _mes < 10 then
	let _periodo_ant = _ano || "-0" || _mes;
else
	let _periodo_ant = _ano || "-" || _mes;
end if

return _periodo_ant;

end procedure;