-- Procedimiento que busca el producto vigente para las polizas de salud modulo de hospitales
-- Creado:	23/07/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web38;
 
create procedure sp_web38(a_no_poliza char(10), a_no_unidad char(5))
returning smallint;
		  
define _cod_cobertura   char(5);
define _count_cobertura smallint;
define _resultado       smallint;
define _cod_ramo        char(3);

--set debug file to "sp_web33.trc";
--trace on;

set isolation to dirty read;

let _resultado = 0;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;
 
SELECT count(*)
  into _count_cobertura
  FROM prdcober, emipocob
 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
   and no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and (nombre like '%LESIONES CORPORALES%' or nombre like '%DAÑOS A LA PROPIEDAD AJENA%');

if _count_cobertura > 0 then
	let _resultado = 1;
end if
	
return _resultado;			   
	   -- WITH RESUME;

end procedure
