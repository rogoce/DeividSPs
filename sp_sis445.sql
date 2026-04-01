-- Numero Interno de Poliza de la ultima Vigencia
-- dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis445;

CREATE PROCEDURE "informix".sp_sis445(a_no_poliza CHAR(10))
RETURNING SMALLINT, CHAR(5),dec(5,2),dec(5,2),dec(5,2),CHAR(50);

define _cod_agente      char(5);
define _porc_comis_agt  dec(5,2);
define _porc_partic_agt dec(5,2);
define _porc_produc     dec(5,2);
define _valor           smallint;
define _n_corredor      char(50);

SET ISOLATION TO DIRTY READ;

LET _cod_agente = NULL;
let _valor      = 0;
let _n_corredor  = '';
FOREACH
 SELECT	cod_agente,
	    porc_comis_agt,
		porc_partic_agt,
		porc_produc
   INTO	_cod_agente,
	    _porc_comis_agt,
		_porc_partic_agt,
		_porc_produc
   FROM	emipoagt
  WHERE no_poliza = a_no_poliza
	EXIT FOREACH;
END FOREACH

if _cod_agente is null then
	let _valor           = 1;
	let _porc_comis_agt  = 0;
	let _porc_partic_agt = 0;
	let _porc_produc     = 0;
	
ELSE
	select nombre into _n_corredor from agtagent where cod_agente = _cod_agente;
end if

RETURN _valor,_cod_agente,_porc_comis_agt,_porc_partic_agt,_porc_produc,_n_corredor;

END PROCEDURE;