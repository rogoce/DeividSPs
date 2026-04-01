--execute procedure sp_sis212e('2018-07')
drop procedure sp_sis212e;
create procedure "informix".sp_sis212e(a_periodo char(7))
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _emi_periodo			char(7);
define _periodo				char(7);
define _cod_contrato_n		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_cober_ter		char(3);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_sin_fac		dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_fac		dec(16,2);
define _suma_sin_fac		dec(16,2);
define _suma_aseg			dec(16,2);
define _prima_rea			dec(16,2);
define _tipo_contrato		smallint;
define _cnt_contrato		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
 	return _error, _error_desc;         
end exception



foreach
	{select distinct r.no_poliza,
		   r.no_endoso,
		   r.no_unidad,
		   r.cod_cober_reas,
		   r.cod_contrato
	  into _no_poliza,
		   _no_endoso,
		   _no_unidad,
		   _cod_cober_reas,
		   _cod_contrato
	  from emipomae p, endedmae e, emifacon r,reacomae c
	 where p.no_poliza = e.no_poliza
	   and e.no_poliza = r.no_poliza
	   and e.no_endoso = r.no_endoso
	   and c.cod_contrato = r.cod_contrato
	   and p.cod_ramo in ('001','003')
	   and p.vigencia_inic >= '01/07/2018'
	   and e.actualizado = 1
	   and p.actualizado = 1
	   and c.tipo_contrato = 1
	   and r.cod_contrato <> '00687'
	   and e.prima_suscrita = e.prima_retenida
	   and e.periodo = a_periodo}

	select first 4 r.no_poliza,
		   r.no_endoso,
		   r.no_unidad,
		   r.cod_cober_reas,
		   r.cod_contrato,
		   c.tipo_contrato,
		   r.porc_partic_prima,
		   r.porc_partic_suma,
		   r.suma_asegurada
	  into _no_poliza,
		   _no_endoso,
		   _no_unidad,
		   _cod_cober_reas,
		   _cod_contrato,
		   _tipo_contrato,
		   _porc_partic_prima,
		   _porc_partic_suma,
		   _suma_asegurada
	  from tmp_reas_inc t, emifacon r, endedmae e, reacomae c
	 where t.no_poliza = r.no_poliza
	   and t.no_endoso = r.no_endoso
	   and e.no_poliza = r.no_poliza
	   and e.no_endoso = r.no_endoso
	   and c.cod_contrato = r.cod_contrato
	   and r.cod_cober_reas in ('001','003')
	   and r.cod_contrato not in ('00687','00688')
	 order by 1,2,3,4,5

	if _tipo_contrato = 1 then
		let _cod_contrato_n = '00687';
		let _orden = 2;
	elif _tipo_contrato = 7 then
		let _cod_contrato_n = '00688';
		let _orden = 4;
	end if

	if _cod_cober_reas = '001' then
		let _cod_cober_ter = '021';
	else
		let _cod_cober_ter = '022';
	end if

	select count(*)
	  into _cnt_contrato
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad
	   and cod_cober_reas = _cod_cober_ter
	   and cod_contrato = _cod_contrato;

	if _cnt_contrato is null then
		let _cnt_contrato = 0;
	end if

	if _cnt_contrato = 0 then
		insert into emifacon(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cober_reas,
				orden,
				cod_contrato,
				cod_ruta,
				porc_partic_prima,
				porc_partic_suma,
				suma_asegurada,
				prima,
				ajustar,
				subir_bo)
		values(	_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cober_ter,
				10,
				_cod_contrato_n,
				null,
				_porc_partic_prima,
				_porc_partic_suma,
				_suma_asegurada,
				0,
				0,
				0);

		insert into emireaco(
				no_poliza,
				no_unidad,
				no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_prima,
				porc_partic_suma)
		values(	_no_poliza,
				_no_unidad,
				0,
				_cod_cober_ter,
				10,
				_cod_contrato_n,
				_porc_partic_prima,
				_porc_partic_suma);

		update emireaco
		   set cod_contrato = _cod_contrato_n,
		       porc_partic_prima = _porc_partic_prima,
			   porc_partic_suma = _porc_partic_suma
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_ter
		   and cod_contrato = _cod_contrato;

		update emifacon
		   set cod_contrato = _cod_contrato_n,
			   porc_partic_prima = _porc_partic_prima,
			   porc_partic_suma = _porc_partic_suma,
			   suma_asegurada = _suma_asegurada
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_ter
		   and cod_contrato = _cod_contrato;
	end if

	update emireaco
	   set cod_contrato = _cod_contrato_n
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cober_reas = _cod_cober_reas
	   and cod_contrato = _cod_contrato;

	update emifacon
	   set cod_contrato = _cod_contrato_n
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad
	   and cod_cober_reas = _cod_cober_reas
	   and cod_contrato = _cod_contrato;

	--return 0,trim(_no_poliza
end foreach

return 0,'Actualización Exitosa';
end
end procedure;