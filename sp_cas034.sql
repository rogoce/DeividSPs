-- Metas del Call Center
-- Creado    : 19/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/06/2003 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas034;
create procedure sp_cas034(
a_compania	char(3), 
a_agencia 	char(3),
a_periodo	char(7))
returning	char(10),
            dec(16,2),
		    smallint,
		    dec(16,2),
		    smallint,
		    char(3),
		    char(50),
		    char(50),
		    dec(16,2),
		    dec(16,2),
		    smallint;

define _nombre_cobrador	varchar(50);
define _nombre_compania	varchar(50);
define _doc_poliza		char(20);
define _cod_cliente		char(10);
define _cod_cobrador	char(3);
define _cod_cob_ant		char(3);
define _monto_pagado	dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_180		dec(16,2);
define _monto_150		dec(16,2);
define _monto_120		dec(16,2);
define _monto_90		dec(16,2);
define _monto_60		dec(16,2);
define _monto_30		dec(16,2);
define _saldo			dec(16,2);
define _monto			dec(16,2);
define _cant_pagar_min	smallint;
define _tipo_cobrador	smallint;
define _cant_pagar		smallint;
define _cant_pagos		smallint;
define a_fecha			date;

set isolation to dirty read;

create temp table tmp_metcall(
cod_cliente	char(10),
meta		dec(16,2),
cobrado		dec(16,2),
saldo		dec(16,2),
meta_min	dec(16,2)) with no log;

let _nombre_compania = sp_sis01(a_compania);
let a_fecha = sp_sis36(a_periodo);

foreach
	select no_documento,
		   cod_cliente
	  into _doc_poliza,
		   _cod_cliente
	  from caspoliza
--  where no_documento = "0299-01882-01"

	{call sp_cas035(a_compania,a_agencia,_doc_poliza,a_periodo,a_fecha)
	returning	_por_vencer,       
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_saldo;}
	call sp_cob398(_doc_poliza, a_periodo,a_fecha,1,0)
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;

	let _monto_90 = _monto_90 + _monto_120 + _monto_150 + _monto_180;

	if _corriente < 0.00 then
		let _corriente = 0.00;
	end if

	if _exigible < 0.00 then
		let _exigible = 0.00;
	end if

	if _monto_90 < 0.00 then
		let _monto_90 = 0.00;
	end if

	let _exigible = _monto_90;

	let _monto_pagado = 0.00;

	foreach
		select monto
		  into _monto
		  from cobredet
		 where doc_remesa   = _doc_poliza
		   and actualizado  = 1
		   and tipo_mov     IN ('P', 'N')
		   and periodo      = a_periodo
		   
		let _monto_pagado = _monto_pagado + _monto;
	end foreach

	insert into tmp_metcall
	values(	_cod_cliente,
			_exigible,
			_monto_pagado,
			_saldo,
			_corriente);
end foreach

foreach 
	select cod_cliente,
		   sum(meta),
		   sum(cobrado),
		   sum(saldo),
		   sum(meta_min)
	  into _cod_cliente,
		   _exigible,
		   _monto_pagado,
		   _saldo,
		   _corriente
	  from tmp_metcall
	 group by 1
	 order by 1

	if _exigible = 0.00 then
		let _cant_pagar = 0;
	else
		let _cant_pagar = 1;
	end if

	if _corriente = 0.00 then
		let _cant_pagar_min = 0;
	else
		let _cant_pagar_min = 1;
	end if

	if _monto_pagado = 0.00 then
		let _cant_pagos = 0;
	else
		let _cant_pagos = 1;
	end if

	select cod_cobrador,
		   cod_cobrador_ant	
	  into _cod_cobrador,
	       _cod_cob_ant
	  from cascliente
	 where cod_cliente = _cod_cliente;

	select nombre,
	       tipo_cobrador
	  into _nombre_cobrador,
	       _tipo_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	if _tipo_cobrador <> 1 then

		select nombre
		  into _nombre_cobrador
		  from cobcobra
		 where cod_cobrador = _cod_cob_ant;

		let _cod_cobrador = _cod_cob_ant;		
	end if

	return _cod_cliente,
	       _exigible,
		   _cant_pagar,
		   _monto_pagado,
		   _cant_pagos,
		   _cod_cobrador,
		   _nombre_cobrador,
		   _nombre_compania,
		   _saldo,
		   _corriente,
		   _cant_pagar_min
		   with resume;
end foreach

drop table tmp_metcall;
end procedure;