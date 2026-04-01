-- Procedimiento para Insertar Transacciones de Pago Control de Reclamos Autos
-- 
-- creado: 17/03/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf47;
CREATE PROCEDURE "informix".sp_rwf47(a_no_reclamo CHAR(10), a_incidente INTEGER, a_user_name_ajust CHAR(20), a_monto DEC(16,2), a_cod_cobertura CHAR(5), a_genera_cheque SMALLINT DEFAULT 0, a_deducible DEC(16,2) DEFAULT 0.00, a_inc_padre INTEGER, a_opcion SMALLINT, a_pieza DEC(16,2) DEFAULT 0.00)
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
DEFINE _monto_ori           DEC(16,2);
DEFINE _variacion        	DEC(16,2);
DEFINE _reserva_actual     	DEC(16,2);
DEFINE _monto_mo            DEC(16,2);
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
DEFINE _hoy                 DATETIME HOUR TO FRACTION(5);
DEFINE _nombre_tipo_pago    VARCHAR(50);
DEFINE _descripcion    		VARCHAR(50);

DEFINE _mo_str              VARCHAR(20);  
DEFINE _piezas_str          VARCHAR(20);  
DEFINE _total_str           VARCHAR(20);
DEFINE _deducible_str       VARCHAR(20);
DEFINE _deducible           DEC(16,2);

LET _null = NULL;
LET _monto_ori = a_monto;
LET _monto_mo = a_monto - a_pieza;

LET _mo_str = _monto_mo;
LET _piezas_str = a_pieza;

LET _deducible = a_deducible * (-1);
LET _deducible_str = _deducible;

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf47.trc";
--trace on;
let a_user_name_ajust = upper(a_user_name_ajust);

begin work;
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
 
 IF a_opcion = 1 THEN
	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

       LET _cod_tipopago = "003";
	   LET _cod_concepto = "015";
	   LET _desc_transaccion_1 = "Indemnizacion total y final al asegurado";
 ELSE
	SELECT cod_tercero
	  INTO _cod_cliente
	  FROM recterce
	 WHERE no_reclamo = a_no_reclamo
	   AND no_incidente = a_inc_padre;

       LET _cod_tipopago = "004";
	   LET _cod_concepto = "016";
       
	   IF _cod_cliente IS NULL OR _cod_cliente = "" THEN
	      ROLLBACK WORK;
	      RETURN 1, "Falta crear el tercero en Deivid","T"; 
	   END IF
	   LET _desc_transaccion_1 = "Indemnizacion total y final al afectado";
   
 END IF

 LET _desc_transaccion_2 = "segun reclamo # " || _numrecla;

 SELECT no_tranrec 
   INTO _no_tranrec2
   FROM rectrmae
  WHERE wf_inc_auto = a_incidente
    AND no_reclamo = a_no_reclamo
    AND cod_tipotran = '004';

 IF _no_tranrec2 IS NULL OR _no_tranrec2 = ""	THEN
	 LET _no_tranrec = sp_sis13(_cod_compania,"REC","02","par_tran_genera");

	 IF _no_tranrec IS NULL OR _no_tranrec = "" OR _no_tranrec = "00000" THEN
		    RETURN 1, "Error al generar # transaccion interno, verifique...","";
	 END IF
 ELSE
	 LET _no_tranrec = _no_tranrec2;
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

 SELECT reserva_actual
   INTO _reserva_actual
   FROM recrccob
  WHERE no_reclamo = a_no_reclamo
    AND cod_cobertura = a_cod_cobertura;

 SELECT usuario
   INTO _user_added
   FROM insuser
  WHERE windows_user = trim(a_user_name_ajust);

 IF _reserva_actual IS NULL THEN
	LET _reserva_actual = 0.00;
 END IF

 IF _reserva_actual < 0 THEN
	LET _reserva_actual = 0.00;
 END IF

 IF a_deducible <> 0.00 THEN
	LET a_monto = a_monto - a_deducible;
 END IF

 LET _total_str = a_monto;

 IF a_monto > 0.00 THEN
	IF a_monto > _reserva_actual THEN
		LET _variacion = _reserva_actual * (-1);
	ELSE
		LET _variacion = a_monto * (-1);
	END IF
 ELSE
	LET _variacion = 0.00;
 END IF 

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar o Actualizar Transaccion","";         
	END EXCEPTION 

	IF _no_tranrec2 IS NULL OR _no_tranrec2 = "" THEN 
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
	    wf_inc_auto,
		wf_aprobado,
		wf_ord_com
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
		a_monto,
		_variacion,
		a_genera_cheque,
		_user_added,
		_fecha_recl_valor,
		a_incidente,
		3,
		1
	    );
	 ELSE
		UPDATE rectrmae
		   SET monto = a_monto,
		       variacion = _variacion,
			   wf_aprobado = 3,
			   cod_cliente = _cod_cliente,
			   cod_tipotran = "004",
			   cod_tipopago = _cod_tipopago,
		       wf_ord_com = 1,
			   generar_cheque = a_genera_cheque
		 WHERE no_tranrec = _no_tranrec2;

		DELETE FROM rectrcob WHERE no_tranrec = _no_tranrec2;
		DELETE FROM rectrcon WHERE no_tranrec = _no_tranrec2;
		DELETE FROM rectrde2 WHERE no_tranrec = _no_tranrec2;
 	 END IF
 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar Coberturas","";         
	END EXCEPTION 
	IF _no_tranrec2 IS NULL OR _no_tranrec2 = "" THEN 
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
		where no_reclamo = a_no_reclamo;
	ELSE
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
		_no_tranrec2,
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
		where no_reclamo = a_no_reclamo;
	END IF
 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Actualizar Coberturas","";         
	END EXCEPTION 

	IF _no_tranrec2 IS NULL OR _no_tranrec2 = "" THEN 
		UPDATE rectrcob
		   SET monto = a_monto,
		       variacion = _variacion
		 WHERE no_tranrec = _no_tranrec
		   AND cod_cobertura = a_cod_cobertura;
    ELSE
		UPDATE rectrcob
		   SET monto = a_monto,
		       variacion = _variacion
		 WHERE no_tranrec = _no_tranrec2
		   AND cod_cobertura = a_cod_cobertura;
	END IF

 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar Concepto","";         
	END EXCEPTION 
   
	IF _no_tranrec2 IS NULL OR _no_tranrec2 = "" THEN 
	    INSERT INTO rectrcon(
		no_tranrec,
		cod_concepto,
		monto
		)
		VALUES(
		_no_tranrec,
		_cod_concepto,
		_monto_ori
		);
 		IF a_deducible <> 0.00 THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"006",
			a_deducible * (-1)
			);
		END IF
	ELSE
	    INSERT INTO rectrcon(
		no_tranrec,
		cod_concepto,
		monto
		)
		VALUES(
		_no_tranrec2,
		_cod_concepto,
		_monto_ori
		);
 		IF a_deducible <> 0.00 THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec2,
			"006",
			a_deducible * (-1)
			);
		END IF
	END IF

 END

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al Insertar la Descripcion","";         
	END EXCEPTION 
   
	IF _no_tranrec2 IS NULL OR _no_tranrec2 = "" THEN 
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
		"Piezas: B/. " || trim(_piezas_str)
		);
		
	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec,
		4,
		"Mano de Obra: B/. " || trim(_mo_str)
		);
		
		IF a_deducible <> 0.00 THEN
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec,
			5,
			"Deducible: B/. " || trim(_deducible_str)
			);
			
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec,
			6,
			"Total: B/. " || trim(_total_str)
			);
		ELSE
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec,
			5,
			"Total: B/. " || trim(_total_str)
			);
		END IF
	ELSE
	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec2,
		1,
		_desc_transaccion_1
		);

	    INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec2,
		2,
		_desc_transaccion_2
		);
		
		INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec2,
		3,
		"Piezas: B/. " || trim(_piezas_str)
		);
		
		INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		_no_tranrec2,
		4,
		"Mano de Obra: B/. " || trim(_mo_str)
		);
		IF a_deducible <> 0.00 THEN
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec2,
			5,
			"Deducible: B/. " || trim(_deducible_str)
			);
			
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec2,
			6,
			"Total: B/. " || trim(_total_str)
			);
		ELSE
			INSERT INTO rectrde2(
			no_tranrec,
			renglon,
			desc_transaccion
			)
			VALUES(
			_no_tranrec2,
			5,
			"Total: B/. " || trim(_total_str)
			);
		END IF
	END IF
	

 END

 -- Insertando RECNOTAS
 LET _hoy = CURRENT;
 LET _hoy = _hoy + 1 units second;

 SELECT nombre
   INTO _nombre_tipo_pago
   FROM rectipag
  WHERE	cod_tipopago = _cod_tipopago;

 IF _nombre_tipo_pago IS NOT NULL AND TRIM(_nombre_tipo_pago) <> "" THEN
	 CALL sp_rwf104(a_no_reclamo,_hoy,"La transaccion de " || trim(_nombre_tipo_pago) || " subio a aprobacion",_user_added) returning _error, _descripcion;
	 IF _error <> 0 THEN
		rollback work;
		RETURN  _error, _descripcion, "";
	 END IF
 END IF


 
commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa",_no_tranrec;
END PROCEDURE