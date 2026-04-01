-- Procedimiento que Realiza la insercion a la tabla de endoso, Proceso de Endosos Electronicos Tecnica de seguros.
-- Creado    : 29/08/2014 - Autor: Federico Coronado 

drop procedure sp_end10;

create procedure "informix".sp_end10(
v_usuario		char(8),
v_cod_agente	char(5),
v_num_carga		char(10),
v_no_documento	char(20),
v_codcompania	char(3),
v_codagencia	char(3),
a_opcion		char(1)
)
returning	smallint,
			char(50),
			char(10),
			char(10);

--- Actualización del endoso


define _cedula_contratante			varchar(30);
define _cedula						varchar(30);
define _pasaporte					varchar(30);
define _ruc							varchar(30);
define _direccion_cobros			char(100);
define _cliente_nom					char(100);
define _cliente_ape					char(50);
define _cliente_ape_seg				char(50);
define _cliente_ape_casada			char(20);
define _tipo_persona				char(1);
define _sexo						char(1);
define _cod_contratante				char(10);
define _cod_asegurado    			char(10);
define _estado_civil				char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _celular						char(10);
define _no_poliza					char(10);
define _no_endoso_edit              varchar(10);
define _no_endoso                   varchar(10);
define _desc_unidad                 varchar(50);
define _e_mail						char(50);
define _cod_ocupacion				char(3);
define _direccion					char(100);
define _responsable_cobro			char(20);
define _observaciones				char(250);
define _error_desc					char(100);
define _cod_ramo					char(3);
define v_codsubramo					char(3);
define _cod_producto				char(5);
define _no_unidad   				char(5);
define _cod_ruta  				char(5);
define v_codformapago				char(3);
define _cod_perpago					char(3);
define _cod_sucursal                char(3);
define _sucursal_origen             char(3);
define _periodo                     char(7);
define _cod_cobertura               char(10);
define _renglon						smallint;
define _no_pagos					smallint;
define _error_isam					smallint;
define _error						smallint;
define _max_Cambio                  smallint;
define _orden                       smallint;
define _fecha_hoy                   date;
define _fecha_primer_pago			date;
define _fecha_aniversario			date;
define _fecha_registro				date;
define v_vigenciainic				date;
define _vigencia_final				date;
define _vigencia_poliza_inic	    date;
define _vigencia_poliza_final       date;
define _porc_partic_suma            decimal(10,2);
define _porc_partic_prima           decimal(10,2);
define _cod_impuesto                decimal(10,2);
define _factor_impuesto             decimal(10,2);
define _porc_impuesto               decimal(10,2);
define _prima_sin_desc              decimal(10,2);
define _prima_sin_descp             decimal(10,2);
define _descuento                   decimal(10,2);
define _recargo                     decimal(10,2);
define _prima_neta                  decimal(10,2);
define _prima_netap                 decimal(10,2);
define _total_impuesto              decimal(10,2);
define _total_impuestop             decimal(10,2);
define _prima_bruta                 decimal(10,2);
define _prima_brutap                decimal(10,2);
define _prima_retenida              decimal(10,2);
define _prima_retenidap             decimal(10,2);
define _prima                       decimal(10,2);
define _prima_vida					dec(16,2);
define _prima_suscrita			    dec(16,2);
define _suma_asegurada				dec(16,2);
define _suma         				dec(16,2);
define _cnt                         integer;
define _cnt_endoso                  integer;
define _fecha_benef                 date;
define _porc_benef                  smallint;
define _cod_beneficiario            varchar(10);
define _nombre_benef                varchar(250);


--set debug file to "sp_end09.trc"; 
--trace on;

set lock mode to wait;
begin
on exception set _error,_error_isam,_error_desc
  return _error,_error_desc,'','';
end exception

let _cod_sucursal = '001';
let v_codcompania = '001';
let _desc_unidad = '';


foreach
	Select cod_ramo,
		   cod_subramo,
		   cod_producto,
		   trim(cod_formapag),
		   cod_perpago,
		   no_pagos,
		   fecha_primer_pago,
		   direccion_cobros,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   cedula_contratante,
		   cedula,
		   pasaporte,
		   ruc,
		   cliente_nom,
		   cliente_ape,
		   cliente_ape_seg,
		   cliente_ape_casada,
		   tipo_persona,
		   fecha_aniversario,
		   sexo,
		   estado_civil,
		   telefono1,
		   telefono2,
		   celular,
		   e_mail,
		   cod_ocupacion,
		   direccion,
		   fecha_registro,
		   responsable_cobro,
		   prima_vida,
		   suma_asegurada,
		   observaciones,
		   renglon					  
	  into _cod_ramo,					  
		   v_codsubramo,	
		   _cod_producto,
		   v_codformapago,
		   _cod_perpago,
		   _no_pagos,
		   _fecha_primer_pago,
		   _direccion_cobros,
		   v_vigenciainic,
		   _vigencia_final,
		   _cod_contratante,
		   _cedula_contratante,
		   _cedula,
		   _pasaporte,
		   _ruc,
		   _cliente_nom,
		   _cliente_ape,
		   _cliente_ape_seg,
		   _cliente_ape_casada,
		   _tipo_persona,
		   _fecha_aniversario,
		   _sexo,
		   _estado_civil,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _e_mail,
		   _cod_ocupacion,
		   _direccion,												   
		   _fecha_registro,
		   _responsable_cobro,
		   _prima_vida,
		   _suma_asegurada,
		   _observaciones,
		   _renglon
	  From prdemielctdet
	 Where cod_agente	= v_cod_agente
	   and num_carga	= v_num_carga
	   and proceso		= a_opcion
	   and no_documento	= v_no_documento
	exit foreach;
end foreach 
	   
select no_poliza,
	   sucursal_origen,
	   cod_contratante,
	   vigencia_inic,
	   vigencia_final
  into _no_poliza,
	   _sucursal_origen,
	   _cod_contratante,
	   _vigencia_poliza_inic,
	   _vigencia_poliza_final
  from emipomae
 where no_documento = v_no_documento
   and v_vigenciainic between vigencia_inic and vigencia_final
   and actualizado = 1;
   
 call sp_sis90(_no_poliza) returning _no_endoso_edit;  
  let _no_endoso_edit = _no_endoso_edit + 1;
 call sp_set_codigo(5,_no_endoso_edit) returning _no_endoso; 
  
 select max(no_cambio)
   into _max_Cambio
   from emireama 
  where no_poliza = _no_poliza;
  
foreach  
	select porc_partic_suma, 
		   porc_partic_prima
	  into _porc_partic_suma,
		   _porc_partic_prima
	  from emireama inner join emireaco on emireama.no_poliza = emireaco.no_poliza
	 inner join reacomae on reacomae.cod_contrato = emireaco.cod_contrato
	 where emireaco.no_poliza = _no_poliza
	   and emireama.no_poliza = _no_poliza
	   and emireama.no_unidad =  emireaco.no_unidad 
	   and emireama.no_cambio = _max_Cambio
	   and tipo_contrato = 1
	   exit foreach;
 end foreach
	 
call sp_sis26() returning _fecha_hoy;

  select nombre 
	into _desc_unidad
    from cliclien 
   where cod_cliente = _cod_contratante;

Select cod_impuesto
  into _cod_impuesto
  From prdimsub
 Where cod_subramo = v_codsubramo
   and cod_ramo = _cod_ramo;

Select factor_impuesto
  into _factor_impuesto
  From prdimpue
 Where cod_impuesto = _cod_impuesto;

select porc_impuesto,
       sum(prima_sin_desc),
       sum(descuento),
       sum(prima_neta),
	   sum(tot_impuesto),
	   sum(prima_bruta)
  into _porc_impuesto,
	   _prima_sin_desc,
	   _descuento,
	   _prima_neta,
	   _total_impuesto,
	   _prima_bruta
  From prdemielctdet
 Where cod_agente	= v_cod_agente
   and num_carga	= v_num_carga
   and proceso		= a_opcion
   and no_documento	= v_no_documento
 group by 1;

select emi_periodo 														   
into _periodo
from parparam
where cod_compania  = v_codcompania;

let _prima_retenida = _prima_sin_desc * _porc_partic_prima / 100;

Insert Into endedmae(no_poliza, 
					no_endoso, 
					cod_compania, 
					cod_sucursal, 
					cod_tipocalc,
					cod_formapag,
					cod_perpago, 
					cod_endomov, 
					no_documento, 
					vigencia_inic, 
					vigencia_final, 
					prima, 
					descuento, 
					recargo, 
					prima_neta, 
					impuesto, 	                        
					prima_bruta, 
					prima_suscrita, 
					prima_retenida, 
					tiene_impuesto, 
					fecha_impresion, 
					fecha_primer_pago, 
					no_pagos, 
					date_added, 
					interna, 
					periodo, 
					user_added, 
					factor_vigencia, 
					suma_asegurada, 
					vigencia_inic_pol, 
					vigencia_final_pol, 
					de_cotizacion, 
					gastos, 
					subir_bo)
			Values(_no_poliza,
					_no_endoso,
					v_codcompania,
					_cod_sucursal,
					'006',
					v_codformapago, 
					_cod_perpago, 
					'006', 
					v_no_documento, 
					v_vigenciainic, 
					_vigencia_final, 
					_prima_sin_desc,
					'0.00',
					'0.00',
					_prima_neta,
					_total_impuesto, 
					_prima_bruta, 
					_prima_sin_desc,
					_prima_retenida, 
					'1',
					_fecha_hoy, 
					_fecha_hoy, 
					10,
					_fecha_hoy,
					_no_pagos, 
					_periodo, 
					'informix', 
					1.000, 
					0.00, 
					_fecha_hoy, 
					_fecha_hoy, 
					'0',
					'0',
					'1');

Insert Into endedimp(no_poliza, 
					 no_endoso, 
					 cod_impuesto,
					 monto)                        
			 Values(_no_poliza,
					_no_endoso, 
					'001', 
					_factor_impuesto);

foreach
	select no_unidad,
		   prima_sin_desc,
		   descuento,
		   prima_neta,
		   tot_impuesto,
		   prima_bruta, 
		   porc_impuesto, 
		   cod_producto
	  into _no_unidad,
		   _prima_sin_desc,
		   _descuento,
		   _prima_neta,
		   _total_impuesto,
		   _prima_bruta,
		   _porc_impuesto,
		   _cod_producto
	  From prdemielctdet
	 Where cod_agente	= v_cod_agente
	   and num_carga	= v_num_carga
	   and proceso		= a_opcion
	   and no_documento	= v_no_documento
  group by 1,2,3,4,5,6,7,8
	
	select cod_producto, 
		   cod_asegurado,
		   cod_ruta
	  into _cod_producto,
		   _cod_asegurado,
		   _cod_ruta
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
   
	let _prima_retenida = 0.00;	   
	let _prima_retenida = _prima_sin_desc * _porc_partic_prima / 100;

	Insert Into endeduni(no_poliza, 
						 no_endoso, 
						 no_unidad, 
						 cod_ruta, 
						 cod_producto, 
						 cod_cliente, 
						 suma_asegurada, 
						 prima,
						 descuento, 
						 recargo, 
						 prima_neta, 
						 impuesto, 
						 prima_bruta, 
						 reasegurada, 
						 vigencia_inic, 
						 vigencia_final, 
						 beneficio_max,
						 desc_unidad, 
						 prima_suscrita, 
						 prima_retenida, 
						 gastos, 
						 subir_bo) 
				 Values(_no_poliza, 
						_no_endoso, 
						_no_unidad, 
						_cod_ruta, 
						_cod_producto,
						_cod_asegurado, 
						'0', 
						_prima_sin_desc, 
						'0',
						'0', 
						_prima_neta, 
						_total_impuesto, 
						_prima_bruta, 
						'0',
						_vigencia_poliza_inic, 
						_vigencia_poliza_final, 
						'0',
						_desc_unidad, 
						_prima_sin_desc, 
						_prima_retenida,
						'0',
						'1');
						
	foreach		
		SELECT cod_cobertura,
			   orden
		  into _cod_cobertura,
			   _orden
		  from emipocob  
		 where no_poliza = _no_poliza 
		   and no_unidad = _no_unidad
	  order by orden
  
		Insert Into endedcob(no_poliza, 
							no_endoso, 
							no_unidad, 
							cod_cobertura, 
							orden, 
							tarifa, 
							deducible, 
							limite_1, 
							limite_2,      
							prima_anual, 
							prima, 
							descuento, 
							recargo, 
							prima_neta, 
							date_added, 
							date_changed, 
							factor_vigencia, 
							opcion, 
							subir_bo)
					  Values(_no_poliza, 
							 _no_endoso,
							 _no_unidad, 
							 _cod_cobertura, 
							 _orden, 
							 '0', 
							 '0', 
							 '0.00',
							 '0.00', 
							 _prima_sin_desc, 
							 _prima_sin_desc,
							 '0', 
							 '0',
							 _prima_sin_desc,
							 _fecha_hoy,
							 _fecha_hoy,
							 '1.00',
							 '0',
							 '1');
		let _prima_sin_desc = 0.00;
	end foreach
	--let _no_unidad = '00001';
	call sp_pro46a(_no_poliza, _no_endoso, _no_unidad, '0','1.000') returning _error, _error_desc, _prima_sin_desc, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap;   					   
	call sp_proe35(_no_poliza, _no_endoso, _no_unidad, '001') returning _error;
	call sp_pro462a(_no_poliza, _no_endoso, _no_unidad) returning _error, _error_desc, _prima_sin_descp, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap,_suma,_prima_suscrita,_prima_retenidap;
	call sp_pro4611a(_no_poliza, _no_endoso) returning _error, _error_desc, _prima_sin_descp, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap,_suma,_prima_suscrita,_prima_retenidap;
				/*	update endeduni 
					   set descuento      = _descuento, 
						   recargo		  = _recargo,                    
						   prima_neta 	  = _prima_neta, 
						   impuesto 	  = _total_impuesto, 
						   prima_bruta 	  = _prima_bruta,
						   prima_retenida = _prima_retenida
					 where no_poliza 	  = _no_poliza 
					   and no_endoso 	  = _no_endoso
					   and no_unidad      = _no_unidad; */
	Insert into endedde2(
				no_poliza,
				no_unidad,
				no_endoso,
				descripcion
				)
		values (_no_poliza,
			   _no_unidad,
			   _no_endoso,
			   NULL);
			   
			   
/*Beneficiarios*/ 

	select count(*)
	  into _cnt
	  from emibenef
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad; 
	   
	select count(*)
	  into _cnt_endoso
	  from prdemielecben
     Where cod_agente		= v_cod_agente
	   and num_carga		= v_num_carga
	   and proceso			= a_opcion
	   and no_documento		= v_no_documento
	   and no_unidad 		= _no_unidad;
		if _cnt_endoso > 0 then
			if _cnt_endoso <> _cnt then
				delete from emibenef where no_poliza = _no_poliza and no_unidad = _no_unidad;  
				foreach
					  select primer_nombre||" "||segundo_nombre||" "||primer_apellido||" "||segundo_apellido,
							 date_beneficio,
							 porcentaje
						into _nombre_benef,
							 _fecha_benef,
							 _porc_benef
						from prdemielecben
					   Where cod_agente		= v_cod_agente
						 and num_carga		= v_num_carga
						 and proceso		= a_opcion
						 and no_documento	= v_no_documento
						 and no_unidad 		= _no_unidad
					CALL sp_sis13('001','PRO','02','par_benefi') RETURNING _cod_beneficiario;
						INSERT INTO emibenef(
									no_poliza,
									no_unidad,
									cod_cliente,
									cod_parentesco,
									benef_desde,
									porc_partic_ben,
									nombre
									)
									values(
									_no_poliza,
									_no_unidad,
									_cod_beneficiario,
									'009',
									_fecha_benef,
									_porc_benef,
									_nombre_benef);
				end foreach
			end if
		end if
/**/		   	   
end foreach
	
	Insert into endedde1(
					no_poliza,
					no_endoso,
					descripcion
					)
			values (_no_poliza,
				    _no_endoso,
				   NULL);
			   
	call sp_pro43(_no_poliza,_no_endoso)returning _error, _error_desc;
	    
		update prdemielctdet
		   set actualizado  = 1
		 Where cod_agente	= v_cod_agente
		   and num_carga	= v_num_carga
		   and proceso		= a_opcion
		   and no_documento	= v_no_documento;
end
return _error,_error_desc,_no_poliza,_no_endoso;
end procedure;