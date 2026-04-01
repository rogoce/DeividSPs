-- Insertando 
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro522;

create procedure sp_pro522(
    a_no_documento char(20),
    a_no_factura char(10))

returning smallint,
		  char(25);

define _no_poliza char(10);
define _no_endoso char(5);
define _error     integer;
define _cant      integer;
--set debug file to "sp_pro172.trc";

set isolation to dirty read;

foreach
	select no_poliza, no_endoso
	  into _no_poliza, _no_endoso 
	  from endedmae
	 where no_factura = a_no_factura
	   and cod_endomov = '002'
	   and cod_tipocalc = '001'

	select count(*)
	 into _cant
	 from endedmae
	where no_poliza = _no_poliza
	  and cod_endomov = '002'
	  and cod_tipocalc = '004';

	if _cant > 0 then
		continue foreach;
	end if


	set lock mode to wait;

	begin
	on exception set _error    		
	--	if _error = -268 or _error = -239 then 
	--	else
	 		return _error, "Error al Actualizar";         
	--	end if
	end exception 


	insert into tmpcoboutle2(
			no_poliza,
			no_endoso,
			no_documento,
			no_factura
			)
	values	(
			_no_poliza,
			_no_endoso,
			a_no_documento,
			a_no_factura
			);

	end
end foreach
return 0, "Actualizacion Exitosa";
end procedure;