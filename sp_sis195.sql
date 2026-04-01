

-- Creado    : 05/05/2014 - Autor: Armando Moreno M.

--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis195;

create procedure sp_sis195(a_no_poliza char(10),a_no_unidad char(5))
returning smallint;

define _tipo		  integer;
define _cod_cobertura char(5);
define _cod_ramo      char(3);

let _tipo = 1;

foreach
     select cod_cobertura
	   into _cod_cobertura
	   from emipocob
	  where no_poliza = a_no_poliza
	    and no_unidad = a_no_unidad

		if _cod_cobertura = "00118" or 
		   _cod_cobertura = "00119" or 
		   _cod_cobertura = "00121" then

			let _tipo = 2;
			exit foreach;
		end if
end foreach

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza
   and actualizado = 1;

if _cod_ramo = '020' then
	let _tipo = 3;
end if

return _tipo;

end procedure;