-- Reporte de Polizas Que No Son Coas. Mayoritario y Tienen Datos en las Tablas de Coaseguro

-- Creado    : 03/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_par58;

create procedure sp_par58() 
returning char(10),
          char(20),
          char(3),
          char(7);

define _no_poliza		char(10);
define _cantidad		smallint;
define _no_documento	char(20);
define _cod_tipoprod	char(3);
define _periodo			char(7);

set isolation to dirty read;

foreach
 select no_poliza,
        no_documento,
		cod_tipoprod,
		periodo
   into _no_poliza,
		_no_documento,
		_cod_tipoprod,
		_periodo
   from emipomae
  where actualizado  = 1
    and cod_tipoprod <> "001"

	select count(*)
	  into _cantidad
	  from emicoama
	 where no_poliza = _no_poliza;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad <> 0 then
		
		return _no_poliza,
		       _no_documento,
			   _cod_tipoprod,
			   _periodo
		  with resume;

	end if


end foreach

end procedure;
