-- Procedimiento traer las direcciones de las polizas que se encuentran en campaña por cliente 
-- 
-- Creado     : 31/10/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par325;

create procedure "informix".sp_par325(a_cod_pagador char(10))
returning char(20),
          char(50),
		  char(50),
		  char(5);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_area		char(5);
define _direccion1		char(50);
define _direccion2		char(50);


--set debug file to "sp_par324.trc";
--trace on;

set isolation to dirty read;

foreach
	select distinct no_documento
  	  into _no_documento
  	  from caspoliza
 	 where cod_cliente = a_cod_pagador

	call sp_sis21(_no_documento) returning _no_poliza;

	select direccion_1,
		   direccion_2,
		   code_correg
	  into _direccion1,
		   _direccion2,
		   _cod_area
	  from emidirco
	 where no_poliza = _no_poliza;

	return _no_documento,
		   _direccion1,
		   _direccion2,
		   _cod_area with resume;

end foreach
end procedure