-- Procedimiento que Genera la Remesa de los Centavos
-- con modificacion 19/05/2010     Armando Moreno
-- Creado    : 14/02/2001 - Autor: Demetrio Hurtado Almanza
-- modificado: 14/02/2001 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob42b;

CREATE PROCEDURE "informix".sp_cob42b(a_no_remesa CHAR(10))
RETURNING INTEGER,
		  CHAR(50);

DEFINE _error_code      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_cliente   	CHAR(10);
DEFINE _cod_agente   	CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _tipo_remesa     CHAR(1);

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Ajustes de Centavos';         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

SELECT fecha,
	   periodo,
	   cod_compania,
	   cod_sucursal,
	   tipo_remesa		   	
  INTO _fecha,
	   _periodo,	
	   _cod_compania,
	   _cod_sucursal,
	   _tipo_remesa	
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _tipo_remesa <> 'T' THEN
	RETURN 1, "Tipo de Remesa Debe Ser Ajuste de Centavos ...";
END IF

SELECT no_recibo
  INTO a_no_recibo
  FROM cobredet
 WHERE no_remesa = a_no_remesa
   AND renglon   = 1;

IF a_no_recibo IS NULL THEN
	RETURN 1, "Es Necesario Capturar El Renglon Inicial ...";
END IF

-- Inicializar Tablas

DELETE FROM cobreagt
 WHERE no_remesa = a_no_remesa;

DELETE FROM cobredet
 WHERE no_remesa = a_no_remesa
   AND renglon  <> 1;

UPDATE cobredet
   SET monto = 0
 WHERE no_remesa = a_no_remesa
   AND renglon   = 1;

LET _renglon = 1;

FOREACH
 SELECT	no_documento
   INTO	_no_documento
   FROM	emipoliza

	let _saldo = sp_cob175(_no_documento, _periodo);

	if _saldo = 0.00 then
		continue foreach;
	end if

	if abs(_saldo) > 2.00 then
		continue foreach;
	end if

	LET _renglon = _renglon + 1;

	let _no_poliza = sp_sis21(_no_documento);

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Tipo de Movimiento
	IF _saldo > 0 THEN
	   	LET _tipo_mov = 'P'; --que tipo poner?
	ELSE
		LET _tipo_mov = 'N';
	END IF

	SELECT SUM(i.factor_impuesto)
	  INTO _factor
	  FROM prdimpue i, emipolim p
	 WHERE i.cod_impuesto = p.cod_impuesto
	   AND p.no_poliza    = _no_poliza;

	IF _factor IS NULL THEN
		LET _factor = 0;
	END IF

	LET _factor   = 1 + _factor / 100;
	LET _prima    = _saldo / _factor;

	-- Descripcion de la Remesa
	
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	LET _nombre_agente = "";

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
    _cod_compania,				   
    _cod_sucursal,				   
    a_no_recibo,				   
    _no_documento,				   
    _tipo_mov,					   
    _saldo,						   
    _prima,						   
    0,
    0,							   
    0,							   
    _descripcion,				   
    _saldo,						   
    _periodo,					   
    _fecha,						   
    0,							   
	_no_poliza					   
	);							   

	FOREACH
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porc_partic,
			_porc_comis
	   FROM	emipoagt
	  WHERE no_poliza = _no_poliza

		INSERT INTO cobreagt
		VALUES(
		a_no_remesa,
		_renglon,
		_cod_agente,
		0,
		0,
		0,
		_porc_partic
		);  
	  
	END FOREACH
	 	
END FOREACH

SELECT SUM(monto)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

IF _saldo > 0 THEN

	UPDATE cobredet
	   SET monto            = _saldo,
	       monto_descontado = _saldo
	 WHERE no_remesa = a_no_remesa
	   AND renglon   = 1;

ELSE

	UPDATE cobredet
	   SET monto            = _saldo,
	       monto_descontado = 0
	 WHERE no_remesa = a_no_remesa
	   AND renglon   = 1;

END IF

RETURN 0, "Actualizacion Exitosa ...";

END

END PROCEDURE;
