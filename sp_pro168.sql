-- Asegurados Hombres y Dependientes Mujeres

-- Creado    : 29/06/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_pro168;

create procedure "informix".sp_pro168()
 
define _cantidad		integer;
define _no_poliza		char(10);

-- Para Asegurados hombres donde el dependiente es mujer necesitaremos la 
-- vigencia inicial y la vigencia final de la poliza (esto ya esta); 
-- la edad del asegurado principal y 
-- la edad de la dependiente, 
-- la prima suscrita y 
-- el incurrido bruto si lo hay.  
-- El peridodo que me han indicado evaluar es desde 
-- enero de 2006 a la fecha. 

foreach
 select 
   into
   from emipomae
  where cod_ramo = "018"
    and cod_subramo in ("007", "008")
	and status_poliza in (1)

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select
	   into
	   from emipouni
	  where no_poliza = _no_poliza

		select nombre,
		       fecha_aniver


	end foreach


end foreach


end procedure
