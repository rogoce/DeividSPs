-- Procedimiento para generacion de cheques
-- 
-- creado: 18/12/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf77;
CREATE PROCEDURE "informix".sp_rwf77(a_incident INTEGER) 
			RETURNING SMALLINT, CHAR(50), CHAR(10);  

DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _fecha				DATE;
DEFINE _periodo			    CHAR(7);
DEFINE _no_requis			CHAR(10);
DEFINE _user_added			CHAR(8);
DEFINE _nombre			    VARCHAR(100);  
DEFINE _acreedor		    VARCHAR(100);  
DEFINE _no_requis_n			CHAR(10);
DEFINE _cod_banco		    CHAR(3);
DEFINE _cod_chequera		CHAR(3);
DEFINE _filas               SMALLINT;
DEFINE _firma_electronica  	SMALLINT;
DEFINE _autorizado  	    SMALLINT;
DEFINE _en_firma            SMALLINT;
DEFINE _cod_ruta			CHAR(2);
DEFINE _tipo_requis         CHAR(1);
DEFINE _tipo_pago           SMALLINT;

DEFINE _fecha_captura       DATE;
DEFINE _nombre_cheq         CHAR(100);
DEFINE _monto_cheq          DEC(16,2);

DEFINE _incident 		    integer; 
DEFINE _factura 		    char(10); 
DEFINE _proveedor 	        char(10);
DEFINE _concepto 		    char(10); 
DEFINE _monto 		        dec(18,2);
DEFINE _usuario 		    char(30); 
DEFINE _cod_cliente 	    char(10); 
DEFINE _cuenta 		        char(12); 
DEFINE _fecha_pago 	        date;
DEFINE _mes_char 		    char(2); 
DEFINE _ano_char 	        char(4);
DEFINE _usu                 char(8);

DEFINE _error   			SMALLINT;

LET _acreedor = NULL;
LET _no_requis = NULL;
LET _autorizado = 0;
LET _en_firma   = 0;
LET _no_requis_n = NULL;
LET _fecha = CURRENT;
LET _cod_ruta = NULL;

SET LOCK MODE TO WAIT;
--set debug file to "sp_rwf77.trc";
--trace on;

--begin work;

IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;


FOREACH
	SELECT incident,
		   factura,
		   concepto,
		   monto,
		   usuario,
		   cod_cliente,
		   cuenta,
		   fecha_pago,
		   no_requis
	  INTO _incident,   
	   	   _factura, 	 
		   _concepto,   
		   _monto,	     
		   _usuario,    
		   _cod_cliente,
		   _cuenta,	 
		   _fecha_pago,
		   _no_requis
	  FROM wf_opago
	 WHERE incident = a_incident

	LET _cod_ruta = NULL;

	SELECT nombre,
	       tipo_pago,
		   cod_ruta
	  INTO _nombre,
	       _tipo_pago,
		   _cod_ruta
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;


    IF _tipo_pago = 2 THEN
		LET _tipo_requis = 'C';
	ELSE
		LET _tipo_requis = 'A';
	END IF

    SELECT usuario
	  INTO _usu
	  FROM insuser
	 WHERE windows_user = trim(_usuario);

   	SELECT codigo_compania,
		   codigo_agencia
	  INTO _cod_compania,
	       _cod_sucursal
	  FROM insusco
	 WHERE usuario = trim(_usu)
	   AND status = 'A';

 
 IF _no_requis IS NULL OR _no_requis = "" THEN
 	LET _no_requis_n = sp_sis71(_cod_compania);
--    LET _no_requis_n = "ultimus";
 	IF _no_requis_n IS NULL OR _no_requis_n = "" OR _no_requis_n = "00000" THEN
	    RETURN 1, "Error al generar requisicion, verifique...","";
	END IF

	LET _no_requis = _no_requis_n;

	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '*'
	   and cod_banco = '001';

    SELECT firma_electronica
	  INTO _firma_electronica
	  FROM chqchequ
	 WHERE cod_banco = _cod_banco
	   AND cod_chequera = _cod_chequera;

    IF _firma_electronica = 1 THEN
		LET _autorizado = 1;
		LET _en_firma = 4;
	END IF


	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar REQUISICION","";         
		END EXCEPTION 
		INSERT INTO chqchmae(
		no_requis,
		monto,
		pagado,
		anulado,
		periodo,
		cobrado,
		cuenta,
		cod_cliente,
		autorizado,
		cod_agente,
		a_nombre_de,
		user_added,
		anulado_por,
		cod_banco,
		cod_chequera,
		cod_compania,
		cod_sucursal,
		no_cheque,
		fecha_cobrado,
		fecha_anulado,
		origen_cheque,
		fecha_captura,
		autorizado_por,
		fecha_impresion,
		cod_ruta,
		en_firma,
		tipo_requis
		)
		VALUES(
		_no_requis_n,
		_monto,
		0,
		0,
		_periodo,
		0,
		null,
		_cod_cliente,
		_autorizado,
		null,
		_nombre,
		_usuario,
		null,
		_cod_banco,
		_cod_chequera,
		_cod_compania,
		_cod_sucursal,
		0,
		null,
		null,
		'G',
		current,
		_usu,
		current,
		_cod_ruta,
		_en_firma,
		_tipo_requis
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar la cuenta de la requisicion","";         
		END EXCEPTION 
		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito
		) 
		VALUES (
		_no_requis_n,
		1,
		_cuenta,
		_monto
		);

	 END
   

     BEGIN
		ON EXCEPTION SET _error 
		  --	rollback work;
		 	RETURN _error, "Error al actualizar descripcion de la requisicion","";         
		END EXCEPTION 
		UPDATE wf_opago
		   SET no_requis = _no_requis_n
		 WHERE incident = _incident;   

	 END

--	IF _no_requis IS NOT NULL AND _no_requis <> "" AND _no_requis <> "00000" THEN	 -->
--		CALL sp_rec122(_no_requis, _monto, _user_added, _transaccion) returning _error;
--	END IF
 END IF



END FOREACH

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa", _no_requis;
END PROCEDURE