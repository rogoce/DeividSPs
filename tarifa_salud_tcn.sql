-- Informes de Detalle de Produccion por Grupo
-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo
-- execute procedure verif_primas_salud_tcn('2018-01', '2023-12')

drop procedure verif_primas_salud_tcn;
create procedure "informix".verif_primas_salud_tcn(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	smallint	as anio_endoso,
			char(20)	as no_documento,
			char(5)		as no_unidad,               
			char(10)	as cod_asegurado,           
			varchar(50)	as subramo,                 
			char(5)		as cod_producto,            
			varchar(50)	as nom_producto,            
			date		as fecha_efectiva,          
			char(20)	as estatus_poliza,          
			date		as fecha_cancelacion,       
			char(1)		as sexo,
			smallint	as edad_emision,
			date		as fecha_nacimiento,		
			dec(16,2)	as prima_anual,
			dec(16,2)	as recargo_anual,
			dec(16,2)	as prima_anual_total,             
			dec(16,2)	as prima_suscrita_anual,             
			char(1)		as tipo_asegurado,
			dec(9,6)	as porc_proporcion,
			dec(16,2)	as pagado_total,
			dec(16,2)	as pagado_bruto;

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
define _sexo				char(1);
define _tipo				char(1);
define _porc_proporcion		dec(9,6);
define _prima_anual_tot_ase	dec(16,2);
define _prima_anual_total	dec(16,2);
define _prima_susc_anual	dec(16,2);
define _recargo_anual		dec(16,2);
define _pagado_bruto		dec(16,2);
define _recargo_dep			dec(16,2);
define _recargo_uni			dec(16,2);
define _pagado_total		dec(16,2);
define _prima_anual			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_tar			dec(16,2);
define _prima_tot			dec(16,2);
define _recargo				dec(16,2);
define _estatus_poliza		smallint;
define _anio_endoso			smallint;
define _edad_endoso			smallint;
define _mes_desde			smallint;
define _mes_hasta			smallint;
define _anio				smallint;
define _dia					smallint;
define _mes					smallint;
define _error_isam			integer;
define _error				integer;
define v_estatus			smallint;
define _fecha_cancelacion	date;
define _fecha_suscripcion	date;
define _fecha_nacimiento	date;
define _fecha_emision_u		date;
define _fecha_efectiva		date;
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
   return _error,		
		  '',           
		  '',           
		  '',           
		  _error_desc,  
		  '',           
		  '',           
		  '01/01/1900', 
		  '',           
		  '01/01/1900', 
		  '',           
		  0,            
		  '01/01/1900', 
		  0.00,        
		  0.00,        
		  0.00,        
		  0.00,        
		  '',           
		  0.00,
		  0.00,
		  0.00;
end exception           

drop table if exists tmp_primas_salud;
create temp table tmp_primas_salud(
anio					smallint,	
no_poliza				char(10),      
no_documento			char(20),      
no_unidad				char(5),       
nombre_subramo			varchar(50),   
cod_producto			char(5),       
nombre_producto			varchar(50),   
edad_emision			smallint,      
estatus_poliza			varchar(30),   
fecha_cancelacion		date,          
cod_asegurado			char(10),      
sexo					char(1),       
fecha_aniversario		date,          
fecha_efectiva			date,          
prima_anual				dec(16,2),     
recargo_anual			dec(16,2),     
prima_anual_total		dec(16,2),     
porc_proporcion			dec(9,6),
tipo_asegurado			char(1),
primary key (anio, no_poliza,no_unidad,cod_asegurado)) with no log;


drop table if exists tmp_primas_censo;
call verif_primas_salud_tcnV2(a_periodo_desde,a_periodo_hasta) returning _error,_error_desc;

drop table if exists tmp_sinis;
let v_filtros = sp_rec704('001','001',a_periodo_desde,a_periodo_hasta,'*','*','018;','*','*','*','*','*'); 

--set debug file to "tarifa_salud_tcn.trc";
--trace on;
foreach
	select tmp.anio,
		   tmp.no_poliza,
		   tmp.no_documento,
		   tmp.no_unidad,
		   tmp.cod_asegurado,
		   tmp.cod_producto,
		   prd.nombre,
		   emi.estatus_poliza,
		   tmp.fecha_efectiva,
		   emi.fecha_cancelacion,
		   tmp.sexo,
		   tmp.fecha_aniversario,
		   sub.nombre,
		   tmp.tipo_asegurado,
		   min(tmp.edad_endoso)
	  into _anio,
		   _no_poliza,
		   _no_documento,
		   _no_unidad,
		   _cod_asegurado,
		   _cod_producto,
		   _nom_producto,
		   _estatus_poliza,
		   _fecha_efectiva,
		   _fecha_cancelacion,
		   _sexo,
		   _fecha_nacimiento,
		   _nom_subramo,
		   _tipo_asegurado,
		   _edad_endoso
	  from tmp_primas_censo tmp
	 inner join endedmae mae on mae.no_poliza = tmp.no_poliza and mae.no_endoso = tmp.no_endoso
	 inner join endtimov mov on mov.cod_endomov = mae.cod_endomov
	 inner join prdprod prd on prd.cod_producto = tmp.cod_producto
	 inner join emipomae emi on emi.no_poliza = tmp.no_poliza
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
--	 where mae.cod_endomov in ('011','014')
	 group by tmp.anio,
		   tmp.no_poliza,
		   tmp.no_documento,
		   tmp.no_unidad,
		   tmp.cod_asegurado,
		   tmp.cod_producto,
		   prd.nombre,
		   emi.estatus_poliza,
		   tmp.fecha_efectiva,
		   emi.fecha_cancelacion,
		   tmp.sexo,
		   tmp.fecha_aniversario,
		   sub.nombre,
		   tmp.tipo_asegurado
	 order by tmp.anio,sub.nombre,tmp.no_documento,tmp.no_unidad,tmp.cod_asegurado

	if _estatus_poliza in (1,3) then
		let _estatus = 'VIGENTE';
	else
		let _estatus = 'CANCELADA';
	end if
  
	foreach
		select tar.prima,
			   min(mae.periodo[6,7]),
			   max(mae.periodo[6,7]),
			   max(tmp.porc_recargo_uni),
			   max(tmp.recargo_dep)
		  into _prima_tar,
			   _mes_desde,
			   _mes_hasta,
			   _recargo_uni,
			   _recargo_dep
		  from tmp_primas_censo tmp
		 inner join endedmae mae on mae.no_poliza = tmp.no_poliza and mae.no_endoso = tmp.no_endoso
		  left join prdtaeda tar on tar.cod_producto = tmp.cod_producto and tmp.edad_endoso between tar.edad_desde and tar.edad_hasta 
		 where tmp.anio = _anio
		   and tmp.no_documento = _no_documento
		   and tmp.no_unidad = _no_unidad
		   and tmp.cod_asegurado = _cod_asegurado
		 group by tmp.tipo_asegurado,tar.prima
		 
		let _prima_anual = 0.00;
		let _recargo_anual = 0.00;
		let _prima_anual_total = 0.00;

		let _prima_anual = _prima_tar * (_mes_hasta - _mes_desde + 1);
		
		if _recargo_uni is null then
			let _recargo_uni = 0.00;
		end if
		if _recargo_dep is null then
			let _recargo_dep = 0.00;
		end if
		
		if _tipo_asegurado = 'A' then
			let _recargo_anual = _prima_anual * (_recargo_uni/100);
		else
			let _recargo_anual = _prima_anual * (_recargo_dep/100);
		end if
		
		let _prima_anual_total = _prima_anual + _recargo_anual;
		
		begin
		on exception in(-239,-268)
			update tmp_primas_salud
			   set prima_anual = prima_anual + _prima_anual,
				   recargo_anual = recargo_anual +  _recargo_anual,
				   prima_anual_total = prima_anual_total + _prima_anual_total
			 where anio = _anio
			   and no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_asegurado = _cod_asegurado;
		end exception
		
			insert into tmp_primas_salud
			(anio,
			 no_documento,
			 no_poliza,
			 no_unidad,
			 nombre_subramo,
			 cod_producto,
			 nombre_producto,
			 estatus_poliza,
			 fecha_efectiva,
			 fecha_cancelacion,	
			 cod_asegurado,
			 sexo,
			 edad_emision,
			 fecha_aniversario,
			 prima_anual,
			 recargo_anual,
			 prima_anual_total,
			 tipo_asegurado)
			values
			(
			_anio,
			_no_documento,
			_no_poliza,
			_no_unidad,
			_nom_subramo,
			_cod_producto,
			_nom_producto,
			_estatus,
			_fecha_efectiva,
			_fecha_cancelacion,
			_cod_asegurado,
			_sexo,
			_edad_endoso,
			_fecha_nacimiento,
			_prima_anual,
			_recargo_anual,
			_prima_anual_total,
			_tipo_asegurado
			);
		end
	end foreach--Tarifa
end foreach--Asegurados por Año, Unidad, Poliza


foreach
	select anio,
		   no_poliza,
		   no_unidad,
		   sum(prima_anual_total)
	  into _anio,
		   _no_poliza,
		   _no_unidad,
		   _prima_anual_total
	  from tmp_primas_salud
	 group by anio,no_poliza,no_unidad,no_unidad
	 having sum(prima_anual_total) <> 0

	foreach 
		select cod_asegurado, prima_anual_total
		  into _cod_asegurado,_prima_anual_tot_ase
	      from tmp_primas_salud
		 where anio = _anio
		   and no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		
		update tmp_primas_salud
		   set porc_proporcion = (_prima_anual_tot_ase/ _prima_anual_total)*100
		 where anio = _anio
		   and no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_asegurado = _cod_asegurado;
	end foreach
end foreach

foreach
	select anio,
		   no_documento,
		   no_poliza,
		   no_unidad,
		   nombre_subramo,
		   cod_producto,
		   nombre_producto,
		   estatus_poliza,
		   fecha_efectiva,
		   fecha_cancelacion,
		   cod_asegurado,
		   sexo,
		   edad_emision,
		   fecha_aniversario,
		   prima_anual,
		   recargo_anual,
		   prima_anual_total,
		   tipo_asegurado,
		   porc_proporcion
	  into _anio,
		   _no_documento,
		   _no_poliza,
		   _no_unidad,
		   _nom_subramo,
		   _cod_producto,
		   _nom_producto,
		   _estatus,
		   _fecha_efectiva,
		   _fecha_cancelacion,
		   _cod_asegurado,
		   _sexo,
		   _edad_endoso,
		   _fecha_nacimiento,
		   _prima_anual,
		   _recargo_anual,
		   _prima_anual_total,
		   _tipo_asegurado,
		   _porc_proporcion
	  from tmp_primas_salud
	 order by nombre_subramo,cod_producto,no_documento,no_unidad,cod_asegurado

	select sum(prima_endoso)
	  into _prima_tot
	  from tmp_primas_censo
	 where anio = _anio
	   and no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and tipo_asegurado = 'A';
	   

	select sum(pagado_bruto),
		   sum(pagado_total)
	  into _pagado_bruto,
		   _pagado_total
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo 
	 inner join rectrmae trx on trx.no_tranrec = tmp.no_tranrec
	 where rec.no_poliza = _no_poliza
	   and rec.no_unidad = _no_unidad
	   and rec.cod_reclamante = _cod_asegurado
	   and trx.periodo[1,4] = _anio
	   and tmp.seleccionado = 1;
	   

	if _pagado_total is null then
		let _pagado_total = 0.00;
	end if
	
	if _pagado_bruto is null then
		let _pagado_bruto = 0.00;
	end if

	let _prima_neta = _prima_tot * (_porc_proporcion/100);

	return _anio,
		   _no_documento,
		   _no_unidad,
		   _cod_asegurado,
		   _nom_subramo,
		   _cod_producto,
		   _nom_producto,
		   _fecha_efectiva,
		   _estatus,
		   _fecha_cancelacion,
		   _sexo,
		   _edad_endoso,
		   _fecha_nacimiento,
		   _prima_anual,
		   _recargo_anual,
		   _prima_anual_total,
		   _prima_neta,
		   _tipo_asegurado,
		   _porc_proporcion,
		   _pagado_total,
		   _pagado_bruto 
		   with resume;
end foreach

end
end procedure;