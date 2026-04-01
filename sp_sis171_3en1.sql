-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado      : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 25/04/2016 -Federico Coronado. 3 en 1 

drop procedure sp_sis171_3en1;
create procedure sp_sis171_3en1(a_no_poliza char(10), a_cod_ramo char(3), a_no_cambio smallint)
returning integer, char(250);

define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6);
define _porcentaje          dec(9,6);
define _no_cambio			smallint;
define _orden				smallint;
define _cnt					smallint;
define _error				integer;


set isolation to dirty read;

begin
	ON EXCEPTION SET _error 
		RETURN _error, 'Error al Actualizar el Endoso ' || a_no_poliza;         
	END EXCEPTION           

create temp table tmp_emireaco(
no_poliza    		char(10),
no_unidad           char(5),
no_cambio           smallint,
cod_cober_reas      char(3),
orden               smallint,
cod_contrato        char(5),
porc_partic_suma	dec(9,6), 	
porc_partic_prima	dec(9,6)
) with no log;
		
if a_cod_ramo <> '024' then
	if a_cod_ramo in('023','002') then
		let _no_unidad = sp_sis446(a_no_poliza, a_no_cambio);
	else
	
		select min(no_unidad)
		  into _no_unidad
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_cambio = a_no_cambio;
	end if   

    if a_cod_ramo = '019' then	--Verificar que emireaco para vida tenga los mismos % que en emifacon, de no sumar 100% AMM
		foreach
			select cod_cober_reas,
				   sum(porc_partic_prima)
			  into _cod_cober_reas,
				   _porcentaje
			  from emireaco
			 where no_poliza = a_no_poliza
			   and no_cambio = a_no_cambio
			 group by cod_cober_reas

			if _porcentaje is null then
				let _porcentaje = 0;
			end if
			
			if _porcentaje <> 100 then
				delete from emireaco
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad
				   and no_cambio = a_no_cambio;
			  
				INSERT INTO emireaco(
				no_poliza,
				no_unidad,
				no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
				)
				SELECT 
				a_no_poliza, 
				no_unidad,
				a_no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
				FROM emifacon
				WHERE no_poliza = a_no_poliza
				  AND no_endoso = '00000';

				exit foreach;
			end if
		end foreach
	end if
	foreach
		select cod_contrato,
			   porc_partic_prima,
			   orden,
			   porc_partic_suma,
			   cod_cober_reas
		  into _cod_contrato,
			   _porc_partic_prima,
			   _orden,
			   _porc_partic_suma,
			   _cod_cober_reas
		  from emireaco
		 where no_poliza      = a_no_poliza
		   and no_unidad      = _no_unidad
		   and no_cambio      = a_no_cambio
		   
		insert into tmp_emireaco(
			no_poliza,    	
			no_unidad,        
			no_cambio,        
			cod_cober_reas,   
			orden,            
			cod_contrato,     
			porc_partic_suma,
			porc_partic_prima)
			values(
			a_no_poliza, 
			_no_unidad,
			a_no_cambio,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima
			);	      
	end foreach
else
	foreach
		select cod_contrato,
			   no_unidad,
			   porc_partic_prima,
			   orden,
			   porc_partic_suma,
			   cod_cober_reas
		  into _cod_contrato,
			   _no_unidad,
			   _porc_partic_prima,
			   _orden,
			   _porc_partic_suma,
			   _cod_cober_reas
		  from emireaco
		 where no_poliza      = a_no_poliza
		   and no_cambio      = a_no_cambio
		   
		insert into tmp_emireaco(
			no_poliza,    	
			no_unidad,        
			no_cambio,        
			cod_cober_reas,   
			orden,            
			cod_contrato,     
			porc_partic_suma,
			porc_partic_prima)
			values(
			a_no_poliza, 
			_no_unidad,
			a_no_cambio,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima
			);	

	end foreach
end if
Return 0, "Actualizacion Exitosa ...";
end 
end procedure;