-- Procedimiento para Insertar Transacciones de Cierre Control de Reclamos Autos
-- 
-- creado: 17/03/2005 - Autor: Amado Perez.

DROP PROCEDURE cerrarec;
CREATE PROCEDURE "informix".cerrarec() 
			RETURNING SMALLINT, CHAR(50), CHAR(10);  

DEFINE _no_tranrec			CHAR(10);
DEFINE _no_tramite        	CHAR(10);
DEFINE _no_tranrec2			CHAR(10);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _fecha				DATE;
DEFINE _transaccion			CHAR(10);
DEFINE _periodo			    CHAR(7);
DEFINE _cod_cliente			CHAR(10);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _no_requis			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _monto_ori           DEC(16,2);
DEFINE _variacion        	DEC(16,2);
DEFINE _reserva_actual     	DEC(16,2);
DEFINE _acum_variacion		DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _numrecla            CHAR(18);
DEFINE _no_poliza           CHAR(10);
DEFINE _cod_cobertura       CHAR(5);
DEFINE _descripcion         VARCHAR(50); 

DEFINE _error   			SMALLINT;
DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);

DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _null, _estatus_reclamo  CHAR(1);

DEFINE _ajust_interno		CHAR(3);
DEFINE _no_reclamo			CHAR(10);
DEFINE _user_name_ajust		CHAR(8);
DEFINE _incidente			INT;

LET _null = NULL;
--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf46.trc";
--trace on;

begin work;

FOREACH
SELECT no_tramite,
       incidente
  INTO _no_tramite,
       _incidente
  FROM cerrarec

 SELECT cod_compania,
        cod_sucursal,
		no_reclamo,
		numrecla,
		no_poliza,
		estatus_reclamo,
		ajust_interno
   INTO _cod_compania,
		_cod_sucursal,
		_no_reclamo,
		_numrecla,
		_no_poliza,
		_estatus_reclamo,
		_ajust_interno
   FROM recrcmae
  WHERE no_tramite = _no_tramite;

 IF _estatus_reclamo = "C" THEN
	    continue foreach;
 END IF

 SELECT usuario
   INTO _user_name_ajust
   FROM recajust
  WHERE cod_ajustador = _ajust_interno;


 SELECT cod_contratante
   INTO _cod_cliente
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 LET _no_tranrec = sp_sis13(_cod_compania,"REC","02","par_tran_genera");

 IF _no_tranrec IS NULL OR _no_tranrec = "" OR _no_tranrec = "00000" THEN
		rollback work;
	    RETURN 1, "Error al generar # transaccion interno, verifique...","";
 END IF

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al BUSCAR PARAMETROS","";         
	END EXCEPTION 

	 SELECT valor_parametro 
	   INTO _fecha_recl_default 
	   FROM inspaag
	  WHERE codigo_compania  = _cod_compania
	    AND aplicacion       = "REC"
	    AND version          = "02"
	    AND codigo_parametro = "fecha_recl_default";

	 IF TRIM(_fecha_recl_default) = "1" THEN
		IF  MONTH(current) < 10 THEN
			LET _mes_char = '0'|| MONTH(current);
		ELSE
			LET _mes_char = MONTH(current);
		END IF

		LET _ano_char = YEAR(current);
		LET _periodo  = _ano_char || "-" || _mes_char;
		LET _fecha_recl_valor = date(current);
	 ELSE
		SELECT valor_parametro 
		  INTO _fecha_recl_valor 
		  FROM inspaag
		 WHERE codigo_compania  = _cod_compania
		   AND aplicacion       = "REC"
		   AND version          = "02"
		   AND codigo_parametro = "fecha_recl_valor";

		LET _fecha_recl_valor = trim(_fecha_recl_valor);
	    LET _periodo = trim(_fecha_recl_valor[7,10]) || "-" || trim(_fecha_recl_valor[4,5]);
	 END IF	 
 END

 -- Buscando # de transaccion externo
 LET _transaccion = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);

 IF _transaccion = "" OR _transaccion IS NULL THEN
    DROP TABLE tmp_prov;
	RETURN 1, "Error generando # de transaccion", "";
 END IF


 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar o Actualizar Transaccion","";         
	END EXCEPTION 

    INSERT INTO rectrmae(
    no_tranrec, 
    cod_compania, 
    cod_sucursal, 
    no_reclamo, 
    cod_cliente, 
    cod_tipotran, 
    numrecla, 
    periodo, 
    pagado, 
    monto, 
    variacion, 
    generar_cheque, 
    user_added, 
    fecha, 
    wf_inc_auto, 
	transaccion,
	actualizado
    )
    VALUES(
	_no_tranrec,
	_cod_compania,
	_cod_sucursal,
	_no_reclamo,
	_cod_cliente,
	"011",
	_numrecla,
	_periodo,
	0,
	0,
	0,
	0,
	_user_name_ajust,
	_fecha_recl_valor,
	_incidente,
	_transaccion,
	1
    );
 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar Coberturas","";         
	END EXCEPTION 

	insert into rectrcob(
	no_tranrec,
	cod_cobertura,
	monto,
	variacion,
	facturado,
	elegible,
	a_deducible,
	co_pago,
	cod_no_cubierto,
	monto_no_cubierto,
	cod_tipo,
	coaseguro,
	ahorro
	)
	select
	_no_tranrec,
	cod_cobertura,
	0.00, -- reserva_inicial,
	0.00, -- reserva_inicial,
	0.00,
	0.00,
	0.00,
	0.00,
	_null,
	0.00,
	_null,
	0.00,
	0.00
	from recrccob
	where no_reclamo = _no_reclamo;
 END

 LET _acum_variacion = 0.00;

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Actualizar Coberturas","";         
	END EXCEPTION 

	FOREACH
		SELECT cod_cobertura,
		       reserva_actual
		  INTO _cod_cobertura,
		       _reserva_actual
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo

        IF _reserva_actual < 0 THEN
			LET _reserva_actual = 0;
		END IF

 		LET _acum_variacion = _acum_variacion + (_reserva_actual * -1);
  
		UPDATE rectrcob
		   SET variacion = _reserva_actual * -1
		 WHERE no_tranrec = _no_tranrec
		   AND cod_cobertura = _cod_cobertura;
	END FOREACH
 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Actualizar Transaccion","";         
	END EXCEPTION 

	UPDATE rectrmae
	   SET variacion = _acum_variacion
	 WHERE no_tranrec = _no_tranrec;
 END

 -- Actualizando coberturas
	BEGIN
	 ON EXCEPTION SET _error 
	 	rollback work;
		RETURN _error, "Error al actualizar las coberturas del reclamo", "";         
	 END EXCEPTION 
	 FOREACH
		SELECT cod_cobertura,
		       variacion
		  INTO _cod_cobertura,
		       _variacion
		  FROM rectrcob
		 WHERE no_tranrec = _no_tranrec

	    SELECT reserva_actual
		  INTO _reserva_actual
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo
		   AND cod_cobertura = _cod_cobertura;

		UPDATE recrccob
		   SET reserva_actual = _reserva_actual + _variacion
		 WHERE no_reclamo     = _no_reclamo
		   AND cod_cobertura  = _cod_cobertura;

    END FOREACH
 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Actualizar Transaccion","";         
	END EXCEPTION 

	UPDATE recrcmae 
	   SET estatus_reclamo = "C"
	 WHERE no_reclamo = _no_reclamo;
 END

 -- Reaseguro a Nivel de Transaccion
 CALL sp_sis58(_no_tranrec) returning _error, _descripcion;

 IF _error = 1 THEN
 	rollback work;
 	RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion","";
 END IF

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al insertar RECNOTAS","";         
	END EXCEPTION 
	INSERT INTO recnotas(
	no_reclamo,
	fecha_nota,
	desc_nota,
	user_added
	) 
	VALUES(
	_no_reclamo,
	current,
    "Se cierra el Reclamo",
	_user_name_ajust
	);
 END

END FOREACH
commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa",_no_tranrec;
END PROCEDURE