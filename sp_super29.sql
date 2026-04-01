-- Procedure que Cambia el Estatus de los Periodos Abiertos a Cerrados
--     

drop procedure sp_super29;

create procedure sp_super29(a_periodo1 char(7), a_periodo2 char(7))
returning char(7)		as periodo,
          varchar(50)	as ramo,
          varchar(50)	as forma_pago,
		  smallint		as fronting,
		  smallint		as facultativo,
		  smallint		as grupo_estado,
          char(20)		as poliza,
		  dec(16,2) 	as prima_suscrita,
		  dec(16,2) 	as pagos_reales,
		  dec(16,2) 	as saldo_cedido,
		  dec(16,2) 	as comision_rea,
		  dec(16,2) 	as impuesto_rea,
		  dec(16,2) 	as saldo_retenido,
		  dec(16,2) 	as comision_agt,
		  dec(16,2) 	as saldo,
		  dec(16,2) 	as por_vencer,
		  dec(16,2) 	as corriente,
		  dec(16,2) 	as dias_30,
		  dec(16,2) 	as dias_60,
		  dec(16,2) 	as dias_90,
		  dec(16,2) 	as dias_120,
		  date			as vigencia_inicial,
		  date			as vigencia_final,
		  char(10)      as estatus_poliza,
		  date			as fecha_cancelacion,
		  smallint		as no_pagos;
		  
define _mensaje			varchar(50);
define _forma_pago		varchar(50);
define _ramo				varchar(50);
define _no_documento		char(20);
define _cod_grupo			char(10);
define _no_poliza			char(10);
define _periodo			char(7);
define _cod_ramo			char(3);
define _porc_comis_agt	dec(5,2); 
define _porc_partic_agt	dec(5,2); 
define _saldo_retenido2	dec(16,2); 
define _saldo_ret_total	dec(16,2); 
define _saldo_retenido 	dec(16,2); 
define _saldo_cedido 		dec(16,2); 
define _prima_no_dev 		dec(16,2); 
define _comis_agt			dec(16,2); 
define _por_vencer	 	dec(16,2); 
define _corriente			dec(16,2);
define _dias_120			dec(16,2);
define _dias_90			dec(16,2);
define _dias_60			dec(16,2);
define _dias_30			dec(16,2);
define _saldo				dec(16,2);
define _prima_suscrita	dec(16,2);
define _comision_rea		dec(16,2);
define _impuesto_rea		dec(16,2);
define _pagos_reales		dec(16,2);
define _vigencia_final	date;
define _vigencia_inic		date;
define _ult_dia_mes		date;
define _facultativo		smallint;
define _flag_grupo		smallint;
define _fronting			smallint;
define _dias_vigencia		integer;
define _error_isam		integer;
define _error				integer;
define _vigencia_inic_emi   date;
define _vigencia_final_emi	date;
define _estatus_poliza	smallint;
define _fecha_cancelacion date;
define _no_pagos		smallint;


set isolation to dirty read;

begin
on exception set _error,_error_isam,_mensaje
 	return '',
		   _mensaje,
		   '',
		   _error,
		   0,
		   0,
		   '',
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   '01-01-1900',
		   '01-01-1900',
		   '',
   		   '01-01-1900',
		   0;
end exception

--set debug file to "sp_super29.trc";
--trace on;




foreach
	select cob.no_documento,
	       cob.no_poliza,
		   cob.por_vencer_pxc,
		   cob.corriente_pxc,
		   cob.monto_30_pxc,
		   cob.monto_60_pxc,
		   cob.monto_90_pxc,
		   cob.dias_120_pxc + dias_150_pxc + dias_180_pxc,
		   cob.saldo_pxc,
		   cob.periodo,
		   ram.nombre,
		   ram.cod_ramo,
		   pag.nombre,
		   emi.cod_grupo,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.estatus_poliza,
		   emi.fecha_cancelacion,
		   emi.no_pagos
	  into _no_documento,
	       _no_poliza,
		   _por_vencer,
		   _corriente,
		   _dias_30,
		   _dias_60,
		   _dias_90,
		   _dias_120,
		   _saldo,
		   _periodo,
		   _ramo,
		   _cod_ramo,
		   _forma_pago,
		   _cod_grupo,
		   _vigencia_inic_emi,
		   _vigencia_final_emi,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _no_pagos
	  from deivid_cob:cobmoros2 cob
	 inner join emipomae emi on emi.no_poliza = cob.no_poliza
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join cobforpa pag on pag.cod_formapag = emi.cod_formapag	 
	 where cob.periodo >= a_periodo1
	   and cob.periodo <= a_periodo2
	   and cob.saldo_pxc !=0	   
	   --and emi.cod_no_renov = '005'
	 order by cob.periodo,cob.no_documento
	 
	let _ult_dia_mes = sp_sis36(_periodo);
	   
	let _prima_suscrita = 0.00;
	let _saldo_retenido = 0.00;
	let _pagos_reales = 0.00;
	let _comision_rea = 0.00;
	let _impuesto_rea = 0.00;
	let _saldo_cedido = 0.00;
	let _comis_agt = 0.00;
	
	/*select 
	  into 
	  */

	let _flag_grupo = 0;
	let _fronting = sp_sis135(_no_poliza);
	let _facultativo = sp_sis439(_no_poliza);

	if _cod_grupo in ('1000','00000') then --Grupos del Estado
		let _flag_grupo = 1;
	end if
	
	foreach
		select porc_partic_agt,
			   porc_comis_agt
		  into _porc_partic_agt,
			   _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza

		let _comis_agt = _comis_agt + (_saldo * (_porc_partic_agt/100) * (_porc_comis_agt/100));
	end foreach
	
	foreach
		select vigencia_inic_pol,
		       vigencia_final_pol
		  into _vigencia_inic,
			   _vigencia_final
		  from endedmae
		 where no_documento = _no_documento
		   and no_poliza = _no_poliza
		   and actualizado = 1
		   and periodo <= _periodo
		 order by no_endoso desc
		exit foreach;
	end foreach
	
	let _dias_vigencia = 0;
	let _dias_vigencia = _vigencia_final - _vigencia_inic;
	
	if _dias_vigencia = 0 then
		let _dias_vigencia = 1;
	end if
	
	if _vigencia_final < _ult_dia_mes then --No hay Prima No Devengada
		let _prima_no_dev = 0;
	elif _vigencia_inic > _ult_dia_mes then --Todo el Saldo Es No Devengado
		let _prima_no_dev = _saldo;
	else
		let _prima_no_dev = _saldo * (((_vigencia_final - _ult_dia_mes) +1)/_dias_vigencia);
	end if
	
	let _prima_no_dev = 0;

	/*if _cod_ramo = '018' then
		select sum(prima_suscrita)
		  into _prima_suscrita
		  from endedmae
		 where no_documento = _no_documento
		   and no_poliza = _no_poliza
		   and cod_endomov not in ('002','003')
		   and actualizado = 1;
	else*/
		/*select sum(prima_suscrita)
		  into _prima_suscrita
		  from endedmae
		 where no_documento = _no_documento
		   and no_poliza = _no_poliza
		   and cod_endomov not in ('002','003')
		   and actualizado = 1;
		   --and periodo <= _periodo;*/
	select sum(ps) as prima_susc
	  into _prima_suscrita
	  from (
				select no_poliza,sum(prima_suscrita) as PS
				  from endedmae
				 where no_documento = _no_documento
				   and cod_endomov not in ('002','003')
				   and no_poliza = _no_poliza
				   and actualizado = 1
				 group by 1
				
				union
				
				select no_poliza,sum(prima_suscrita) as PS
				  from endedmae
				 where no_documento = _no_documento
				   and cod_endomov = '002'
				   and cod_tipocan = '009' -- PARA SER REEMPLAZADA
				   and no_poliza = _no_poliza
				   and actualizado = 1
				 group by no_poliza
				 
			);

		select sum(prima_neta)
		  into _pagos_reales
		  from cobredet
		 where doc_remesa = _no_documento
		   and no_poliza = _no_poliza
		   and actualizado = 1
		   and tipo_mov in ('P','N','X');
		   --and periodo <= _periodo;
	--end if
	
	if _prima_suscrita is null then
		let _prima_suscrita = 0;
	end if

	if _pagos_reales is null then
		let _pagos_reales = 0;
	end if
	
	select sum(comision),
		   sum(impuesto)
	  into _comision_rea,
		   _impuesto_rea
	  from rea_saldo2 
	 where no_documento = _no_documento
	   and periodo = _periodo;

	select sum(saldo_tot)
	  into _saldo_cedido
	  from rea_saldo2 rea
	 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato != 1
	 where no_documento = _no_documento
	   and periodo = _periodo;

	select sum(saldo_tot)
	  into _saldo_retenido
	  from rea_saldo2 rea
	 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
	 where no_documento = _no_documento
	   and periodo = _periodo;
	 
	select sum(saldo_tot)
	  into _saldo_retenido2
	  from rea_saldo2 rea
	  left join reacomae con on con.cod_contrato = rea.cod_contrato
	 where no_documento = _no_documento
	   and periodo = _periodo
	   and con.tipo_contrato is null;
	 
	if _saldo_cedido is null then
		let _saldo_cedido = 0.00;
	end if

	if _saldo_retenido is null then
		let _saldo_retenido = 0.00;
	end if
	
	if _saldo_retenido2 is null then
		let _saldo_retenido2 = 0.00;
	end if
	
	let _saldo_ret_total = _saldo_retenido + _saldo_retenido2;	
	
	if _estatus_poliza in (2,4) and _fecha_cancelacion >= _ult_dia_mes then
		let _estatus_poliza = 1;
	end if
	
	return _periodo,
	       _ramo,
		   _forma_pago,
		   _fronting,
		   _facultativo,
		   _flag_grupo,
		   _no_documento,
		   _prima_suscrita,
		   _pagos_reales,
		   _saldo_cedido,
		   _comision_rea,
		   _impuesto_rea,
		   _saldo_ret_total,
		   _comis_agt,
	       _saldo,
	       _por_vencer,
		   _corriente,
		   _dias_30,
		   _dias_60,
		   _dias_90,
		   _dias_120, 
		   _vigencia_inic_emi,
		   _vigencia_final_emi,
		   (case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end),
		   _fecha_cancelacion,
		   _no_pagos with resume; 
end foreach
end
end procedure;