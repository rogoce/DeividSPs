-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis171rd;

CREATE PROCEDURE "informix".sp_sis171rd()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
DEFINE _renglon         SMALLINT;
DEFINE _no_cambio       SMALLINT;
DEFINE _no_unidad       CHAR(5);
DEFINE _cod_cober_reas  CHAR(3);
DEFINE _cod_tipoprod 	CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _cod_coasegur    CHAR(3);
DEFINE _cod_compania    CHAR(3);
DEFINE _cod_ramo        CHAR(3);
DEFINE _ramo_sis        SMALLINT;
DEFINE _porcentaje      DEC(7,4);
DEFINE _contador_ret	SMALLINT;
DEFINE _abierta         SMALLINT;
DEFINE _vigencia_final  DATE;
DEFINE _cod_contrato    CHAR(5);
DEFINE _porc_partic_prima DEC(9,6); 
DEFINE _porc_partic_suma  DEC(9,6); 
DEFINE _orden,_cnt,_cnt2  SMALLINT;
DEFINE _porc_partic_reas  decimal(9,6);
define _porc_proporcion   decimal(9,6);
define _cod_cober_ant     char(3);
define _no_remesa         char(10);
define _error_isam		  integer;


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171c.trc";
--TRACE ON;

begin


FOREACH

	select distinct r.no_remesa,r.renglon
	into _no_remesa,_renglon
  from cobredet d, cobreaco r
 where d.no_remesa = r.no_remesa and d.renglon = r.renglon and d.no_poliza in ('1212408',
'1212574',
'1212577',
'1212677',
'1212736',
'1212760',
'1213223',
'1213314',
'1213332',
'1213357',
'1213395',
'1213604',
'1213933',
'1216335',
'1216555',
'1216771',
'1216792',
'1216895',
'1217056',
'1217057',
'1217762',
'1219745',
'1220311',
'1220319',
'1220632',
'1220635',
'1220798',
'1220836',
'1220852',
'1220872',
'1220893',
'1220895',
'1220897',
'1220911',
'1220917',
'1220929',
'1220959',
'1220983',
'1221792',
'1222333',
'1222340',
'1222402',
'1222472',
'1222767',
'1222788',
'1222801',
'1222803',
'1222837',
'1222841',
'1222860',
'1222931',
'1222975')  and periodo = '2018-08'

	   call sp_sis171r(_no_remesa,_renglon) returning _error, _mensaje;

       if _error <> 0 then

		RETURN _error, _mensaje;

	   end if

END FOREACH

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
end

END PROCEDURE;
