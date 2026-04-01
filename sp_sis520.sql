-- Procedimiento para buscar registros de cobenvau para proceso de envio de correos a corredores
-- Diario sis100
-- Creado: 06/06/2025 - Autor: Armando Moreno

DROP PROCEDURE sp_sis520;
CREATE PROCEDURE sp_sis520(a_tipo smallint)
RETURNING char(10), CHAR(5),char(50);

DEFINE	_cod_agente		CHAR(5);
DEFINE	_no_remesa		CHAR(10);
define _cnt 			smallint;
define _n_agente        char(50);

BEGIN
let _n_agente = "";

{select count(*)
  into _cnt
  from cobenvau
 where tipo    = a_tipo
   and enviado = 0;

if _cnt is null then
	let _cnt = 0;
end if
if _cnt = 0 then
	RETURN "","","";
end if}

foreach
	select distinct no_remesa
	  into _no_remesa
	  from cobenvau
	 where tipo = a_tipo
       and enviado = 0
	   
	foreach
		select cod_agente
		  into _cod_agente
		  from cobpaex0
		 where no_remesa_ancon = _no_remesa
		 
		exit foreach;
	end foreach
	
	select nombre into _n_agente from agtagent
	where cod_agente = _cod_agente;
	
	let _n_agente = trim(_n_agente);
	
	return _no_remesa,_cod_agente,_n_agente with resume;
end foreach
END
END PROCEDURE
