-- Polizas que Cobra Ancon y no estan en el Call Center
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas041;

create procedure sp_cas041(a_compania char(3), a_agencia char(3))
returning char(20),
          date,
          char(1),
          char(50),
          char(3),
          char(10),
          char(100),
          char(5),
          char(50),
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cobra_poliza	char(1);
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _cantidad		smallint;
define _fecha_emision	date;

define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _nombre_formapag	char(50);
define _dias			smallint;
define _return			smallint;
define _cod_pagador		char(10);
define _nombre_pagador	char(100);
define _cod_agente		char(5);
define _nombre_agente	char(50);
define _nombre_compania	char(50);

set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania);

foreach
 select no_documento
   into	_no_documento
   from emipomae 
  where actualizado    = 1
    and cobra_poliza   = "A"
    and estatus_poliza = 1   
	and cod_tipoprod   not in ("002", "004")
  group by no_documento		

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
		   cobra_poliza,
		   estatus_poliza,
		   fecha_suscripcion,
		   cod_formapag,
		   cod_pagador
	  into _cod_tipoprod,
		   _cobra_poliza,
		   _estatus_poliza,
		   _fecha_emision,
		   _cod_formapag,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	if _cobra_poliza <> "A" then
		continue foreach;
	end if

	SELECT tipo_forma,
	       nombre
	  INTO _tipo_forma,
	       _nombre_formapag
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma = 3 or   -- Descuento Directo
	   _tipo_forma = 5 then -- Call Center
		
		let _dias = today - _fecha_emision;

		if _dias <= 20 then
			continue foreach;
		end if

	end if

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	 order by 1
		exit foreach;
	end foreach

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	return _no_documento,
	       _fecha_emision,
		   _cobra_poliza,
		   _nombre_formapag,
		   _cod_formapag,
		   _cod_pagador,
		   _nombre_pagador,
		   _cod_agente,
		   _nombre_agente,     
		   _nombre_compania     
	       with resume;

end foreach

end procedure