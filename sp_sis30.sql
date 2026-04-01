-- Procedimiento que Genera el Numero de Endoso Externo (Cuando esta Actualizado)
-- 
-- Creado    : 14/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/09/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis30;

create procedure sp_sis30(
a_no_poliza char(10),
a_no_endoso char(5)
)
returning char(5);

define _no_endoso_int	integer;
define _no_endoso_ext	char(5);

if a_no_endoso = "00000" then

	let _no_endoso_int = 0;

else

	select max(no_endoso_ext)
	  into _no_endoso_int
	  from endedmae
	 where no_poliza   = a_no_poliza
	   and actualizado = 1;

	if _no_endoso_int is null then
		let _no_endoso_int = 0;
	end if

	let _no_endoso_int = _no_endoso_int + 1;

end if

let _no_endoso_ext = sp_set_codigo(5, _no_endoso_int);

return _no_endoso_ext;

end procedure;