-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado      : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 25/04/2016 -Federico Coronado. 3 en 1 

drop procedure sp_sis171_3en1;
create procedure "informix".sp_sis171_3en1(a_no_poliza char(10))
returning integer, char(250);

define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6); 
define _no_cambio			smallint;
define _orden				smallint;
define _cnt					smallint;
define _error				integer;

set isolation to dirty read;

begin
on exception set _error 
	return _error, 'Error al crear la proporción de la distribución de reaseguro. ' || a_no_poliza;         
end exception           

drop table if exists tmp_emireaco;
create temp table tmp_emireaco(
no_poliza			char(10),
no_unidad			char(5),
no_cambio			smallint,
cod_cober_reas		char(3),
orden				smallint,
cod_contrato		char(5),
porc_partic_suma	dec(9,6), 	
porc_partic_prima	dec(9,6)) with no log;

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	 order by 1

	select nvl(max(no_cambio),0)
	  into _no_cambio
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	--Validación de Emireaco
	if _no_cambio = 0 then
	end if

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   orden,
			   porc_partic_prima,
			   porc_partic_suma
		  into _cod_contrato,
			   _cod_cober_reas,
			   _orden,
			   _porc_partic_prima,
			   _porc_partic_suma
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		   and porc_partic_prima <> 0
		   
		insert into tmp_emireaco(
				no_poliza,    	
				no_unidad,        
				no_cambio,        
				cod_cober_reas,   
				orden,            
				cod_contrato,     
				porc_partic_suma,
				porc_partic_prima)
		values(	a_no_poliza, 
				_no_unidad,
				_no_cambio,
				_cod_cober_reas,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima);	      
	end foreach
end foreach

return 0, "Actualizacion Exitosa ...";
end 
end procedure;