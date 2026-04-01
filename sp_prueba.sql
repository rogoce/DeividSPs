--DROP PROCEDURE sp_prueba;

CREATE PROCEDURE sp_prueba(a_periodo CHAR(7))
RETURNING char(7);

define _mes_act			smallint;
define _ano_act			smallint;
define _mes_ant			smallint;
define _ano_ant			smallint;
define _per_fin_ap      char(7);




let _ano_act = a_periodo[1,4];
let _mes_act = a_periodo[6,7];

let _ano_ant = _ano_act - 1;

if _mes_act < 10 then
	let _per_fin_ap = _ano_ant || "-0" || _mes_act;
else
	let _per_fin_ap = _ano_ant || "-" || _mes_act;
end if

return _per_fin_ap;

end procedure