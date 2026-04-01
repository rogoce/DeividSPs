-- Procedimiento para generar el correo de Estado de Cuenta Masivo 
--
-- Creado    : 29/03/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob273;

create procedure "informix".sp_cob273(a_secuencia	integer)
returning char(100),char(10),char(2),date,date,char(30);

define _ano				char(4);
define _mes				char(2);
define _cod_pagador		char(10);
define _fecha_char		char(30);
define _e_mail			char(50);
define _nombre_aseg		char(100);
define _periodo			char(7);
define _fecha_desde		date;
define _fecha_hasta		date;

set isolation to dirty read;

Select asegurado,
	   no_remesa
  into _cod_pagador,
	   _periodo
  from parmailcomp
 where secuencia = a_secuencia;

Select nombre
  into _nombre_aseg
  from cliclien
 where cod_cliente = _cod_pagador; 

let _fecha_hasta	= sp_sis36(_periodo);
let _ano			= _periodo[1,4];
let _mes			= _periodo[6,7];
let _fecha_desde	= MDY(_mes, 1, _ano);

if _mes = '01' then
	let _fecha_char = 'Enero de ' || _ano;
elif _mes = '02' then
	let _fecha_char = 'Febrero de ' || _ano;
elif _mes = '03' then
	let _fecha_char = 'Marzo de ' || _ano;
elif _mes = '04' then
	let _fecha_char = 'Abril de ' || _ano;
elif _mes = '05' then
	let _fecha_char = 'Mayo de ' || _ano;
elif _mes = '06' then
	let _fecha_char = 'Junio de ' || _ano;
elif _mes = '07' then
	let _fecha_char = 'Julio de ' || _ano;
elif _mes = '08' then
	let _fecha_char = 'Agosto de ' || _ano;
elif _mes = '09' then
	let _fecha_char = 'Septiembre de ' || _ano;
elif _mes = '10' then
	let _fecha_char = 'Octubre de ' || _ano;
elif _mes = '11' then
	let _fecha_char = 'Noviembre de ' || _ano;
elif _mes = '12' then
	let _fecha_char = 'Diciembre de ' || _ano;
end if    

return _nombre_aseg,
	   _cod_pagador,
	   _mes,
	   _fecha_desde,
	   _fecha_hasta,
	   _fecha_char;

end procedure
