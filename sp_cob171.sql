-- Procedimiento que Genera la Remesa de los Pagos Externos

-- Creado    : 09/09/2004 - Autor: Armando Moreno
-- Modificado: 30/09/2004 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob171;

CREATE PROCEDURE "informix".sp_cob171(a_no_remesa CHAR(10)) 

define _monto_calc		dec(16,2);
define _monto_man		dec(16,2);
define _comis_dif		dec(16,2);
define _renglon			integer;
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _no_recibo		char(10);
define _tipo_mov		char(1);
define _periodo			char(7);
define _fecha			date;
define _cod_agente		char(10);
define _cedula			char(30);
define _comis_prima_sus	dec(16,2);
define _null			char(1);
define _saldo			dec(16,2);

let _null = null;

select cod_compania,
       cod_sucursal,
	   periodo,
	   fecha
  into _cod_compania,
       _cod_sucursal,          
	   _periodo,
	   _fecha
  from cobremae
 where no_remesa = a_no_remesa;

select no_recibo
  into _no_recibo
  from cobredet
 where no_remesa = a_no_remesa
   and renglon   = 1;

foreach
 select cod_agente
   into _cod_agente
   from cobreagt
  where no_remesa = a_no_remesa
	exit foreach;
end foreach

select cedula
  into _cedula
  from agtagent
 where cod_agente = _cod_agente;

select sum(monto_calc),
       sum(monto_man) 
  into _monto_calc,
       _monto_man
  from cobreagt
 where no_remesa = a_no_remesa;

let _comis_dif = _monto_calc - _monto_man;

select sum(saldo)
  into _comis_prima_sus
  from cobredet
 where no_remesa = a_no_remesa
   and tipo_mov  = "E";

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

{
if _comis_dif <> 0.00 then

	let _renglon = _renglon + 1;

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
    _cod_compania,
    _cod_sucursal,
    _no_recibo,
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
}
--{
if _comis_prima_sus <> 0.00 then

	let _renglon = _renglon + 1;

	LET _tipo_mov = 'M';

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
    _no_recibo,
    "26401",
    _tipo_mov,
    _comis_prima_sus,
    0.00,
    0.00,
    0.00,
    0,
    "AFECTACION CATALOGO ...",
    0.00,
    _periodo,
    _fecha,
    0,
	_null
	);

end if
--}
SELECT SUM(monto - monto_descontado)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;

end procedure