-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv15;		

create procedure "informix".sp_reainv15()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;
define _no_poliza       char(10);
define _no_endoso       char(5);
define _no_unidad       char(5);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


set debug file to "sp_sac161cam.trc";
trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

let _sac_notrx = null;

foreach 
	select no_poliza,
	       no_unidad,
		   no_endoso
	  into _no_poliza,
	       _no_unidad,
		   _no_endoso
	  from endeduni 
	 where no_poliza = '0001659610'
	   and no_unidad <> '00029'
	   and no_endoso =  '00000'
	 
--	select max(no_cambio)
--	  into _no_cambio
--	  from emireaco
--	 where no_poliza = _no_poliza
--	   and no_unidad = _no_unidad;  								   
	   	   																								   
--	if _no_cambio is null THEN
--		let _no_cambio = 0;
--	else 
--		let _no_cambio = _no_cambio + 1;
--	end if		

	insert into emireaco (
	  no_poliza,
	  no_unidad,
	  no_cambio,
	  cod_cober_reas,
	  orden,
	  cod_contrato,
	  porc_partic_suma,
	  porc_partic_prima)
	select a.no_poliza,
		   a.no_unidad,
		   1,
		   a.cod_cober_reas,
		   a.orden,
		   a.cod_contrato,
		   a.porc_partic_suma,
		   a.porc_partic_prima
	  from emifacon a
	 where a.no_poliza = _no_poliza
	   and a.no_unidad = _no_unidad
	   and a.no_endoso = _no_endoso;	
	   

	insert into emireafa (
	  no_poliza,
	  no_unidad,
	  no_cambio,
	  cod_cober_reas,
	  orden,
	  cod_contrato,
	  cod_coasegur,
	  porc_partic_reas,
	  porc_comis_fac,
	  porc_impuesto)
	select a.no_poliza,
		   a.no_unidad,
		   1,
		   a.cod_cober_reas,
		   a.orden,
		   a.cod_contrato,
		   a.cod_coasegur,
		   a.porc_partic_reas,
		   a.porc_comis_fac,
		   a.porc_impuesto
	  from emifafac a
	 where a.no_poliza = _no_poliza
	   and a.no_unidad = _no_unidad
	   and a.no_endoso = _no_endoso;	
	   
end foreach

end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
