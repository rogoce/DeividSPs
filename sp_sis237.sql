--Procedure que Verifica la cantidad de cambios en emireaco vs los endosos que deberian insertar en emireaco.
-- Creado    : 28/07/2017 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

--execute procedure sp_sis237()
drop procedure sp_sis237;
create procedure sp_sis237()
returning	char(10)		as no_poliza,
			char(5)			as unidad,
			smallint		as cambios_endedmae,
			smallint		as cambios_emireaco,
			smallint		as ult_cambio,
			varchar(250)	as error_desc;

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_poliza			char(10);
define _no_unidad2			char(5);
define _no_unidad			char(5);
define _ult_no_cambio		smallint;
define _cnt_emireaco		smallint;
define _cnt_cambios			smallint;
define _cnt_existe			smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_sis212a.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	return '','',0,0, _error, _error_desc;         
end exception

foreach
	select distinct no_poliza 
	  into _no_poliza
	  from camrea
	 where actualizado = 0

	foreach
		select u.no_unidad,
			   count(*)
		  into _no_unidad,
			   _cnt_cambios
		  from endedmae e, endeduni u
		 where e.no_poliza = u.no_poliza
		   and e.no_endoso = u.no_endoso
		   and e.no_poliza = _no_poliza
		   and e.cod_endomov in ('004','011','017') --Endosos de Póliza Original, Inclusión de Unidades y Cambio de Reaseguro Individual
		 group by 1

		select u.no_unidad,
			   count(distinct no_cambio),
			   max(no_cambio)
		  into _no_unidad2,
			   _cnt_emireaco,
			   _ult_no_cambio
		  from emipomae e, emireaco u
		 where e.no_poliza = u.no_poliza
		   and e.no_poliza = _no_poliza
		   and u.no_unidad = _no_unidad
		 group by 1;

		if _cnt_cambios <> _cnt_emireaco then
			{delete from emireaco 
			 where no_poliza = _no_poliza 
			   and no_unidad = _no_unidad
			   and no_cambio = _ult_no_cambio;
			
			delete from emireama
			 where no_poliza = _no_poliza 
			   and no_unidad = _no_unidad
			   and no_cambio = _ult_no_cambio;}

			return _no_poliza,
				   _no_unidad,
				   _cnt_cambios,
				   _cnt_emireaco,
				   _ult_no_cambio,
				   '' with resume;
		end if
	end foreach	
end foreach
end
end procedure;