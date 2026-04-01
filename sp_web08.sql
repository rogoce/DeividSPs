  -- Procedimiento que Genera la Remesa para Aplicar recibo Automatico para una poliza SODA

-- Creado    : 07/09/2011 - Autor: Federico
-- Modificado: 07/09/2011 - Autor: Federico

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web08;

CREATE PROCEDURE "informix".sp_web08(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_monto         decimal(16,2),
a_no_recibo     char(10),
a_no_documento  CHAR(20)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;
DEFINE _saldo        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10);
DEFINE _cod_contratante	CHAR(10);
DEFINE _doc_remesa    	CHAR(30);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _periodo_hoy		CHAR(7);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE _cant	      	INTEGER;
DEFINE _mensaje         CHAR(100);
--define a_no_recibo		char(10);

define _caja_caja		char(3);
define _caja_comp		char(3);

{SET DEBUG FILE TO "sp_cob50a.trc"; 
TRACE ON;}

SET ISOLATION TO DIRTY READ;

--begin work;

BEGIN

ON EXCEPTION SET _error_code
 	RETURN _error_code, 'Error al Actualizar la Remesa', '';         
END EXCEPTION

LET _null       = NULL;
LET a_no_remesa = '1';  
Let _doc_remesa = _null;

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	
/*
LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF
*/
let _fecha = today;
/*
if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if
*/
select cob_periodo
  into _periodo
  from deivid:parparam;
  
  call sp_sis39(_fecha) RETURNING _periodo_hoy;
    --ultimo dia del mes del periodo
  if _periodo <> _periodo_hoy then
		if _periodo < _periodo_hoy then
			CALL sp_sis36(_periodo) RETURNING _fecha;
		else
			CALL sp_sis36bk(_periodo) RETURNING _fecha;
		end if
  end if



-- Insertar el Maestro de Remesas

--call sp_cob224() returning _caja_caja, _caja_comp;
LET _caja_caja = '146';
LET _caja_comp = '035';


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
cod_chequera
)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
_caja_caja,
'232',
_null,
'C',   --averiguar
_fecha,
0,
2,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha,
_caja_comp
);

--***PAGO DE PRIMA***

-- Impuestos de la Poliza

LET _no_poliza = sp_sis21(a_no_documento);

SELECT SUM(saldo)
  INTO _saldo
  FROM emipomae
 WHERE no_documento = a_no_documento
   AND actualizado  = 1;

IF _saldo IS NULL THEN
	LET _saldo = 0;
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
LET _prima    = a_monto / _factor;
LET _impuesto = a_monto - _prima;

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

select cod_contratante
  into _cod_contratante
  from emipomae
 where no_poliza = _no_poliza;

select nombre
  into _nombre_cliente
  from cliclien
 where cod_cliente = _cod_contratante;			

LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);

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
1,
a_compania,
a_sucursal,
a_no_recibo,
a_no_documento,
"P",
a_monto,
_prima,
_impuesto,
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

		INSERT INTO cobreagt(
	        no_remesa,
		renglon,
		cod_agente,
		monto_calc,
		monto_man,
		porc_comis_agt,
		porc_partic_agt
		)
		VALUES(
		a_no_remesa,
		1,
		_cod_agente,
		0,
		0,
		_porc_comis,
		_porc_partic
		);
END FOREACH

SELECT SUM(monto)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;


--Actualizacion de Remesa

call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

if _error_code <> 0 then
	return _error_code, _mensaje, a_no_remesa;
end if

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;