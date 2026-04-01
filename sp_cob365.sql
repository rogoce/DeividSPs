-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob365;
create procedure sp_cob365(a_no_remesa char(10))
returning	int,
			char(50);

define _error_desc		char(50);
define _error_isam		integer;
define _error			integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _nueva_renov     char(1);
define _dias,_renglon	integer;
define _fecha_recibo    date;
define _cod_ramo		char(3);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob365.trc";
--trace on;
let _dias = 0;

foreach
	select no_poliza,
		   renglon,
		   fecha
	  into _no_poliza,
		   _renglon,
		   _fecha_recibo
	  from cobredet
	 where no_remesa    = a_no_remesa
	   and tipo_mov     in('P','N')

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "018" then -- Ramo de Salud
	
		let _dias = _fecha_recibo - _vigencia_inic;
		
		if _dias > 365 then
			let _nueva_renov = "R";
		else
			let _nueva_renov = "N";
		end if			

	end if

	update cobredet
	   set nueva_renov = _nueva_renov
	 where no_remesa   = a_no_remesa
       and renglon     = _renglon;

end foreach

return 0,'Actualización Exitosa';
end
end procedure;