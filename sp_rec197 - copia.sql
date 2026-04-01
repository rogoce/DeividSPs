-- Procedimiento que Genera el Recibo de Pago de los Movimientos de Reclamos de Primas Pendientes

-- Creado    : 24/07/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec197;

create procedure "informix".sp_rec197(a_no_tranrec char(10))
returning smallint,
          char(100);

define _saldo        	dec(16,2);
define _monto        	dec(16,2);
define _no_poliza    	char(10);
define _cod_contratante	char(10);
define _doc_remesa    	char(30);
define _fecha			date;
define _periodo			char(7);
define _factor			dec(16,2);
define _prima			dec(16,2);
define _impuesto		dec(16,2);
define _nombre_cliente 	char(50);
define _nombre_agente 	char(50);
define _descripcion   	char(100);
define _cod_agente   	char(10);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _null            char(1);
define _ano_char        char(4);
define _cant	      	integer;

define _recibo_tmp		char(20);

define _caja_caja		char(3);
define _caja_comp		char(3);

define a_no_remesa      char(10);
define a_no_recibo      char(20);
define a_user			char(8);
define a_compania		char(3);
define a_sucursal		char(3);
define a_no_documento  	char(20);

define _no_reclamo		char(10);

define _error_code      integer;
define _error_isam      integer;
define _error_desc		char(100);

--SET DEBUG FILE TO "sp_rec197.trc"; 
--TRACE ON;

set isolation to dirty read;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;         
end exception

select sum(r.monto)
  into _monto
  from rectrmae t, rectrcon r, recconce c
 where t.no_tranrec    = r.no_tranrec
   and r.cod_concepto  = c.cod_concepto
   and t.no_tranrec    = a_no_tranrec
   and c.genera_recibo = 1
   and r.monto         <> 0;

if _monto >= 0 or _monto is null then
	return 0, 'Actualizacion Exitosa, Remesa # ' || "00000"; 
end if

select transaccion,
       user_added,
       cod_compania,
       cod_sucursal,
       no_reclamo 
  into a_no_recibo,
       a_user,
	   a_compania,
	   a_sucursal,
	   _no_reclamo
  from rectrmae
 where no_tranrec = a_no_tranrec;

select no_poliza
  into _no_poliza
  from recrcmae
 where no_reclamo = _no_reclamo;

select no_documento
  into a_no_documento
  from emipomae
 where no_poliza = _no_poliza;

let _null       = null;
let a_no_remesa = '1';  
let a_no_recibo = trim(a_no_recibo);
let _doc_remesa = _null;

let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
end if	

LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

-- Insertar el Maestro de Remesas

call sp_cob224() returning _caja_caja, _caja_comp;

-- Pago de Prima

let _monto = _monto * -1;

select sum(saldo)
  into _saldo
  from emipomae
 where no_documento = a_no_documento
   and actualizado  = 1;

if _saldo is null then
	let _saldo = 0;
end if

select sum(i.factor_impuesto)
  into _factor
  from prdimpue i, emipolim p
 where i.cod_impuesto = p.cod_impuesto
   and p.no_poliza    = _no_poliza;

if _factor is null then
	let _factor = 0;
end if

let _factor   = 1 + _factor / 100;
let _prima    = _monto / _factor;
let _impuesto = _monto - _prima;

-- Descripcion de la Remesa

let _nombre_agente = "";

foreach
 select cod_agente
   into _cod_agente
   from emipoagt
  where no_poliza = _no_poliza

	select nombre
  	  into _nombre_agente
  	  from agtagent
 	 where cod_agente = _cod_agente;

	exit foreach;

end foreach

select cod_contratante
  into _cod_contratante
  from emipomae
 where no_poliza = _no_poliza;

select nombre
  into _nombre_cliente
  from cliclien
 where cod_cliente = _cod_contratante;			

LET _descripcion = TRIM(_nombre_cliente) || " / " || TRIM(_nombre_agente);

insert into cobremae(
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
_null,
_nombre_cliente,
'C',
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
_monto,
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

foreach
 select	cod_agente,
	    porc_partic_agt,
	    porc_comis_agt
   into	_cod_agente,
    	_porc_partic,
	    _porc_comis
   from	emipoagt
  where no_poliza = _no_poliza

	insert into cobreagt(
	no_remesa,
	renglon,
	cod_agente,
	monto_calc,
	monto_man,
	porc_comis_agt,
	porc_partic_agt
	)
	values(
	a_no_remesa,
	1,
	_cod_agente,
	0,
	0,
	_porc_comis,
	_porc_partic
	);

end foreach

select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = a_no_remesa;

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = a_no_remesa;

-- Actualizacion de Remesa

call sp_cob29(a_no_remesa, a_user) returning _error_code, _error_desc;

if _error_code <> 0 then
  	return _error_code, _error_desc || " " || a_no_remesa;
end if

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa; 

end 

end procedure;