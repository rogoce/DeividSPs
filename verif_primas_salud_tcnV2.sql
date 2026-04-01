-- Informes de Detalle de Produccion por Grupo
-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo
--execute procedure verif_primas_salud_tcnV2('2018-01','2018-12')

drop procedure verif_primas_salud_tcnV2;
create procedure "informix".verif_primas_salud_tcnV2(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	smallint	as _error,				
			varchar(50)	as _error_desc;    

define v_filtros			char(255);
define _error_desc			varchar(50);
define _nom_subramo			varchar(50);
define _nom_producto		varchar(50);
define v_desc_nombre		char(35);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza			char(10);
define _cod_asegurado		char(10);
define v_nopoliza			char(10);
define _periodo_endoso		char(7);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define v_cod_subramo		char(3);
define v_forma_pago			char(3);
define v_cod_ramo			char(3);
define s_tipopro			char(3);
define s_cia				char(3);
define _tipo_produccion		char(1);
define _tipo_asegurado		char(1);
define _sexo_dep			char(1);
define _sexo				char(1);
define _tipo				char(1);
define _porc_partic_agt		dec(5,2);
define _por_recargo_dep		dec(5,2);
define _porc_recar_uni		dec(5,2);
define v_porc_comis			dec(5,2);
define v_comision			dec(9,2);
define _prima_neta_anual	dec(16,2);
define _prima_susc_anual	dec(16,2);
define _prima_calc_dep		dec(16,2);
define _recargo_anual		dec(16,2);
define _pagado_bruto		dec(16,2);
define _prima_unidad		dec(16,2);
define _pagado_total		dec(16,2);
define _prima_anual			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_dep			dec(16,2);
define _prima_tot			dec(16,2);
define _recargo				dec(16,2);
define _estatus_poliza		smallint;
define _edad_endoso			smallint;
define _anio_endoso			smallint;
define _activo_uni			smallint;
define _activo				smallint;
define _cnt_dep				smallint;
define _anio				smallint;
define _dia					smallint;
define _mes					smallint;
define _error_isam			integer;
define _error				integer;
define v_estatus			smallint;
define _fecha_cancelacion	date;
define _fecha_suscripcion	date;
define _fecha_nacimiento	date;
define _fecha_nac_dep		date;
define _fecha_emision_u		date;
define _no_activo_desde		date;
define _vigencia_endoso		date;
define _fecha_efect_dep		date;
define _date_added_dep		date;
define _vigencia_desde		date;
define _vigencia_hasta		date;
define _no_activo_dep		date;
define _vigencia_inic		date;
define _vigencia_uni		date;


SET ISOLATION TO DIRTY READ;



begin
on exception set _error, _error_isam, _error_desc
   return _error,_error_desc;
end exception

drop table if exists temp_det;
let v_filtros = sp_pro34('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','018;','*','1');

--drop table if exists tmp_sinis;
--let v_filtros = sp_rec704('001','001',a_periodo_desde,a_periodo_hasta,'*','*','018;','*','*','*','*','*'); 



drop table if exists tmp_primas_censo;
create temp table tmp_primas_censo(
anio					smallint,
no_poliza				char(10),
no_documento			char(20),
no_unidad				char(5),
no_endoso				char(5),
cod_asegurado			char(10),
sexo					char(1),
edad_endoso				smallint,
fecha_aniversario		date,
fecha_suscripcion		date,
fecha_efectiva			date,
no_activo_desde			date,
cod_producto			char(5),
prima_endoso			dec(16,2),
prima_uni				dec(16,2),
porc_recargo_uni		dec(16,2),
recargo_uni				dec(16,2),
prima_neta_uni			dec(16,2),
activo_dep				smallint,
prima_dep				dec(16,2),
recargo_dep				dec(16,2),
tipo_asegurado			char(1),
primary key (anio, no_poliza,no_endoso,no_unidad,cod_asegurado)) with no log;



--set debug file to "verif_primas_salud_tcn.trc";
--trace on;

foreach
	select tmp.no_poliza,
		   tmp.no_endoso,
		   sum(tmp.prima)
	  into _no_poliza,
		   _no_endoso,
		   _prima_tot
	  from temp_det tmp
	 inner join emipomae emi on emi.no_poliza = tmp.no_poliza and emi.cod_subramo not  in ('010','012')
	 where tmp.prima <> 0
	   and tmp.seleccionado = 1
	 group by tmp.no_poliza,tmp.no_endoso

	foreach
		select mae.periodo[1,4],
			   mae.no_documento,
			   emi.vigencia_inic,
			   mae.no_poliza,
			   uni.no_unidad,
			   mae.vigencia_inic,
			   sub.nombre,
			   uni.cod_producto,
			   prd.nombre,
			   emi.estatus_poliza,
			   emi.fecha_cancelacion,
			   uni.cod_cliente,
			   ase.sexo,
			   ase.fecha_aniversario,
			   emi.fecha_suscripcion,
			   uni.prima,
			   uni.recargo,
			   uni.prima_suscrita,
			   pun.activo,
			   pun.no_activo_desde,
			   pun.fecha_emision,
			   pun.vigencia_inic,
			   rnu.porc_recargo
		  into _anio_endoso,
			   _no_documento,
			   _vigencia_inic,
			   _no_poliza,
			   _no_unidad,
			   _vigencia_endoso,
			   _nom_subramo,
			   _cod_producto,
			   _nom_producto,
			   _estatus_poliza,
			   _fecha_cancelacion,
			   _cod_asegurado,
			   _sexo,
			   _fecha_nacimiento,
			   _fecha_suscripcion,
			   _prima_unidad,
			   _recargo,
			   _prima_neta,
			   _activo_uni,
			   _no_activo_desde,
			   _fecha_emision_u,
			   _vigencia_uni,
			   _porc_recar_uni
		  from endedmae mae
		 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_endoso = mae.no_endoso
		 inner join emipomae emi on emi.no_poliza = mae.no_poliza
		 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
		 inner join cliclien ase on ase.cod_cliente = uni.cod_cliente
		 inner join prdprod prd on prd.cod_producto = uni.cod_producto
		 inner join emipouni pun on pun.no_poliza = uni.no_poliza and pun.no_unidad = uni.no_unidad
		  left join endunire rnu on uni.no_poliza = rnu.no_poliza and uni.no_endoso = rnu.no_endoso and uni.no_unidad = rnu.no_unidad
		 --inner join emidepen dep on dep.no_poliza = uni.no_poliza and dep.no_unidad = uni.no_unidad
		 where mae.no_poliza = _no_poliza
		   and mae.no_endoso = _no_endoso

		let _cnt_dep = 1;	
		
		foreach
			select dep.cod_cliente,
				   dep.fecha_efectiva,
				   dep.date_added,
				   dep.no_activo_desde,
				   dep.activo,
				   dep.prima,
				   cli.sexo,
				   cli.fecha_aniversario,
				   rde.por_recargo
			  into _cod_dependiente,
				   _fecha_efect_dep,
				   _date_added_dep,
				   _no_activo_dep,
				   _activo,
				   _prima_dep,
				   _sexo_dep,
				   _fecha_nac_dep,			   
				   _por_recargo_dep
			  from emidepen dep
			 inner join cliclien cli on cli.cod_cliente = dep.cod_cliente
			  left join emiderec rde on rde.no_poliza = dep.no_poliza and rde.no_unidad = dep.no_unidad and rde.cod_cliente = dep.cod_cliente
			 where dep.no_poliza = _no_poliza
			   and dep.no_unidad = _no_unidad
			   and dep.fecha_efectiva <= _vigencia_endoso

			if _no_activo_dep is not null and _activo = 0 then
				if _no_activo_dep < _vigencia_endoso then
					continue foreach;
				end if
			end if
			
			if _por_recargo_dep is null then
				let _por_recargo_dep = 0;
			end if
			
			let _edad_endoso = sp_sis78(_fecha_nac_dep,_vigencia_endoso);
			
			insert into tmp_primas_censo(
			anio,
			no_poliza,
			no_documento,
			no_unidad,
			no_endoso,
			cod_asegurado,		
			sexo,
			edad_endoso,
			fecha_aniversario,	
			fecha_suscripcion,	
			fecha_efectiva,
			no_activo_desde,
			cod_producto,
			prima_endoso,
			prima_uni,
			porc_recargo_uni,
			recargo_uni,
			prima_neta_uni,
			activo_dep,
			prima_dep,
			recargo_dep,
			tipo_asegurado)
			values(
			_anio_endoso,      
			_no_poliza,        
			_no_documento,     
			_no_unidad,        
			_no_endoso,
			_cod_dependiente,    
			_sexo,
			_edad_endoso,
			_fecha_nac_dep, 
			_fecha_suscripcion,
			_fecha_efect_dep,  
			_no_activo_dep,
			_cod_producto,
			_prima_tot,
			_prima_unidad,
			_porc_recar_uni,
			_recargo,
			_prima_neta,
			_activo,
			_prima_dep,
			_por_recargo_dep,
			'D'		
			);			
		end foreach
		
		let _edad_endoso = sp_sis78(_fecha_nacimiento,_vigencia_endoso);		
		
		begin
			on exception in(-239,-268)
			end exception

			insert into tmp_primas_censo(
			anio,						
			no_poliza,                  
			no_documento,               
			no_unidad,                  
			no_endoso,                  
			cod_asegurado,		        
			sexo,                       
			edad_endoso,                
			fecha_aniversario,	        
			fecha_suscripcion,	        
			fecha_efectiva,             
			no_activo_desde,            
			cod_producto,               
			prima_endoso,               
			prima_uni,                  
			porc_recargo_uni,           
			recargo_uni,                
			prima_neta_uni,             
			prima_dep,                  
			recargo_dep,                
			tipo_asegurado)             
			values(                     
			_anio_endoso,      
			_no_poliza,        
			_no_documento,     
			_no_unidad,        
			_no_endoso,
			_cod_asegurado,    
			_sexo,
			_edad_endoso,
			_fecha_nacimiento, 
			_fecha_suscripcion,
			_vigencia_uni,  
			_no_activo_desde,
			_cod_producto,
			_prima_tot,
			_prima_unidad,
			_porc_recar_uni,
			_recargo,
			_prima_neta,
			0,
			0,
			'A'		
			);
		end
	end foreach
end foreach
/*
foreach with hold
	select	anio,				
			no_poliza,
			no_documento,
			no_unidad,
			nombre_subramo,
			cod_producto,
			nombre_producto,
			estatus_poliza,
			fecha_cancelacion,
			vigencia_inic,
			cod_asegurado,
			sexo,
			fecha_aniversario,
			fecha_suscripcion,
			date_added,
			fecha_efectiva,
			no_activo_desde,
			prima_dep,
			prima_neta_pol,
			prima,
			recargo,
			prima_neta_uni,
			tipo_asegurado
	  into	_anio_endoso,
			_no_poliza,
			_no_documento,
			_no_unidad,
			_nom_subramo,
			_cod_producto,
			_nom_producto,
			_estatus_poliza,
			_fecha_cancelacion,
			_vigencia_inic,
			_cod_asegurado,
			_sexo,
			_fecha_nacimiento,
			_fecha_suscripcion,
			_date_added_dep,	
			_fecha_efect_dep,	
			_no_activo_dep,		
			_prima_dep,			
			_prima_tot,
			_prima_unidad,
			_recargo,
			_prima_neta,
			_tipo_asegurado
	  from tmp_primas_salud
	
	let _pagado_total = 0.00;
	let _pagado_bruto = 0.00;
	
	select sum(pagado_total),
		   sum(pagado_bruto)
	  into _pagado_total,
		   _pagado_bruto
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo
	 inner join tmp_primas_salud sal on sal.no_poliza = rec.no_poliza and sal.no_unidad = rec.no_unidad
	 where sal.no_poliza = _no_poliza
	   and sal.no_unidad = _no_unidad 
	   and tmp.seleccionado = 1;
	 
	if _pagado_total is null then
		let _pagado_total = 0.00;
	end if
	
	if _pagado_bruto is null then
		let _pagado_bruto = 0.00;
	end if
	 
	let _mes = month(_vigencia_inic);
	let _dia = day(_vigencia_inic);
	
	let _vigencia_desde = mdy(_mes,_dia,_anio_endoso);
	let _periodo_desde = sp_sis39(_vigencia_desde);
	
	let _vigencia_hasta = mdy(_mes,_dia,_anio_endoso + 1);
	let _periodo_hasta = sp_sis39(_vigencia_hasta);
	
	let _prima_neta_anual = 0.00;
	let _prima_susc_anual = 0.00;
	let _recargo_anual = 0.00;
	let _prima_anual = 0.00;
	
	if _tipo_asegurado = 'A' then
	
		if _periodo_hasta <= '2023-08' then
			select sum(uni.prima_neta),
				   sum(uni.prima),
				   sum(uni.recargo),
				   sum(uni.prima_suscrita)
			  into _prima_neta_anual,
				   _prima_anual,
				   _recargo_anual,
				   _prima_susc_anual
			  from endedmae mae
			 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_endoso = mae.no_endoso
			 where mae.no_poliza = _no_poliza
			   and uni.no_unidad = _no_unidad 
			   and mae.periodo between _periodo_desde and _periodo_hasta
			   and mae.actualizado = 1;
		else
			select sum(uni.prima_neta),
				   sum(uni.prima),
				   sum(uni.recargo),
				   sum(uni.prima_suscrita)
			  into _prima_neta_anual,
				   _prima_anual,
				   _recargo_anual,
				   _prima_susc_anual
			  from emipomae mae
			 inner join emipouni uni on uni.no_poliza = mae.no_poliza
			 where mae.no_poliza = _no_poliza
			   and uni.no_unidad = _no_unidad;
		end if
	end if

	if _estatus_poliza in (1,3) then
		let _estatus = 'VIGENTE';
	else
		let _estatus = 'CANCELADA';
		let _anio = year(_fecha_cancelacion);
		let _prima_neta_anual = 0.00;
		let _prima_susc_anual = 0.00;
		let _recargo_anual = 0.00;
		let _prima_anual = 0.00;
		
		if _tipo_asegurado = 'A' then
			if _anio = _anio_endoso then
				select sum(uni.prima_neta),
					   sum(uni.prima),
					   sum(uni.recargo),
					   sum(uni.prima_suscrita)
				  into _prima_neta_anual,
					   _prima_anual,
					   _recargo_anual,
					   _prima_susc_anual
				  from emipomae mae
				 inner join emipouni uni on uni.no_poliza = mae.no_poliza
				 where mae.no_poliza = _no_poliza
				   and uni.no_unidad = _no_unidad;
			end if
		end if
	end if

	return	_anio_endoso,
			_no_documento,
			_no_poliza,
			_no_unidad,
			_nom_subramo,
			_cod_producto,
			_nom_producto,
			_estatus,
			_fecha_cancelacion,
			_vigencia_inic,
			_cod_asegurado,
			_sexo,
			_fecha_nacimiento,
			_fecha_suscripcion,
			_date_added_dep,	
			_fecha_efect_dep,	
			_no_activo_dep,		
			_prima_dep,			
			_prima_tot,
			_prima_unidad,
			_recargo,
			_prima_neta,
			_pagado_total,
			_pagado_bruto,
			_prima_anual,
			_recargo_anual,
			_prima_neta_anual,
			_prima_susc_anual,
			_tipo_asegurado
	with resume;
end foreach

let _prima_tot = 0.00;

foreach
	select rec.no_poliza,
		   rec.no_unidad,
		   sum(tmp.pagado_total),
		   sum(tmp.pagado_bruto)
	  into _no_poliza,
		   _no_unidad,
		   _pagado_total,
		   _pagado_bruto
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo
	 inner join emipomae emi on emi.no_poliza = rec.no_poliza and emi.cod_subramo not in ('010','012')
	  left join tmp_primas_salud sal on sal.no_poliza = rec.no_poliza and sal.no_unidad = rec.no_unidad
	 where tmp.seleccionado = 1
	   and sal.no_poliza is null
	 group by 1,2

	select emi.no_documento,
		   emi.vigencia_inic,
		   sub.nombre,
		   uni.cod_producto,
		   prd.nombre,
		   emi.estatus_poliza,
		   emi.fecha_cancelacion,
		   uni.cod_asegurado,
		   ase.sexo,
		   ase.fecha_aniversario,
		   emi.fecha_suscripcion,
		   uni.prima,
		   uni.recargo,
		   uni.prima_suscrita
	  into _no_documento,
		   _vigencia_inic,
		   _nom_subramo,
		   _cod_producto,
		   _nom_producto,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _cod_asegurado,
		   _sexo,
		   _fecha_nacimiento,
		   _fecha_suscripcion,
		   _prima_unidad,
		   _recargo,
		   _prima_neta		   
	  from emipomae emi
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
	 inner join prdprod prd on prd.cod_producto = uni.cod_producto
	 where emi.no_poliza = _no_poliza
	   and uni.no_unidad = _no_unidad;
	 
	let _mes = month(_vigencia_inic);
	let _dia = day(_vigencia_inic);
	
	let _vigencia_desde = mdy(_mes,_dia,_anio_endoso);
	let _periodo_desde = sp_sis39(_vigencia_desde);
	
	let _vigencia_hasta = mdy(_mes,_dia,_anio_endoso + 1);
	let _periodo_hasta = sp_sis39(_vigencia_hasta);
	
	let _prima_neta_anual = 0.00;
	let _prima_susc_anual = 0.00;
	let _recargo_anual = 0.00;
	let _prima_anual = 0.00;
	
	if _periodo_hasta <= '2023-05' then
		select sum(uni.prima_neta),
			   sum(uni.prima),
			   sum(uni.recargo),
			   sum(uni.prima_suscrita)
		  into _prima_neta_anual,
			   _prima_anual,
			   _recargo_anual,
			   _prima_susc_anual
		  from endedmae mae
		 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_endoso = mae.no_endoso
		 where mae.no_poliza = _no_poliza
		   and uni.no_unidad = _no_unidad 
		   and mae.periodo between _periodo_desde and _periodo_hasta
		   and mae.actualizado = 1;
	else
		select sum(uni.prima_neta),
			   sum(uni.prima),
			   sum(uni.recargo),
			   sum(uni.prima_suscrita)
		  into _prima_neta_anual,
			   _prima_anual,
			   _recargo_anual,
			   _prima_susc_anual
		  from emipomae mae
		 inner join emipouni uni on uni.no_poliza = mae.no_poliza
		 where mae.no_poliza = _no_poliza
		   and uni.no_unidad = _no_unidad;
	end if

	if _estatus_poliza in (1,3) then
		let _estatus = 'VIGENTE';
	else
		let _estatus = 'CANCELADA';
		let _anio = year(_fecha_cancelacion);
		
		if _anio = _anio_endoso then
			select sum(uni.prima_neta),
				   sum(uni.prima),
				   sum(uni.recargo),
				   sum(uni.prima_suscrita)
			  into _prima_neta_anual,
				   _prima_anual,
				   _recargo_anual,
				   _prima_susc_anual
			  from emipomae mae
			 inner join emipouni uni on uni.no_poliza = mae.no_poliza
			 where mae.no_poliza = _no_poliza
			   and uni.no_unidad = _no_unidad;
		end if		
	end if

	return	_anio_endoso,
			_no_documento,
			_no_poliza,
			_no_unidad,
			_nom_subramo,
			_cod_producto,
			_nom_producto,
			_estatus,
			_fecha_cancelacion,
			_vigencia_inic,
			_cod_asegurado,
			_sexo,
			_fecha_nacimiento,
			_fecha_suscripcion,
			_prima_tot,
			_prima_unidad,
			_recargo,
			_prima_neta,
			_pagado_total,
			_pagado_bruto,
			_prima_anual,
			_recargo_anual,
			_prima_neta_anual,
			_prima_susc_anual
	with resume;
end foreach*/

return 0,'Carga Exitosa';
end
end procedure;