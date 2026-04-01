-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis56;

create procedure "informix".sp_sis56()
returning char(10),
          char(10),
          char(3),
          char(10),
          char(5);

define _no_factura	char(10);
define _cantidad	smallint;
define _cod_endomov char(3);
define _no_factura2 char(10);
define _no_poliza	char(10);
define _no_endoso	char(5);

set isolation to dirty read;

foreach 
 select no_factura, 
        count(*)
   into _no_factura,
        _cantidad
   from endedmae
  where actualizado = 1
    and periodo    >= '2003-01'
    and periodo    <= '2003-12'
  group by no_factura
 having count(*) > 1

	foreach	with hold
	 select cod_endomov,
		    no_poliza,
		    no_endoso
	   into _cod_endomov,
		    _no_poliza,
		    _no_endoso
	   from endedmae
	  where no_factura = _no_factura

		if _cod_endomov = "014" then

			let _no_factura2 = trim(_no_factura) || ".";
			
			update endedmae
			   set no_factura = _no_factura2
			 where no_poliza  = _no_poliza
			   and no_endoso  = _no_endoso;

			return _no_factura,
			       _no_factura2,
				   _cod_endomov,
				   _no_poliza,
				   _no_endoso
				   with resume;

			exit foreach;

		end if
				
	end foreach

end foreach

end procedure