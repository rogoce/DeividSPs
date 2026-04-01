-- Eliminar las Polizas de Super Corretaje con Acreedor del Call Center
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas044;

create procedure sp_cas044()
returning char(20),
          char(50),
          char(50),
          char(5);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_agente		char(5);
define _es_super		smallint;
define _cantidad		smallint;
define _nombre_acreedor	char(50);
define _nombre_pagador	char(50);
define _cod_pagador		char(10);
define _cod_acreedor	char(5);
define _cant_pol		smallint;

set isolation to dirty read;

foreach with hold
 select no_documento,
        cod_cliente
   into _no_documento,
        _cod_pagador
   from caspoliza

	let _no_poliza = sp_sis21(_no_documento);
	let _es_super  = 0;
	
   foreach	
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza
		
		if _cod_agente = "00243"  then
			let _es_super  = 1;
			exit foreach;
		end if

	end foreach

	if _es_super = 0 then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from emipoacr
	 where no_poliza = _no_poliza;

	if _cantidad = 0 then
		continue foreach;
	end if

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

   foreach	
	select cod_acreedor
	  into _cod_acreedor
	  from emipoacr
	 where no_poliza = _no_poliza

		select nombre
		  into _nombre_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;

	end foreach
	
{

	if _cod_acreedor = "00171" or
	   _cod_acreedor = "00169" or
	   _cod_acreedor = "00172" or
	   _cod_acreedor = "01361" then
		continue foreach;
	end if


	delete from caspoliza
	 where no_documento = _no_documento;

	update emipomae
	   set cobra_poliza = "C",
	       cod_formapag = "008"
	 where no_poliza    = _no_poliza;

	select count(*)
	  into _cant_pol
	  from caspoliza
	 where cod_cliente = _cod_pagador;

	if _cant_pol = 0 then

		delete from cascliente
		 where cod_cliente = _cod_pagador;

		delete from cobcapen
		 where cod_cliente = _cod_pagador;

	end if

--}

	return _no_documento,
	       _nombre_pagador,
		   _nombre_acreedor,
		   _cod_acreedor
	       with resume;

end foreach

end procedure
