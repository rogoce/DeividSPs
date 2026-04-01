-- Proceso que Inserta las pólizas anuladas que fueron eliminadas de la estrucutra de campañas.
-- Creado    : 08/04/2015 - Autor: Román Gordón

drop procedure sp_cob370;
create procedure sp_cob370()
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _desc_gestion		varchar(100);
define _no_documento		char(19);
define _cod_pagador			char(10);
define _cod_campana			char(10);
define _cod_cliente			char(10);
define _cod_formapag		char(3);
define _cod_gestion			char(3);
define _cod_pagos			char(3);
define _cod_zona			char(3);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _cnt_anula			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_ult_pro		date;

--set debug file to "sp_cob356.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	drop table if exists tmp_filtros;
	return _error,_error_desc;
end exception

drop table if exists tmp_filtros;

create temp table tmp_filtros(
cod_campana		char(10),
cod_formapag	char(3),
cod_zonacob		char(3),
primary key(cod_campana, cod_formapag, cod_zonacob)) with no log;


let _cod_formapag = '';
let _cod_campana = '';
let _cod_zona = '';

foreach
	select no_documento
	  into _no_documento
	  from tmp_sobat

	select count(*)
	  into _cnt_anula
	  from caspoliza
	 where no_documento = _no_documento
	   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3 and cod_campana <> '01408' );

	if _cnt_anula is null then
		let _cnt_anula = 0;
	end if

	if _cnt_anula > 0 then
		delete from tmp_sobat
		 where no_documento = _no_documento;

		continue foreach;
	end if
	
	select cod_formapag,
		   cod_pagos,
		   cod_pagador,
		   dia_cobros1,
		   dia_cobros2,
		   exigible,
		   por_vencer,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   saldo,
		   cod_zona
	  into _cod_formapag,
		   _cod_pagos,
		   _cod_pagador,
		   _dia_cobros1,
		   _dia_cobros2,
		   _exigible,
		   _por_vencer,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo,
		   _cod_zona
	  from emipoliza
	 where no_documento = _no_documento;

	let _cod_campana = '01408';
	
	select count(*)
	  into _cnt_cascliente
	  from cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_pagador;

	if _cnt_cascliente is null then
		let _cnt_cascliente = 0;
	end if

	if _cnt_cascliente = 0 then
		insert into cascliente(
				cod_cliente,
				dia_cobros1,
				dia_cobros2,
				procesado,
				fecha_ult_pro,
				cod_gestion,
				dia_cobros3,
				cod_cobrador_ant,
				ultima_gestion,
				cant_call,
				pago_fijo,
				mando_mail,
				cod_campana,
				corriente,
				exigible,
				monto_30,
				monto_60,
				monto_90,
				monto_120,
				monto_150,
				monto_180,
				saldo,
				por_vencer,
				cod_pagos,
				cod_cobrador,
				fecha_promesa,
				monto_promesa,
				nuevo)
		values(	_cod_pagador,
				_dia_cobros1,
				_dia_cobros2,
				1,
				_fecha_ult_pro,
				_cod_gestion,
				0,
				null,
				_desc_gestion,
				0,
				0,
				0,
				_cod_campana,
				_corriente,
				_exigible,
				_monto_30,
				_monto_60,
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo,
				_por_vencer,
				_cod_pagos,
				null,
				null,
				0.00,
				0);
	end if

	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_pagador
	   and no_documento = _no_documento;

	if _cnt_caspoliza is null then
		let _cnt_caspoliza = 0;
	end if

	if _cnt_caspoliza = 0 then
		insert into caspoliza(
				no_documento,
				cod_cliente,
				dia_cobros1,
				dia_cobros2,
				a_pagar,
				cod_campana)
		values(	_no_documento,
				_cod_pagador,
				_dia_cobros1,
				_dia_cobros2,
				_exigible,
				_cod_campana);
	end if
	
	return 0,_no_documento with resume;
end foreach
end
end procedure;