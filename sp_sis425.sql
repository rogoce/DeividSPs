-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis425;
create procedure "informix".sp_sis425(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5))
returning dec(16,2),dec(16,2),dec(16,2);

define _suma_asegurada_ter		dec(16,2);
define _suma_asegurada_inc	dec(16,2);
define _prima_ter	dec(16,2);
define _prima_inc	dec(16,2);
define _suma_asegurada dec(16,2);
define _prima dec(16,2);
define _cod_cober_reas char(3);
define _cod_ramo char(3);
define _es_terremoto smallint;

-- Prima cobrada para terremoto

let _suma_asegurada_ter = 0;
let _suma_asegurada_inc = 0;
let _prima_ter = 0;
let _prima_inc = 0;

set isolation to dirty read;

FOREACH
	Select cod_cober_reas, SUM(emifacon.suma_asegurada),SUM(emifacon.prima)
	  Into _cod_cober_reas, _suma_asegurada, _prima
	  From emifacon
	 Where emifacon.no_poliza  	 = a_no_poliza
		And emifacon.no_endoso  	 = a_no_endoso
		And emifacon.no_unidad  	 = a_no_unidad
	 GROUP BY cod_cober_reas

	Select es_terremoto
	  Into _es_terremoto
	  From reacobre
	 Where cod_cober_reas  	 = _cod_cober_reas;

	if _es_terremoto = 1 then
		let _suma_asegurada_ter = _suma_asegurada;
		let _prima_ter = _prima;
	else
		let _suma_asegurada_inc = _suma_asegurada;
		let _prima_inc = _prima;
	end if
end foreach	
 
return _suma_asegurada_ter, _prima_ter, _prima_inc;


end procedure;