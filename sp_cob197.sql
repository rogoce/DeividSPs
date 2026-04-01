-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cob197;

create procedure sp_cob197(
a_no_documento	char(20)
) returning integer,
            char(50);

define _periodo_pro			char(7);
define _periodo_ant			char(7);
define _periodo_ini			char(7);
define _mes_act				smallint;
define _ano_act				smallint;
define _mes_ant				smallint;
define _ano_ant				smallint;

define _error			integer;
define _descripcion		char(50);

let _error = 0;
let _descripcion = "";

set isolation to dirty read;

select cob_periodo
  into _periodo_pro
  from parparam
 where cod_compania = "001";

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

let _periodo_ini = "2003-01";

while _periodo_ini <= _periodo_ant

	call sp_cob194(a_no_documento, _periodo_ini) returning _error, _descripcion;
	call sp_cob195(a_no_documento, _periodo_ini) returning _error, _descripcion;
	call sp_cob196(a_no_documento, _periodo_ini) returning _error, _descripcion;

	let _ano_act = _periodo_ini[1,4];
	let _mes_act = _periodo_ini[6,7];

	if _mes_act = 12 then
		let _mes_ant = 1;
		let _ano_ant = _ano_act + 1;
	else
		let _mes_ant = _mes_act + 1;
		let _ano_ant = _ano_act;
	end if

	if _mes_ant < 10 then
		let _periodo_ini = _ano_ant || "-0" || _mes_ant;
	else
		let _periodo_ini = _ano_ant || "-" || _mes_ant;
	end if		
	
end while

return 0, "Actualizacion Exitosa";

end procedure