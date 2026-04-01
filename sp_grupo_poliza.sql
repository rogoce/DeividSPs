drop procedure sp_grupo_poliza;

create procedure "informix".sp_grupo_poliza() 
returning	char(20), --_no_documento
			char(10),	
			char(50), --_pagador
			char(10),			
			char(50), --_asegurado		  	
			char(10),
			char(50);

define _cod_pagador			char(10);
define _cod_asegurado		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _cant_pol			smallint;
define _asegurado			char(50);
define _no_documento		char(20);
define _pagador				char(50);
define _cliente_cascliente	char(50);


set isolation to dirty read;

foreach
	select distinct cod_cliente
	  into _cod_cliente
	  from cascliente
	 where cod_campana = '00000'
		
   {	select count(*)
	  into _cant_pol
	  from caspoliza
	 where cod_cliente = _cod_cliente;

	if _cant_pol < 2 then
		continue foreach;
	end if }
	select nombre
	  into _cliente_cascliente
	  from cliclien
	 where cod_cliente = _cod_cliente; 
	 
	foreach
		select no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = _cod_cliente

		call sp_sis21(_no_documento) returning _no_poliza;

	   --	update emipomae set cod_pagador = _cod_cliente where no_poliza = _no_poliza;
		
	   	select cod_pagador,
			   cod_contratante
		  into _cod_pagador,
		       _cod_asegurado
		  from emipomae 
		 where no_poliza = _no_poliza;
		
	   	if _cod_pagador = _cod_cliente then
			continue foreach;
		end if 

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		select nombre
		  into _pagador
		  from cliclien
		 where cod_cliente = _cod_pagador;


		return _no_documento,_cod_pagador,_pagador,_cod_asegurado,_asegurado,_cod_cliente,_cliente_cascliente with resume;

	end foreach
end foreach
end procedure;
