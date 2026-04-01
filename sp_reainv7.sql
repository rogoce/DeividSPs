-- Cambio en distribucion de reaseguro, 	PRODUCCION
-- 
-- Creado     : 17/11/2021 - Autor: Amado Perez M
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv7;

create procedure sp_reainv7()
 returning integer,
           char(200);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(200);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada, _suma_asegurada_fac	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _no_documento    char(20);
define _no_factura      char(10);
define li_return        integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_unidad, _no_unidad_ant       char(5);
define _cnt             smallint;
define _periodo2        char(7);
define _ruta            char(5);
define _cod_ramo        char(3);
define _cod_cober_reas  char(3);
DEFINE _porc_partic_suma, _porc_partic_prima, _porc_partic_suma_comp1, _porc_partic_suma_comp2, _porc_partic_suma_fac  DECIMAL(9,6);
define _tipo            smallint;
define _cant            integer;
define _cod_ruta        char(5);
define _serie           smallint;
define _suma_asegurada_t dec(16,2);
define _pri_ret_uni     dec(16,2);
define _pri_ret_end     dec(16,2);
define _pri_ret         dec(16,2);
define _no_remesa       char(10);
define _renglon         integer;
define _sac_notrx       integer;
define _no_cambio, _no_cambio_ant       smallint;
define _corregir_uni    smallint;
define _corregir_pol    smallint;
define _corregir_end    smallint;
define _corregir_end_uni smallint;
define ls_tipopro			char(3);
define li_tipopro			integer;
define ld_porc_coaseg		dec(16,4);
define _suma            dec(16,2);
define _suma_otr        dec(16,2);


--set debug file to "sp_sis119bk.trc";
--set debug file to "sp_reainv5.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc || " Pol:" || _no_poliza || " end:" || _no_endoso || " uni: " || _no_unidad;
end exception

set isolation to dirty read;

let _suma_asegurada = 0;
let _suma_asegurada_t = 0;

let _cantidad   = 0;
--let _periodo2   = "2014-11";
let _porc_partic_suma  = 0;
let _porc_partic_prima = 0;


-- Pólizas con suma menor o igual a 500,000

foreach WITH HOLD
	select no_poliza,
		   periodo,
	       tipo
	  into _no_poliza,
	       _periodo,
	       _tipo
	  from camrea
	 where actualizado = 0
	--   and no_documento = '0113-00581-01'
	   and tipo in (2, 3)
	 order by 1,3,2
  
	select serie,
	  	   cod_ramo,
		   cod_tipoprod
	  into _serie,
	   	   _cod_ramo,
		   ls_tipopro
	  from emipomae
	 where no_poliza = _no_poliza;
 
	select tipo_produccion 
	  into li_tipopro
	  from emitipro
	 where cod_tipoprod = ls_tipopro;
 
	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_compania = '001'
	   and cod_ramo = _cod_ramo
	   and serie = _serie
	   and activo = 1;
	   
	let ld_porc_coaseg = 0.00;

	if li_tipopro = 2 then
	-- la suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
	-- campo - aseguradora lider

		select e.porc_partic_coas 					  
		  into ld_porc_coaseg
		  from parparam p, emicoama e
		 where p.cod_compania = '001'
		   and e.no_poliza    = _no_poliza
		   and e.cod_coasegur = p.par_ase_lider;

		if ld_porc_coaseg is null then
			let ld_porc_coaseg = 0.00;
		end if
	end if
	   	   
		   
    let _error = 0;
	
	let _corregir_pol = 0;

	begin work;
	
    -- Corrigiendo distribución de reaseguro en endosos	
	 
		let _suma_asegurada_t = 0.00;
		
				   
		foreach with hold
		    select no_endoso,
                   vigencia_inic,
                   vigencia_final,
                   cod_endomov				   
              into _no_endoso,
			       _vigencia_inic,
				   _vigencia_final,
				   _cod_endomov
              from endedmae
             where no_poliza = _no_poliza
               and periodo >= '2021-06'
		  order by no_endoso
		  
			let _corregir_end = 0;
			let _corregir_uni = 0;
			let _no_unidad_ant = '';
			let _corregir_end_uni = 0;
			
			if _cod_endomov = '017' THEN
				continue foreach;
			end if
			
 				foreach
					select suma_asegurada,
					       no_unidad
					  into _suma_asegurada,
					       _no_unidad
					  from endeduni
					 where no_poliza = _no_poliza
					   and no_endoso = _no_endoso
					  order by no_unidad
					  
					if _no_poliza = '0001659610' and _no_unidad = '00029' THEN
						continue foreach;
					end if
					  
					let _corregir_end_uni = 0;
					
					let _suma_asegurada_t = _suma_asegurada;					
					   
					if ld_porc_coaseg > 0 then
						let _suma_asegurada = (_suma_asegurada * ld_porc_coaseg) / 100;
					end if		

					-- Buscar % contrato facultativos
					let _suma_asegurada_fac = 0;
					
					select first 1 r.suma_asegurada
					  into _suma_asegurada_fac
					  from emifacon r, reacomae t
					 where r.cod_contrato = t.cod_contrato
					   and r.no_poliza = _no_poliza
					   and r.no_endoso = _no_endoso
					   and r.no_unidad = _no_unidad
					   and t.tipo_contrato = 3;
					   
					if _suma_asegurada_fac is null then
						let _suma_asegurada_fac = 0;
					end if	
					
					if  _suma_asegurada_fac <> 0 THEN
						let _suma_asegurada = _suma_asegurada - _suma_asegurada_fac;
                    end if					
					
					if _no_endoso = '00000' or _cod_endomov = '004' then
						if 	_suma_asegurada <= 500000 then
							select count(*)
							  into _cnt
							  from emifacon r, reacomae t
							 where r.cod_contrato = t.cod_contrato
							   and r.no_poliza = _no_poliza
							   and r.no_endoso = _no_endoso
							   and r.no_unidad = _no_unidad
							   and t.tipo_contrato <> 1;
							   
							if _cnt is null then
								let _cnt = 0;
							end if
							
							if _cnt > 0 then
								let _corregir_pol = 1;
								let _corregir_uni = 1;
								let _corregir_end = 1;
								let _corregir_end_uni = 1;
							
								select max(no_cambio)
								  into _no_cambio
								  from emireama
								 where no_poliza = _no_poliza
								   and no_unidad = _no_unidad;  								   
								   
								-- Buscar % contrato facultativos
								let _porc_partic_suma_fac = 0;
								let _no_cambio_ant = _no_cambio;
								
								select first 1 r.porc_partic_suma
								  into _porc_partic_suma_fac
								  from emifacon r, reacomae t
								 where r.cod_contrato = t.cod_contrato
								   and r.no_poliza = _no_poliza
								   and r.no_endoso = _no_endoso
								   and r.no_unidad = _no_unidad
								   and t.tipo_contrato = 3;
								   
								if _porc_partic_suma_fac is null then
									let _porc_partic_suma_fac = 0;
								end if	
								                               																   
								if _no_cambio is null THEN
									let _no_cambio = 0;
								else 
									let _no_cambio = _no_cambio + 1;
								end if	
								
								insert into emireama(
									no_poliza,
									no_unidad,
									no_cambio,
									cod_cober_reas,
									vigencia_inic,
									vigencia_final)
								select _no_poliza,
									   _no_unidad,
									   _no_cambio,
									   a.cod_cober_reas,
									   _vigencia_inic,
									   _vigencia_final
								  from rearucon a, reacomae b
								 where a.cod_contrato = b.cod_contrato
								   and a.cod_ruta = _cod_ruta
								   and b.tipo_contrato = 1;		
									   
								-- Retencion
								insert into emireaco (
								  no_poliza,
								  no_unidad,
								  no_cambio,
								  cod_cober_reas,
								  orden,
								  cod_contrato,
								  porc_partic_suma,
								  porc_partic_prima)
								select _no_poliza,
									   _no_unidad,
									   _no_cambio,
									   a.cod_cober_reas,
									   a.orden,
									   a.cod_contrato,
									   100.00 - _porc_partic_suma_fac,
									   100.00 - _porc_partic_suma_fac
								  from rearucon a, reacomae b
								 where a.cod_contrato = b.cod_contrato
								   and a.cod_ruta = _cod_ruta
								   and b.tipo_contrato = 1;	
								   
								if _porc_partic_suma_fac <> 0 then   
									insert into emireaco (
									  no_poliza,
									  no_unidad,
									  no_cambio,
									  cod_cober_reas,
									  orden,
									  cod_contrato,
									  porc_partic_suma,
									  porc_partic_prima)
									select _no_poliza,
										   _no_unidad,
										   _no_cambio,
										   a.cod_cober_reas,
										   a.orden,
										   a.cod_contrato,
										   _porc_partic_suma_fac,
										   _porc_partic_suma_fac
									  from rearucon a, reacomae b
									 where a.cod_contrato = b.cod_contrato
									   and a.cod_ruta = _cod_ruta
									   and b.tipo_contrato = 3;	
									   
									if _no_poliza = '1656427' then	
										insert into emireafa (
										  no_poliza,
										  no_unidad,
										  no_cambio,
										  cod_cober_reas,
										  orden,
										  cod_contrato,
										  cod_coasegur,
										  porc_partic_reas,
										  porc_comis_fac,
										  porc_impuesto)
										select no_poliza,
											   no_unidad,
											   _no_cambio,
											   cod_cober_reas,
											   (case when orden = 5 then (case when cod_cober_reas = '001' then 6 else orden end) else (case when orden = 6 then (case when cod_cober_reas = '021' then 7 else orden end) end) end ),
											   cod_contrato,
											   cod_coasegur,
											   porc_partic_reas,
											   porc_comis_fac,
											   porc_impuesto
										  from emireafa
										 where no_poliza = _no_poliza
										   and no_unidad = _no_unidad
										   and no_cambio = _no_cambio_ant;	
								   else										
										insert into emireafa (
										  no_poliza,
										  no_unidad,
										  no_cambio,
										  cod_cober_reas,
										  orden,
										  cod_contrato,
										  cod_coasegur,
										  porc_partic_reas,
										  porc_comis_fac,
										  porc_impuesto)
										select no_poliza,
											   no_unidad,
											   _no_cambio,
											   cod_cober_reas,
											   orden,
											   cod_contrato,
											   cod_coasegur,
											   porc_partic_reas,
											   porc_comis_fac,
											   porc_impuesto
										  from emireafa
										 where no_poliza = _no_poliza
										   and no_unidad = _no_unidad
										   and no_cambio = _no_cambio_ant;	
									end if
								end if
									
							end if		
						else
							select first 1 a.cod_cober_reas
							  into _cod_cober_reas
							  from rearucon a, reacomae b
							 where a.cod_contrato = b.cod_contrato
							   and a.cod_ruta = _cod_ruta
							   and b.tipo_contrato = 1;		
												
							select sum(r.suma_asegurada)
							  into _suma		  
							  from emifacon r, reacomae t
							 where r.cod_contrato = t.cod_contrato
							   and r.no_poliza = _no_poliza
							   and r.no_endoso = _no_endoso
							   and r.no_unidad = _no_unidad
							   and t.tipo_contrato = 1
							   and r.cod_cober_reas = _cod_cober_reas
							 group by r.cod_cober_reas;
							 
							if _suma is null THEN
								let _suma = 0.00;
							end if
							
							if _suma <= 499900 or _suma > 500000 then
								foreach
									select distinct sum(r.suma_asegurada)
									  into _suma_otr
									  from emifacon r, reacomae t
									 where r.cod_contrato = t.cod_contrato
									   and r.no_poliza = _no_poliza
									   and t.tipo_contrato <> 1
									 group by r.cod_cober_reas,t.tipo_contrato

								end foreach
								
								if _suma_otr is null THEN
									let _suma_otr = 0.00;
								end if
								
								if _suma_otr <> 0 then
									let _corregir_pol = 1;
									let _corregir_uni = 1;
									let _corregir_end = 1;
									let _corregir_end_uni = 1;
									
									select max(no_cambio)
									  into _no_cambio
									  from emireama
									 where no_poliza = _no_poliza
									   and no_unidad = _no_unidad;
									   
									-- Buscar % contrato facultativos
									let _porc_partic_suma_fac = 0;
									let _no_cambio_ant = _no_cambio;
									
									select first 1 r.porc_partic_suma
									  into _porc_partic_suma_fac
									  from emifacon r, reacomae t
									 where r.cod_contrato = t.cod_contrato
									   and r.no_poliza = _no_poliza
									   and r.no_endoso = _no_endoso
									   and r.no_unidad = _no_unidad
									   and t.tipo_contrato = 3;
									   
									if _porc_partic_suma_fac is null then
										let _porc_partic_suma_fac = 0;
									end if										   									   
									   
									if _no_cambio is null THEN
										let _no_cambio = 0;
									else 
										let _no_cambio = _no_cambio + 1;
									end if	
									
									if _suma_asegurada_fac <> 0 then
										let _suma_asegurada = _suma_asegurada + _suma_asegurada_fac;
									end if

									let _porc_partic_suma = 500000 / _suma_asegurada * 100;
									
									insert into emireama(
										no_poliza,
										no_unidad,
										no_cambio,
										cod_cober_reas,
										vigencia_inic,
										vigencia_final)
									select distinct _no_poliza,
										   _no_unidad,
										   _no_cambio,
										   a.cod_cober_reas,
										   _vigencia_inic,
										   _vigencia_final
									  from rearucon a, reacomae b
									 where a.cod_contrato = b.cod_contrato
									   and a.cod_ruta = _cod_ruta;							
									
									-- Retencion
									insert into emireaco (
									  no_poliza,
									  no_unidad,
									  no_cambio,
									  cod_cober_reas,
									  orden,
									  cod_contrato,
									  porc_partic_suma,
									  porc_partic_prima)
									select _no_poliza,
										   _no_unidad,
										   _no_cambio,
										   a.cod_cober_reas,
										   a.orden,
										   a.cod_contrato,
										   _porc_partic_suma,
										   _porc_partic_suma
									  from rearucon a, reacomae b
									 where a.cod_contrato = b.cod_contrato
									   and a.cod_ruta = _cod_ruta
									   and b.tipo_contrato = 1;	
									   
									-- Excedente
									insert into emireaco (
									  no_poliza,
									  no_unidad,
									  no_cambio,
									  cod_cober_reas,
									  orden,
									  cod_contrato,
									  porc_partic_suma,
									  porc_partic_prima)
									select _no_poliza,
										   _no_unidad,
										   _no_cambio,
										   a.cod_cober_reas,
										   a.orden,
										   a.cod_contrato,
										   100 - (_porc_partic_suma + _porc_partic_suma_fac),
										   100 - (_porc_partic_suma + _porc_partic_suma_fac)
									  from rearucon a, reacomae b
									 where a.cod_contrato = b.cod_contrato
									   and a.cod_ruta = _cod_ruta
									   and b.tipo_contrato = 7;	
								
									-- Facultativo
									if _porc_partic_suma_fac <> 0 then   
										insert into emireaco (
										  no_poliza,
										  no_unidad,
										  no_cambio,
										  cod_cober_reas,
										  orden,
										  cod_contrato,
										  porc_partic_suma,
										  porc_partic_prima)
										select _no_poliza,
											   _no_unidad,
											   _no_cambio,
											   a.cod_cober_reas,
											   a.orden,
											   a.cod_contrato,
											   _porc_partic_suma_fac,
											   _porc_partic_suma_fac
										  from rearucon a, reacomae b
										 where a.cod_contrato = b.cod_contrato
										   and a.cod_ruta = _cod_ruta
										   and b.tipo_contrato = 3;	
										
                                        if _no_poliza = '1656427' then	
 											insert into emireafa (
											  no_poliza,
											  no_unidad,
											  no_cambio,
											  cod_cober_reas,
											  orden,
											  cod_contrato,
											  cod_coasegur,
											  porc_partic_reas,
											  porc_comis_fac,
											  porc_impuesto)
											select no_poliza,
												   no_unidad,
												   _no_cambio,
												   cod_cober_reas,
												   (case when orden = 5 then (case when cod_cober_reas = '001' then 6 else orden end) else (case when orden = 6 then (case when cod_cober_reas = '021' then 7 else orden end) end) end ),
												   cod_contrato,
												   cod_coasegur,
												   porc_partic_reas,
												   porc_comis_fac,
												   porc_impuesto
											  from emireafa
											 where no_poliza = _no_poliza
											   and no_unidad = _no_unidad
											   and no_cambio = _no_cambio_ant;	
                                       else										
											insert into emireafa (
											  no_poliza,
											  no_unidad,
											  no_cambio,
											  cod_cober_reas,
											  orden,
											  cod_contrato,
											  cod_coasegur,
											  porc_partic_reas,
											  porc_comis_fac,
											  porc_impuesto)
											select no_poliza,
												   no_unidad,
												   _no_cambio,
												   cod_cober_reas,
												   orden,
												   cod_contrato,
												   cod_coasegur,
												   porc_partic_reas,
												   porc_comis_fac,
												   porc_impuesto
											  from emireafa
											 where no_poliza = _no_poliza
											   and no_unidad = _no_unidad
											   and no_cambio = _no_cambio_ant;	
                                        end if											   
									end if
									   
									
								end if
							end if							
						end if
                    else	
                        select max(no_cambio)
						  into _no_cambio
						  from emireama
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
									   
                        select first 1 a.porc_partic_suma
                         into _porc_partic_suma_comp1
						 from emireaco a, reacomae b
                        where a.cod_contrato = b.cod_contrato
						  and a.no_poliza	= _no_poliza
                          and a.no_unidad	= _no_unidad
                          and a.no_cambio = _no_cambio
						  and b.tipo_contrato = 1;

                        select first 1 a.porc_partic_suma
                         into _porc_partic_suma_comp2	
						 from emifacon a, reacomae b
                        where a.cod_contrato = b.cod_contrato
						  and a.no_poliza = _no_poliza
                          and a.no_unidad = _no_unidad
						  and a.no_endoso = _no_endoso
						  and b.tipo_contrato = 1;

						if _porc_partic_suma_comp1 <> _porc_partic_suma_comp2 THEN
							let _corregir_pol = 1;
							let _corregir_uni = 1;
							let _corregir_end = 1;
							let _corregir_end_uni = 1;
						end if
					end if	
					
					if _corregir_end_uni = 1 then				
					  
						let _error = sp_proe04bcam(_no_poliza, _no_unidad, _suma_asegurada_t, _no_endoso, _cod_ruta); --Procedure que crea el reaseguro emifacon
						
						if _error <> 0 THEN
							rollback work;
							exit foreach;
						end if
						--Actualizando prima retenida unidades
						let _pri_ret_uni = 0.00;
						select sum(r.prima)
						  into _pri_ret_uni
						  from emifacon r, reacomae t
						 where r.cod_contrato = t.cod_contrato
						   and r.no_poliza = _no_poliza
						   and r.no_endoso = _no_endoso
						   and r.no_unidad = _no_unidad
						   and t.tipo_contrato = 1;

						update endeduni
						   set prima_retenida = _pri_ret_uni
						 where no_poliza = _no_poliza
						   and no_endoso = _no_endoso
						   and no_unidad = _no_unidad;
						   
						--Actualizando prima retenida de emipouni
						let _pri_ret_uni = 0.00;
						select sum(r.prima)
						  into _pri_ret_uni
						  from emifacon r, reacomae t
						 where r.cod_contrato = t.cod_contrato
						   and r.no_poliza = _no_poliza
						   and r.no_unidad = _no_unidad
						   and t.tipo_contrato = 1;
						   
						update emipouni
						   set prima_retenida = _pri_ret_uni
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					end if
					
					let _no_unidad_ant = _no_unidad;
				end foreach	
			
			if _error <> 0 THEN
				exit foreach;
			end if
						
			--Verificar esto cuando es en dataserver
			if _corregir_end = 1 then
--				FOREACH
--					select distinct sac_notrx 
--					  into _sac_notrx
--					from sac999:reacompasie where no_registro in (
--					select no_registro from sac999:reacomp 
--					 where no_poliza     = _no_poliza
--					   and no_endoso     = _no_endoso
--					   and tipo_registro = 1
--					   and periodo = '2021-11')
					   
--					call sp_sac77a(_sac_notrx) returning _error, _error_desc;   
--					if _error <> 0 THEN
--						exit foreach;
--					end if
--				END FOREACH

				if _error <> 0 THEN
					rollback work;
					continue foreach;
				end if
				   
			--Actualizando prima retenida de endedmae y endedhis
				let _pri_ret_end = 0.00;
				select sum(r.prima)
				  into _pri_ret_end
				  from emifacon r, reacomae t
				 where r.cod_contrato = t.cod_contrato
				   and r.no_poliza = _no_poliza
				   and r.no_endoso = _no_endoso
				   and t.tipo_contrato = 1;
				   
				update endedmae
				   set prima_retenida = _pri_ret_end
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;
				   
				update endedhis
				   set prima_retenida = _pri_ret_end
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;
			end if
		end foreach

	if _error <> 0 THEN
		continue foreach;
	end if
	--Actualizando prima retenida de emipomae
	if _corregir_pol = 1 then
		let _pri_ret = 0.00;
		select sum(r.prima)
		  into _pri_ret
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and t.tipo_contrato = 1;
		   
		update emipomae
		   set prima_retenida = _pri_ret
		 where no_poliza = _no_poliza;
		 
		-- Corrigiendo distribución de reaseguro en remesas	
		foreach
			select no_remesa,
				   renglon
			  into _no_remesa,
				   _renglon
			  from cobredet
			 where no_poliza = _no_poliza
			   and tipo_mov   in ('P','N')
			   and periodo >= '2021-06'
			 order by renglon
		  
			call sp_sis171bk(_no_remesa, _renglon) returning _error, _error_desc; --Procedure que crea el reaseguro cobreaco
			
--			if _error = 0 then
--				 FOREACH
--					select distinct sac_notrx 
--					  into _sac_notrx
--					from sac999:reacompasie where no_registro in (
--					select no_registro from sac999:reacomp 
--					 where no_remesa     = _no_remesa
--					   and renglon       = _renglon
--					   and tipo_registro = 2
--					   and periodo = '2021-11')
					   
--					call sp_sac77a(_sac_notrx) returning _error, _error_desc;   
--					if _error <> 0 THEN
--						exit foreach;
--					end if
--				 END FOREACH
--			end if		

			if _error <> 0 THEN
				rollback work;
				continue foreach;
			end if
		   
		end foreach
	end if
	
	update camrea
	   set actualizado = 1
	 where no_poliza = _no_poliza;

    let _cantidad = _cantidad + 1;

	commit work;

--	if _cantidad >= 1 then
--		exit foreach;
--	end if
end foreach
end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados";

end procedure