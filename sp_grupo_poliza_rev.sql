drop procedure sp_grupo_poliza_rev;

create procedure "informix".sp_grupo_poliza_rev() 
returning	char(20), --_no_documento
			char(10),	
			char(50), --_pagador
			char(10),			
			char(50), --_asegurado		  	
			char(10),
			char(50);

define _cod_pagador_orig	char(10);
define _cod_asegurado		char(10);
define _cod_pagador_cas		char(10);
define _no_poliza			char(10);
define _cant_pol			smallint;
define _asegurado			char(50);
define _no_documento		char(20);
define _pagador				char(50);
define _cliente_cascliente	char(50);


set isolation to dirty read;

foreach
	SELECT no_documento,   
           cod_pagador_orig,      
           cod_asegurado,    
           cod_pagador_cas
      into _no_documento,   
      	   _cod_pagador_orig,
      	   _cod_asegurado,   
      	   _cod_pagador_cas        
      FROM cascliente_rev
     where no_documento not in ('0209-00075-04','0210-00312-01','0210-01096-01','0208-00053-04','0304-00188-01','0208-00747-02','0601-00040-01','0101-00128-01','0201-01256-01','0210-00718-01','1807-00669-01','0207-01597-01','0609-00005-03')
	  call sp_sis21(_no_documento) returning _no_poliza;																		
      
      update emipomae set cod_pagador = _cod_pagador_orig where no_poliza = _no_poliza;
		
   {	select count(*)
	  into _cant_pol
	  from caspoliza
	 where cod_cliente = _cod_cliente;

	if _cant_pol < 2 then
		continue foreach;
	end if
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

		update emipomae set cod_pagador = _cod_cliente where no_poliza = _no_poliza;
		
	   	select cod_pagador,
			   cod_contratante
		  into _cod_pagador,
		       _cod_asegurado
		  from emipomae 
		 where no_poliza = _no_poliza;
		
	   {	if _cod_pagador = _cod_cliente then
			continue foreach;
		end if 

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		select nombre
		  into _pagador
		  from cliclien
		 where cod_cliente = _cod_pagador;  }


		return _no_documento,'','','','','','' with resume;

   --	end foreach
end foreach
end procedure;
