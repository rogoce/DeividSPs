-- Formulario de Impresion de Recuperos-- 
-- Creado    : 17/07/2001 - Autor: Marquelda Valdelamar

DROP PROCEDURE sp_rec53;

CREATE PROCEDURE "informix".sp_rec53(
a_compania    CHAR(3),
a_no_recupero CHAR(5)
) RETURNING	CHAR(5),       -- no_recupero
            CHAR(18), 	   -- Reclamo
			CHAR(50), 	   -- Coaseguro
			CHAR(50),	   -- Abogado
			CHAR(30),  	   -- periodo de pago
			DATE,     	   -- Fecha Recupero   
			DATE,     	   -- Fecha Audiencia 
			CHAR(100), 	   -- Nombre Tercero    
			CHAR(100), 	   -- Direccion Tercero         
			CHAR(10),	   -- telefono
			CHAR(10),      -- celular
			CHAR(50),      -- estatus_recobro
			CHAR(50),      -- estatus_abogado
			DECIMAL(16,2), -- monto_arreglo
			DECIMAL(16,2), -- monto_recuperado
			DECIMAL(16,2), -- pagado_reclamo
			CHAR(8),       -- usuario de adicion
			DATE,          -- fecha de adicion
			INTEGER,       -- no_pagos
			DATE,          -- fecha primer pago
			CHAR(30),      -- cedula tercero
			CHAR(20),      -- modo de cobros  
			CHAR(50),      -- nombre_cliente
			CHAR(20),      -- no_documento
			DECIMAL(16,2), -- saldo
			CHAR(100),
			CHAR(10);     -- no_reclamo


DEFINE _cod_coasegur       CHAR(3);
DEFINE _cod_abogado        CHAR(3);
DEFINE _cod_perpago        CHAR(3);
DEFINE _estatus_recobro    INTEGER;
DEFINE _estatus_abogado    CHAR(1);
DEFINE _modo_cobros        CHAR(1);
DEFINE _no_reclamo         CHAR(10);
DEFINE _no_poliza          CHAR(10);
DEFINE _cod_contratante    CHAR(10);


DEFINE v_numrecla          CHAR(18);
DEFINE v_nombre_coase	   CHAR(50); 
DEFINE v_nombre_abogado	   CHAR(50); 
DEFINE v_nombre_perpago    CHAR(30);
DEFINE v_fecha_recupero    DATE;
DEFINE v_fecha_audi_rec    DATE;
DEFINE v_nombre_tercero    CHAR(100);
DEFINE v_direccion_tercero CHAR(100);
DEFINE v_telefono_tercero  CHAR(10);
DEFINE v_celular_tercero   CHAR(10);
DEFINE v_estado_recobro    CHAR(50);
DEFINE v_estado_abogado    CHAR(50);
DEFINE v_monto_arreglo     DECIMAL(16,2);
DEFINE v_monto_recup       DECIMAL(16,2);
DEFINE v_pagado_reclamo    DECIMAL(16,2);
DEFINE v_user_added        CHAR(8);
DEFINE v_date_added        DATE;
DEFINE v_no_pagos          INTEGER;
DEFINE v_fecha_primer_pago DATE;
DEFINE v_cedula_tercero    CHAR(30);
DEFINE v_modo_cobros       CHAR(20);
DEFINE v_nombre_cliente    CHAR(50);
DEFINE v_no_documento      CHAR(20);
DEFINE v_compania_nombre   CHAR(100);
DEFINE v_monto_recuperado  DECIMAL(16,2);
DEFINE v_monto_pagado      DECIMAL(16,2);
DEFINE v_saldo             DECIMAL(16,2);

LET v_monto_recuperado = 0.00;
LET v_saldo = 0.00;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

 SELECT no_reclamo,
 		numrecla,
		cod_coasegur,
		cod_abogado,
		cod_perpago,
		fecha_recupero,
		fecha_audi_rec,
		nombre_tercero,
		direccion_tercero,
		telefono_tercero,
		celular_tercero,
		estatus_recobro,
		estatus_abogado,
		monto_arreglo,
		user_added,
		date_added,
		no_pagos,
		fecha_primer_pago,
		cedula_tercero,
		modo_cobros
   INTO	_no_reclamo,
        v_numrecla,
		_cod_coasegur,
		_cod_abogado,
		_cod_perpago,
		v_fecha_recupero,
		v_fecha_audi_rec,
		v_nombre_tercero,
		v_direccion_tercero,
		v_telefono_tercero,
		v_celular_tercero,
		_estatus_recobro,
		_estatus_abogado,
		v_monto_arreglo,
		v_user_added,
		v_date_added,
		v_no_pagos,
		v_fecha_primer_pago,
		v_cedula_tercero,
		v_modo_cobros
   FROM recrecup
  WHERE no_recupero = a_no_recupero;
  
	   --	monto_recuperado,
	   --	pagado_reclamo,
	   --	v_monto_recup,
	   --	v_pagado_reclamo,

  	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo= _no_reclamo;

	SELECT cod_contratante,
	       no_documento
	  INTO _cod_contratante,
	       v_no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	SELECT nombre_abogado
	  INTO v_nombre_abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;

	SELECT nombre
	  INTO v_nombre_coase
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;

	SELECT nombre
	  INTO v_nombre_perpago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

--Calculo del monto Recuperado
    SELECT SUM (monto)
	  INTO v_monto_recuperado
	  FROM rectrmae a, rectitra b
     WHERE a.no_reclamo = _no_reclamo
	   AND a.cod_tipotran = b.cod_tipotran
       AND a.actualizado = 1
	   AND b.tipo_transaccion = 6;

--Calculo del Total pagado
    SELECT SUM (monto)
	  INTO v_monto_pagado
	  FROM rectrmae a, rectitra b
     WHERE a.no_reclamo = _no_reclamo
	   AND a.cod_tipotran = b.cod_tipotran
       AND a.actualizado = 1
	   AND b.tipo_transaccion = 4;

LET v_monto_recuperado = v_monto_recuperado * -1;

IF v_monto_recuperado IS NULL THEN
 LET v_monto_recuperado = 0.00;
END IF


LET v_saldo = v_monto_arreglo - v_monto_recuperado;


IF _estatus_abogado = 'N' THEN
	 LET v_estado_abogado = 'NO APLICA';
	ELIF _estatus_abogado = 'I' THEN
	 LET v_estado_abogado = 'INVESTIGACION';
	ELIF _estatus_abogado = 'D' THEN
	 LET v_estado_abogado = 'DEMANDA';
	ELSE
	 LET v_estado_abogado = 'SECUESTRO';
END IF

IF _estatus_recobro = 1 THEN
	 LET v_estado_recobro = 'TRAMITE';
	ELIF _estatus_recobro = 2 THEN
	 LET v_estado_recobro = 'INVESTIGACION';
	ELIF _estatus_recobro  = 3 THEN
	 LET v_estado_recobro = 'SUBROGACION';
	ELIF _estatus_recobro = 4 THEN
	 LET v_estado_recobro = 'ABOGADO'; 
	ELIF _estatus_recobro = 5 THEN
	 LET v_estado_recobro = 'ARREGLO DE PAGO'; 
	ELIF _estatus_recobro = 6 THEN
	 LET v_estado_recobro = 'INFRUCTUOSO'; 
    ELIF _estatus_recobro = 7 THEN
	 LET v_estado_recobro = 'RECUPERADO';
	ELSE
	 LET v_estado_recobro = NULL;
END  IF


	RETURN	a_no_recupero,
			v_numrecla,
		    v_nombre_coase,
		    v_nombre_abogado,
		    v_nombre_perpago,
		    v_fecha_recupero,
			v_fecha_audi_rec,
			v_nombre_tercero,
			v_direccion_tercero,
			v_telefono_tercero,
			v_celular_tercero,
			v_estado_recobro,
			v_estado_abogado,
			v_monto_arreglo,
			v_monto_recuperado,
			v_monto_pagado,
			v_user_added,
			v_date_added,
			v_no_pagos,
			v_fecha_primer_pago,
			v_cedula_tercero,
			v_modo_cobros,
			v_nombre_cliente,
			v_no_documento,
			v_saldo,
			v_compania_nombre,
			_no_reclamo
			WITH RESUME;

END PROCEDURE;

