-- Verificacion de Periodo para el programa de cierre mensual

-- Creado    : 23/07/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par189; 

create procedure sp_par189()
returning integer,
          char(7);

define _emi_periodo_cerrado	smallint;
define _periodo_pro			char(7);
define _periodo_ant			char(7);
define _mes_act				smallint;
define _ano_act				smallint;
define _mes_ant				smallint;
define _ano_ant				smallint;
define _cerrado				integer;

set isolation to dirty read;

select emi_periodo,
       par_periodo_act
  into _periodo_pro,
       _periodo_ant
  from parparam
 where cod_compania = "001";

{
let _ano_act = _periodo_pro[1,4];
let _mes_act = _periodo_pro[6,7];

if _mes_act = 1 then
	let _mes_ant = 12;
	let _ano_ant = _ano_act - 1;
else
	let _mes_ant = _mes_act - 1;
	let _ano_ant = _ano_act;
end if

if _mes_ant < 10 then
	let _periodo_ant = _ano_ant || "-0" || _mes_ant;
else
	let _periodo_ant = _ano_ant || "-" || _mes_ant;
end if		
}

if _emi_periodo_cerrado = 1 then
	let _cerrado = 1;
else
	let _cerrado = 0;
end if

{
if _cob_periodo_cerrado = 1 and
   _emi_periodo_cerrado = 1 then
	let _cerrado = 1;
else
	let _cerrado = 0;
end if
}

--let _cerrado = 0;

return _cerrado, _periodo_ant;
 
end procedure