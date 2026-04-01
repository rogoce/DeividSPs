-- Procedimiento que Pasa a Texto un Fecha tipo DateTime

-- Creado     : 24/08/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis60;

create procedure "informix".sp_sis60()
returning datetime year to minute,
          char(50);

define _fecha_hora_date	datetime year to minute;
define _fecha_hora_txt	char(50);

define _dia				smallint;
define _mes				smallint;
define _ano				smallint;
define _hora			smallint;
define _min				smallint;

let _fecha_hora_date = current;
let _fecha_hora_txt  = _fecha_hora_date;

--let _fecha_hora_txt  = day(_fecha_hora_date) || month(_fecha_hora_date) || year(_fecha_hora_date);

{
let _dia  = day(_fecha_hora_date);
let _mes  = month(_fecha_hora_date);
let _ano  = year(_fecha_hora_date);
--let _hora = hour(_fecha_hora_date);
let _min  = minute(_fecha_hora_date);

let _fecha_hora_txt = "";

if _dia < 10 then
	let _fecha_hora_txt  = "0" || _dia;
else
	let _fecha_hora_txt  = _dia;
end if

if _mes < 10 then
	let _fecha_hora_txt  = trim(_fecha_hora_txt) || "/" || "0" || _mes;
else
	let _fecha_hora_txt  = _fecha_hora_txt || "/" || _mes;
end if

let _fecha_hora_txt  = trim(_fecha_hora_txt) || "/" || _ano;

if _hora < 10 then
	let _fecha_hora_txt  = trim(_fecha_hora_txt) || " " || "0" || _hora;
else
	let _fecha_hora_txt  = _fecha_hora_txt || " " || _hora;
end if

if _min < 10 then
	let _fecha_hora_txt  = trim(_fecha_hora_txt) || ":" || "0" || _min;
else
	let _fecha_hora_txt  = _fecha_hora_txt || ":" || _min;
end if
}

return _fecha_hora_date,
	   _fecha_hora_txt;

end procedure