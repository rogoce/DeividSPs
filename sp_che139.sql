-- - Procedimiento que Genera el Archivo para las comisiones automaticas de General Representatives

-- Creado    : 17/04/2013	- Autor: Roman Gordon

drop procedure sp_che139;

create procedure "informix".sp_che139(
a_fecha_desde    date,
a_fecha_hasta    date
) --returning integer,char(100);

define _nombre_cliente		char(100);
define _error_desc			char(100);
define _no_documento		char(20);
define _no_remesa_ancon		char(10);
define _vigen_inic_char		char(10);
define _vigen_fin_char		char(10);
define _no_recibo_a			char(10);
define _no_registro			char(10);
define _no_licencia			char(10);
define _fecha_desde			char(10);
define _fecha_hasta			char(10);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_agente2			char(5);
define _cod_agente			char(5);
define _cod_compania		char(4);
define _ano					char(4);
define _dia					char(2);
define _mes					char(2);
define _lugar_cobro			char(1);
define _porc_comision		dec(8,5);
define _comision_adelanto	dec(16,2);
define _total_comision		dec(16,2);
define _total_descont		dec(16,2);
define _comis_descont		dec(16,2);
define _prima_pagada		dec(16,2);
define _total_prima			dec(16,2);
define _neto_pagado			dec(16,2);
define _comis_monto			dec(16,2);
define _comis_neta			dec(16,2);
define _cnt_existe			smallint;
define _valor				smallint;
define _error				smallint;
define _error_isam			integer;
define _secuencia			integer;
define _vigen_inic_date		date;
define _vigen_fin_date		date;

--set debug file to "sp_che139.txt";
--trace on;

begin 
{on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception}
set isolation to dirty read;

{CALL sp_che02(
'001', 
'001',
a_fecha_desde,
a_fecha_hasta,
1
);}

--set debug file to "sp_che139.trc";
--trace on;
let _comis_descont	= 0.00;
let _cod_compania	= "0161";
let _lugar_cobro	= "A";
let _cod_agente		= "00161";
let _no_registro	= sp_sis13("001", 'CHE', '02', 'com_rem_ducruet');

update parparam
   set che_reg_genrep = _no_registro
 where cod_compania    = "001";
    
-- Fecha Desde
let _fecha_desde = 	sp_sis85(a_fecha_desde);


-- Fecha Hasta
let _fecha_hasta = 	sp_sis85(a_fecha_hasta);

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
	  into _no_documento,
		   _prima_pagada,
		   _neto_pagado,
		   _porc_comision,
		   _comis_monto,
		   _no_recibo,
		   _no_poliza
	  from tmp_agente
	 where cod_agente in (_cod_agente)
	 order by no_recibo, no_documento

	select no_remesa
	  into _no_remesa_ancon
	  from cobpaex0
	 where cod_agente      = _cod_agente
	   and no_recibo_ancon = _no_recibo; 

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
		
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where no_documento = _no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe > 0 then
			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
			  	   _no_recibo_a
			  from cobadeco
			 where cod_agente	= _cod_agente
			   and no_documento = _no_documento;

			if _no_recibo = _no_recibo_a then
				let _comis_monto = _comision_adelanto;
			else
				let _comis_monto = 0.00;
			end if
		end if
	end if

	let _comis_neta     = _comis_monto    - _comis_descont;
	let _total_prima    = _total_prima    + _prima_pagada;
	let _total_comision = _total_comision + _comis_monto;
	let _total_descont  = _total_descont  + _comis_descont;
	
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
    _no_remesa_ancon,
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


--return 0,'';
end  
end procedure