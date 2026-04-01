-- Procedimiento que genera la información de pólizas canceladas/anuladas y que estan en saldo crédito
-- Creado    : 23/05/2018 -- Román Gordón
-- execute procedure sp_sis240(today)

drop procedure sp_sis240;
create procedure sp_sis240(a_fecha_cancelacion date)
returning	char(20)	as poliza,
			varchar(50)	as contratante,
			date		as vigencia_inic,
			date		as vigencia_final,
			varchar(50) as ramo,
			varchar(50) as forma_pago,
			varchar(50) as zona_cobros,
			varchar(50) as tipo_cancelacion,
			date		as fecha_cancelacion,
			dec(16,2)	as saldo,
			date		as ult_fecha_cobro,
			dec(16,2)	as monto_cobrado;

define _tipo_cancelacion	varchar(50);
define _nom_contratante		varchar(50);
define _descripcion			varchar(50);
define _zona_cobros			varchar(50);
define _forma_pago			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _monto_cobrado		dec(16,2);
define _saldo				dec(16,2);
define _error_isam			smallint;
define _error				smallint;
define _fecha_cancelacion	date;
define _ult_fecha_cobro		date;
define _vigencia_final		date;
define _vigencia_inic		date;


set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return	'',
			_descripcion,
			null,
			null,
			'',
			'',
			'',
			'',
			null,
			_error,
			null,
			0.00;
end exception

--set debug file to "sp_sis240.trc";    BG17111708  
--trace on;

foreach
	select e.no_poliza,
		   e.no_documento,
		   c.nombre,
		   e.vigencia_inic,
		   e.vigencia_final,
		   r.nombre,
		   f.nombre,
		   z.nombre,
		   p.saldo
	  into _no_poliza,
		   _no_documento,
		   _nom_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_ramo,
		   _forma_pago,
		   _zona_cobros,
		   _saldo
	  from emipomae e, emipoliza p,cliclien c,prdramo r, cobforpa f,cobcobra z
	 where e.no_documento = p.no_documento
	   and e.cod_pagador = c.cod_cliente
	   and e.cod_ramo = r.cod_ramo
	   and e.cod_formapag = f.cod_formapag
	   and p.cod_zona = z.cod_cobrador
	   and e.estatus_poliza in (2,4)
	   and p.saldo < -1
	   and actualizado = 1
	 order by p.saldo

	foreach
		select c.nombre,
			   fecha_emision
		  into _tipo_cancelacion,
			   _fecha_cancelacion
		  from endedmae e, endtican c
		 where e.cod_tipocan = c.cod_tipocan
		   and no_documento = _no_documento
		   and cod_endomov = '002'
		   and actualizado = 1
		 order by fecha_emision desc
		exit foreach;
	end foreach

	if _fecha_cancelacion <= a_fecha_cancelacion then
		continue foreach;
	end if

	select max(fecha),
		   sum(monto)
	  into _ult_fecha_cobro,
		   _monto_cobrado
	  from cobredet
	 where doc_remesa = _no_documento
	   and fecha >= _fecha_cancelacion
	   and tipo_mov in ('P','N')
	   and actualizado = 1;

	if _monto_cobrado is null then
		let _monto_cobrado = 0.00;
	end if

	return _no_documento,
		   _nom_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_ramo,
		   _forma_pago,
		   _zona_cobros,
		   _tipo_cancelacion,
		   _fecha_cancelacion,
		   _saldo,
		   _ult_fecha_cobro,
		   _monto_cobrado with resume;
end foreach
end
end procedure;