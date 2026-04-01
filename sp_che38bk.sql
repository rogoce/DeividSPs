-- Procedimiento que Genera la Remesa de los Pago a Poliza y las Deudas de los corredores Comisiones

-- ref. sp_cob50;   : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Creado: 09/12/2005 - Autor: Amado Perez M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che38;

CREATE PROCEDURE "informix".sp_che38(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_fecha_hasta	DATE
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code,_no_tran      INTEGER;

DEFINE _cod_agente      CHAR(5);
DEFINE _cod_agente2     CHAR(5); 
DEFINE _tipo			smallint;
DEFINE _monto			dec(16,2);
DEFINE _monto_desc      DEC(16,2);
DEFINE _no_documento	char(30);
DEFINE _cod_auxiliar	char(5);
DEFINE _cod_contratante CHAR(10);
DEFINE _cedula         	CHAR(30);

DEFINE _renglon      	INTEGER;  
DEFINE _renglon2      	CHAR(5);  
DEFINE _saldo        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(100);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa', '';
END EXCEPTION           

LET _tipo_mov   = 'P'; 
LET _null       = NULL;
LET a_no_remesa = '1';  

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	

LET _fecha = current;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

-- Numero de Comprobante

LET a_no_recibo = 'CD';	

IF DAY(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || DAY(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || DAY(_fecha);
END IF

IF MONTH(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || MONTH(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || MONTH(_fecha);
END IF

LET _ano_char   = YEAR(_fecha);
LET a_no_recibo = TRIM(a_no_recibo) || _ano_char[3,4];

-- Insertar el Maestro de Remesas

INSERT INTO cobremae(
no_remesa,
cod_compania,
cod_sucursal,
cod_banco,
cod_cobrador,
recibi_de,
tipo_remesa,
fecha,
comis_desc,
contar_recibos,
monto_chequeo,
actualizado,
periodo,
user_added,
date_added,
user_posteo,
date_posteo
)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
'001',		--Global bank
_null,
_null,
'C',
a_fecha_hasta,
0,
3,
0.00,
0,
_periodo,
a_user,
a_fecha_hasta,
a_user,
a_fecha_hasta
);

LET _renglon = 0;

FOREACH
	SELECT cod_agente
	  INTO _cod_agente   
	  FROM tmp_comis

 --	 WHERE cod_agente = '00124' --Rovi y asociados	   	

	LET _nombre_agente = "";

	SELECT nombre,
	       cedula
	  INTO _nombre_agente,
		   _cedula
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	FOREACH
		SELECT tipo,
			   no_documento,
			   monto,
			   cod_auxiliar,
			   saldo_pol,
			   renglon
		  INTO _tipo,			
			   _no_documento,	
			   _monto,			
			   _cod_auxiliar,
			   _saldo,
			   _renglon2
		  FROM tmp_comis2
		 WHERE cod_agente = _cod_agente --Rovi y asociados	  
		
		LET _renglon   = _renglon + 1;

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF

		IF _tipo = 2 THEN  -- Pago a Primas	
			LET _tipo_mov   = 'P'; 
			LET _no_poliza = sp_sis21(_no_documento);
			SELECT cod_contratante
			  INTO _cod_contratante
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

	        SELECT nombre
			  INTO _nombre_cliente
			  FROM cliclien
			 WHERE cod_cliente = _cod_contratante;

		    -- Impuestos de la Poliza

			SELECT SUM(i.factor_impuesto)
			  INTO _factor
			  FROM prdimpue i, emipolim p
			 WHERE i.cod_impuesto = p.cod_impuesto
			   AND p.no_poliza    = _no_poliza;

			IF _factor IS NULL THEN
				LET _factor = 0;
			END IF

			LET _factor   = 1 + _factor / 100;

			LET _prima    = _monto / _factor;
			LET _impuesto = _monto - _prima;

	        -- Descripcion de la Remesa

			LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);

			-- Detalle de la Remesa

			INSERT INTO cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			no_poliza
			)
			VALUES(
		    a_no_remesa,
		    _renglon,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    _no_documento,
		    _tipo_mov,
		    _monto,
		    _prima,
		    _impuesto,
		    0,
		    0,
		    _descripcion,
		    _saldo,
		    _periodo,
		    a_fecha_hasta,
		    0,
			_no_poliza
			);

			FOREACH
			 SELECT	cod_agente,
					porc_partic_agt,
					porc_comis_agt
			   INTO	_cod_agente2,
					_porc_partic,
					_porc_comis
			   FROM	emipoagt
			  WHERE no_poliza = _no_poliza

			 INSERT INTO cobreagt
			 VALUES(
			 a_no_remesa,
			 _renglon,
			 _cod_agente2,
			 0,
			 0,
			 _porc_comis,
			 _porc_partic
			 );  
			  
			END FOREACH

		ELIF _tipo = 1 THEN	  -- Pago de Deuda
			LET _tipo_mov  = 'O'; 
			LET _prima    = 0;
			LET _impuesto = 0;

	        -- Descripcion de la Remesa

			LET _descripcion = TRIM(_nombre_agente);

			-- Detalle de la Remesa

			INSERT INTO cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			cod_agente,
			cod_auxiliar,
			no_unidad
			)
			VALUES(
		    a_no_remesa,
		    _renglon,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    _no_documento,
		    _tipo_mov,
		    _monto,
		    _prima,
		    _impuesto,
		    0,
		    0,
		    _descripcion,
		    _saldo,
		    _periodo,
		    a_fecha_hasta,
		    0,
			_cod_agente,
			_cod_auxiliar,
			_renglon2
			);
		END IF
	 
	END FOREACH

	SELECT SUM(monto)
	  INTO _monto_desc
	  FROM tmp_comis2
	 WHERE cod_agente = _cod_agente;

	LET _renglon    = _renglon + 1;

	IF _monto_desc IS NULL THEN
		LET _monto_desc = 0;
	END IF

	LET _monto_desc = _monto_desc * -1;

    -- Descripcion de la Remesa

	LET _descripcion = TRIM(_nombre_agente);

	-- Comision Descontada

	INSERT INTO cobredet(
    no_remesa,
    renglon,
    cod_compania,
    cod_sucursal,
    no_recibo,
    tipo_mov,
	doc_remesa,
    monto,
    prima_neta,
    impuesto,
    monto_descontado,
    comis_desc,
    desc_remesa,
    saldo,
    periodo,
    fecha,
    actualizado,
	no_poliza,
	cod_agente
	)
	VALUES(
    a_no_remesa,
    _renglon,
    a_compania,
    a_sucursal,
    a_no_recibo, 
    "C",
	_cedula,
    _monto_desc,
    0.00,
    0.00,
    0,
    0,
    _descripcion, 
    0.00,
    _periodo,
    a_fecha_hasta,
    0,
	NULL,
	_cod_agente
	);

END FOREACH

SELECT SUM(monto)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;


RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;
