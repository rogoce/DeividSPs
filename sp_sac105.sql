-- Procedure que arregla que cuadre cglresumen vs cglresumen1

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac105;

create procedure sp_sac105(a_notrx integer)
returning integer,
          char(50);

define _noregistro		integer;

foreach
 select res_noregistro
   into _noregistro
   from cglresumen
  where res_notrx = a_notrx

	delete from cglresumen1
	 where res1_noregistro = _noregistro;

end foreach

delete from cglresumen
 where res_notrx = a_notrx;

return 0, "Actualizacion Exitosa";

end procedure