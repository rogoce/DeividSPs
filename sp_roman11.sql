-- Informes de Detalle de Produccion por Grupo
-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo
--execute procedure verif_primas_salud_tcnV2('2018-01','2018-12')

drop procedure sp_roman11;
create procedure sp_roman11(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	smallint	as _error,				
			varchar(50)	as _error_desc;    

define v_filtros			char(255);
define _error_desc			varchar(50);
define _nom_subramo			varchar(50);
define _nom_producto		varchar(50);
define _no_motor            varchar(30);
define v_desc_nombre		char(35);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza,_placa    char(10);
define _cod_contratante		char(10);
define v_nopoliza			char(10);
define _periodo_endoso		char(7);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_endoso			char(5);
define _no_unidad,_cod_marca,_cod_modelo	char(5);
define v_noendoso			char(5);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define v_cod_subramo		char(3);
define v_forma_pago			char(3);
define _cod_ramo			char(3);
define s_tipopro,_cod_endomov char(3);
define s_cia,_cod_tipoveh   char(3);
define _tipo_produccion		char(1);
define _tipo_asegurado		char(1);
define _sexo_dep			char(1);
define _sexo,_uso_auto		char(1);
define _tipo,_tipo_pol   	char(1);
define _porc_partic_agt		dec(5,2);
define _porc_recar_uni		dec(5,2);
define v_porc_comis			dec(5,2);
define v_comision			dec(9,2);
define _prima_neta_anual	dec(16,2);
define _prima_susc_anual	dec(16,2);
define _prima_sus_uni	    dec(16,2);
define _prima_calc_dep		dec(16,2);
define _recargo_anual		dec(16,2);
define _pagado_bruto		dec(16,2);
define _prima_unidad		dec(16,2);
define _pagado_total		dec(16,2);
define _prima_anual			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_tot,_desc_uni			dec(16,2);
define _recargo,_suma_asegurada		dec(16,2);
define _estatus_poliza		smallint;
define _edad_endoso			smallint;
define _anio_endoso			smallint;
define _activo_uni			smallint;
define _activo				smallint;
define _cnt_dep				smallint;
define _anio				smallint;
define _dia,_ano_auto		smallint;
define _mes					smallint;
define _error_isam			integer;
define _error,_cnt,_cnt2	integer;
define v_estatus			smallint;
define _fecha_cancelacion	date;
define _fecha_suscripcion	date;
define _fecha_nacimiento	date;
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
let v_filtros = sp_pro34('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','020,002,023;','*','1');

--drop table if exists tmp_sinis;
--let v_filtros = sp_rec704('001','001',a_periodo_desde,a_periodo_hasta,'*','*','018;','*','*','*','*','*'); 

drop table if exists tmp_primas_censo;
create temp table tmp_primas_censo(
anio					smallint,
no_poliza				char(10),
no_documento			char(20),
no_unidad				char(5),
no_endoso				char(5),
cod_contratante			char(10),
sexo					char(1),
fecha_suscripcion		date,
cod_producto			char(5),
prima_endoso			dec(16,2),
prima_uni				dec(16,2),
porc_recargo_uni		dec(16,2),
recargo_uni				dec(16,2),
prima_neta_uni			dec(16,2),
tipo_poliza			    char(1),
placa                   char(10),
fecha_cancelacion       date,
ano_auto                smallint,
cod_marca               char(5),
cod_modelo              char(5),
cod_tipoveh             char(3),
uso_auto                char(1),
suma_asegurada          dec(16,2),
descuento_uni           dec(16,2),
prima_sus_uni           dec(16,2),
primary key (anio, no_poliza,no_endoso,no_unidad,cod_contratante)) with no log;


--set debug file to "verif_primas_salud_tcn.trc";
--trace on;

let _suma_asegurada = 0.00;
foreach
	select tmp.no_poliza,
		   tmp.no_endoso,
		   sum(tmp.prima)
	  into _no_poliza,
		   _no_endoso,
		   _prima_tot
	  from temp_det tmp
	 inner join emipomae emi on emi.no_poliza = tmp.no_poliza
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
			   emi.estatus_poliza,
			   emi.fecha_cancelacion,
			   ase.sexo,
			   ase.fecha_aniversario,
			   emi.fecha_suscripcion,
			   uni.prima,
			   uni.recargo,
			   uni.prima_suscrita,
			   pun.activo,
			   pun.fecha_emision,
			   pun.vigencia_inic,
			   rnu.porc_recargo,
			   emi.cod_contratante,
			   uni.suma_asegurada,
			   uni.descuento,
			   emi.cod_ramo,
			   uni.prima_neta,
			   mae.cod_endomov
		  into _anio_endoso,
			   _no_documento,
			   _vigencia_inic,
			   _no_poliza,
			   _no_unidad,
			   _vigencia_endoso,
			   _nom_subramo,
			   _cod_producto,
			   _estatus_poliza,
			   _fecha_cancelacion,
			   _sexo,
			   _fecha_nacimiento,
			   _fecha_suscripcion,
			   _prima_unidad,
			   _recargo,
			   _prima_sus_uni,
			   _activo_uni,
			   _fecha_emision_u,
			   _vigencia_uni,
			   _porc_recar_uni,
			   _cod_contratante,
			   _suma_asegurada,
			   _desc_uni,
			   _cod_ramo,
			   _prima_neta,
			   _cod_endomov
		  from endedmae mae
		 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_endoso = mae.no_endoso
		 inner join emipomae emi on emi.no_poliza = mae.no_poliza
		 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
		 inner join cliclien ase on ase.cod_cliente = uni.cod_cliente
		 inner join prdprod prd on prd.cod_producto = uni.cod_producto
		  left join emipouni pun on pun.no_poliza = uni.no_poliza and pun.no_unidad = uni.no_unidad
		  left join endunire rnu on uni.no_poliza = rnu.no_poliza and uni.no_endoso = rnu.no_endoso and uni.no_unidad = rnu.no_unidad
		 where mae.no_poliza = _no_poliza
		   and mae.no_endoso = _no_endoso
		   
		if _cod_ramo = '023' then
			let _tipo_pol = 'C';
		else
			let _tipo_pol = 'I';
		end if
	
		select count(*)
		  into _cnt
		  from emiauto
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then	--No esta en emiauto
			foreach
				select no_motor,
					   cod_tipoveh,
					   uso_auto
				  into _no_motor,
					   _cod_tipoveh,
					   _uso_auto
				  from endmoaut
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad
				   
				select placa,
					   ano_auto,
					   cod_marca,
					   cod_modelo
				  into _placa,
					   _ano_auto,
					   _cod_marca,
					   _cod_modelo
				  from emivehic
				 where no_motor = _no_motor;
				 
				insert into tmp_primas_censo(
				anio,
				no_poliza,
				no_documento,
				no_unidad,
				no_endoso,
				cod_contratante,
				sexo,
				fecha_suscripcion,	
				cod_producto,
				prima_endoso,
				prima_uni,
				porc_recargo_uni,
				recargo_uni,
				prima_sus_uni,
				tipo_poliza,
				placa,
				fecha_cancelacion,
				ano_auto,
				cod_marca,
				cod_modelo,
				cod_tipoveh,
				uso_auto,
				suma_asegurada,
				descuento_uni,
				prima_neta_uni)
				values(
				_anio_endoso,      
				_no_poliza,        
				_no_documento,     
				_no_unidad,        
				_no_endoso,
				_cod_contratante,
				_sexo,
				_fecha_suscripcion,
				_cod_producto,
				_prima_tot,
				_prima_unidad,
				_porc_recar_uni,
				_recargo,
				_prima_sus_uni,
				_tipo_pol,		
				_placa,
				_fecha_cancelacion,
				_ano_auto,
				_cod_marca,
				_cod_modelo,
				_cod_tipoveh,
				_uso_auto,
				_suma_asegurada,
				_desc_uni,
				_prima_neta);
				
				let _cnt = 1;	
			end foreach
			if _cnt = 0 then
			
				select count(*)
				  into _cnt2
		          from endmoaut
		         where no_poliza = _no_poliza
                   and no_unidad = _no_unidad;
		
				if _cnt2 is null then
					let _cnt2 = 0;
				end if
				if _cnt2 = 0 then
						let _cod_tipoveh = '001';
						let _uso_auto = 'P';
						let _no_motor = 'NO.TIENE';
						
						select placa,
							   ano_auto,
							   cod_marca,
							   cod_modelo
						  into _placa,
							   _ano_auto,
							   _cod_marca,
							   _cod_modelo
						  from emivehic
						 where no_motor = _no_motor;
						 
						insert into tmp_primas_censo(
						anio,
						no_poliza,
						no_documento,
						no_unidad,
						no_endoso,
						cod_contratante,
						sexo,
						fecha_suscripcion,	
						cod_producto,
						prima_endoso,
						prima_uni,
						porc_recargo_uni,
						recargo_uni,
						prima_sus_uni,
						tipo_poliza,
						placa,
						fecha_cancelacion,
						ano_auto,
						cod_marca,
						cod_modelo,
						cod_tipoveh,
						uso_auto,
						suma_asegurada,
						descuento_uni,
						prima_neta_uni)
						values(
						_anio_endoso,      
						_no_poliza,        
						_no_documento,     
						_no_unidad,        
						_no_endoso,
						_cod_contratante,
						_sexo,
						_fecha_suscripcion,
						_cod_producto,
						_prima_tot,
						_prima_unidad,
						_porc_recar_uni,
						_recargo,
						_prima_sus_uni,
						_tipo_pol,		
						_placa,
						_fecha_cancelacion,
						_ano_auto,
						_cod_marca,
						_cod_modelo,
						_cod_tipoveh,
						_uso_auto,
						_suma_asegurada,
						_desc_uni,
						_prima_neta);
				else
					foreach
						select no_motor,
							   cod_tipoveh,
							   uso_auto
						  into _no_motor,
							   _cod_tipoveh,
							   _uso_auto
						  from endmoaut
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   
						select placa,
							   ano_auto,
							   cod_marca,
							   cod_modelo
						  into _placa,
							   _ano_auto,
							   _cod_marca,
							   _cod_modelo
						  from emivehic
						 where no_motor = _no_motor;
						 
						insert into tmp_primas_censo(
						anio,
						no_poliza,
						no_documento,
						no_unidad,
						no_endoso,
						cod_contratante,
						sexo,
						fecha_suscripcion,	
						cod_producto,
						prima_endoso,
						prima_uni,
						porc_recargo_uni,
						recargo_uni,
						prima_sus_uni,
						tipo_poliza,
						placa,
						fecha_cancelacion,
						ano_auto,
						cod_marca,
						cod_modelo,
						cod_tipoveh,
						uso_auto,
						suma_asegurada,
						descuento_uni,
						prima_neta_uni)
						values(
						_anio_endoso,      
						_no_poliza,        
						_no_documento,     
						_no_unidad,        
						_no_endoso,
						_cod_contratante,
						_sexo,
						_fecha_suscripcion,
						_cod_producto,
						_prima_tot,
						_prima_unidad,
						_porc_recar_uni,
						_recargo,
						_prima_sus_uni,
						_tipo_pol,		
						_placa,
						_fecha_cancelacion,
						_ano_auto,
						_cod_marca,
						_cod_modelo,
						_cod_tipoveh,
						_uso_auto,
						_suma_asegurada,
						_desc_uni,
						_prima_neta);
						exit foreach;
					end foreach
				end if
			end if
		else	
			foreach
				select no_motor,
					   cod_tipoveh,
					   uso_auto
				  into _no_motor,
					   _cod_tipoveh,
					   _uso_auto
				  from emiauto
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   
				select placa,
					   ano_auto,
					   cod_marca,
					   cod_modelo
				  into _placa,
					   _ano_auto,
					   _cod_marca,
					   _cod_modelo
				  from emivehic
				 where no_motor = _no_motor;
				 
				insert into tmp_primas_censo(
				anio,
				no_poliza,
				no_documento,
				no_unidad,
				no_endoso,
				cod_contratante,
				sexo,
				fecha_suscripcion,	
				cod_producto,
				prima_endoso,
				prima_uni,
				porc_recargo_uni,
				recargo_uni,
				prima_sus_uni,
				tipo_poliza,
				placa,
				fecha_cancelacion,
				ano_auto,
				cod_marca,
				cod_modelo,
				cod_tipoveh,
				uso_auto,
				suma_asegurada,
				descuento_uni,
				prima_neta_uni)
				values(
				_anio_endoso,      
				_no_poliza,        
				_no_documento,     
				_no_unidad,        
				_no_endoso,
				_cod_contratante,
				_sexo,
				_fecha_suscripcion,
				_cod_producto,
				_prima_tot,
				_prima_unidad,
				_porc_recar_uni,
				_recargo,
				_prima_sus_uni,
				_tipo_pol,		
				_placa,
				_fecha_cancelacion,
				_ano_auto,
				_cod_marca,
				_cod_modelo,
				_cod_tipoveh,
				_uso_auto,
				_suma_asegurada,
				_desc_uni,
				_prima_neta);			
			end foreach
		end if
	end foreach
end foreach
return 0,'Carga Exitosa';
end
end procedure;