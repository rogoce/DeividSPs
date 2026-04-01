-- Actualizacion del Area de un pagador dependiendo de la poliza
-- Creado    : 26/10/2011 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_cas110;

create procedure sp_cas110(
a_no_documento		char(20)
returning integer;

define _mando_mail          	smallint;
define _cod_pagador    			char(10);
define _no_poliza  				char(10);
define _code_pais		    	char(3);
define _code_provincia	    	char(2);
define _code_ciudad  	    	char(2);
define _code_distrito	    	char(2);

 

--set debug file to "sp_cas014bk.trc";
--trace on;
set isolation to dirty read;

call sp_sis21(a_no_documento) returning _no_poliza;

select cod_pagador
  into _cod_pagador
  from emipomae
 where no_poliza = _no_poliza;

select _code_pais		
	   _code_provincia
	   _code_ciudad  	
	   _code_distrito	