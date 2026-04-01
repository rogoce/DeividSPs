-- Procedimiento que Genera la Remesa de Creditos de Cuentas Especiales
-- 
-- Creado    : 03/10/2003 - Autor: Demetrio Hurtado Almanza
-- modificado: 03/10/2003 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob125;

CREATE PROCEDURE "informix".sp_cob125()
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
DEFINE a_no_remesa 		CHAR(10);
define _ano_char		char(4);
define _null			char(1);
define _comision		DEC(16,2);

define _cuenta			char(25);

define _dia				char(2);
define _mes				char(2);
define _ano				char(4);
define _estoy           char(50);

--set debug file to "sp_cob125.trc";
--trace on;

begin work;

BEGIN

ON EXCEPTION SET _error_code 
	rollback work;
 	RETURN _error_code, _estoy;         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

create temp table tmp_cuentas(
cuenta		char(25),
monto		dec(16,2),
comision	dec(16,2)
) with no log;

LET a_no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _null         = null;
let _cod_compania = "001";
let _cod_sucursal = "001";

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	rollback work;
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
END IF	

LET _fecha = "31/12/2007";
--LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

-- Numero de Comprobante

LET a_no_recibo = 'CD';	-- Comprobantes

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

LET _estoy = "COBREMAE";

INSERT INTO cobremae
VALUES(
a_no_remesa,
"001",
"001",
'005',
_null,
"ACTUALIZACION SALDOS CREDITOS",
'C',
_fecha,
0,
3,
0.00,
0,
_periodo,
"GERENCIA",
_fecha,
"GERENCIA",
_fecha,
1
);

-- Inicializar Tablas

DELETE FROM cobreagt
 WHERE no_remesa = a_no_remesa;

DELETE FROM cobredet
 WHERE no_remesa = a_no_remesa;

LET _nombre_agente = "";
LET _cod_agente    = "00099";

SELECT nombre
  INTO _nombre_agente
  FROM agtagent
 WHERE cod_agente = _cod_agente;

LET _renglon = 0;

FOREACH
 SELECT poliza,
        saldo
   INTO _no_documento,
        _saldo
   FROM deivid_tmp:psc0712b

	-- Poliza en Credito

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then
		rollback work;
		RETURN 1, "Este Numero de Poliza No Existe " || _no_documento;
	end if

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

{	update emipomae
	   set cobra_poliza = "G"
	 where no_poliza    = _no_poliza;
}
	LET _renglon = _renglon + 1;

	-- Tipo de Movimiento
	IF _saldo > 0 THEN
		LET _tipo_mov = 'P';
	ELSE
		LET _tipo_mov = 'N';
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
	LET _prima    = _saldo / _factor;
	LET _impuesto = _saldo - _prima;
	
	-- Descripcion de la Remesa
	
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);

	-- Detalle de la Remesa
    LET _estoy = "COBREDET " || _no_poliza || " " || _no_documento;

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
    0.00,
    _periodo,
    _fecha,
    0,
	_no_poliza
	);

  	LET _estoy = "cobreagt " || _no_documento;

   foreach	
	select porc_partic_agt,
	       porc_comis_agt
	  into _porc_partic,
		   _porc_comis
	  from emipoagt
	 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	let _comision = _prima * _porc_partic / 100 * _porc_comis / 100;

	INSERT INTO cobreagt
	VALUES(
	a_no_remesa,
	_renglon,
	_cod_agente,
	_comision,
	_comision,
	_porc_comis,
	_porc_partic
	);  
	  
	let _cuenta  = sp_sis15('CGSALCRE', '01', _no_poliza); 

	insert into tmp_cuentas
	values (_cuenta, _saldo - _comision, _comision);

END FOREACH

let _tipo_mov = "M";

foreach
 select cuenta,
        sum(monto)
   into _no_documento,
        _comision
   from tmp_cuentas
  group by 1
  order by 1

	let _renglon  = _renglon  + 1;
	let _comision = _comision * -1;

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
	_cod_compania,
	_cod_sucursal,
	a_no_recibo,
	_no_documento,
	_tipo_mov,
	_comision,
	0.00,
	0.00,
	0,
	0,
	_descripcion,
	0.00,
	_periodo,
	_fecha,
	0,
	null
	);

end foreach

let _tipo_mov = "M";

select sum(comision)
  into _comision
  from tmp_cuentas;

let _no_documento = sp_sis15('PPCOMXPCO', '01', _no_poliza); 
let _renglon      = _renglon  + 1;
let _comision     = _comision * -1;

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
_cod_compania,
_cod_sucursal,
a_no_recibo,
_no_documento,
_tipo_mov,
_comision,
0.00,
0.00,
0,
0,
_descripcion,
0.00,
_periodo,
_fecha,
0,
null
);

drop table tmp_cuentas; 
 
commit work;

RETURN 0, "Actualizacion Exitosa, Remesa # " || a_no_remesa;

END

END PROCEDURE;
