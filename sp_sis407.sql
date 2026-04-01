--Armando Moreno 27/06/2013
--Procedure para verificar que la suma del porcentaje de participacion del corredor sea 100,
--ademas de que si el corredor es tipo 'O' oficina que el porcentaje de comision sea 0.
-- Se agrega validación del % de comisión por corredor -- Amado Perez M -- 16-08-2024

drop procedure sp_sis407;

create procedure "informix".sp_sis407(a_no_poliza char(10))
returning smallint,char(100);


DEFINE _valor              integer;
DEFINE _valor2             integer;
DEFINE _valor1             integer;
DEFINE _cod_agente   	   CHAR(5);
DEFINE _porc_partic,_porc_comis,_porc_produc,_porc_acum, _porc_comis_max  DEC(5,2);
DEFINE _mensaje            char(100);
DEFINE _tipo_agente        char(1);
DEFINE _cod_ramo, _cod_subramo, _cod_tipoprod	char(3); 

if a_no_poliza = '0001545158' then
SET DEBUG FILE TO "sp_sis373.trc"; 
trace on;
end if

set isolation to dirty read;


LET	_porc_partic = 0.00;
LET	_porc_comis	 = 0.00;
LET _porc_acum   = 0.00;
let _mensaje     = "";
LET _porc_comis_max = 0.00;

SELECT cod_ramo,
       cod_subramo,
	   cod_tipoprod
  INTO _cod_ramo,
       _cod_subramo,
	   _cod_tipoprod
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

FOREACH
	 SELECT	cod_agente, 
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente, 
			_porc_partic,
			_porc_comis
	   FROM	emipoagt
	  WHERE	no_poliza = a_no_poliza

	 select tipo_agente
	   into _tipo_agente
	   from agtagent
	  where cod_agente = _cod_agente;

	if _tipo_agente = 'O' and _porc_comis <> 0 then  --Oficina
	 	LET _mensaje = 'El porcentaje de comision para agente tipo Oficina debe ser cero...';
	 	RETURN 6, _mensaje;
	end if

	let _porc_acum = _porc_acum + _porc_partic;
	
	if _cod_ramo <> '019' then
		let _porc_comis_max = sp_pro305(_cod_agente, _cod_ramo, _cod_subramo);
	else
		let _porc_comis_max = sp_pro305(_cod_agente, _cod_ramo, _cod_subramo, a_no_poliza);
	end if
	
	if _cod_tipoprod <> '002' and _porc_comis > _porc_comis_max then
		LET _mensaje = "El porcentaje no puede ser mayor al establecido de " || _porc_comis_max || "%, verifique...";
		RETURN 1, _mensaje;
	end if
		
END FOREACH

if _porc_acum <> 100.00 then
 	LET _mensaje = 'El porcentaje de participacion de los agentes debe sumar 100.00';
 	RETURN 7, _mensaje;
end if

return 0, '';
end procedure
