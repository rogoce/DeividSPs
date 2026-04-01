-- - Procedimiento que Genera el Archivo para las comisiones automaticas de Ducruet

-- - Creado    : 31/08/2005 - Autor: Demetrio Hurtado Almanza 

-- - SIS v.2.0 - sp_che05 - DEIVID, S.A.

drop procedure sp_che28;

create procedure "informix".sp_che28(
a_fecha_desde    date,
a_fecha_hasta    date
)

define _no_registro		char(10);
define _cod_agente		char(5);
define _no_licencia		char(10);
define _cod_compania	char(4);

define _dia				char(2);
define _mes				char(2);
define _ano				char(4);
define _valor			smallint;
define _fecha_desde		char(10);
define _fecha_hasta		char(10);

define _secuencia		integer;
define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _nombre_cliente	char(100);
define _lugar_cobro		char(1);

define _prima_pagada	dec(16,2);
define _neto_pagado		dec(16,2);
define _porc_comision	dec(8,5);
define _comis_monto		dec(16,2);
define _comis_descont	dec(16,2);
define _comis_neta		dec(16,2);
define _no_recibo		char(10);

define _total_prima		dec(16,2);
define _total_comision	dec(16,2);
define _total_descont	dec(16,2);

define _vigen_inic_date	date;
define _vigen_fin_date	date;
define _vigen_inic_char	char(10);
define _vigen_fin_char	char(10);

set isolation to dirty read;

let _cod_agente    = "00035";
let _cod_compania  = "0007";
let _lugar_cobro   = "A";
let _comis_descont = 0.00;
let _no_registro   = sp_sis13("001", 'CHE', '02', 'com_rem_ducruet');

update parparam
   set che_reg_ducruet = _no_registro
 where cod_compania    = "001";
    
-- Fecha Desde
let _valor = day(a_fecha_desde);

if _valor < 10 then
	let _dia = "0" || _valor;
else 
	let _dia = _valor;
end if

let _valor = month(a_fecha_desde);

if _valor < 10 then
	let _mes = "0" || _valor;
else 
	let _mes = _valor;
end if

let _ano = year(a_fecha_desde);

let _fecha_desde = _mes || "/" || _dia || "/" || _ano;

-- Fecha Hasta
let _valor = day(a_fecha_hasta);

if _valor < 10 then
	let _dia = "0" || _valor;
else 
	let _dia = _valor;
end if

let _valor = month(a_fecha_hasta);

if _valor < 10 then
	let _mes = "0" || _valor;
else 
	let _mes = _valor;
end if

let _ano = year(a_fecha_hasta);

let _fecha_hasta = _mes || "/" || _dia || "/" || _ano;

-- Detalle del corredor
select no_licencia
  into _no_licencia
  from agtagent
 where cod_agente = _cod_agente;

insert into checomen(
no_registro,
cod_compania,
periodo_desde,
periodo_hasta,
total_prima,
total_comision,
total_descontada,
no_cheque,
cant_detalle,
no_licencia
)
values(
_no_registro,
_cod_compania,
_fecha_desde,
_fecha_hasta,
0.00,
0.00,
0.00,
0,
0,
_no_licencia
);

let _secuencia      = 0;
let _total_prima    = 0.00;
let _total_comision = 0.00;
let _total_descont  = 0.00;

foreach
 select no_documento,
        monto,
		prima,
		porc_comis,
		comision,
		no_recibo,
		no_poliza
   into	_no_documento,
		_prima_pagada,
		_neto_pagado,
		_porc_comision,
		_comis_monto,
		_no_recibo,
		_no_poliza
   from tmp_agente
  where cod_agente = _cod_agente
  ORDER BY no_recibo, no_documento

	let _secuencia = _secuencia + 1;

	if _no_poliza = "00000" then
		
		let _nombre_cliente  = "COMISION DESCONTADA";
		let _vigen_inic_char = "";
		let _vigen_fin_char  = "";
		 
	else

		select cod_contratante,
		       vigencia_inic,
			   vigencia_final
		  into _cod_cliente,
			   _vigen_inic_date,
			   _vigen_fin_date
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;

		let _vigen_inic_char = sp_sis85(_vigen_inic_date);
		let _vigen_fin_char  = sp_sis85(_vigen_fin_date);

	end if

	let _comis_neta     = _comis_monto    - _comis_descont;
	let _total_prima    = _total_prima    + _prima_pagada;
	let _total_comision = _total_comision + _comis_monto;
	let _total_descont  = _total_descont  + _comis_descont;

	let _no_documento = sp_che36(_no_documento); -- Cambiar Numero de poliza para Ducruet

	insert into checomde(
	no_registro,
	secuencia,
	no_documento,
	cliente,
	lugar_cobro,
	prima_pagada,
	neto_pagado,
	porc_comision,
	comis_monto,
	comis_descontada,
	comis_neta,
	no_recibo,
	no_recibo_aa,
	vigencia_inic,
	vigencia_fin	
	)
	values(
	_no_registro,
	_secuencia,
	_no_documento,
	_nombre_cliente,
	_lugar_cobro,
	_prima_pagada,
	_neto_pagado,
	_porc_comision,
	_comis_monto,
	_comis_descont,
	_comis_neta,
	_no_recibo,
	_no_recibo,
	_vigen_inic_char,
	_vigen_fin_char
	);

end foreach

update checomen
   set total_prima		= _total_prima,
	   total_comision	= _total_comision,
	   total_descontada	= _total_descont,
	   cant_detalle     = _secuencia
 where no_registro      = _no_registro;

end procedure