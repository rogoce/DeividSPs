-- Procedimiento que Genera la Remesa de los Centavos.
-- 
-- Creado    : 25/05/2010 - Autor: Armando Moreno
-- modificado: 26/05/2010 - Autor: Armando Moreno
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob42d;

CREATE PROCEDURE "informix".sp_cob42d(a_no_remesa CHAR(10), a_user char(8))
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
DEFINE _ano_char        CHAR(4);
DEFINE _valor           integer;
DEFINE _valor_msg       CHAR(50);

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Ajustes de Centavos';         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

LET _fecha = current;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

let _cod_compania = "001";
let _cod_sucursal = "001";

let a_no_remesa = sp_sis13(_cod_compania, 'COB', '02', 'par_no_remesa');

--set debug file to "sp_cob42d.trc";
--trace on;


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
date_posteo,
cod_chequera)
VALUES(
a_no_remesa,
'001',
'001',
'146',
null,
null,
'T',
_fecha,
0,
3,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha,
'023'
);

LET a_no_recibo = 'CONT';

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

LET _renglon = 1;

let _tipo_mov = "X";
let _no_documento = sp_sis15('INGVAR'); --7000204
let _no_documento = trim(_no_documento);

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
"M",
0,
0,
0,
0,
0,
"INGRESOS VARIOS",
0,
_periodo,
_fecha,
0,
null
);

-- Inicializar Tablas

DELETE FROM cobreagt
 WHERE no_remesa = a_no_remesa;

DELETE FROM cobredet
 WHERE no_remesa = a_no_remesa
   AND renglon  <> 1;

FOREACH

 SELECT	no_documento
   INTO	_no_documento
   FROM	emipoliza

	let _saldo = sp_cob175(_no_documento, _periodo);

	if _saldo = 0.00 then
		continue foreach;
	end if

	if abs(_saldo) > 0.99 then --Se modificó de 2.00 a 0.99 por solicitud de Enilda --05/07/2018
		continue foreach;
	end if

	LET _renglon = _renglon + 1;

  	IF _renglon > 15000 THEN  
  		EXIT FOREACH;      
  	END IF                 

	let _no_poliza = sp_sis21(_no_documento);

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

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
	LET _impuesto = _saldo - _prima;

	-- Descripcion de la Remesa
	
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

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
    _impuesto,
    0,
    0,
    _descripcion,
    0,
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
		_porc_partic,
		0
		);  
	  
	END FOREACH
	 	
END FOREACH

CALL sp_cob42c(a_no_remesa) RETURNING _valor,_valor_msg;

RETURN 0, "Actualizacion Exitosa... Remesa: " || a_no_remesa;

END

END PROCEDURE;
