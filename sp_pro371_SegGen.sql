-- Procedimiento que carga el archivo de renovaciones para la Cartera Banisi.
-- creado    : 05/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_pro371_banisi('2020-10')

drop procedure sp_pro371_seggen;
create procedure "informix".sp_pro371_seggen(a_periodo char(7))
returning   integer,
			char(100);   -- _error

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _cod_agente		char(5);
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

let _mes = a_periodo[6,7];

foreach
	select mae.no_poliza,
		   mae.no_documento,
		   cod_agente,
		   mae.periodo
	  into _no_poliza,
		   _no_documento,
		   _cod_agente,
		   _periodo
	  from emipomae mae
	 inner join emipoagt agt
			 on agt.no_poliza = mae.no_poliza
	 where no_documento in ('0220-00167-11')
	   and cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
--	   and periodo = a_periodo
	   and year(vigencia_final) >= 2022
	   --and no_poliza not in ('1516011','1516122','1515502','1515980','1516292','1515733','1516002')
	   and estatus_poliza = 1
	 order by 2

	call sp_pro371(_no_poliza) returning _error, _error_desc;
	
	if _error = 0 then
		{update emirenduc
		   set periodo = '2024-' || _mes
		 where no_documento = _no_documento
		   and periodo = a_periodo;}
	end if
end foreach
end

return 0,'Inserción Exitosa del Registro';
end procedure;