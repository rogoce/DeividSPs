-- Clientes de Pago Fijo.
-- 
-- Creado    : 27/11/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob131;
create procedure "informix".sp_cob131() 
       returning char(10),
       			 char(100),
				 integer,
				 integer,
				 integer,
				 integer,
				 date,
       			 char(20);

define _nombre_pagador   char(100);
define _no_documento     char(20);
define _cod_pagador      char(10);
define _cod_campana      char(10);
define _dia_cobros1  	 integer;
define _dia_cobros2  	 integer;
define _cantidad 		 integer;
define _dia_1 		 	 integer;
define _dia_2		  	 integer;
define _fecha_ult_pro    date;

set isolation to dirty read;

--set debug file to "sp_cob131.trc"; 
--trace on;


let _cantidad = 0;

foreach
	select distinct cod_cliente
	  into _cod_pagador
	  from cascliente
	 where pago_fijo = 1
	 order by cod_cliente desc

	if _cod_pagador is null then
		continue foreach;
	end if

	foreach
		select fecha_ult_pro,
	   		   dia_cobros1,
			   dia_cobros2
		  into _fecha_ult_pro,
			   _dia_cobros1,
			   _dia_cobros2
		  from cascliente
		 where cod_cliente = _cod_pagador
		 order by fecha_ult_pro desc
		exit foreach;
	end foreach

	select count(*)
	  into _cantidad
	  from cobruter1
	 where cod_pagador = _cod_pagador;

	if _cantidad > 0 then
		foreach
			select dia_cobros1,
				   dia_cobros2	
			  into _dia_1,
			  	   _dia_2	
			  from cobruter1
			 where cod_pagador = _cod_pagador
			exit foreach;
		end foreach
	else
		let _dia_1 = 0;
		let _dia_2 = 0;
	end if

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	foreach
		select distinct no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = _cod_pagador

		return _cod_pagador,   
			   _nombre_pagador,  
			   _dia_cobros1,  
			   _dia_cobros2,  
			   _dia_1,      
			   _dia_2,
			   _fecha_ult_pro,
			   _no_documento
			   with resume;
	end foreach
end foreach
end procedure