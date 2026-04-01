-- Procedimiento para Insertar Transacciones de Pago Control de Reclamos Autos
-- 
-- creado: 17/03/2005 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf47;
DROP PROCEDURE sp_rwf102;
CREATE PROCEDURE "informix".sp_rwf102(a_no_reclamo CHAR(10), a_opcion smallint default 1, a_user_added CHAR(8))
			RETURNING SMALLINT, CHAR(50), CHAR(10);  

DEFINE _no_tranrec			CHAR(10);
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
DEFINE _variacion        	DEC(16,2);
DEFINE _reserva_actual     	DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _numrecla            CHAR(18);
DEFINE _no_poliza           CHAR(10);
DEFINE _cod_concepto        CHAR(3);

DEFINE _error   			SMALLINT;
DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);

DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _null			    CHAR(1);
DEFINE _desc_transaccion_1  CHAR(60);
DEFINE _desc_transaccion_2  CHAR(60);
DEFINE _desc_transaccion_3  CHAR(60);
DEFINE _desc_transaccion_4  CHAR(60);

DEFINE _perdida				DEC(16,2);
DEFINE _deducible			DEC(16,2);
DEFINE _salvamento			DEC(16,2);
DEFINE _prima_pend			DEC(16,2);
DEFINE _cod_cobertura		CHAR(5);

DEFINE _deducible_s			VARCHAR(16);
DEFINE _salvamento_s		VARCHAR(16);
DEFINE _prima_pend_s		VARCHAR(16);


LET _null = NULL;

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf102.trc";
--trace on;

--begin work;
 BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al leer rcrcmae, recperdida","";         
	END EXCEPTION 

 SELECT cod_compania,
        cod_sucursal,
		numrecla,
		no_poliza
   INTO _cod_compania,
		_cod_sucursal,
		_numrecla,
		_no_poliza
   FROM recrcmae
  WHERE no_reclamo = a_no_reclamo;

 SELECT perdida,
        deducible,
		salvamento,
		prima_pend,
		cod_cobertura
   INTO _perdida,
		_deducible,
		_salvamento,
		_prima_pend,
		_cod_cobertura
   FROM recperdida
  WHERE no_reclamo = a_no_reclamo;

 IF _perdida IS NULL THEN
	LET _perdida = 0.00;
 END IF
 IF _deducible IS NULL THEN
	LET _deducible = 0.00;
 END IF
 IF _salvamento IS NULL THEN
	LET _salvamento = 0.00;
 END IF
 IF _prima_pend IS NULL THEN
	LET _prima_pend = 0.00;
 END IF

 LET _deducible_s  = _deducible;
 LET _salvamento_s = _salvamento;
 LET _prima_pend_s = _prima_pend;

 LET _cod_tipopago = "003";
 LET _cod_concepto = "015";
 
 IF a_opcion = 1 THEN
	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

     LET _monto = _perdida - (_deducible + _salvamento + _prima_pend); 

	   LET _desc_transaccion_1 = "PAGO TOTAL Y FINAL AL ASEGURADO POR PERDIDA TOTAL";
	   LET _desc_transaccion_2 = "DE LA UNIDAD DESCONTANDO PRIMA PENDIENTE POR B/"||TRIM(_prima_pend_s)||"," ;
	   LET _desc_transaccion_3 = "DEDUCIBLE POR B/"||TRIM(_deducible_s)||", "||"SALVAMENTO POR B/"||TRIM(_salvamento_s);
 ELSE
    LET _cod_cliente = '11394';
	LET _monto =  _salvamento;
   
	   LET _desc_transaccion_1 = "PARA APLICAR COMO SALVAMENTO";
   
 END IF

 LET _desc_transaccion_4 = "SEGUN RECLAMO # " || _numrecla;

 LET _no_tranrec = sp_sis13(_cod_compania,"REC","02","par_tran_genera");

 IF _no_tranrec IS NULL OR _no_tranrec = "" OR _no_tranrec = "00000" THEN
	    RETURN 1, "Error al generar # transaccion interno, verifique...","";
 END IF

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
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

 SELECT reserva_actual
   INTO _reserva_actual
   FROM recrccob
  WHERE no_reclamo = a_no_reclamo
    AND cod_cobertura = _cod_cobertura;

 IF _reserva_actual IS NULL THEN
	LET _reserva_actual = 0.00;
 END IF

 IF _reserva_actual < 0 THEN
	LET _reserva_actual = 0.00;
 END IF

 IF _monto > 0.00 THEN
	IF _monto > _reserva_actual THEN
		LET _variacion = _reserva_actual * (-1);
	ELSE
		LET _variacion = _monto * (-1);
	END IF
 ELSE
	LET _variacion = 0.00;
 END IF 

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
	 	RETURN _error, "Error al Insertar o Actualizar Transaccion","";         
	END EXCEPTION 

		DELETE FROM rectrcob WHERE no_tranrec = _no_tranrec;
		DELETE FROM rectrcon WHERE no_tranrec = _no_tranrec;
		DELETE FROM rectrde2 WHERE no_tranrec = _no_tranrec;


	    INSERT INTO rectrmae(
	    no_tranrec, 
	    cod_compania, 
	    cod_sucursal, 
	    no_reclamo, 
	    cod_cliente, 
	    cod_tipotran, 
		cod_tipopago,
	    numrecla, 
	    periodo, 
	    pagado, 
	    monto, 
	    variacion, 
	    generar_cheque, 
	    user_added, 
	    fecha, 
		wf_aprobado,
		wf_ord_com,
		perd_total
	    )
	    VALUES(
		_no_tranrec,
		_cod_compania,
		_cod_sucursal,
		a_no_reclamo,
		_cod_cliente,
		"004",
		_cod_tipopago,
		_numrecla,
		_periodo,
		0,
		_monto,
		_variacion,
		1,
		a_user_added,
		_fecha_recl_valor,
		3,
		1,
		1
	    );
 END

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
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
		_monto, 
		_variacion, 
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
		where no_reclamo = a_no_reclamo
		  and cod_cobertura = _cod_cobertura;
 END

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
	 	RETURN _error, "Error al Insertar Concepto","";         
	END EXCEPTION 
 
    IF a_opcion = 1 THEN   
	    INSERT INTO rectrcon(
		no_tranrec,
		cod_concepto,
		monto
		)
		VALUES(
		_no_tranrec,
		_cod_concepto,
		_perdida
		);

 		IF _prima_pend <> 0.00 THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"020",
			_prima_pend * (-1)
			);
		END IF

 		IF _salvamento <> 0.00 THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"019",
			_salvamento * (-1)
			);
		END IF

 		IF _deducible <> 0.00 THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"006",
			_deducible * (-1)
			);
		END IF
	ELSE
	    INSERT INTO rectrcon(
		no_tranrec,
		cod_concepto,
		monto
		)
		VALUES(
		_no_tranrec,
		_cod_concepto,
		_monto
		);
	END IF
 END

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
	 	RETURN _error, "Error al Insertar la Descripcion","";         
	END EXCEPTION 
  
    IF a_opcion = 1 THEN 
	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		1,
		_desc_transaccion_1
		);

	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		2,
		_desc_transaccion_2
		);

	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		3,
		_desc_transaccion_3
		);

	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		4,
		_desc_transaccion_4
		);
	ELSE
	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		1,
		_desc_transaccion_1
		);

	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		2,
		_desc_transaccion_4
		);
	END IF
 END
 
--commit work;
--rollback work;
END

 RETURN 0, "Actualizacion Exitosa",_no_tranrec;
END PROCEDURE