-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure ap_cod_coop;

create procedure "informix".ap_cob_coop()
returning char(5) as unidad;

define _anular_nt		char(10);
define _transaccion     char(10);
define _no_unidad       char(5);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _user_anulo_nt   char(8);
DEFINE _fecha_anulo_nt	DATE;


define _cnt             integer;

--SET LOCK MODE TO WAIT;

--set debug file to "aa.trc";
--trace on;
set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error_desc;
end exception

let _cnt = 0;
let _anular_nt = null;
LET _fecha_anulo_nt = current;

foreach
	select no_unidad 
	  into _no_unidad
	  from emipouni
	 where no_poliza = '0001301129'
	 order by 1

	let _cnt = 0;

	select count(*) 
	  into _cnt
	  from emipocob 
	 where no_poliza = '0001301129'
	   and no_unidad = _no_unidad;
 
	if _cnt is null then
		let _cnt = 0;
	end if
 
	if _cnt = 0 then
		return _no_unidad with resume;
	end if
end foreach 
end
return "";

end procedure
