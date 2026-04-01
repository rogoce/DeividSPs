-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis171f;

CREATE PROCEDURE "informix".sp_sis171f(a_no_tranrec CHAR(10))
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
define _error_isam		  integer;
define _no_reclamo		  char(10);
define _no_tranrec		  char(10);


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171c.trc";
--TRACE ON;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar el Reclamo: ' || trim(_no_tranrec) || ' en el Renglon: ' || trim(cast(_orden as char(3)));
	rollback work;
 	return _error,_mensaje;
end exception

FOREACH WITH HOLD

	 SELECT	distinct no_tranrec,orden
	   INTO	_no_tranrec,_orden
	   FROM	rectrrea
	  where cod_cober_reas = '000'
--	    and no_tranrec     = a_no_tranrec
	  order by no_tranrec,orden

BEGIN WORK;

	SELECT no_reclamo
	  INTO _no_reclamo
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;

	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

   call sp_sis188bk(_no_poliza) returning _error,_mensaje;

	select count(*)
	  into _cnt
	  from tmp_dist_rea;

		  if _cnt = 1 then

				select cod_cober_reas
				  into _cod_cober_reas
				  from tmp_dist_rea;

				update rectrrea
				   set cod_cober_reas = _cod_cober_reas
				 WHERE no_tranrec     = _no_tranrec
				   AND orden          = _orden;

                update rectrref
				   set cod_cober_reas = _cod_cober_reas
				 WHERE no_tranrec     = _no_tranrec;

		   elif _cnt > 1 then

				let _cod_cober_ant = '000';

				foreach

					select cod_cober_reas
					  into _cod_cober_reas
					  from tmp_dist_rea

					select count(*)
					  into _cnt2
					  from rectrrea
					 WHERE no_tranrec     = _no_tranrec
					   AND orden          = _orden
					   AND cod_cober_reas = '000';

					if _cnt2 > 0 then

						update rectrrea
						   set cod_cober_reas = _cod_cober_reas
						 WHERE no_tranrec     = _no_tranrec
						   AND orden          = _orden;

		                update rectrref
						   set cod_cober_reas = _cod_cober_reas
						 WHERE no_tranrec     = _no_tranrec
  	 					   AND orden          = _orden;

					else

						insert into rectrrea(
						no_tranrec,
						orden,
						cod_contrato,
						porc_partic_suma,
						porc_partic_prima,
						tipo_contrato,
						subir_bo,
						cod_cober_reas)
						select no_tranrec,
							   orden,
							   cod_contrato,
							   porc_partic_suma,
							   porc_partic_prima,
							   tipo_contrato,
							   subir_bo,
							   _cod_cober_reas
						  from rectrrea
						 where no_tranrec     = _no_tranrec
					       and orden          = _orden
					       and cod_cober_reas = _cod_cober_ant;


						insert into rectrref(
						no_tranrec,
						orden,
						cod_contrato,
						cod_coasegur,
						porc_partic_reas,
						cod_cober_reas)
						select no_tranrec,
							   orden,
							   cod_contrato,
							   cod_coasegur,
							   porc_partic_reas,
							   _cod_cober_reas
						  from rectrref
						 where no_tranrec     = _no_tranrec
					       and orden          = _orden
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
