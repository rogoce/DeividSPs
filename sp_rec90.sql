-- Porcedure que determina si es un reclamo de una poliza con cobertura 
-- Completa o solo pagos a terceros

--drop procedure sp_rec90;

create procedure "informix".sp_rec90(a_no_reclamo char(10))
returning char(1);

define _no_poliza	char(10);
define _no_unidad	char(5);
define _cod_ramo	char(3);
define _tipo_cob	char(1);
define _cantidad	smallint;
define _no_endoso	char(5);

-- Tipos de Cobertura
-----------------------------
-- 0 - No Aplica
-- 1 - Cobertura Completa
-- 2 - Daños a Terceros

set isolation to dirty read;

let _tipo_cob = "0";

select no_poliza,
       no_unidad
  into _no_poliza,
       _no_unidad
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

if _cod_ramo <> "002" then
	return _tipo_cob;
end if

 select count(*)
   into _cantidad
   from emipocob
  where no_poliza = _no_poliza
    and no_unidad = _no_unidad;

if _cantidad = 0 then

	select min(e.no_endoso)
	  into _no_endoso
	  from endedmae	e, endeduni u
	 where e.no_poliza   = u.no_poliza
	   and e.no_endoso   = u.no_endoso
	   and u.no_unidad   = _no_unidad
	   and e.actualizado = 1;

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from endedcob
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
	    and no_unidad = _no_unidad

	end foreach

else

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from emipocob
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad

		if _cod_cobertura = "00102"	or 
		   _cod_cobertura = "00113"	or
		   _cod_cobertura = "00117"	or
		   _cod_cobertura = "00118"	or
		   _cod_cobertura = "00119"	or
		   _cod_cobertura = "00606"	then

		end if

	end foreach

end if

end procedure