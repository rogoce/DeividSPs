-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par285;

CREATE PROCEDURE "informix".sp_par285(a_fecha date)
returning CHAR(10), CHAR(10), SMALLINT, CHAR(8), CHAR(3), DATE, CHAR(10), CHAR(3);

BEGIN

DEFINE	_cod_peticion		CHAR(10);
DEFINE	_cod_suministro		CHAR(10);
DEFINE	_cantidad			SMALLINT;
DEFINE	_usuario			CHAR(8);
DEFINE	_depto				CHAR(3);
DEFINE	_fecha				DATE;
DEFINE	_cod_marca			CHAR(10);
DEFINE  _cod_agencia		CHAR(3);


SET ISOLATION TO DIRTY READ;

FOREACH

	SELECT 	 cod_peticion,
			 cod_suministro,
			 cantidad,
			 user_added,
			 cod_depto,
			 date_added,
			 cod_marca,
			 cod_agencia
	INTO	_cod_peticion,
			_cod_suministro,
			_cantidad,
			_usuario,
			_depto,
			_fecha,
			_cod_marca,
		    _cod_agencia
	FROM psumin
	WHERE psumin.estatus = 0
	and entregado = 1 
	and	cod_agencia = "001"
	and date_added = a_fecha

	RETURN _cod_peticion,
	_cod_suministro,
	_cantidad,
	_usuario,
	_depto,
	_fecha,
	_cod_marca,
	_cod_agencia WITH RESUME;

END FOREACH

commit work;

END

END PROCEDURE