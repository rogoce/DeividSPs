-- Arreglo de la Tabla emiunivi

-- Creado    : 04/04/2006 - Autor: Demetrio Hurtado Almanza 

DROP PROCEDURE sp_par210;

CREATE PROCEDURE "informix".sp_par210()
RETURNING INTEGER,
		  CHAR(100);

define _no_documento	char(20);
define _periodo			char(7);
define _cant_uni_vig	integer;
define _cantidad		integer;
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_motor		char(30);

set isolation to dirty read;

create temp table tmp_emiunivi(
	no_documento	char(20),
	no_unidad		char(5),
	periodo	   	    char(7),
	cant_uni_vig	integer,
	no_poliza		char(10),
	no_motor		char(30)
) with no log;

foreach
 select no_documento,
        no_unidad, 
        periodo, 
        count(*)
   into _no_documento,
        _no_unidad,
        _periodo,
		_cantidad
   from emiunivi
  group by 1, 2, 3
 having count(*) > 1
  order by 1, 2, 3

	foreach
	 select cant_uni_vig,
			no_poliza,
			no_motor
	   into _cant_uni_vig,
			_no_poliza,
			_no_motor
	   from emiunivi
	  where no_documento = _no_documento
	    and no_unidad    = _no_unidad
	    and periodo      = _periodo

		insert into tmp_emiunivi
		values (_no_documento, _no_unidad, _periodo, _cant_uni_vig, _no_poliza, _no_motor);
		
	end foreach

end foreach

foreach
 select no_documento,
        no_unidad, 
        periodo, 
        cant_uni_vig,
		no_poliza,
		no_motor
   into _no_documento,
        _no_unidad, 
        _periodo, 
        _cant_uni_vig,
		_no_poliza,
		_no_motor
   from tmp_emiunivi

	delete from emiunivi
	 where no_documento = _no_documento
	   and no_unidad    = _no_unidad
	   and periodo      = _periodo;

	insert into	emiunivi
	values (_no_documento, _no_unidad, _periodo, _cant_uni_vig, _no_poliza, _no_motor);

end foreach

drop table tmp_emiunivi;

return 0, "Actualizacion Exitosa";

end procedure									
