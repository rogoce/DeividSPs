-- Procedimiento que Genera la Remesa de los Pagos Externos

-- Creado    : 09/09/2004 - Autor: Armando Moreno
-- Modificado: 30/09/2004 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob162;

CREATE PROCEDURE "informix".sp_cob162(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_numero		CHAR(10),
a_no_remesa 	CHAR(10)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      	INTEGER;
DEFINE _renglon      		INTEGER;
DEFINE _renglon2     		INTEGER;
define _secuencia			integer;
define _cant				integer;
DEFINE _saldo        		DEC(16,2);
DEFINE _monto        		DEC(16,2);
define _monto_calc			DEC(16,2);
define _monto_comis			DEC(16,2);
define _monto_descontado	DEC(16,2);
DEFINE _factor				DEC(16,2);
DEFINE _prima				DEC(16,2);
DEFINE _impuesto			DEC(16,2);
DEFINE _porc_partic			DEC(5,2);
DEFINE _porc_comis			DEC(5,2);
DEFINE _no_poliza    		CHAR(10); 
DEFINE _no_documento 		CHAR(20);
define _doc_suspenso 		CHAR(30);
define _cod_agt		 		CHAR(5);
DEFINE _periodo				CHAR(7);
DEFINE _tipo_mov        	CHAR(1);
DEFINE _nombre_cliente 		CHAR(80);
DEFINE _nombre_agente 		CHAR(50);
DEFINE _descripcion   		CHAR(100);
DEFINE _cod_agente   		CHAR(10);
DEFINE _null            	CHAR(1);
DEFINE _ano_char        	CHAR(4);
DEFINE _no_recibo_ancon 	CHAR(10);
DEFINE _fecha				DATE;
define _comis_dif			DEC(16,2);
define _cedula				char(30);
define _recibi_de			char(50);

--SET DEBUG FILE TO "sp_cob162.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Pagos Externos', '';
END EXCEPTION

LET _null       = NULL;

SELECT fecha_recibo,
	   no_recibo_ancon,
	   cod_agente	
  INTO _fecha,
	   _no_recibo_ancon,
	   _cod_agt
  FROM cobpaex0
 WHERE numero = a_numero;

select cedula,
       nombre
  into _cedula,
       _recibi_de
  from agtagent
 where cod_agente = _cod_agt;

IF _fecha IS NULL THEN
	LET _fecha = TODAY;
END IF

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

select count(*)
  into _cant
  from cobremae
 where no_remesa = a_no_remesa;

-- Insertar el Maestro de Remesas

if _cant = 0 then	--no esta insertado

	INSERT INTO cobremae
	VALUES(
	a_no_remesa,
	a_compania,
	a_sucursal,
	'001',
	_null,
	_recibi_de,
	'M',
	_fecha,
	0,
	3,
	0.00,
	0,
	_periodo,
	a_user,
	_fecha,
	a_user,
	_fecha
	);
end if

let _comis_dif = 0.00;

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

let _renglon = _renglon + 1;

FOREACH
 SELECT	no_documento,
		monto_cobrado,
		cliente,
		monto_comis,
		renglon
   INTO	_no_documento,
		_monto,
		_nombre_cliente,
		_monto_comis,
		_renglon2
   FROM cobpaex1
  WHERE numero = a_numero
  ORDER BY renglon

	LET _no_poliza = sp_sis21(_no_documento);

	if _no_poliza IS NOT NULL OR _no_poliza <> "" THEN

		if _monto >= 0.00 then 
			LET _tipo_mov   = 'P';
		else
			LET _tipo_mov   = 'N';
		end if

		{SELECT SUM(saldo)  --02/02/2011 se cambio para que trajera el saldo correcto
		  INTO _saldo
		  FROM emipomae
		 WHERE no_documento = _no_documento
		   AND actualizado  = 1; }

		let _saldo = sp_cob115b('001','001',_no_documento,'');

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF

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
		
		LET _nombre_agente = "";

		FOREACH
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza

			SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			EXIT FOREACH;

		END FOREACH

		LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);

	else   --Crear prima en suspenso

--		RETURN 1, 'No se encontro numero de poliza, Por favor verifique ... ' , ""; 

		let _secuencia = 0;

		select count(*)
		  into _secuencia
		  from cobpaex3
		 where no_recibo = _no_recibo_ancon;

		if _secuencia = 0 then  --no existe

			INSERT INTO cobpaex3(
			no_recibo,
			secuencia
			)
			VALUES(
		    _no_recibo_ancon,
		    0
			);

		end if

		LET _descripcion = TRIM(_nombre_cliente);

		SELECT nombre
		  INTO _nombre_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agt;

		--tabla que lleva la secuencia por recibo
		select max(secuencia)
		  into _secuencia
		  from cobpaex3
		 where no_recibo = _no_recibo_ancon;

		let _secuencia = _secuencia + 1;

		let _tipo_mov     = 'E';
		let _doc_suspenso = trim(_no_recibo_ancon) || "-" || _secuencia;
		let _no_poliza    = _null;
		let _monto        = _monto;
--		let _monto        = _monto - _monto_comis;
		let _prima        = 0;
		let _impuesto     = 0;
		let _saldo        = 0.00;
		let _monto_comis  = 0.00;

{
		INSERT INTO cobsuspe(
		doc_suspenso,
		cod_compania,
		cod_sucursal,
		monto,
		fecha,
		coaseguro,
		asegurado,
		poliza,
		ramo,
		actualizado,
		user_added,
		date_added
		)
		VALUES(
	    _doc_suspenso,
	    a_compania,
	    a_sucursal,
	    _monto,
		_fecha,
		_nombre_agente,
		_nombre_cliente,
	    _no_documento,
		_null,
	    0,
		a_user,
		_fecha
		);
}
		let _no_documento = _doc_suspenso;

		update cobpaex3
		   set secuencia = _secuencia
		 where no_recibo = _no_recibo_ancon;

	end if

	-- Comision descontada

	if _monto_comis > 0 then
		let _monto_descontado = _monto_comis;
	else
		let _monto_descontado = 0;
	end if

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
    _no_recibo_ancon,
    _no_documento,
    _tipo_mov,
    _monto,
    _prima,
    _impuesto,
    _monto_descontado,
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
	  WHERE no_poliza  = _no_poliza
--		and cod_agente = _cod_agente

		if _monto_descontado <> 0 then
			let _monto_calc = _prima * (_porc_partic / 100) * (_porc_comis / 100);
		else
			let _monto_calc = _monto_descontado;
		end if

		INSERT INTO cobreagt
		VALUES(
		a_no_remesa,
		_renglon,
		_cod_agente,
		_monto_calc,
		_monto_descontado,
		_porc_comis,
		_porc_partic
		);  
	  
	END FOREACH

	select sum(monto_calc)
	  into _monto_calc
	  from cobreagt
	 where no_remesa = a_no_remesa
	   and renglon   = _renglon;

	if _monto_calc is null then
		let _monto_calc = 0.00;
	end if

	update cobredet
	   set monto_descontado = _monto_calc
	 where no_remesa        = a_no_remesa
	   and renglon          = _renglon;

	let _comis_dif = _comis_dif + (_monto_calc - _monto_descontado);
	let _renglon   = _renglon + 1;

END FOREACH

-- Diferencia en el monto de la comision

if _comis_dif <> 0.00 then

	let _renglon  = _renglon + 1;
	LET _tipo_mov = 'C';

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
    _no_recibo_ancon,
    _cedula,
    _tipo_mov,
    _comis_dif,
    0.00,
    0.00,
    0.00,
    0,
    "COMISON DESCONTADA ...",
    0.00,
    _periodo,
    _fecha,
    0,
	_null
	);

end if

-- Comision de Cobro, Visa y Clave

select sum(comis_cobro + comis_visa + comis_clave)
  into _monto_comis
  from cobpaex1
 where numero = a_numero;

if _monto_comis <> 0 then
 
	let _renglon      = _renglon + 1;
	let _tipo_mov     = 'M';
	let _no_documento = "564020103";

	select cta_nombre
	  into _descripcion
	  from cglcuentas
	 where cta_cuenta = _no_documento;

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
	_no_recibo_ancon,
	_no_documento,
	_tipo_mov,
	_monto_comis,
	0.00,
	0.00,
	_monto_comis,
	0,
	_descripcion,
	0.00,
	_periodo,
	_fecha,
	0,
	_null
	);

end if

SELECT SUM(monto - monto_descontado)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;


{UPDATE cobpaex0
   SET insertado_remesa = 1
 WHERE numero           = a_numero;}

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 					 

END PROCEDURE;
