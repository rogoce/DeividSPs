-- Cambia el Cobra de Polizas dependiendo de diferentes condicones
-- 
-- Creado    : 29/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 29/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas063;

create procedure sp_cas063()
RETURNING 	CHAR(50),  -- Nombre Agente
			CHAR(50),  -- Nombre Compania
			CHAR(5),   -- cod_agente
			CHAR(20),  -- poliza
			CHAR(100),  -- cliente
			CHAR(1),
			smallint,
			char(100);

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _cod_agente		char(5);
define _cod_acreedor	char(5);
define _cobra_poliza	char(1);
define _cod_tipoprod	char(3);
define v_compania_nombre char(50);
define v_nombre_agente	char(50);
define v_nombre_cte     char(100);
define v_nombre_pag		char(100);
define _estatus_poliza  smallint;
define _cod_cliente,_cod_pagador   char(10);

set isolation to dirty read;

LET v_compania_nombre = sp_sis01("001");

foreach
 select no_documento
   into	_doc_poliza
   from emipomae 
  where actualizado = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select cod_tipoprod,
		   estatus_poliza,
		   cod_contratante,
		   cobra_poliza,
		   cod_pagador
	  into _cod_tipoprod,
		   _estatus_poliza,
		   _cod_cliente,
		   _cobra_poliza,
		   _cod_pagador
	  from emipomae
	 where no_poliza    = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _cobra_poliza <> "C" then
		continue foreach;
	end if

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	let _cod_agente   = null;
	let _cod_acreedor = null;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	    and cod_agente in("00780","00243")
		exit foreach;
	end foreach

	if _cod_agente is not null then

		foreach
		 select cod_acreedor
		   into _cod_acreedor
		   from emipoacr
		  where no_poliza = _no_poliza
		    and cod_acreedor not in("01358","01359","01360","01577","01361","00541","00547")
			exit foreach;
		end foreach

		if _cod_acreedor is not null then

		    select nombre
			  into v_nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;

		    select nombre
			  into v_nombre_cte
			  from cliclien
			 where cod_cliente = _cod_cliente;

		    select nombre
			  into v_nombre_pag
			  from cliclien
			 where cod_cliente = _cod_pagador;

			RETURN 	v_nombre_agente,
				    v_compania_nombre,
					_cod_agente,
					_doc_poliza,
					v_nombre_cte,
					_cobra_poliza,
					_estatus_poliza,
					v_nombre_pag
					WITH RESUME;
		end if
	end if

end foreach
end procedure