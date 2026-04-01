-- Generacion de los Datos a la Tabla Chqfor20

-- Creado    : 16/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/04/2001 - Autor: Armando Moreno para reporte
-- Modificado: 23/07/2002 - Autor: Amado Perez - Se agrego al retorno el no_cheque y la fecha y se corrige el monto
--                                               de entero a decimal     
-- Modificado: 11/12/2002 - Autor: Armando Moreno cambiar codigo 06 '0r 04 para corredores                             
-- SIS v.2.0 - d_cheq_formulario_20 - DEIVID, S.A.

DROP PROCEDURE sp_che16;

CREATE PROCEDURE sp_che16(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
	RETURNING INTEGER,CHAR(30),CHAR(2),CHAR(100),CHAR(2),DECIMAL(16,2),DATE,INT,CHAR(50),CHAR(1);


-- Variable para la definicion del Informado

DEFINE _renglon           INTEGER;
DEFINE _cedula            CHAR(30);
DEFINE _digito_ver		  CHAR(2);
DEFINE _nombre			  CHAR(100);
DEFINE _tipo_persona      CHAR(1);
DEFINE _monto             DECIMAL(16,2);
DEFINE _transaccion       CHAR(10); 
DEFINE _fecha,_fecha1,_fecha2  DATE;     
DEFINE _concepto_pago     CHAR(2);
DEFINE _no_cheque		  CHAR(20);
	
-- Otras Variables

DEFINE _no_requis         CHAR(10); 
DEFINE _cod_tipopago      CHAR(3);  
DEFINE _cod_cliente       CHAR(10); 
DEFINE _error_code,_ano1  INTEGER;
DEFINE _ano2,_mes1,_mes2  INTEGER;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;
DEFINE _cod_agente        CHAR(5);
DEFINE _null              CHAR(1);
DEFINE _no_reclamo        CHAR(10);
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _ramo_sis          SMALLINT;
DEFINE _ced_correcta	  SMALLINT;
DEFINE v_descr_cia        CHAR(50);
	

CREATE TEMP TABLE temp_Chqfor20(
              renglon       INTEGER,
              cedula        CHAR(30),
              digito_ver    CHAR(2),
              nombre	    CHAR(100),
              concepto      CHAR(2),
              tipo_persona  CHAR(1),
              monto		    DECIMAL(16,2),
			  transaccion	CHAR(20),
			  fecha			DATE,
			  no_cheque     INTEGER,
              PRIMARY KEY(renglon)) WITH NO LOG;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che12.trc"; 
--TRACE ON;                                                                

-- Nombre de la Compania

LET  v_descr_cia = sp_sis01(a_compania); 

LET _null = NULL;

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _mes1 = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

BEGIN

{ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar el Formulario 20';         
END EXCEPTION           

DELETE FROM chqfor20;}

LET _renglon = 0;

FOREACH
 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado,
		no_cheque
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado,
		_no_cheque
   FROM chqchmae
  WHERE	pagado                 = 1
    AND origen_cheque          = 3
	AND fecha_impresion >= _fecha1 AND fecha_impresion <= _fecha2

	IF _fecha_anulado IS NOT NULL THEN
		IF MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
		    YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			CONTINUE FOREACH;
		END IF
	END IF

   FOREACH
	SELECT transaccion,
	       monto
	  INTO _transaccion,
		   _monto
	  FROM chqchrec
	 WHERE no_requis = _no_requis

	   FOREACH	
		SELECT cod_tipopago,
		       cod_cliente,
		   	   fecha,
			   no_reclamo
		  INTO _cod_tipopago,
		       _cod_cliente,
		   	   _fecha,
		   	   _no_reclamo	
		  FROM rectrmae
		 WHERE transaccion = _transaccion
 			EXIT FOREACH; 
		END FOREACH       

		IF _cod_tipopago = '003' OR
		   _cod_tipopago = '004' THEN		
			CONTINUE FOREACH;
		END IF

		SELECT cedula,
			   nombre,
			   digito_ver,
			   tipo_persona,
			   ced_correcta	
		  INTO _cedula,
		       _nombre,
			   _digito_ver,
			   _tipo_persona,
			   _ced_correcta	
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente; 		

		IF _ced_correcta = 0 THEN
			CONTINUE FOREACH;
		END IF

		IF _cedula IS NULL THEN
			CONTINUE FOREACH;
--			LET _cedula = '';
		END IF

		IF _digito_ver IS NULL THEN
			CONTINUE FOREACH;
--			LET _digito_ver = '';
		END IF

		IF	_cod_tipopago = '002' THEN -- Pago a Taller
			LET _concepto_pago = '09';
		ELSE                           -- Pago a Proveedor
			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;

			SELECT cod_ramo
			  INTO _cod_ramo
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT ramo_sis
			  INTO _ramo_sis
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			
			IF _ramo_sis = 5 THEN
				LET _concepto_pago = '04'; -- Medicos
			ELSE
				LET _concepto_pago = '09'; -- Repuestos
			END IF
		END IF

		IF _tipo_persona = 'N' THEN
			LET _tipo_persona = '1';
		ELSE
			LET _tipo_persona = '2';
		END IF
		
		LET _renglon = _renglon + 1;

		BEGIN 
		ON EXCEPTION IN(-239)

			UPDATE temp_Chqfor20
			   SET monto      = monto + _monto
			 WHERE cedula     = _cedula
			   AND digito_ver = _digito_ver
			   AND concepto   = _concepto_pago
			   AND fecha      = _fecha_impresion;

		END EXCEPTION

			INSERT INTO temp_Chqfor20
			VALUES(
			_renglon,
			_cedula, 
			_digito_ver,
			_nombre,
			_concepto_pago,
			_tipo_persona,
			_monto,
			_no_cheque, 
			_fecha_impresion,
			_no_cheque
			);

		END

	END FOREACH

END FOREACH

-- Corredores

--LET _concepto_pago = '06';
LET _concepto_pago = '04';

FOREACH
 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado,
		cod_agente,
		monto,
		no_cheque
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado,
		_cod_agente,
		_monto,
		_no_cheque
   FROM chqchmae
  WHERE	pagado                 = 1
    AND origen_cheque          = 2
	AND fecha_impresion >= _fecha1 AND fecha_impresion <= _fecha2
    AND cod_compania           = a_compania 

	IF _fecha_anulado IS NOT NULL THEN
		IF MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
		    YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			CONTINUE FOREACH;
		END IF
	END IF

	SELECT cedula,
		   nombre,
		   digito_ver,
		   tipo_persona,
		   ced_correcta	
	  INTO _cedula,
	       _nombre,
		   _digito_ver,
		   _tipo_persona,	
		   _ced_correcta	
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 		
	
	IF _ced_correcta = 0 THEN
		CONTINUE FOREACH;
	END IF

	IF _cedula IS NULL THEN
		CONTINUE FOREACH;
--		LET _cedula = '                    ';
	END IF			  

	IF _digito_ver IS NULL THEN
		CONTINUE FOREACH;
--		LET _digito_ver = '  ';
	END IF

	IF _tipo_persona = 'N' THEN
		LET _tipo_persona = '1';
	ELSE
		LET _tipo_persona = '2';
	END IF

	LET _renglon = _renglon + 1;

	BEGIN 
	ON EXCEPTION IN(-239)

		UPDATE temp_Chqfor20
		   SET monto      = monto + _monto
		 WHERE cedula     = _cedula
		   AND digito_ver = _digito_ver
		   AND concepto   = _concepto_pago
		   AND fecha      = _fecha_impresion;

	END EXCEPTION

		INSERT INTO temp_Chqfor20
		VALUES(
		_renglon,
		_cedula, 
		_digito_ver,
		_nombre,
		_concepto_pago,
		_tipo_persona,
		_monto,
		_no_cheque, 
		_fecha_impresion,
		_no_cheque
		);

	END 

END FOREACH

END 

FOREACH
 SELECT	renglon,
		cedula,
		digito_ver,
		nombre,
		concepto,
		monto,
		fecha,
		no_cheque,
		tipo_persona
   INTO	_renglon,
		_cedula,
		_digito_ver,
		_nombre,
		_concepto_pago,
		_monto,
		_fecha_impresion,
		_no_cheque,
		_tipo_persona
   FROM temp_chqfor20

    RETURN _renglon,
    	   _cedula,
    	   _digito_ver,
           _nombre,
           _concepto_pago,
		   _monto,
		   _fecha_impresion,
		   _no_cheque,
           v_descr_cia,
		   _tipo_persona
           WITH RESUME;

END FOREACH
DROP TABLE temp_Chqfor20;
END PROCEDURE;