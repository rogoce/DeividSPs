-- Procedimiento Para Actualizar el Numero de Endoso
-- 
-- Creado    : 14/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/09/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par41;

create procedure sp_par41()

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_endoso_ext	char(5);

update endedmae
   set no_endoso_ext = NULL;

foreach
 select	no_poliza,
        no_endoso
   into	_no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
--    and no_poliza   = "40212"
  order by 1, 2

	let _no_endoso_ext = sp_sis30(_no_poliza, _no_endoso);

	update endedmae
	   set no_endoso_ext = _no_endoso_ext
	 where no_poliza     = _no_poliza
	   and no_endoso     = _no_endoso;

end foreach

end procedure
