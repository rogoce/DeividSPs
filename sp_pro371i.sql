-- Procedimiento que carga el archivo de renovaciones para la Cartera Banisi.
-- creado    : 08/03/2021 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_pro371_banisi('2020-10')

drop procedure sp_pro371i;
create procedure "informix".sp_pro371i()
returning   integer,
			char(100);   -- _error

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _mes				char(2);
define _error_isam		integer;
define _error			integer;

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

--set debug file to "sp_pro371.trc";
--trace on;

set isolation to dirty read;

let _error = 0;
let _error_desc = "";

foreach
	/*select no_poliza
	  into _no_poliza
	  from emipomae
	 where cod_grupo in ('1122','77850','77857')
	   and cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
	   and no_poliza = a_poliza
	   and estatus_poliza = 1
	   and nueva_renov = 'R'*/

	select emi.no_poliza
	  into _no_poliza
	  from emipomae emi
	  left join emirenduc duc on duc.no_documento = emi.no_documento and duc.periodo = '2021-12'
	 where emi.cod_grupo in ('1122','77850','77960')      -- SD#3010 77960  11/04/2022 10:00
	   and emi.vigencia_inic between '01/12/2021' and '31/12/2021'
	   and emi.nueva_renov = 'R'
	   and emi.actualizado = 1
	   and emi.estatus_poliza = 1
	   and duc.no_documento is null

	call sp_pro371(_no_poliza) returning _error, _error_desc;	
end foreach
end

if _error is null then
	let _error = 0;
end if

if _error_desc is null then
	let _error_desc = "";
end if

return _error, _error_desc;
end procedure;