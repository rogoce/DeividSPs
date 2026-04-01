-- Procedure que trae el periodo a evaluar para las verificaciones diarias del mayor

--drop procedure sp_sac104;

create procedure sp_sac104()
returning smallint,
          char(7),
		  date;

define _ano		smallint;
define _mes		smallint;
define _periodo	char(7);
define _fecha	date;

select par_anofiscal
  into _ano
  from cglparam;

let _mes = 1;

if _mes < 10 then
	let _periodo = _ano || "-0" || _mes;
else
	let _periodo = _ano || "-" || _mes;
end if

let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);

return _ano, _periodo, _fecha;

end procedure
