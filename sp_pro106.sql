-- Procedure que Genera una Historia de las Facturas

-- Creado    : 28/11/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/11/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

-- drop procedure sp_pro106;

create procedure sp_pro106()

define _no_poliza	char(10);
define _no_endoso	char(5);
define _cantidad    integer;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado  = 1

	select count(*)
	  into _cantidad
	  from endedhis
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad = 0 then
		call sp_pro100(_no_poliza, _no_endoso);
	end if

end foreach


end procedure