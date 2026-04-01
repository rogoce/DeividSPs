-- - Procedimiento que Genera el Archivo para las comisiones automaticas de General Representatives

-- Creado    : 17/04/2013	- Autor: Roman Gordon

drop procedure sp_che140;

create procedure "informix".sp_che140(a_no_registro char(10))
returning date,				--_fecha_apertura,
		  date,				--_fecha_cierre,
		  char(20),			--_no_documento,
		  varchar(100),		--_nombre_cliente,
		  char(10),			--_no_recibo,
		  date,				--_fecha_pago,
		  dec(16,2),		--_neto_pagado,
		  dec(16,2),		--_prima_pagada,
		  dec(8,5),			--_porc_comision,
		  dec(16,2),		--_comis_monto,
		  dec(16,2);		--_saldo 	

define _nombre_cliente		char(100);
define _no_documento		char(20);
define _no_remesa_ancon		char(10);
define _vigen_inic_char		char(10);
define _vigen_fin_char		char(10);
define _no_recibo_a			char(10);
define _no_licencia			char(10);
define _fecha_desde			char(10);
define _fecha_hasta			char(10);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente2			char(5);
define _cod_agente			char(5);
define _cod_compania		char(4);
define _ano_char			char(4);
define _mes_char			char(2);
define _lugar_cobro			char(1);
define _porc_comision		dec(8,5);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _prima_pagada		dec(16,2);
define _neto_pagado			dec(16,2);
define _comis_monto			dec(16,2);
define _comis_neta			dec(16,2);
define _secuencia			integer;
define _fecha_apertura		date;
define _fecha_cierre		date;
define _fecha_pago			date;
define _fecha				date;

--set debug file to "sp_che140.txt";
--trace on;


set isolation to dirty read;

let _fecha = current;

if month(_fecha) < 10 then
	let _mes_char = '0'|| month(_fecha);
else
	let _mes_char = month(_fecha);
end if

let _ano_char = year(_fecha);
let _periodo  = _ano_char || "-" || _mes_char;

select periodo_desde,
	   periodo_hasta
  into _fecha_apertura,
	   _fecha_cierre
  from checomen
 where no_registro = a_no_registro;

foreach
	select secuencia,
		   no_documento,
		   cliente,
		   prima_pagada,
		   neto_pagado,
		   porc_comision,
		   comis_monto,
		   no_recibo,
		   no_recibo_aa
	  into _secuencia,
		   _no_documento,
		   _nombre_cliente,
		   _prima_pagada,
		   _neto_pagado,
		   _porc_comision,
		   _comis_monto,
		   _no_remesa_ancon,
		   _no_recibo
	  from checomde
	 where no_registro = a_no_registro
	
	foreach
		select fecha
		  into _fecha_pago
		  from cobredet
		 where no_recibo	= _no_recibo
		   and doc_remesa	= _no_documento
		exit foreach;
	end foreach
	
	call sp_cob245(
		 "001",
		 "001",	
		 _no_documento,
		 _periodo,
		 _fecha
		 ) returning _por_vencer,      
					 _exigible,         
					 _corriente,        
					 _monto_30,         
					 _monto_60,         
					 _monto_90,
					 _monto_120,
					 _monto_150,
					 _monto_180,
					 _saldo;
	
	return _fecha_apertura,
		   _fecha_cierre,
		   _no_documento,
		   _nombre_cliente,
		   _no_recibo,
		   _fecha_pago,
		   _neto_pagado,
		   _prima_pagada,
		   _porc_comision,
		   _comis_monto,
		   _saldo 
		   with resume;		   
end foreach 
end procedure