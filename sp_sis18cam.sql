-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 29/01/2002 - Autor: Amado Perez M.

	-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
	-- ano del auto y placa del vehiculo cuando es automovil.

-- SIS v.2.0 - DEIVID, S.A.

drop PROCEDURE sp_sis18cam;

CREATE PROCEDURE "informix".sp_sis18cam(a_no_reclamo CHAR(10))
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       CHAR(5);
DEFINE _fecha_siniestro DATE; 
DEFINE _no_cambio       CHAR(3);
DEFINE _cod_cober_prod  CHAR(5);
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
DEFINE _cod_asegurado 	CHAR(10); 
DEFINE _cod_conductor 	CHAR(10); 
DEFINE _placa 			CHAR(10); 
DEFINE _cedula_aseg 	CHAR(30); 
DEFINE _cedula_cond 	CHAR(30); 
DEFINE _no_motor 		CHAR(30); 
DEFINE _cod_marca 		CHAR(5);
DEFINE _cod_modelo 		CHAR(5);
DEFINE _ano_auto 		SMALLINT;
DEFINE _tipo_persona    CHAR(1); 
DEFINE _incidente       INTEGER;
define _no_tranrec		char(10);
DEFINE _fecha_reclamo   DATE;
DEFINE _cod_contrato    char(5);
DEFINE _porc_partic_prima DEC(9,6); 
DEFINE _porc_partic_suma  DEC(9,6);
define _porc_partic_reas  DEC(9,6);
define _orden             smallint; 
 

SET ISOLATION TO DIRTY READ;

DELETE FROM recreafa WHERE no_reclamo = a_no_reclamo;
DELETE FROM recreaco WHERE no_reclamo = a_no_reclamo;


--SET DEBUG FILE TO "sp_sis18.trc";
--tRACE ON;

-- Lectura del Reclamo

SELECT no_unidad,
	   fecha_siniestro,
	   no_poliza,
	   cod_compania,
	   cod_asegurado,
	   cod_conductor,
	   no_motor,
	   incidente,
	   fecha_reclamo
  INTO _no_unidad,
	   _fecha_siniestro,
	   _no_poliza,
	   _cod_compania,
	   _cod_asegurado,
	   _cod_conductor,
	   _no_motor,
	   _incidente,
	   _fecha_reclamo
  FROM recrcmae
 WHERE no_reclamo = a_no_reclamo;


-- Reaseguradoras

LET _no_cambio = NULL;

-- IF _ramo_sis = 5 THEN -- Salud 
--	LET _no_unidad = '00001'; 
-- END IF



 SELECT	max(no_cambio)
   INTO	_no_cambio
   FROM	emireama
  WHERE	no_poliza       = _no_poliza
	AND no_unidad       = _no_unidad;


IF _no_cambio IS NULL THEN
	LET _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

foreach

	 select cod_contrato,
	        porc_partic_prima,
			orden,
			porc_partic_suma,
			cod_cober_reas
	   into _cod_contrato,
	        _porc_partic_prima,
			_orden,
			_porc_partic_suma,
			_cod_cober_reas
	   from emireaco
	  where no_poliza      = _no_poliza
	    and no_unidad      = _no_unidad
	    and no_cambio      = _no_cambio

		INSERT INTO recreaco(
		no_reclamo,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		cod_cober_reas)
		values(
		a_no_reclamo,
		_orden,
		_cod_contrato,
		_porc_partic_suma,
		_porc_partic_prima,
		_cod_cober_reas);

end foreach

delete from recreaco
 where no_reclamo        = a_no_reclamo
   and porc_partic_suma  = 0.00
   and porc_partic_prima = 0.00;

-- Facultativos

foreach

   select orden,
		  cod_contrato,
		  cod_coasegur,
		  porc_partic_reas,
		  cod_cober_reas
	 into _orden,
	      _cod_contrato,
		  _cod_coasegur,
		  _porc_partic_reas,
		  _cod_cober_reas
	 FROM emireafa
	WHERE no_poliza       = _no_poliza
	  AND no_unidad       = _no_unidad
	  AND no_cambio       = _no_cambio


		INSERT INTO recreafa(
		no_reclamo,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		cod_cober_reas)
		values(
		a_no_reclamo,
		_orden,
		_cod_contrato,
		_cod_coasegur,
		_porc_partic_reas,
		_cod_cober_reas);

end foreach

foreach
	SELECT SUM(porc_partic_prima)
	  INTO _porcentaje
	  FROM recreaco
	 WHERE no_reclamo = a_no_reclamo
  GROUP BY no_reclamo,cod_cober_reas

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

end foreach

foreach

	SELECT SUM(porc_partic_suma)
	  INTO _porcentaje
	  FROM recreaco
	 WHERE no_reclamo = a_no_reclamo
  GROUP BY no_reclamo,cod_cober_reas

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

end foreach

-- Verificacion para el Facultativo

SELECT COUNT(*)
  INTO _contador_ret 
  FROM recreaco, reacomae
 WHERE recreaco.no_reclamo    = a_no_reclamo 
   AND recreaco.cod_contrato  = reacomae.cod_contrato
   AND reacomae.tipo_contrato = 3; 
 
IF _contador_ret IS NULL THEN
	LET _contador_ret = 0;
END IF 

IF _contador_ret <> 0 THEN

	SELECT COUNT(*)
	  INTO _contador_ret
	  FROM recreafa
	 WHERE no_reclamo = a_no_reclamo;

	IF _contador_ret IS NULL THEN
		LET _contador_ret = 0; 
	END IF

	IF _contador_ret = 0 THEN
		LET _mensaje = 'No Existe Distribucion de Facultativos, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

	foreach

		SELECT SUM(porc_partic_reas)
		  INTO _porcentaje
		  FROM recreafa
		 WHERE no_reclamo = a_no_reclamo
		 group by no_reclamo,cod_cober_reas

		IF _porcentaje IS NULL THEN
			LET _porcentaje = 0;
		END IF

		IF _porcentaje <> 100 THEN
			LET _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF
	end foreach

END IF

-- Verificacion de Varias Retenciones

foreach

	SELECT COUNT(*) 
	  INTO _contador_ret 
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = a_no_reclamo 
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1
	 group by recreaco.no_reclamo,recreaco.orden,recreaco.cod_cober_reas	    	    
	    
	 
	IF _contador_ret IS NULL THEN
		LET _contador_ret = 0;
	END IF 
	 
	IF _contador_ret > 1 THEN
		LET _mensaje = 'Existe Mas de Una Retencion ...';
		RETURN 1, _mensaje;
	END IF;

end foreach


-- Procedure para crear los reaseguro por transaccion

let _no_tranrec = "00000";

foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where no_reclamo   = a_no_reclamo
    and actualizado = 1
  order by no_tranrec

	if _no_tranrec <> "00000" then

		call sp_sis58cam(_no_tranrec) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if

	end if


end foreach


LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
