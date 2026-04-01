-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis171d;

CREATE PROCEDURE "informix".sp_sis171d()
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

	select no_remesa
	  into _no_remesa
	  from cobremae
	 where fecha = '23/09/2013'
	   and actualizado = 1
	 order by 1


	 SELECT	count(*)
	   INTO	_cnt
	   FROM	cobreaco
	  where no_remesa = _no_remesa;

     if _cnt = 0 then

	   call sp_sis171(_no_remesa) returning _error, _mensaje;

       if _error <> 0 then

		RETURN _error, _mensaje;

	   end if

	 end if


END FOREACH

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
end

END PROCEDURE;
