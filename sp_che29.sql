-- Procedimiento que Realiza los Pagos a los Medicos de las Polizas de Salud del Plan Dental

-- Creado    : 14/09/2005 - Autor: Amado Perez Mendoza
-- Modificado: 14/09/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - d_cheq_sp_che29_crit - DEIVID, S.A.

--DROP PROCEDURE sp_che29;

CREATE PROCEDURE sp_che29(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_periodo        CHAR(7),
a_usuario        CHAR(8),
a_banco			 CHAR(3),
a_chequera		 CHAR(3)
) RETURNING INTEGER,
			CHAR(100);

DEFINE _doc_poliza          CHAR(20); 
DEFINE _monto_pagado        DEC(16,2);
DEFINE _fecha            	DATE;
DEFINE _no_poliza           CHAR(10); 
DEFINE _cod_tipoprod        CHAR(3);  
DEFINE _tipo_produccion     SMALLINT; 
DEFINE _cod_ramo	        CHAR(3);  
DEFINE _cod_subramo	        CHAR(3);  
DEFINE _cod_doctor          CHAR(10); 
DEFINE _descripcion         CHAR(60);
DEFINE _comision 			DEC(16,2);
DEFINE _no_requis			CHAR(10);
DEFINE _nombre      		CHAR(100);
DEFINE _cuenta      		CHAR(25);
DEFINE _error           	SMALLINT;
DEFINE _error_desc      	CHAR(100);
DEFINE _valor_parametro     SMALLINT;

CREATE TEMP TABLE tmp_pagos(
		no_documento    CHAR(18)	NOT NULL,
		monto_pagado    DEC(16,2)	NOT NULL,
		no_poliza       CHAR(10)    NOT NULL,
		cod_doctor      CHAR(10)    NOT NULL,
		pago    		DEC(16,2)	NOT NULL
		) WITH NO LOG;

--SET DEBUG FILE TO "sp_pro30.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 
	RETURN _error, _error_desc;
END EXCEPTION           

-- Nombre de la Compania

--LET _nombre_compania = sp_sis01(a_compania); 

FOREACH
 SELECT doc_remesa, 
        monto,
		fecha,
		no_poliza
   INTO _doc_poliza,
    	_monto_pagado,
		_fecha,
		_no_poliza
   FROM cobredet
  WHERE actualizado  = 1			              -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')           	  -- Pago de Prima(P)
    AND periodo      = a_periodo 

--	Let _no_poliza = sp_sis21(_doc_poliza);

	SELECT cod_tipoprod,
	       cod_ramo,
		   cod_subramo
	  INTO _cod_tipoprod,
	       _cod_ramo,
		   _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 4 Or _cod_ramo <> "018" Or (_cod_ramo = "018" And _cod_subramo <> "015") then	--Reaseguro Asumido
		continue foreach;
	End if

    FOREACH
		SELECT cod_doctor
		  INTO _cod_doctor
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		   AND activo = 1
		EXIT FOREACH;
	END FOREACH

	INSERT INTO tmp_pagos(
	no_documento,
	monto_pagado,
	no_poliza,
	cod_doctor,
	pago 
	)
	VALUES(
	_doc_poliza,
	_monto_pagado,
	_no_poliza,
	_cod_doctor,
	_monto_pagado
	);

END FOREACH

LET _descripcion = 'PAGO A MEDICOS PLAN DENTAL PERIODO ' || a_periodo;

SELECT valor_parametro
  INTO _valor_parametro
  FROM parcont
 WHERE cod_compania = a_compania
   AND aplicacion = "CHE"
   AND cod_parametro = "par_comis_dent"; 

FOREACH
	SELECT SUM(monto_pagado),
	       cod_doctor
	  INTO _monto_pagado,
	       _cod_doctor
	  FROM tmp_pagos
  GROUP BY cod_doctor
  ORDER BY cod_doctor

    LET _comision =  _monto_pagado * _valor_parametro / 10;

	-- Numero Interno de Requisicion

	LET _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_doctor;

	-- Encabezado del Cheque

	INSERT INTO chqchmae(
	no_requis,
	cod_cliente,
	cod_agente,
	cod_banco,
	cod_chequera,
	cuenta,
	cod_compania,
	cod_sucursal,
	origen_cheque,
	no_cheque,
	fecha_impresion,
	fecha_captura,
	autorizado,
	pagado,
	a_nombre_de,
	cobrado,
	fecha_cobrado,
	anulado,
	fecha_anulado,
	anulado_por,
	monto,
	periodo,
	user_added,
	autorizado_por
	)
	VALUES(
	_no_requis,
	NULL,
	_cod_doctor,
	a_banco,
	a_chequera,
	NULL,
	a_compania,
	a_sucursal,
	'2',
	0,
	CURRENT,
	CURRENT,
	1,
	0,
	_nombre,
	0,
	NULL,
	0,
	NULL,
	NULL,
	_comision,
	a_periodo,
	a_usuario,
	a_usuario
	);	 

	-- Descripcion del Cheque

	INSERT INTO chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	VALUES(
	_no_requis,
	1,
	_descripcion
	);

	-- Registros Contables de Comisiones por Pagar

	LET _cuenta = sp_sis15('CGCPMED');

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	_no_requis,
	1,
	_cuenta,
	_comision,
	0
	);


END FOREACH

RETURN 0, 'Actualizacion Exitosa ...';

END

END PROCEDURE;
