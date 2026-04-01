-- 

DROP PROCEDURE sp_sis411;

CREATE PROCEDURE "informix".sp_sis411() 
returning smallint;

define _no_documento	char(20);
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_emision	date;
define _cant_uni		integer;
define _porcentaje		dec(16,2);
define _prima			dec(16,2);
define _prima_neta		dec(16,2);
define _suma_asegurada  dec(16,2);
define _error			integer;
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_endoso0		char(5);
define _cod_descuen		char(3);

--set debug file to "sp_par32.trc";
--trace on;

let _no_poliza = "1578880";
let _suma_asegurada = 0;

foreach 
		 select no_unidad,suma_asegurada
		   into _no_unidad,_suma_asegurada
		   from emipouni
		  where no_poliza = _no_poliza

--		let _error = sp_proe01(_no_poliza, _no_unidad, "001"); -- Este procedure llama al proe02		end foreach

		let _error = sp_proe04(_no_poliza, _no_unidad, _suma_asegurada,'001');

end foreach

return _error;

END PROCEDURE 

