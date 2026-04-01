-- Cheques Pagados a Proveedores de Salud

-- Creado    : 05/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che11_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che11;
CREATE PROCEDURE sp_che11(
a_compania    CHAR(3),
a_sucursal    CHAR(3),
a_fecha_desde DATE,   
a_fecha_hasta DATE,
a_cod_cliente CHAR(255) DEFAULT "*"    
) RETURNING CHAR(10),	-- Transaccion
			DATE,		-- Fecha
			INTEGER,	-- No. Cheque
			DEC(16,2),	-- Monto
			CHAR(10),	-- Cliente
			CHAR(100),	-- Nombre
			CHAR(30),	-- Cedula
			CHAR(50),	-- Compania
			CHAR(50),	-- Nombre Pago	
			CHAR(20),	-- Numrecla
			CHAR(100),	-- Nombre Asegurado
			CHAR(100),	-- Nombre Reclamante
			CHAR(255),	-- Filtros
			CHAR(18),	-- No. Poliza
			char(10),    -- No. Factura
			date;       -- Fecha Factura

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE _no_requis         CHAR(10); 
DEFINE _transaccion       CHAR(10); 
DEFINE _no_reclamo        CHAR(10); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _cod_ramo          CHAR(3);  
DEFINE _ramo_sis          SMALLINT; 
DEFINE _cod_tipopago      CHAR(3);  
DEFINE _no_cheque         INTEGER;  
DEFINE _nombre            CHAR(100);
DEFINE _cedula            CHAR(30); 
DEFINE _fecha,_fecha_factura             DATE;     
DEFINE _monto             DEC(16,2);
DEFINE v_nombre_cia       CHAR(50); 
DEFINE _nombre_pago       CHAR(50); 
DEFINE _numrecla          CHAR(20); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _nombre_reclamante CHAR(100);
DEFINE _no_documento      CHAR(18); 

DEFINE _cod_asegurado     CHAR(10); 
DEFINE _cod_cliente,_no_factura,_cod_reclamante       CHAR(10); 

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania);
let _fecha_factura = null;

--DROP TABLE tmp_pagos;

CREATE TEMP TABLE tmp_pagos(
	nombre            CHAR(100),
	cod_cliente       CHAR(10), 
	transaccion       CHAR(10), 
	no_cheque         INTEGER,  
	monto             DEC(16,2),
	cedula            CHAR(30), 
	fecha             DATE,     
	cod_tipopago      CHAR(3),  
	numrecla          CHAR(20), 
	nombre_cliente    CHAR(100),
	nombre_reclamante CHAR(100),
	seleccionado      SMALLINT,
	no_documento      CHAR(18),
	no_factura        char(10),
	fecha_factura     date
	) WITH NO LOG;
	 
--set debug file to "sp_che11.trc";

FOREACH
 SELECT	no_requis,
		no_cheque,
		fecha_impresion
   INTO	_no_requis,
		_no_cheque,
		_fecha
   FROM chqchmae
  WHERE	pagado           = 1
    AND origen_cheque    = 3
	AND fecha_impresion >= a_fecha_desde
	AND fecha_impresion <= a_fecha_hasta
	AND anulado = 0

   FOREACH
		SELECT transaccion,
			   monto
		  INTO _transaccion,
			   _monto
		  FROM chqchrec
		 WHERE no_requis = _no_requis

	    FOREACH	
			SELECT no_reclamo,
				   cod_tipopago,
				   cod_cliente,
				   no_factura,			   
				   fecha_factura
			  INTO _no_reclamo,
				   _cod_tipopago,
				   _cod_cliente,
				   _no_factura,
				   _fecha_factura
			  FROM rectrmae
		     WHERE transaccion = _transaccion
 			EXIT FOREACH; 
		END FOREACH       

		IF _cod_tipopago = '003' OR
		   _cod_tipopago = '004' THEN		
			CONTINUE FOREACH;
		END IF

		SELECT no_poliza,
			   cod_asegurado,
			   numrecla,
			   cod_reclamante	
		  INTO _no_poliza,
			   _cod_asegurado,	
			   _numrecla,	
			   _cod_reclamante	
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		SELECT cod_ramo,
		       no_documento
		  INTO _cod_ramo,
		       _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		SELECT cedula,
			   nombre	
		  INTO _cedula,
		       _nombre
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente; 		
		
		SELECT nombre	
		  INTO _nombre_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado; 		

		SELECT nombre	
		  INTO _nombre_reclamante
		  FROM cliclien
		 WHERE cod_cliente = _cod_reclamante; 		

		INSERT INTO tmp_pagos
		VALUES(
		_nombre,
		_cod_cliente,
		_transaccion,
		_no_cheque,
		_monto,
		_cedula,
		_fecha,
		_cod_tipopago,
		_numrecla,
		_nombre_cliente,
		_nombre_reclamante,
		1,
		_no_documento,
		_no_factura,
		_fecha_factura
		);

	END FOREACH
END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_cod_cliente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Proveedor: " ||  TRIM(a_cod_cliente);

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF
	DROP TABLE tmp_codigos;
END IF

FOREACH
 SELECT	nombre,
		cod_cliente,
		transaccion,
		no_cheque,
		monto,
		cedula,
		fecha,
		cod_tipopago,
		numrecla,
		nombre_cliente,
		nombre_reclamante,
		no_documento,
		no_factura,
		fecha_factura
   INTO _nombre,
		_cod_cliente,
		_transaccion,
		_no_cheque,
		_monto,
		_cedula,
		_fecha,
		_cod_tipopago,
		_numrecla,
		_nombre_cliente,
		_nombre_reclamante,
		_no_documento,
		_no_factura,
		_fecha_factura
   FROM tmp_pagos
  WHERE seleccionado = 1
  ORDER BY nombre, fecha, no_cheque

	SELECT nombre
	  INTO _nombre_pago
	  FROM rectipag
	 WHERE cod_tipopago = _cod_tipopago;

	RETURN _transaccion,
		   _fecha,
		   _no_cheque,
		   _monto,
		   _cod_cliente,
		   _nombre,
		   _cedula,
		   v_nombre_cia,
		   _nombre_pago,
		   _numrecla,
		   _nombre_cliente,
		   _nombre_reclamante,
		   v_filtros,
		   _no_documento,
		   _no_factura,
		   _fecha_factura
		   WITH RESUME;	

END FOREACH
DROP TABLE tmp_pagos;
END PROCEDURE;