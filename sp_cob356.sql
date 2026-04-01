-- Procedimiento para la inserción inicial de registros a las campañas de la nueva ley de seguros (Proceso de Primera Letra)
-- Creado    : 08/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.
-- execute procedure sp_cob356('01/05/2015', 30)


drop procedure sp_cob356;
create procedure sp_cob356(a_fecha_desde date, a_dias_vencida smallint)
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _nom_agente			varchar(100);
define _motivo_rechazo		varchar(50);
define _nom_cobrador		varchar(50);
define _desc_vip			varchar(50);
define _nom_div_cob			char(50);
define _no_documento		char(20);
define _cod_campana			char(10);
define _cod_pagador			char(10);
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
define _monto_pag			dec(16,2);
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
define _dias_anula_ren		smallint;
define _estatus_poliza		smallint;
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _cod_acreencia		smallint;
define _dias_vencido		smallint;
define _cliente_vip			smallint;
define _cnt_credito			smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _cnt_ajuste			smallint;
define _cnt_ley68			smallint;
define _fronting			smallint;
define _leasing				smallint;
define _error_isam			integer;
define _error				integer;
define _fec_inic_anula_ren	date;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _fecha_ult_pro		date;
define _vigencia_inic		date;
define _vigencia_fin		date;
define _fecha_hoy			date;
define _cnt_polpag			smallint;
define _pagada				smallint;

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
let _dias_anula_ren = 20; --Mover para que salgan pólizas renovadas a partir del día 20 sin pago.
let _pagada = 0;

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

select date(valor_parametro)
  into _fec_inic_anula_ren
  from inspaag
 where codigo_parametro = 'fec_inic_anula_ren';

foreach
	select l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza 
	   and e.vigencia_inic >= a_fecha_desde
	   and _fecha_hoy - e.fecha_primer_pago >= a_dias_vencida
	   and l.no_letra = 1
	   and l.pagada = 0
	   and l.monto_letra <> 0
	   and l.monto_pag = 0
	 group by l.no_documento

	{select l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and l.no_letra = 1
	   and l.pagada = 0
	   and l.monto_letra <> 0
	   and ((e.nueva_renov = 'N' and l.monto_pag = 0 and today - e.fecha_primer_pago >= a_dias_vencida and e.vigencia_inic >= a_fecha_desde) or 
			(e.nueva_renov = 'R' and today - e.fecha_primer_pago >= _dias_anula_ren and e.vigencia_inic >= _fec_inic_anula_ren))
	 group by l.no_documento}

	call sp_sis21(_no_documento) returning _no_poliza;

	if _no_poliza is null then
		continue foreach;
	end if

	{let _cnt_ley68 = 0;

	select count(*)
	  into _cnt_ley68
	  from caspoliza
	 where no_documento = _no_documento
	   and cod_campana = '01408';

	if _cnt_ley68 is null then
		let _cnt_ley68 = 0;
	end if

	if _cnt_ley68 > 0 then
		continue foreach;
	end if}

	select nueva_renov,
		   estatus_poliza,
		   fecha_primer_pago,
		   fecha_suscripcion,
		   vigencia_inic,
		   fronting,
		   cod_ramo,
		   cod_grupo,
		   cod_tipoprod,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final
	  into _nueva_renov,
		   _estatus_poliza,
		   _fecha_primer_pago,
		   _fecha_suscripcion,
		   _vigencia_inic,
		   _fronting,
		   _cod_ramo,
		   _cod_grupo,
		   _cod_tipoprod,
		   _cod_subramo,
		   _vigencia_inic,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fecha_suscripcion > _fecha_primer_pago then
		let _dias_vencido = _fecha_hoy - _fecha_suscripcion;

		if _dias_vencido < a_dias_vencida then
			continue foreach;
		end if
	else
		let _dias_vencido = _fecha_hoy - _fecha_primer_pago;
	end if
	
	if _nueva_renov = 'R' then
		if _vigencia_inic < _fec_inic_anula_ren then
			continue foreach;
		end if

		if _dias_vencido < _dias_anula_ren then
			continue foreach;
		end if
	end if
	
	{if _estatus_poliza <> 1 then
		continue foreach;
	end if

	if _fronting = 1 then
		continue foreach;
	end if

	if _cod_ramo in ('008','014') then --'004','016','018','019') Se elimina ramos personales de la exclusión 19/01/2016
		continue foreach;
	elif _cod_ramo in ('016') and _cod_subramo in ('007') then --Colectivo de Vida, Subramo Desgravamen
		continue foreach;
	end if

	if _cod_grupo in ('00000','1000','1090','1009','01016') then --grupos del Estado, SCOTIA BANK y BAGATRAC
		continue foreach;
	end if
	
	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_produccion = 3 then
		continue foreach;
	end if}


	call sp_ley003(_no_documento,1) returning _error, _error_desc;
	
	if _error < 0 then
		return _error, _error_desc;
	elif _error = 1 then
		continue foreach;
	end if
	
	--SD#8393 ENILDA 16/11/2023 Emiletra cero serafin niño
--if trim(_no_documento) = '1916-00127-01' then --_no_poliza = '2033047'  then
	--set debug file to "sp_cob356_1.trc";
	--trace on;
	let _cnt_polpag = 0;
 
		select count(*)
		  into _cnt_polpag	
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.tipo_mov in ('P', 'N', 'X')
		   and d.doc_remesa = _no_documento
		   and m.fecha between _vigencia_inic and _vigencia_fin;
		   
			if _cnt_polpag is null then
				let _cnt_polpag = 0;
			end if	
			
	       -- trace off;	   
			if _cnt_polpag > 0 then
				continue foreach;
			end if	 

--end if			

	
	call sp_pro545(_no_documento)returning _error, _error_desc;
	call sp_pro544(_no_documento)returning _error, _error_desc;

	if _nueva_renov = 'R' then
		--continue foreach;
		
		let _cnt_credito = 0;

		select count(*)
		  into _cnt_credito
		  from emiletra
		 where no_documento = _no_documento
		   and monto_pen < 0;

		if _cnt_credito is null then
			let _cnt_credito = 0;
		end if

		if _cnt_credito > 0 then
			call sp_cob346a(_no_documento) returning _error,_error_desc;
		end if

		let _cnt_ajuste = 0;
		select count(*)
		  into _cnt_ajuste 
		  from emiletra
		 where no_documento = _no_documento
		   and no_letra = 1
		   and pagada = 0;

		if _cnt_ajuste is null then
			let _cnt_ajuste = 0;
		end if

		if _cnt_ajuste = 0 then
			continue foreach;
		end if
	else
		let _monto_pag = 0;

		select sum(monto_pag)
		  into _monto_pag
		  from emiletra
		 where no_poliza = _no_poliza;
		
		if _monto_pag > 0 then
			continue foreach;
		end if
	end if

	call sp_cob116(_no_poliza)
	returning	_cod_agente,  
				_nom_agente,      
				_cod_cobrador,
				_nom_cobrador,
				_leasing,
				_cod_div_cob,
				_nom_div_cob;

	select cod_formapag,
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
	  into _cod_formapag,
		   _cod_area,   
		   _cod_pagos,
		   _cod_pagador,
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
	 where no_documento = _no_documento;

	call sp_sis233(_cod_pagador) returning _cliente_vip,_desc_vip;
	
	select cod_campana
	  into _cod_campana
	  from tmp_filtros
	 where cod_formapag = _cod_formapag 
	   and cod_zonacob = _cod_zona
	   and nueva_renov = _nueva_renov
	   and cliente_vip = _cliente_vip;

	if _cod_campana is null or _cod_campana = '' then
		--return 1,trim(_no_documento) || ' sin filtros: cod_formapag: ' || _cod_formapag || ' cod_zona: ' || _cod_zona with resume;
		continue foreach;
	end if

	select count(*)
	  into _cnt_cascliente
	  from tmp_cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_pagador;

	if _cnt_cascliente is null then
		let _cnt_cascliente = 0;
	end if

	if _cnt_cascliente = 0 then
		let _fecha_ult_pro = current;

		insert into tmp_cascliente(
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
				0,
				_fecha_ult_pro,
				null,
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
				1);

		insert into tmp_caspoliza(
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
	else
		select count(*)
		  into _cnt_caspoliza
		  from tmp_caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_pagador
		   and no_documento = _no_documento;

		if _cnt_caspoliza is null then
			let _cnt_caspoliza = 0;
		end if

		if _cnt_caspoliza = 0 then
			insert into tmp_caspoliza(
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
	end if
end foreach
return 0,'Actualización Exitosa';
end
end procedure;