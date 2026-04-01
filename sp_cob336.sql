-- Procedimiento que Genera la Remesa de las Primas en Suspenso con Polizas ya Creadas
-- Creado    : 28/10/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob336;

create procedure "informix".sp_cob336()
returning smallint,char(100),char(10);

define _descripcion			char(100);
define _mensaje				char(100);
define _error_desc			char(50);
define _doc_remesa			char(30);
define _no_documento		char(21);
define _no_remesa			char(10);
define _cod_agente			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_endomov			char(3);
define _no_pagos			dec(16,2);
define _diferencia			dec(16,2);
define _monto_ult_factura	dec(16,2);
define _monto_descontado	dec(16,2);
define _monto_facturado		dec(16,2);
define _monto_devuelto		dec(16,2);
define _monto_cobrado		dec(16,2);
define _monto_pagado		dec(16,2);
define _monto_endoso		dec(16,2);
define _monto				dec(16,2);
define _cant_endosos		smallint;
define _cnt					smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;
define _fecha				date;

--set debug file to "sp_cob336.trc"; 
--trace on;

set isolation to dirty read;

begin
on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc, _error_isam;         
end exception

create temp table temp_facturas
	(cod_endoso		smallint,
	no_documento	char(20),
	no_poliza		char(10),
	no_endoso		char(5),
	cod_endomov		char(3),
	monto_endoso	dec(16,2),
	no_remesa		char(10),
	renglon			smallint,
	monto_cobrado	dec(16,2),
	cod_formapag	char(3),
primary key(no_poliza,no_endoso)) with no log;

create temp table temp_det
	(no_poliza			char(10),
	no_endoso			char(5),
	monto_endoso		dec(16,2),
	monto_cobrado		dec(16,2),
	total_cobrado		dec(16,2),
	total_facturado		dec(16,2),
	diferencia			dec(16,2),
	no_facturas			smallint,
	no_pagos_cubiertos	smallint,
primary key(no_poliza,no_endoso)) with no log;

foreach
	select d.no_remesa,
		   d.renglon,
		   d.monto,
		   e.no_poliza
	  into _no_remesa,
		   _renglon,
		   _monto,
		   _no_poliza
	  from cobredet d, emipomae e
	 where e.no_poliza = d.no_poliza
	   and d.no_remesa in ('773575','773333','773508')
	   and e.cod_ramo in ('018')--('016','018','019')
	 order by no_remesa,renglon

	let _monto_cobrado = 0.00;

	select sum(monto)
	  into _monto_cobrado
	  from cobredet
	 where no_poliza = _no_poliza
	   and tipo_mov in ('P','N','X')
	   and no_remesa <> _no_remesa;
	   
	let _monto_descontado = 0.00;	

	select sum(prima_bruta * -1)
	  into _monto_descontado
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov in ('024','006');
	
	if _monto_descontado is null then
		let _monto_descontado = 0.00;
	end if

	let _cnt = 0;

	foreach
		select no_documento,
			   no_endoso,
			   cod_endomov,
			   cod_formapag,
			   prima_bruta
		  into _no_documento,
			   _no_endoso,
			   _cod_endomov,
			   _cod_formapag,
			   _monto_endoso
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov in ('011','014')
		 order by no_endoso

		let _cnt = _cnt + 1;

		insert into temp_facturas
		values	(_cnt,
				_no_documento,
				_no_poliza,
				_no_endoso,
				_cod_endomov,
				_monto_endoso,
				_no_remesa,
				_renglon,
				_monto,
				_cod_formapag);
	end foreach
	
	let _monto_devuelto = 0.00;
	
	select sum(monto)
	  into _monto_devuelto
	  from chqchpol
	 where no_poliza = _no_poliza;

	if _monto_devuelto is null then
		let _monto_devuelto = 0.00;
	end if

	let _monto_pagado = 0.00;
	let _monto_pagado = _monto_cobrado + _monto_descontado - _monto_devuelto;
	let _monto_cobrado = 0.00;
	
	select sum(monto_endoso),
		   max(cod_endoso)
	  into _monto_facturado,
		   _cant_endosos
	  from temp_facturas
	 where no_poliza = _no_poliza;

	select no_endoso,
		   monto_endoso
	  into _no_endoso,
		   _monto_ult_factura
	  from temp_facturas
	 where no_poliza = _no_poliza
	   and cod_endoso = _cant_endosos;
	
	select sum(monto)
	  into _monto_cobrado
	  from cobredet
	 where no_poliza = _no_poliza
	   and tipo_mov in ('P','N','X')
	   and no_remesa = _no_remesa;
	
	let _diferencia = _monto_facturado - _monto_pagado;
	let _no_pagos = _monto_pagado / _monto_facturado;
	
	insert into temp_det(
			no_poliza,
			no_endoso,
			monto_endoso,
			monto_cobrado,
			total_cobrado,
			total_facturado,
			diferencia,
			no_facturas,
			no_pagos_cubiertos)
	values	(_no_poliza,
			_no_endoso,
			_monto_ult_factura,
			_monto_cobrado,
			_monto_pagado,
			_monto_facturado,
			_diferencia,
			_cant_endosos,
			_no_pagos);
end foreach
end
end procedure 