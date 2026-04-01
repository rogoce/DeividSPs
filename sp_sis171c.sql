-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


--drop PROCEDURE sp_sis171c;

CREATE PROCEDURE "informix".sp_sis171c(a_no_remesa CHAR(10))
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
define _error_isam			integer;


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171c.trc";
--TRACE ON;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar la Remesa: ' || trim(_no_remesa) || ' en el Renglon: ' || trim(cast(_renglon as char(3)));
	rollback work;
 	return _error,_mensaje;
end exception

FOREACH WITH HOLD

	 SELECT	distinct no_remesa,
	        renglon
	   INTO	_no_remesa,
		    _renglon
	   FROM	cobreaco
	  where cod_cober_reas = '000'
	  order by no_remesa,renglon

BEGIN WORK;

	SELECT no_poliza
	  INTO _no_poliza
	  FROM cobredet
	 WHERE no_remesa = _no_remesa
	   AND renglon   = _renglon;

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

   call sp_sis188(_no_poliza) returning _error,_mensaje;

	select count(*)
	  into _cnt
	  from tmp_dist_rea;

		  if _cnt = 1 then

				select cod_cober_reas,porc_cober_reas
				  into _cod_cober_reas,_porc_proporcion
				  from tmp_dist_rea;

				update cobreaco
				   set cod_cober_reas  = _cod_cober_reas,
				       porc_proporcion = _porc_proporcion
				 WHERE no_remesa      = _no_remesa
				   AND renglon        = _renglon;


		   elif _cnt > 1 then

				let _cod_cober_ant = '000';

				foreach

					select cod_cober_reas,porc_cober_reas
					  into _cod_cober_reas,_porc_proporcion
					  from tmp_dist_rea

					select count(*)
					  into _cnt2
					  from cobreaco
					 WHERE no_remesa      = _no_remesa
					   AND renglon        = _renglon
					   AND cod_cober_reas = '000';

					if _cnt2 > 0 then

						update cobreaco
						   set cod_cober_reas  = _cod_cober_reas,
						       porc_proporcion = _porc_proporcion
						 WHERE no_remesa      = _no_remesa
						   AND renglon        = _renglon;
					else

						insert into cobreaco(
						no_remesa,
						renglon,
						orden,
						cod_contrato,
						porc_partic_suma,
						porc_partic_prima,
						subir_bo,
						cod_cober_reas,
						porc_proporcion)
						select no_remesa,
							   renglon,
							   orden,
							   cod_contrato,
							   porc_partic_suma,
							   porc_partic_prima,
							   subir_bo,
							   _cod_cober_reas,
							   _porc_proporcion 
						  from cobreaco
						 where no_remesa      = _no_remesa
					       and renglon        = _renglon
					       and cod_cober_reas = _cod_cober_ant;

					end if

					let _cod_cober_ant = _cod_cober_reas;

				end foreach

		   end if

   drop table tmp_dist_rea;

COMMIT WORK;

END FOREACH

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
end

END PROCEDURE;
