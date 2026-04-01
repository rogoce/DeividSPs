-- Arreglo de la Tabla emipolvi

-- Creado    : 04/04/2006 - Autor: Demetrio Hurtado Almanza 

DROP PROCEDURE sp_par209;		

CREATE PROCEDURE "informix".sp_par209()
RETURNING INTEGER,
		  CHAR(100);

define _no_documento	char(20);
define _periodo			char(7);
define _cant_pol_vig	integer;
define _cant_uni_vig	integer;
define _cantidad		integer;
define _no_poliza		char(10);

set isolation to dirty read;

create temp table tmp_emipolvi(
	no_documento	char(20),
	periodo	   	    char(7),
	cant_pol_vig	integer,
	cant_uni_vig	integer,
	no_poliza		char(10)
) with no log;

foreach
 select no_documento, 
        periodo, 
        count(*)
   into _no_documento,
        _periodo,
		_cantidad
   from emipolvi
  group by 1, 2
 having count(*) > 1
  order by 1, 2

	foreach
	 select cant_pol_vig,
	        cant_uni_vig,
			no_poliza
	   into _cant_pol_vig,
	        _cant_uni_vig,
			_no_poliza
	   from emipolvi
	  where no_documento = _no_documento
	    and periodo      = _periodo

		insert into tmp_emipolvi
		values (_no_documento, _periodo, _cant_pol_vig, _cant_uni_vig, _no_poliza);
		
	end foreach

end foreach

foreach
 select no_documento, 
        periodo, 
        cant_pol_vig,
        cant_uni_vig,
		no_poliza
   into _no_documento, 
        _periodo, 
        _cant_pol_vig,
        _cant_uni_vig,
		_no_poliza
   from tmp_emipolvi

	delete from emipolvi
	 where no_documento = _no_documento
	   and periodo      = _periodo;

	insert into	emipolvi
	values (_no_documento, _periodo, _cant_pol_vig, _cant_uni_vig, _no_poliza);

end foreach

drop table tmp_emipolvi;

return 0, "Actualizacion Exitosa";

end procedure									
