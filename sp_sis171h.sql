-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis171h;

CREATE PROCEDURE "informix".sp_sis171h(a_no_remesa CHAR(10), _renglon smallint)
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
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
DEFINE _cnt				SMALLINT;
DEFINE _porc_partic_prima DEC(9,6); 
DEFINE _porc_partic_suma  DEC(9,6); 
DEFINE _orden             SMALLINT;
DEFINE _porc_partic_reas  decimal(9,6);
define _porc_proporcion   decimal(9,6);

SET ISOLATION TO DIRTY READ;

DELETE FROM cobreafa WHERE no_remesa = a_no_remesa and renglon = _renglon;
DELETE FROM cobreaco WHERE no_remesa = a_no_remesa and renglon = _renglon;


--SET DEBUG FILE TO "sp_sis171.trc";
--TRACE ON;

-- Lectura del Detalle de la Remesa

FOREACH

	 SELECT	no_poliza
	   INTO	_no_poliza
	   FROM	cobredet
	  WHERE	no_remesa  = a_no_remesa
		AND renglon    = _renglon
		AND tipo_mov   IN ('P','N')
      ORDER BY renglon

	SELECT cod_tipoprod,
	       cod_ramo,
		   vigencia_final,
		   abierta
	  INTO _cod_tipoprod,
		   _cod_ramo,
		   _vigencia_final,
		   _abierta
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

   	insert into camcobreaco(no_poliza,no_remesa,renglon) values(_no_poliza,a_no_remesa,_renglon);
	-- Reaseguro

	LET _no_cambio = NULL;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	IF _no_cambio IS NULL THEN
		LET _mensaje = 'No Existe Distribucion de Reaseguro para Esta Poliza, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	   
		-- Contratos
	call sp_sis188(_no_poliza) returning _error,_mensaje;
	
	if _error <> 0 then
		--let _mensaje = trim(_mensaje) || ' la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
		return _error,_mensaje;
	end if

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

		select porc_cober_reas
		  into _porc_proporcion
		  from tmp_dist_rea
		 where cod_cober_reas = _cod_cober_reas;
     

		INSERT INTO cobreaco(
		no_remesa,
		renglon,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		subir_bo,
		cod_cober_reas,
		porc_proporcion)
		values(
		a_no_remesa,
		_renglon,
		_orden,
		_cod_contrato,
		_porc_partic_suma,
		_porc_partic_prima,
		1,
		_cod_cober_reas,
		_porc_proporcion);

	end foreach

	drop table tmp_dist_rea;

	delete from cobreaco
	 where no_remesa         = a_no_remesa
	   and porc_partic_suma  = 0.00
	   and porc_partic_prima = 0.00;

	-- Facultativos
	foreach

	 select cod_contrato,
			orden,
			cod_coasegur,
			porc_partic_reas
	   into _cod_contrato,
			_orden,
			_cod_coasegur,
	        _porc_partic_reas
	   from emireafa
	  where no_poliza      = _no_poliza
	    and no_unidad      = _no_unidad
	    and no_cambio      = _no_cambio

		select count(*)
		  into _cnt
		  from cobreafa
		 where no_remesa = a_no_remesa
		   and renglon	 = _renglon
		   and orden	 = _orden
		   and cod_contrato	= _cod_contrato
		   and cod_coasegur	= _cod_coasegur;

	   if _cnt = 0 then
		INSERT INTO cobreafa(
		no_remesa,
		renglon,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas)
		values(
		a_no_remesa,
		_renglon,
		_orden,
		_cod_contrato,
		_cod_coasegur,
		_porc_partic_reas);
	   end if
	end foreach

 	FOREACH
		SELECT SUM(porc_partic_prima)
		  INTO _porcentaje
		  FROM cobreaco
		 WHERE no_remesa = a_no_remesa
	  GROUP BY no_remesa,renglon,cod_cober_reas

		IF _porcentaje IS NULL THEN
			LET _porcentaje = 0;
		END IF

		IF _porcentaje <> 100 THEN
			LET _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF
	END FOREACH


	FOREACH
		SELECT SUM(porc_partic_suma)
		  INTO _porcentaje
		  FROM cobreaco
		 WHERE no_remesa = a_no_remesa
	  GROUP BY no_remesa,renglon,cod_cober_reas

		IF _porcentaje IS NULL THEN
			LET _porcentaje = 0;
		END IF

		IF _porcentaje <> 100 THEN
			LET _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF
	END FOREACH

	-- Verificacion para el Facultativo

	SELECT COUNT(*)
	  INTO _contador_ret 
	  FROM cobreaco, reacomae
	 WHERE cobreaco.no_remesa     = a_no_remesa
	   AND cobreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 3; 
	 
	IF _contador_ret IS NULL THEN
		LET _contador_ret = 0;
	END IF 

	IF _contador_ret <> 0 THEN

		SELECT COUNT(*)
		  INTO _contador_ret
		  FROM cobreafa
		 WHERE no_remesa = a_no_remesa;

		IF _contador_ret IS NULL THEN
			LET _contador_ret = 0; 
		END IF

		IF _contador_ret = 0 THEN
			LET _mensaje = 'No Existe Distribucion de Facultativos, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF

	   FOREACH
			SELECT SUM(porc_partic_reas)
			  INTO _porcentaje
			  FROM cobreafa
			 WHERE no_remesa = a_no_remesa
		  GROUP BY no_remesa,renglon

			IF _porcentaje IS NULL THEN
				LET _porcentaje = 0;
			END IF

			IF _porcentaje <> 100 THEN
				LET _mensaje = _no_poliza || ' Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
				RETURN 1, _mensaje;
			END IF
	   END FOREACH

	END IF

	-- Verificacion de Varias Retenciones

   FOREACH

		SELECT COUNT(*) 
		  INTO _contador_ret 
		  FROM cobreaco, reacomae
		 WHERE cobreaco.no_remesa     = a_no_remesa
		   AND cobreaco.cod_contrato  = reacomae.cod_contrato
		   AND reacomae.tipo_contrato = 1
	  group by cobreaco.no_remesa,cobreaco.renglon,cobreaco.cod_cober_reas	    
		 
		IF _contador_ret IS NULL THEN
			LET _contador_ret = 0;
		END IF 
		 
		IF _contador_ret > 1 THEN
			LET _mensaje = 'Existe Mas de Una Retencion ...';
			RETURN 1, _mensaje;
		END IF;

   END FOREACH

END FOREACH


LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
