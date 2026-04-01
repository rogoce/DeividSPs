--- Procedimiento para cargar tabla en MySql
--- Creado 03/02/2012 por Armando Moreno

drop procedure sp_sis08;

create procedure "informix".sp_sis08()
returning char(20),char(50),char(30),char(10),char(10);--decimal(16,2),decimal(16,2);

begin

define _nombre          char(50);
define _cedula          char(30);
define v_documento  	char(20);
define _cod_pagador     char(10);
define _no_poliza		char(10);
define _exigible		char(10);--decimal(16,2);
define _saldo			char(10);--decimal(16,2);
define _cod_no_renov	char(3);
define _cod_ramo		char(3);
define _cod_status		char(1);

--SET DEBUG FILE TO "sp_cob248.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

foreach

	select no_documento,
	       cod_pagador,
		   saldo,
		   exigible,
		   cod_status,
		   cod_ramo
	  into v_documento,
		   _cod_pagador,
		   _saldo,
		   _exigible,
		   _cod_status,
		   _cod_ramo
	  from emipoliza
	 where cod_status = '1'
	    or (cod_status = '3' and cod_ramo = '018')

	call sp_sis21(v_documento) returning _no_poliza;
		
	select cod_no_renov
	  into _cod_no_renov
	  from emipomae 
	 where no_poliza = _no_poliza;
	
	if _cod_ramo = '018' then
		if _cod_no_renov <> '027' then
			continue foreach;
		end if
	end if

	select nombre,
	       cedula
	  into _nombre,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_pagador;
	
	if _cedula is null then
		let _cedula = "";
	end if 

	return v_documento,_nombre,_cedula,_saldo,_exigible with resume;

end foreach

 
end
end procedure;
