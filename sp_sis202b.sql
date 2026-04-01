-- Procedimiento que cambia los codigos de contratos en emifacon,emireaco
-- 
-- Creado     : 07/09/2016 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis202b;
create procedure sp_sis202b()
 returning integer,
           char(200),
           char(5);

define _error_desc		varchar(200);
define _no_poliza		char(10);
define _periodo			char(7);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_ramo		char(3);
define _cantidad		smallint;
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_sis119bk.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

let _cantidad   = 0;

--Verificar Endosos nuevos de las pólizas que esten camrea
foreach with hold
	select no_poliza,
		   no_unidad,
		   no_endoso,
		   periodo
	  into _no_poliza,
		   _no_unidad,
		   _no_endoso,
		   _periodo
	  from camrea
	 where actualizado = 0
	 order by 1,3,2

	begin work;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	update emireaco
	   set cod_contrato = '00671'
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_contrato = '00664';

	if _cod_ramo in ('006','008') then
		update emireaco
		   set cod_contrato = '00672'
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_contrato = '00665';
	end if

	update emifacon
	   set cod_contrato = '00671'
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad
	   and cod_contrato = '00664';
	
	if _cod_ramo in ('006','008') then
		update emifacon
		   set cod_contrato = '00672'
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_contrato = '00665';
	end if

	update camrea
	   set actualizado = 1
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = _no_endoso;

	--Verificar esto cuando es en dataserver
	if _periodo >= '2017-07' then
		update endedmae
		   set sac_asientos = 0
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		update sac999:reacomp
		   set sac_asientos = 0
		 where no_poliza     = _no_poliza
		   and no_endoso     = _no_endoso
		   and tipo_registro = 1;
	end if
		
	let _cantidad  = _cantidad + 1;
	commit work;
end foreach
end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados", _no_endoso;

end procedure;