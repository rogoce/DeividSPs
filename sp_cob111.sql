-- Cambia el Cobra de Polizas dependiendo de diferentes condicones
-- 
-- Creado    : 29/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 29/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob111;

create procedure sp_cob111()
returning char(20),char(100),char(10),date,date;

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _incobrable		smallint;
define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _cod_agente		char(5);
define _cobra_poliza	char(1);
define _cobra_poliza2	char(1);
define _cod_tipoprod	char(3);
define _formapag        char(2);
define _cod_pagador		char(10);
define _asignado		smallint;
define _cantidad        integer;
define _gestion			char(1);
define _pagador			char(100);
define _vig_ini			date;
define _vig_fin			date;
set isolation to dirty read;

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where actualizado = 1
    and cobra_poliza = "E"
  group by no_documento		

  let _no_poliza = sp_sis21(_doc_poliza);

	select incobrable,
	       cobra_poliza,
		   cod_formapag,
		   cod_tipoprod,
		   gestion,
		   cod_pagador,
		   vigencia_inic,
		   vigencia_final
	  into _incobrable,
	       _cobra_poliza2,
		   _cod_formapag,
		   _cod_tipoprod,
		   _gestion,
		   _cod_pagador,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _cobra_poliza2 = "E" then
	else
		continue foreach;
	end if

	select cod_cliente
	  into _cod_cliente
	  from caspoliza
	 where no_documento = _doc_poliza;

	if _cod_cliente is null then  --no esta en CC.
	else
		continue foreach;
	end if

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	return _doc_poliza,
		   _pagador,
		   _cod_pagador,
		   _vigencia_inic,
		   _vigencia_final
		   with resume;
end foreach
end procedure
