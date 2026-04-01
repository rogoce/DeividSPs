-- Procedimiento para verificar si una poliza tiene reclamos
--
-- Creado    : 27/12/2012 - Autor: Federico Coronado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp08;

CREATE PROCEDURE sp_imp08(a_poliza CHAR(10), a_fecha_inicial date)
			RETURNING   integer,	--v
						char(100);	-- mensaje

define _resultado integer;
define _mensaje char(100);
define _fecha_siniestro date;
define _cod_ramo 	char(3);
						
						
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_imp08.trc";      
--TRACE ON;                                                    

let _mensaje = "";
let _resultado = "";

select count(*)
  into _resultado
  from recrcmae
 where no_poliza = a_poliza
   and actualizado = 1;

select cod_ramo into _cod_ramo from emipomae where no_poliza = a_poliza;
if _cod_ramo not in('002') then
	return 0, _mensaje;
end if	
   
if _resultado > 0 then
	select max(fecha_siniestro)
	into _fecha_siniestro
	from recrcmae 
	where no_poliza = a_poliza
	and actualizado = 1;
	
	if a_fecha_inicial <= _fecha_siniestro then
		let _mensaje = "Esta póliza tiene un reclamo el " || _fecha_siniestro ||", por favor verifique";
		RETURN 1, _mensaje;
	else 
		return 0, _mensaje;
	end if
else 
	return 0, _mensaje;
end if 
	
END PROCEDURE