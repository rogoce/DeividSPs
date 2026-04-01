-- Procedimiento para la inserción inicial de registros a las campañas de la nueva ley de seguros (Proceso de Primera Letra)
-- Creado    : 08/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.
--execute procedure sp_cob356c('0213-02377-09','312191','073')

drop procedure sp_cob356c;
create procedure sp_cob356c(a_no_documento char(20), a_cod_pagador char(10),a_cod_gestion char(3))
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _nom_agente			varchar(100);
define _motivo_rechazo		varchar(50);
define _nom_cobrador		varchar(50);
define _desc_vip			varchar(50);
define _nom_div_cob			char(50);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _periodo_ren			char(7);
define _fecha_exp			char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_area			char(5);
define _cod_cobrador		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_formapag		char(3);
define _sin_gestion			char(3);
define _cod_pagos			char(3);
define _cod_ramo			char(3);
define _cod_zona			char(3);
define _cod_div_cob			char(1);
define _nueva_renov			char(1);
define _cod_status			char(1);
define _prima_bruta			dec(16,2);
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
define _carta_aviso_canc	smallint;
define _tipo_produccion		smallint;
define _estatus_poliza		smallint;
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _cod_acreencia		smallint;
define _cnt_cobanula		smallint;
define _cliente_vip			smallint;
define _tipo_accion			smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _fronting			smallint;
define _leasing				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_emision_ren	date;
define _fecha_ult_pro		date;
define _vigencia_inic		date;
define _vigencia_fin		date;
define _fecha_hoy			date;

--set debug file to "sp_cob356.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	drop table if exists tmp_cascliente;
	drop table if exists tmp_caspoliza;
	drop table if exists tmp_filtros;
	return _error,_error_desc;
end exception  

drop table if exists tmp_cascliente;
drop table if exists tmp_caspoliza;
drop table if exists tmp_filtros;

create temp table tmp_filtros(
cod_campana		char(10),
cod_formapag	char(3),
cod_zonacob		char(3),
nueva_renov		char(1),
cliente_vip		smallint default 0,
primary key(cod_campana, cod_formapag, cod_zonacob)) with no log;

select a.*
  from cascliente a, cascampana c
 where c.cod_campana = a.cod_campana
   and c.estatus = 2
   and c.tipo_campana = 3
  into temp tmp_cascliente;

select p.*,a.fecha_ult_pro
  from caspoliza p,cascliente a, cascampana c
 where c.cod_campana = a.cod_campana
   and a.cod_campana = p.cod_campana
   and a.cod_cliente = p.cod_cliente
   and c.estatus = 2
   and c.tipo_campana = 3
  into temp tmp_caspoliza;

let _fecha_hoy = current;
let _cod_compania = '001';
--let _fecha_hoy = '31/05/2015';

foreach
	select f.cod_campana,
		   f.cod_filtro
	  into _cod_campana,
		   _cod_formapag
	  from cascampana c, cascampanafil f
	 where c.cod_campana = f.cod_campana
	   and c.estatus = 2
	   and c.tipo_campana = 3
	   and f.tipo_filtro = 3

	foreach
		select cod_filtro
		  into _cod_zona
		  from cascampana c, cascampanafil f
		 where c.cod_campana = f.cod_campana
		   and c.cod_campana = _cod_campana
		   and c.estatus = 2
		   and c.tipo_campana = 3
		   and f.tipo_filtro = 4

		insert into tmp_filtros(
				cod_campana,
				cod_formapag,
				cod_zonacob)
		values(	_cod_campana,
				_cod_formapag,
				_cod_zona);
	end foreach
end foreach

foreach
	select f.cod_campana,
		   f.cod_filtro
	  into _cod_campana,
		   _nueva_renov
	  from cascampana c, cascampanafil f
	 where c.cod_campana = f.cod_campana
	   and c.estatus = 2
	   and c.tipo_campana = 3
	   and f.tipo_filtro = 17

	update tmp_filtros
	   set nueva_renov = _nueva_renov
	 where cod_campana = _cod_campana;
end foreach

foreach
	select f.cod_campana
	  into _cod_campana
	  from cascampana c, cascampanafil f
	 where c.cod_campana = f.cod_campana
	   and c.estatus = 2
	   and c.tipo_campana = 3
	   and f.tipo_filtro = 13

	update tmp_filtros
	   set cliente_vip = 1
	 where cod_campana = _cod_campana;
end foreach

let _cod_formapag = '';
let _cod_campana = '';
let _cod_zona = '';

call sp_sis21(a_no_documento) returning _no_poliza;

select nueva_renov,
	   estatus_poliza,
	   cod_tipoprod,
	   cod_grupo,
	   fronting,
	   cod_ramo,
	   cod_subramo
  into _nueva_renov,
	   _estatus_poliza,
	   _cod_tipoprod,
	   _cod_grupo,
	   _fronting,
	   _cod_ramo,
	   _cod_subramo
  from emipomae
 where no_poliza = _no_poliza;

if _estatus_poliza not in (1,3) then
	return 1,'La póliza ' || trim(a_no_documento) || ' no esta vigente, por favor verifique.';
end if

if _cod_grupo in ('00000','1000','1090','1009','01016') then
	return 1,'El Grupo de la póliza ' || trim(a_no_documento) || ' no aplica para ingresar al proceso de anulación, por favor verifique.';
end if

if _fronting = 1 then
	return 1,'La póliza ' || trim(a_no_documento) || ' es Fronting, por favor verifique.';
end if

if _cod_ramo in ('008','014')  or (_cod_ramo in ('016') and _cod_subramo in ('007')) then --'004','016','018','019') then --Ramos Personales y Fianzas
	return 1,'El Ramo de la póliza ' || trim(a_no_documento) || ' no aplica para ingresar al proceso de anulación, por favor verifique.';
end if

select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion = 3 then
	return 1,'La póliza ' || trim(a_no_documento) || ' es Coaseguro Minoritario, por favor verifique.';
end if

let _fecha_emision_ren = '01/01/1900';

call sp_cob116(_no_poliza)
returning	_cod_agente,  
			_nom_agente,      
			_cod_cobrador,
			_nom_cobrador,
			_leasing,
			_cod_div_cob,
			_nom_div_cob;

select cod_ramo,
	   cod_formapag,
	   cod_area,   
	   cod_pagos,
	   cod_pagador,
	   cod_sucursal,
	   dia_cobros1,
	   dia_cobros2,
	   cod_status,
	   vigencia_inic,
	   vigencia_fin,
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
	   cod_acreencia,
	   cod_zona,
	   cod_agente,
	   prima_bruta,
	   carta_aviso_canc,
	   fecha_exp,
	   motivo_rechazo,
	   cod_subramo,
	   sin_gestion
  into _cod_ramo,
	   _cod_formapag,
	   _cod_area,   
	   _cod_pagos,
	   a_cod_pagador,
	   _cod_sucursal,
	   _dia_cobros1,
	   _dia_cobros2,
	   _cod_status,
	   _vigencia_inic,
	   _vigencia_fin,
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
	   _cod_acreencia,
	   _cod_zona,
	   _cod_agente,
	   _prima_bruta,
	   _carta_aviso_canc,
	   _fecha_exp,
	   _motivo_rechazo,
	   _cod_subramo,
	   _sin_gestion
  from emipoliza
 where no_documento = a_no_documento;

call sp_sis233(a_cod_pagador) returning _cliente_vip,_desc_vip;

select cod_campana
  into _cod_campana
  from tmp_filtros
 where cod_formapag = _cod_formapag 
   and cod_zonacob = _cod_zona
   and nueva_renov = _nueva_renov
   and cliente_vip = _cliente_vip;

if _cod_campana is null or _cod_campana = '' then
	return 1,'No se encuentra ninguna campaña con los filtros para la póliza: ' || trim(a_no_documento) || ', por favor verifique.';
end if

select count(*)
  into _cnt_cascliente
  from cascliente
 where cod_campana = _cod_campana
   and cod_cliente = a_cod_pagador;

if _cnt_cascliente is null then
	let _cnt_cascliente = 0;
end if

delete from emireaut where no_poliza = _no_poliza;

if _cnt_cascliente = 0 then
	let _fecha_ult_pro = current;

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
	values(	a_cod_pagador,
			_dia_cobros1,
			_dia_cobros2,
			1,
			_fecha_ult_pro,
			a_cod_gestion,
			0,
			null,
			'',
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

	insert into caspoliza(
			no_documento,
			cod_cliente,
			dia_cobros1,
			dia_cobros2,
			a_pagar,
			cod_campana)
	values(	a_no_documento,
			a_cod_pagador,
			_dia_cobros1,
			_dia_cobros2,
			_exigible,
			_cod_campana);
else
	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = a_cod_pagador
	   and no_documento = a_no_documento;

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
		values(	a_no_documento,
				a_cod_pagador,
				_dia_cobros1,
				_dia_cobros2,
				_exigible,
				_cod_campana);
	end if
end if

select tipo_accion
  into _tipo_accion
  from cobcages
 where cod_gestion = a_cod_gestion;

if _tipo_accion = 12 then
	select count(*)
	  into _cnt_cobanula
	  from cobanula
	 where cod_cliente = a_cod_pagador
	   and no_documento = a_no_documento;

	if _cnt_cobanula is null then
		let _cnt_cobanula = 0;
	end if
	
	if _cnt_cobanula > 0 then
		update cobanula
		   set cod_gestion = a_cod_gestion
		 where cod_campana = _cod_campana
		   and cod_cliente = a_cod_pagador
		   and no_documento = a_no_documento;
	else
		insert into cobanula(cod_campana,cod_cliente,cod_gestion,no_documento,date_added)
		values(_cod_campana,a_cod_pagador,a_cod_gestion,a_no_documento,current);
	end if
end if

drop table if exists tmp_filtros;

return 0,'Actualización Exitosa';
end
end procedure;