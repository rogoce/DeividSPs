
-- Creado: 30/10/2024 - Autor: Armando Moreno M.
--execute procedure sp_tarifas_salud_n2()

drop procedure sp_tarifas_salud_n2;
create procedure sp_tarifas_salud_n2(a_periodo char(7))
returning integer;

define v_filtros			char(255);
define _nom_corredor		varchar(150);
define _nom_zona			varchar(150);
define _error_desc			varchar(50);
define _asegurado			varchar(50);
define _dependiente		varchar(50);
define _recargo_uni		varchar(50);
define _recargo_dep		varchar(50);
define v_desc_nombre		char(35);
define _periodo_pago		char(20);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza			char(10);
define _cod_asegurado		char(10);
define v_nopoliza			char(10);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _cod_recargo		char(3);
define _cod_perpago		char(3);
define _prima_dependiente	dec(16,2);
define _prima_neta_tot	dec(16,2);
define _prima_neta_pol	dec(16,2);
define _prima_desde_dep	dec(16,2);
define _prima_hasta_dep	dec(16,2);
define _prima_desde		dec(16,2);
define _prima_hasta		dec(16,2);
define _porc_recarg_uni	dec(16,2);
define _porc_recarg_dep	dec(16,2);
define _porc_aum_edad		dec(5,2);
define _fecha_aniv_dep	date;
define _fecha_aniv_uni	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _vigencia2022		date;
define _vigencia2023		date;
define _vigencia2024		date;
define _dia_vigencia		smallint;
define _mes_vigencia		smallint;
define _edad_dep_d		smallint;
define _edad_dep_h		smallint;
define _edad_aseg_d		smallint;
define _edad_aseg_h		smallint;
define _edad_aseg_22		smallint;
define _edad_aseg_23		smallint;
define _edad_aseg_24		smallint;
define _edad_dep_22		smallint;
define _edad_dep_23		smallint;
define _edad_dep_24		smallint;
define _mes_periodo		smallint;
define _meses				smallint;
define _error_isam,_error   integer;
define _periodo_validar     char(7);

set isolation to dirty read;

--set debug file to "sp_tarifas_salud_n2.trc";
--trace on;
create temp table tmp_tar_salud_n(
no_documento      char(20),
no_unidad		  char(5),
cod_asegurado     char(10),
cod_dependiente   char(10)) with no log;

create index tmp_tar_s_ix1 on tmp_tar_salud_n(no_documento);

begin
on exception set _error,_error_isam,_error_desc

	if _no_documento is null then
		let _no_documento = '';
	end if	
	
	return _error;
end exception                                            

let _nom_corredor = '';
let _nom_zona = '';

let _mes_periodo = a_periodo[6,7];
let _fecha_desde = mdy(_mes_periodo,1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);

foreach                                           
	select emi.no_documento,               
		    uni.no_unidad,                  
			uni.cod_asegurado,              
			cli.nombre,                     
			cli.fecha_aniversario,         
			uni.prima_neta,                 
			ure.cod_recargo,                
			rec.nombre,                     
			ure.porc_recargo,               
			emi.vigencia_inic,              
			emi.vigencia_final,              
			per.cod_perpago,
			per.nombre,
			per.meses,
			dep.cod_cliente,
			cld.nombre,
			cld.fecha_aniversario,
			dep.prima,
			rea.nombre,
			dre.por_recargo,
			emi.prima_neta,
			uni.cod_producto
	  into _no_documento,			
		   _no_unidad,             
		   _cod_asegurado,
		   _asegurado,             
		   _fecha_aniv_uni,        
		   _prima_neta_tot,        
		   _cod_recargo,           
		   _recargo_uni,           
		   _porc_recarg_uni,      
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_perpago,           
		   _periodo_pago,          
		   _meses,                 
		   _cod_dependiente,      
		   _dependiente,           
		   _fecha_aniv_dep,        
		   _prima_dependiente,    
		   _recargo_dep,           
		   _porc_recarg_dep,      
		   _prima_neta_pol,        
		   _cod_producto           
	  from emipomae emi
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza and activo = 1
	 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
	 inner join cobperpa per on per.cod_perpago = emi.cod_perpago
	  left join emiunire ure on ure.no_poliza = uni.no_poliza and ure.no_unidad = uni.no_unidad
	  left join emirecar rec on rec.cod_recargo = ure.cod_recargo
	  left join emidepen dep on dep.no_poliza = uni.no_poliza and uni.no_unidad = dep.no_unidad and dep.activo = 1
	  left join cliclien cld on cld.cod_cliente = dep.cod_cliente
	  left join emiderec dre on dre.no_poliza = dep.no_poliza and dre.no_unidad = dep.no_unidad and dre.cod_cliente = dep.cod_cliente
	  left join emirecar rea on rea.cod_recargo = dre.cod_recargo
	 where emi.cod_compania   = '001'
	   and emi.cod_ramo       = '018'
	   and emi.vigencia_final >= _fecha_desde
	   and emi.vigencia_final <= _fecha_hasta
	   and emi.estatus_poliza in (1,3)
	   and emi.actualizado    = 1
	   and emi.cod_tipoprod  in ('001','005')
	   and emi.cod_subramo not in ('010','012')
	   and month(emi.vigencia_inic) = _mes_periodo
	 order by emi.no_documento

	let _mes_vigencia = month(_vigencia_inic);
	let _dia_vigencia = day(_vigencia_inic);
	
	let _vigencia2022 = mdy(_mes_vigencia,_dia_vigencia,2022);
	let _vigencia2023 = mdy(_mes_vigencia,_dia_vigencia,2023);
	let _vigencia2024 = mdy(_mes_vigencia,_dia_vigencia,2024);
	
	let _edad_aseg_22 = sp_sis78(_fecha_aniv_uni,_vigencia2022);
	let _edad_aseg_23 = sp_sis78(_fecha_aniv_uni,_vigencia2023);
	let _edad_aseg_24 = sp_sis78(_fecha_aniv_uni,_vigencia2024);

	let _edad_dep_22 = sp_sis78(_fecha_aniv_dep,_vigencia2022);
	let _edad_dep_23 = sp_sis78(_fecha_aniv_dep,_vigencia2023);
	let _edad_dep_24 = sp_sis78(_fecha_aniv_dep,_vigencia2024);

	
	let _prima_desde = 0.00;
	let _prima_hasta = 0.00;
	
	if _mes_vigencia > _mes_periodo then -- Aumento entre 2022 y 2023
		let _edad_aseg_d = _edad_aseg_22;
		let _edad_aseg_h = _edad_aseg_23;
		let _edad_dep_d = _edad_dep_22;
		let _edad_dep_h = _edad_dep_23;--
	else						-- Aumento entre 2023 y 2024
		let _edad_aseg_d = _edad_aseg_23;
		let _edad_aseg_h = _edad_aseg_24;
		let _edad_dep_d = _edad_dep_23;
		let _edad_dep_h = _edad_dep_24;
	end if
	
	select prima
	  into _prima_desde
	  from prdtaeda tar 
	 where tar.cod_producto = _cod_producto
	   and _edad_aseg_d between edad_desde and edad_hasta;

	select prima
	  into _prima_hasta
	  from prdtaeda tar 
	 where tar.cod_producto = _cod_producto
	   and _edad_aseg_h between edad_desde and edad_hasta;

	select prima
	  into _prima_desde_dep
	  from prdtaeda tar 
	 where tar.cod_producto = _cod_producto
	   and _edad_dep_d between edad_desde and edad_hasta;

	select prima
	  into _prima_hasta_dep
	  from prdtaeda tar 
	 where tar.cod_producto = _cod_producto
	   and _edad_dep_h between edad_desde and edad_hasta;

	if _prima_desde is null then
		let _prima_desde = 0.00;
	end if
	
	if _prima_hasta is null then
		let _prima_hasta = 0.00;
	end if
	
	if _prima_desde <> _prima_hasta then
		let _porc_aum_edad = round(((_prima_hasta - _prima_desde)/_prima_desde) * 100,2);
	else
		let _porc_aum_edad = 0.00;
	end if
	
	--Validacion de exclusion de polizas para insercion del recargo. Caso 14171 Fany 29/06/2025
	let _periodo_validar = null;
	foreach
		select periodo
		  into _periodo_validar
		  from prd_sal_rec_exc
		 where no_documento = _no_documento
		   and activo = 1
		exit foreach;   
	end foreach
	if _periodo_validar is not null then
		if a_periodo < _periodo_validar then
			continue foreach;
		end if
	end if
	
	insert into tmp_tar_salud_n(
	no_documento,   
	no_unidad,
	cod_asegurado,
	cod_dependiente)
	values(
	_no_documento,
	_no_unidad,
	_cod_asegurado,
	_cod_dependiente);

end foreach
return 0;
end
end procedure;   