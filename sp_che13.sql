-- Proveedores sin Numero de RUC ni DV

-- Creado    : 05/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che13_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che13;

CREATE PROCEDURE sp_che13(
a_compania    CHAR(3),
a_sucursal    CHAR(3),
a_periodo     CHAR(7)    
) RETURNING CHAR(10),	-- Codigo
			CHAR(100),	-- Nombre
			CHAR(10),	-- Telefono
			CHAR(30),	-- Cedula
			CHAR(2),    -- Digito Ver
			CHAR(50),	-- Compania
			CHAR(1);    -- Tipo de Cliente


DEFINE _transaccion       CHAR(10);
DEFINE _no_requis         CHAR(10);
DEFINE _cod_tipopago      CHAR(3);

DEFINE _nombre            CHAR(100);
DEFINE _cod_cliente       CHAR(10); 
DEFINE _cedula            CHAR(30); 
DEFINE _digito_ver        CHAR(2);
DEFINE _telefono1         CHAR(10);
DEFINE v_nombre_cia       CHAR(50); 

DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;
DEFINE _cod_agente        CHAR(5);
DEFINE _tipo_cliente      CHAR(1);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_pagos;

CREATE TEMP TABLE tmp_pagos(
	nombre            CHAR(100),
	cod_cliente       CHAR(10), 
	cedula            CHAR(30), 
	digito_ver		  CHAR(2),
	telefono1		  CHAR(10),
	tipo_cliente      CHAR(1)	
	) WITH NO LOG;

-- Clientes
	 
FOREACH
 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado
   FROM chqchmae
  WHERE	pagado           = 1
    AND origen_cheque    = 3
	AND MONTH(fecha_impresion) = a_periodo[6,7]
	AND YEAR(fecha_impresion)  = a_periodo[1,4]

	IF _fecha_anulado IS NOT NULL THEN
		IF MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
		    YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			CONTINUE FOREACH;
		END IF
	END IF

   FOREACH
	SELECT transaccion
	  INTO _transaccion
	  FROM chqchrec
	 WHERE no_requis = _no_requis

	   FOREACH	
		SELECT cod_tipopago,
			   cod_cliente	
		  INTO _cod_tipopago,
			   _cod_cliente	
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
			   telefono1	
		  INTO _cedula,
		       _nombre,
			   _digito_ver,
			   _telefono1
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente; 		
		
		IF _cedula     IS NULL OR
		   _digito_ver IS NULL THEN

			INSERT INTO tmp_pagos
			VALUES(
			_nombre,
			_cod_cliente,
			_cedula,
			_digito_ver,
			_telefono1,
			'1' 
			);

		END IF

	END FOREACH

END FOREACH

-- Corredores

FOREACH
 SELECT	no_requis,
		fecha_impresion,
		fecha_anulado,
		cod_agente
   INTO	_no_requis,
		_fecha_impresion,
		_fecha_anulado,
		_cod_agente
   FROM chqchmae
  WHERE	pagado           = 1
    AND origen_cheque    = 2
	AND MONTH(fecha_impresion) = a_periodo[6,7]
	AND YEAR(fecha_impresion)  = a_periodo[1,4]

	IF _fecha_anulado IS NOT NULL THEN
		IF MONTH(_fecha_anulado) = MONTH(_fecha_impresion) AND
		    YEAR(_fecha_anulado) = YEAR(_fecha_impresion)  THEN
			CONTINUE FOREACH;
		END IF
	END IF

	SELECT cedula,
		   nombre,
		   digito_ver,
		   telefono1	
	  INTO _cedula,
	       _nombre,
		   _digito_ver,
		   _telefono1
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 		
	
	IF _cedula     IS NULL OR
	   _digito_ver IS NULL THEN

		INSERT INTO tmp_pagos
		VALUES(
		_nombre,
		_cod_agente,
		_cedula,
		_digito_ver,
		_telefono1,
		'2' 
		);

	END IF

END FOREACH

FOREACH
 SELECT	nombre,
		cod_cliente,
		cedula,
		digito_ver,
		telefono1,
		tipo_cliente
   INTO _nombre,
		_cod_cliente,
		_cedula,
		_digito_ver,
		_telefono1, 
		_tipo_cliente
   FROM tmp_pagos
  GROUP BY tipo_cliente, nombre, cod_cliente, cedula, digito_ver, telefono1
  ORDER BY tipo_cliente, nombre

	RETURN _cod_cliente,
		   _nombre,
		   _telefono1,
		   _cedula,
		   _digito_ver,
		   v_nombre_cia,
		   _tipo_cliente
		   WITH RESUME;	

END FOREACH

DROP TABLE tmp_pagos;

END PROCEDURE;