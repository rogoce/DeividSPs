-- Procedure que Carga los Reclamos Pendientes para BO

-- Creado:	06/12/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_sis512;

create procedure sp_sis512()
returning	char(20)		as poliza,
			date			as vigencia_inic,
			date			as vigencia_final,
			date			as fecha_suscripcion,
			varchar(50)		as tipo_produccion,
			varchar(50)		as grupo,
			varchar(100)	as nom_cliente,
			char(3)			as cod_ramo,
			varchar(50)		as nom_ramo,
			char(3)			as cod_subramo,
			varchar(50)		as nom_subramo,
			varchar(50)		as nom_formapag,
			char(5)			as cod_agente,
			varchar(50)		as nom_corredor,
			dec(5,2)		as porc_partic_agt,
			dec(5,2)		as porc_comis_agt,
			dec(5,2)		as porc_comis_plan,
			dec(5,2)		as porc_comis_ramo,
			dec(5,2)		as porc_comis_subramo,
			dec(5,2)		as porc_comis_esp,
			smallint		as no_pagos,
			dec(16,2)		as prima_neta,
			dec(16,2)		as saldo,
			char(1)			as nueva_renov;


define _nom_cliente			varchar(100);
define _tipo_produccion		varchar(50);
define _nom_formapag		varchar(50);
define _nom_corredor		varchar(50);
define _nom_subramo			varchar(50);
define _nom_ramo			varchar(50);
define _grupo				varchar(50);	
define _no_documento		char(20);
define _no_reclamo			char(10);
define _cod_agente			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _porc_comis_subramo	dec(5,2);
define _porc_comision_esp	dec(5,2);
define _porc_comis_ramo		dec(5,2);
define _porc_partic_agt		dec(5,2);
define _porc_comis_tab		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _prima_neta			dec(16,2);	
define _saldo				dec(16,2);	
define _no_pagos			smallint;
define _anio				integer;
define _flag				smallint;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _fecha_suscripcion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return 	_no_documento,
			null,
			null,
			null,
			_error_desc,
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			0,
			0,
			0,
			0,
			0,
			0,
			_error,
			_error_isam,
			0,
			'';
end exception

let _fecha_hoy = current;

foreach
	select emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.fecha_suscripcion,
		   pro.nombre,
		   grp.nombre,
		   cli.nombre,
		   ram.cod_ramo,
		   ram.nombre,
		   ram.porc_comision,
		   sub.cod_subramo,
		   sub.nombre,
		   sub.porc_comision,
		   pag.nombre,
		   agt.cod_agente,
		   agt.nombre,
		   cor.porc_partic_agt,
		   cor.porc_comis_agt,
		   emi.no_pagos,
		   emi.prima_neta,
		   mae.saldo,
		   emi.nueva_renov
	  into _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_suscripcion,
		   _tipo_produccion,
		   _grupo,
		   _nom_cliente,
		   _cod_ramo,
		   _nom_ramo,
		   _porc_comis_ramo,
		   _cod_subramo,
		   _nom_subramo,
		   _porc_comis_subramo,
		   _nom_formapag,
		   _cod_agente,
		   _nom_corredor,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _no_pagos,
		   _prima_neta,
		   _saldo,
		   _nueva_renov
	  from emipomae emi
	 inner join emipoliza mae on mae.no_poliza = emi.no_poliza
	 inner join emipoagt cor on cor.no_poliza = emi.no_poliza
	 inner join agtagent agt on agt.cod_agente = cor.cod_agente
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join cobforpa pag on pag.cod_formapag = emi.cod_formapag
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 inner join emitipro pro on pro.cod_tipoprod = emi.cod_tipoprod
	 where emi.estatus_poliza = 1
	   and emi.cod_tipoprod in ('001','005')
	   and emi.actualizado = 1
	   and agt.tipo_agente = 'A'

	let _porc_comis_tab = sp_pro305(_cod_agente, _cod_ramo, _cod_subramo);
	let _porc_comision_esp = 0;
	
	select porc_comis_agt
	  into _porc_comision_esp
	  from agtcomra
	 where cod_agente  = _cod_agente
	   and cod_ramo	   = _cod_ramo;

	if _porc_comision_esp is null then
		let _porc_comision_esp = 0;
	end if

	let _flag = 0;

	if _cod_ramo = '018' then
		let _anio = trunc((_fecha_hoy - mdy(month(_vigencia_inic),1,year(_vigencia_inic))/365),0);

		if _anio = 0 and _cod_subramo <> '019' and _porc_comis_agt > 15 and _porc_comis_agt > _porc_comis_subramo then
			let _flag = 1;
		elif _anio > 0 and _cod_subramo <> '019' and _porc_comis_agt > 10 and _porc_comis_agt > _porc_comis_subramo then
			let _flag = 1;
		end if
	elif _cod_ramo = '019' then
		if _nueva_renov = 'N' and _porc_comis_agt > 50 then
			let _flag = 1;
		elif _nueva_renov = 'R' and _porc_comis_agt not in (10,3) and _porc_comis_agt > 3 then
			let _flag = 1;
		end if
/*	elif _cod_ramo = '008' then
		if _porc_comis_agt > 7.5 then
			let _flag = 1;
		end if*/
	else
		if _porc_comis_agt > _porc_comis_ramo then
			let _flag = 1;
		end if
	end if

	if _flag = 1 then
		return	_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_fecha_suscripcion,
				_tipo_produccion,
				_grupo,
				_nom_cliente,
				_cod_ramo,
				_nom_ramo,
				_cod_subramo,
				_nom_subramo,
				_nom_formapag,
				_cod_agente,
				_nom_corredor,
				_porc_partic_agt,
				_porc_comis_agt,
				_porc_comis_tab,
				_porc_comis_ramo,
				_porc_comis_subramo,
				_porc_comision_esp,
				_no_pagos,
				_prima_neta,
				_saldo,
				_nueva_renov with resume;
	end if
end foreach
end
end procedure;