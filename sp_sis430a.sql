-- Procedimiento para buscar el valor del descuento
-- f_emision_busca_descuento
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe21 pero para tablas de endoso.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis430a;
create procedure sp_sis430a()
returning   char(10);

define _no_poliza 		char(10);
define _cnt             smallint;
let _cnt = 0;
begin

set isolation to dirty read;

foreach
	select no_poliza
	  into _no_poliza
	  from sac999:reacomp
	 where tipo_registro = 1
	 and periodo = '2023-07'
	 and sac_asientos = 0
	 and fecha = '25/07/2023'
	 and no_endoso = '00000'
	 
	select count(*)
      into _cnt
      from endedmae
	 where no_poliza = _no_poliza;

	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
	else
		return _no_poliza with resume;
	end if
	  
end foreach	 

end
end procedure;