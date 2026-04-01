-- Generacion de los Datos a la Tabla Chqfor20

-- Creado    : 16/02/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 11/12/2002 - Autor: Armando  Moreno  cambiar codigo 06 '0r 04 para corredores
-- Modificado: 24/09/2008 - Autor: Amado Perez -- Se cambia el monto de entero a decimal.
                                               -- Se cambia el concepto de 04 a 03 para corredores y medicos
											   -- Se cambia el concepto de 09 a 01 para talleres y repuestos

-- Modificado: 23/10/2008 - Autor: Ricardo Jimenez -- Se agregan dos campos mas en el archivo (chqfor20) compras de bienes y servicos y itbms 
                                                   -- El monto debe ser sin itbm
											       

-- SIS v.2.0 - d_cheq_formulario_20 - DEIVID, S.A.

DROP PROCEDURE sp_che12;

CREATE PROCEDURE sp_che12(
a_compania    CHAR(3),
a_sucursal    CHAR(3),
a_periodo	  CHAR(7)
) RETURNING SMALLINT, CHAR(100);

-- Variable para la definicion del Informado

DEFINE _renglon           INTEGER;
DEFINE _cedula            CHAR(20);
DEFINE _digito_ver		  CHAR(2);
DEFINE _nombre			  CHAR(60);
DEFINE _tipo_persona      CHAR(1);
DEFINE _monto             DEC(16,2);
DEFINE _transaccion       CHAR(10);
DEFINE _fecha             DATE;     
DEFINE _concepto_pago     CHAR(1);
DEFINE _no_cheque		  CHAR(20);
DEFINE _compras           CHAR(1);
DEFINE _itbms			  DEC(16,2);
DEFINE _origen_cheque     CHAR(1);
DEFINE _paga_impuesto     SMALLINT;

-- Otras Variables

DEFINE _no_requis         CHAR(10);
DEFINE _cod_tipopago      CHAR(3);
DEFINE _cod_cliente       CHAR(10); 
DEFINE _error_code        INTEGER;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;
DEFINE _cod_agente        CHAR(5);
DEFINE _null              CHAR(1);
DEFINE _no_reclamo        CHAR(10);
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _ramo_sis          SMALLINT;
DEFINE _ced_correcta	  SMALLINT;
	
SET ISOLATION TO DIRTY READ;
LET _null = NULL;

--BEGIN WORK;

BEGIN

	ON EXCEPTION SET _error_code
	 	RETURN _error_code, 'Error al Actualizar el Formulario 20';
	END EXCEPTION

	DELETE FROM chqfor20;

	LET _renglon =    0;
	LET _compras =  '1';
	LET _itbms	 =    0;

FOREACH	 

 		SELECT no_requis,
			   fecha_impresion,
			   fecha_anulado,
			   no_cheque
   		  INTO _no_requis,
			   _fecha_impresion,
			   _fecha_anulado,
			   _no_cheque
   		  FROM chqchmae
  		 WHERE pagado                 = 1
    	   AND origen_cheque          = 3
		   AND MONTH(fecha_impresion) = a_periodo[6,7]
		   AND YEAR(fecha_impresion)  = a_periodo[1,4]

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

		IF _ced_correcta = 0 Or _cedula IS NULL THEN
		   CONTINUE FOREACH;
		   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
		END IF

  
		IF  _digito_ver IS NULL THEN
			CONTINUE FOREACH;
			--RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
		END IF

		IF	_cod_tipopago = '002' THEN -- Pago a Taller
			LET _concepto_pago = '1';
		ELSE                           -- Pago a Proveedor
			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			WHERE  no_reclamo = _no_reclamo;

			SELECT cod_ramo
			  INTO _cod_ramo
			  FROM emipomae
			WHERE  no_poliza = _no_poliza;

			SELECT ramo_sis
			  INTO _ramo_sis
			  FROM prdramo
			WHERE cod_ramo = _cod_ramo;
			
			IF _ramo_sis = 5 THEN
			   LET _concepto_pago = '3'; -- Medicos
			ELSE
			   LET _concepto_pago = '1'; -- Repuestos
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

			UPDATE chqfor20
			   SET monto      = monto + _monto
			 WHERE cedula     = _cedula
			   AND digito_ver = _digito_ver
			   AND concepto   = _concepto_pago
			   AND fecha      = _fecha_impresion;

			END EXCEPTION
									
			INSERT INTO chqfor20
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
			_compras,
			_itbms
			);

		END

 
	END FOREACH

END FOREACH

LET _concepto_pago = '3'; -- Corredores
LET _itbms	 	   =   0;
LET _monto   	   =   0;
LET	_paga_impuesto =   0; 
LET _compras 	   = '1';

FOREACH

	 SELECT	no_requis,
			fecha_impresion,
			fecha_anulado,
			cod_agente,
			monto,
			no_cheque,
			origen_cheque, 
	     	cod_cliente 
	   INTO	_no_requis,
			_fecha_impresion,
			_fecha_anulado,
			_cod_agente,
			_monto,
			_no_cheque,
			_origen_cheque,
			_cod_cliente 
	   FROM chqchmae
	  WHERE	pagado                 = 1
	    AND origen_cheque          in ('2', 'A')
		AND MONTH(fecha_impresion) = a_periodo[6,7]
		AND YEAR(fecha_impresion)  = a_periodo[1,4]
	    AND cod_compania           = a_compania 

		IF _fecha_anulado IS NOT NULL THEN
			IF MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
			   YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			   CONTINUE FOREACH;
			END IF
		END IF

		IF  _origen_cheque = '2' THEN

		  SELECT cedula,
			     nombre,
			     digito_ver,
			     tipo_persona,
			     ced_correcta
		  INTO  _cedula,
		        _nombre,
			    _digito_ver,
			    _tipo_persona,
			    _ced_correcta
		   	FROM agtagent
		   WHERE cod_agente = _cod_agente;
		
		 IF _ced_correcta = 0 OR _cedula IS NULL THEN
			CONTINUE FOREACH;
			--RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
		 END IF


		 IF _digito_ver IS NULL THEN
			CONTINUE FOREACH;
			--RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
		 END IF

		 IF _tipo_persona = 'N' THEN
		    LET _tipo_persona = '1';
		 ELSE
		    LET _tipo_persona = '2';
		 END IF

		 

   	    ELSE
		   	SELECT cedula,
				   nombre,
				   digito_ver,
				   tipo_persona,
				   ced_correcta,
				   paga_impuesto	
			  INTO _cedula,
			       _nombre,
				   _digito_ver,
				   _tipo_persona,
				   _ced_correcta,
				   _paga_impuesto	
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente; 		

			IF _ced_correcta = 0 OR _cedula IS NULL THEN
			   CONTINUE FOREACH;
			   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
			END IF

			
			IF _digito_ver IS NULL THEN
			   CONTINUE FOREACH;
			   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
			END IF

		   	IF _paga_impuesto IS NULL THEN
			   LET _paga_impuesto = 0;
			END IF

			IF _paga_impuesto = 1 THEN
			   LET _itbms = _monto;
			   LET _monto = _monto / 1.05;
			   LET _itbms = _itbms - _monto;
			ELSE
			   LET _itbms = 0;
			END IF


	    END IF
		LET _renglon = _renglon + 1;
	BEGIN 
	  ON EXCEPTION IN(-239)

		UPDATE chqfor20
		   SET monto      = monto + _monto
		 WHERE cedula     = _cedula
		   AND digito_ver = _digito_ver
		   AND concepto   = _concepto_pago
		   AND fecha      = _fecha_impresion;

	  END EXCEPTION

		INSERT INTO chqfor20
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
		_compras,
		_itbms
		);

	END 

END FOREACH

LET _concepto_pago = '4'; -- Alquiler por arrendamiento comerciales
LET _itbms	 	   =   0;
LET _monto   	   =   0;
LET	_paga_impuesto =   0; 
LET _compras 	   = '1';

FOREACH

 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado,
		cod_agente,
		cod_cliente,
		monto,
		no_cheque
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado,
		_cod_agente,
		_monto,
		_cod_cliente,
		_no_cheque
   FROM chqchmae
  WHERE	pagado                 = 1
    AND origen_cheque          = 'C'
	AND MONTH(fecha_impresion) = a_periodo[6,7]
	AND YEAR(fecha_impresion)  = a_periodo[1,4]
    AND cod_compania           = a_compania

	IF _fecha_anulado IS NOT NULL THEN
		IF  MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
		    YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			CONTINUE FOREACH;
		END IF
	END IF

	SELECT cedula,
		   nombre,
		   digito_ver,
		   tipo_persona,
		   ced_correcta,
		   paga_impuesto	
	  INTO _cedula,
		   _nombre,
		   _digito_ver,
		   _tipo_persona,
		   _ced_correcta,
		   _paga_impuesto
		FROM cliclien
	  WHERE cod_cliente = _cod_cliente;
	
	IF _ced_correcta = 0 OR _cedula IS NULL THEN
	   CONTINUE FOREACH;
	   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
	END IF


	IF _digito_ver IS NULL THEN
	   CONTINUE FOREACH;
	   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
	END IF

	IF _tipo_persona = 'N' THEN
	   LET _tipo_persona = '1';
	ELSE
	   LET _tipo_persona = '2';
	END IF

	LET _renglon = _renglon + 1;

	BEGIN 
	ON EXCEPTION IN(-239)

		UPDATE chqfor20
		  SET monto       = monto + _monto
		 WHERE cedula     = _cedula
		   AND digito_ver = _digito_ver
		   AND concepto   = _concepto_pago
		   AND fecha      = _fecha_impresion;

	END EXCEPTION

		INSERT INTO chqfor20
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
		_compras,
		_itbms
		);

	END

END FOREACH
 				
LET _concepto_pago = '2'; -- Servicos Básicos
LET _itbms	 	   =   0;
LET _monto   	   =   0;
LET	_paga_impuesto =   0; 
LET _compras 	   = '1';

FOREACH

 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado,
		cod_agente,
		cod_cliente,
		monto,
		no_cheque
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado,
		_cod_agente,
		_cod_cliente,
		_monto,
		_no_cheque
   FROM chqchmae
  WHERE	pagado                 = 1
    AND origen_cheque          = 'B'
	AND MONTH(fecha_impresion) = a_periodo[6,7]
	AND YEAR(fecha_impresion)  = a_periodo[1,4]
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
		    ced_correcta,
		    paga_impuesto	
	   INTO _cedula,
		    _nombre,
		    _digito_ver,
		    _tipo_persona,
		    _ced_correcta,
		    _paga_impuesto
	   FROM cliclien
	  WHERE cod_cliente = _cod_cliente;
	
	IF _ced_correcta = 0 OR _cedula IS NULL THEN
	   CONTINUE FOREACH;
	   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
	END IF


	IF _digito_ver IS NULL THEN
	   CONTINUE FOREACH;
	   --RETURN 1, 'Se ha detenido el proceso de carga ....Favor verificar en reporte LISTADO DE VERIFICACION D.G.I.';
	END IF

	IF _tipo_persona = 'N' THEN
	   LET _tipo_persona = '1';
	ELSE
	   LET _tipo_persona = '2';
	END IF

	LET _renglon = _renglon + 1;

	BEGIN 
	  ON EXCEPTION IN(-239)

		UPDATE chqfor20
		   SET monto      = monto + _monto
		 WHERE cedula     = _cedula
		   AND digito_ver = _digito_ver
		   AND concepto   = _concepto_pago
		   AND fecha      = _fecha_impresion;

	  END EXCEPTION

		INSERT INTO chqfor20
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
		_compras,
		_itbms
		);

	END

END FOREACH

END 

 
UPDATE parcont
   SET valor_parametro = _renglon
 WHERE cod_compania    = a_compania
   AND aplicacion	   = 'CHE'
   AND version		   = '02'
   AND cod_parametro   = 'par_formulari20';

--COMMIT WORK;

RETURN 0, 'Actualizacion Exitosa';

END PROCEDURE;