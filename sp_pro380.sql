-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_pro380;
create procedure sp_pro380()
returning	smallint,
			varchar(50);

			
define _cod_modelo_bien char(5);
define _cod_modelo_mal char(5);

set isolation to dirty read;

--set debug file to "sp_pro380.trc";	 																						 
--trace on;

foreach
	select distinct cod_modelo_queda,
		   cod_modelo_eli
	  into _cod_modelo_bien,
		   _cod_modelo_mal
	  from equimodel e, modeldepur d
	 where e.cod_modelo_ancon = d.cod_modelo_eli
	   and cod_modelo_ancon not in (select cod_modelo from emimodel)
	 order by 1
	 
	update equimodel
	   set cod_modelo_ancon = _cod_modelo_bien
	 where cod_modelo_ancon = _cod_modelo_mal;

	update prdemielctdet
	   set cod_modelo = _cod_modelo_bien
	 where cod_modelo = _cod_modelo_mal;
	 
end foreach
end procedure;