-- Creado: Armando Moreno	25/04/2012

--Procedimiento para hacer una copia de la tabla cobsuspe hacia la tabla cobsuspeh
--Para Auditoria

drop procedure sp_sis118;

create procedure "informix".sp_sis118(a_periodo_ant char(7)
) returning integer,char(10);

define _error			integer;
define _fecha    		date;
define _no_poliza 		char(10);
define _fecha_inicio    date;
define _no_aviso		char(10);
define _renglon			smallint;

BEGIN
ON EXCEPTION SET _error
	return _error,_no_poliza;
end exception

let _fecha = sp_sis36(a_periodo_ant);

--set debug file to "sp_sis118.trc";
--trace on;

let _no_poliza = "";

insert into cobsuspeh(
doc_suspenso,
cod_compania,
cod_sucursal,
monto,
fecha,
coaseguro,
asegurado,
poliza,
ramo,
actualizado,
user_added,
date_added,
corredor,
cedula,
periodo)
select doc_suspenso,
	   cod_compania,
	   cod_sucursal,
	   monto,
	   fecha,
	   coaseguro,
	   asegurado,
	   poliza,
	   ramo,
	   actualizado,
	   user_added,
	   date_added,
	   corredor,
	   cedula,
	   a_periodo_ant
  from cobsuspe
 where fecha       <= _fecha
   and actualizado = 1;
--***************************************************************************
--Liberar pólizas de id avisos que no han sido procesados en el mes a cerrar.
--***************************************************************************
let _fecha_inicio = MDY(a_periodo_ant[6,7], 1, a_periodo_ant[1,4]); -- primer dia del mes a cerrar

foreach 
	select no_aviso,
		   renglon,
		   no_poliza 
	  into _no_aviso,
		   _renglon,
		   _no_poliza 
	  from avisocanc 
	 where estatus in ('G')			   
	   and fecha_proceso >= _fecha_inicio	
	   and fecha_proceso <= _fecha

	update avisocanc
	   set estatus			= "Y",  -- Se desmarca y se coloca motivo	
		   fecha_desmarca	= _fecha,
		   motivo_desmarca	= '012' -- motivo en AVICANMOT
	 where no_poliza		= _no_poliza
	   and no_aviso			= _no_aviso
	   and renglon			= _renglon;
	   
end foreach
		
end
return 0,"";
end procedure