--drop procedure beneficiarios;

create procedure "informix".beneficiarios(
v_poliza       char(10),
v_poliza_nuevo char(10))

define _no_unidad char(5);
define _cant	  integer;	

BEGIN
foreach

select no_unidad
  into _no_unidad
  from emipouni
 where no_poliza = v_poliza_nuevo

select count(*)
  into _cant 
  from emibenef
 where no_poliza = v_poliza_nuevo
   and no_unidad = _no_unidad;

if _cant = 0 then

	select *
	  from emibenef
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad
	  into temp prueba;
	
	update prueba
	   set no_poliza = v_poliza_nuevo
	 where no_poliza = v_poliza;

	insert into emibenef
	select * from prueba
	 where no_poliza = v_poliza_nuevo;

	drop table prueba;

end if

end foreach

END

end procedure;