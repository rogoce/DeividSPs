-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- SIS v.2.0 d_- DEIVID, S.A.

drop procedure sp_pro321cSimu;

create procedure sp_pro321cSimu(a_no_poliza char(10), a_no_poliza_ant char(10))
returning  integer;

define _ld_deduc_nuevo	varchar(50); --dec(16,2);
define _ld_deduc_anter	varchar(50); --dec(16,2);
define _filtros			char(255);
define _asegurado		char(100);
define _cobertura		char(100);
define _acreedor		char(100);
define _no_motor		char(30);
define _no_documento	char(20);
define _no_doc			char(20);
define _cod_contratante	char(10);
define _no_unidad_otr	char(5);
define _cod_cobertura	char(5);
define _cod_acreedor	char(5);
define _cod_agente		char(5);
define _no_unidad		char(5);
define _cod_grupo		char(5);
define _cod_marca		char(5);
define _cod_prod		char(5);
define _cod_impuesto	char(3);
define _cod_ramo		char(3);
define _tipo_rec_col	char(1);
define _tipo_rec_com	char(1);
define _uso_auto		char(1);
define _factor_imp		dec(5,2);
define _monto_impuesto	dec(16,2);
define _ld_prima_bruta	dec(16,2);
define _ld_prima_nueva	dec(16,2);
define _ld_prima_deduc	dec(16,2);
define _ld_prima_anter	dec(16,2);
define _ld_nuevo_deduc	dec(16,2);
define _ld_sum_aseg_1	dec(16,2);
define _ld_sum_aseg_2	dec(16,2);
define _ld_descuento	dec(16,2);
define _ld_porc_desc	dec(16,2);
define _ld_porc_depr	dec(16,2);
define _rec_ded_col		dec(16,2);
define _ld_limite_1		dec(16,2);
define _ld_limite_2		dec(16,2);
define _rec_ded_com		dec(16,2);
define _ld_recargo		dec(16,2);
define _ld_tarifa		dec(16,2);
define _ld_saldo		dec(16,2);
define _ld_rec_existe	smallint;
define _ld_identrec		smallint;
define _ano_actual		smallint;
define _acep_desc		smallint;
define _ld_orden		smallint;
define _retorno			smallint;
define _resultado		integer;
define _ano_auto		integer;
define _valor			integer;
define _error			integer;
define _vigencia_final	date;
define _vigencia_inic	date;
define _ld_vig_inici	date;
define _ld_vig_final	date;
define _vig_fin_otr		date;
define _fecha_aud1		date;
define _fecha_aud2		date;
define _vig_ini			date;
define _nuevo           smallint;
define _desc_comb       dec(16,2);
define _desc_modelo 	dec(16,2);
define _desc_sini 		dec(16,2);
define _cod_tipo_tar 	char(3); 

define _incurrido_bruto		dec(16,2);
define _prima_devengada		dec(16,2);
define _siniestralidad		dec(16,2);
define _descuento_sini		dec(16,2);
define _condicion           smallint;
define _descuento_modelo    decimal(16,2);
DEFINE _cod_modelo			CHAR(5);
DEFINE _cod_tipo			CHAR(3);
DEFINE _tipo_auto			SMALLINT;

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		smallint;
define _no_sinis_pro		dec(16,2);
define _max_orden           integer;
define _cnt_cober           integer;
define _desc_vehic          dec(16,2);

define _cod_prod_new		char(5);
define _nueva_renov         char(1);
define _texto           references text;
define _cnt_descu           smallint;
define _descuento           dec(5,2);
define _ld_prima_anual_anter dec(16,2);
define _ld_prima_neta_anter	 dec(16,2);
define _cambio_producto      smallint;
define _cnt_ren              integer;
define _cnt_end_mu           smallint;
define _cnt_descu_otro       smallint;
define _periodo              char(7);
define _cambio_a_00313 		 smallint;

begin
on exception set _error 
 	return _error;         
end exception

set isolation to dirty read;

--*********************inicializa las variables********************--
let _ano_actual = year(current);

let _ld_prima_nueva	= 0.00;
let _ld_prima_deduc	= 0.00;
let _ld_deduc_nuevo	= 0.00;
let _ld_deduc_anter	= 0.00;
let _ld_prima_anter	= 0.00;
let _ld_nuevo_deduc	= 0.00;
let _ld_sum_aseg_1	= 0.00;
let _ld_sum_aseg_2	= 0.00;
let _ld_descuento	= 0.00;
let _ld_porc_desc	= 0.00;
let _ld_porc_depr	= 0.00;
let _ld_limite_1	= 0.00;
let _ld_limite_2	= 0.00;  
let _rec_ded_col	= 0.00;
let _rec_ded_com	= 0.00;
let _ld_tarifa		= 0.00;
let _ld_saldo		= 0.00;
let _monto_impuesto	= 0;
let _ld_prima_bruta	= 0;
let _ld_rec_existe	= 0;
let _ld_identrec	= 0;
let _ld_recargo		= 0;
let _acep_desc		= 0;
let _ld_orden		= 0;
let	_no_unidad_otr	= null;
let	_vig_fin_otr	= null;	
let	_vig_ini		= null;
let	_no_doc			= null;
let _texto          = null;
let _descuento      = 0.00;
let _cambio_producto = 0;

--if a_no_poliza_ant = '2650001' then
-- set debug file to "sp_pro321.trc"; 
-- trace on;
--end if 

select cod_ramo,
	   year(vigencia_inic),
	   vigencia_inic,
	   cod_grupo,
	   no_documento,
	   periodo
  into _cod_ramo,
	   _ano_actual,
	   _vig_ini,
	   _cod_grupo,
	   _no_documento,
	   _periodo
  from emipomae
 where no_poliza = a_no_poliza;

foreach
    select no_unidad
      into _no_unidad
      from emipouni
     where no_poliza = a_no_poliza

    let _ld_sum_aseg_2 = 0.00;

    select suma_asegurada,
	       cod_producto
      into _ld_sum_aseg_2,
	       _cod_prod
      from emipouni
     where no_poliza = a_no_poliza
       and no_unidad = _no_unidad;

 	let _ld_prima_nueva	= 0.00;
	let _ld_descuento	= 0.00;
	let _ld_porc_depr	= 0.00;

    select no_motor,
           uso_auto
   	  into _no_motor,
   	       _uso_auto
   	  from emiauto
     where no_poliza = a_no_poliza
   	   and no_unidad = _no_unidad;

	let _resultado = 0;

	select ano_auto,nuevo
	  into _ano_auto,_nuevo
	  from emivehic
	 where no_motor = _no_motor;

	let _resultado = _ano_actual - _ano_auto;

	if (_resultado <= 0) or (_resultado = 1) then
		let _resultado = 1;
	else
	    if _nuevo <> 1 then
			let _resultado = _resultado + 1;
		end if	
	end if

   --*** porcentaje de depreciacion
	let _retorno = sp_pro511(a_no_poliza_ant, _no_unidad, _cod_prod); --> endoso beneficio ancon plus, si retorna 1 no debe depreciar
	
	let _cnt_ren = 0;
	let _ld_porc_depr = 0;

	if _retorno = 0 then
		select count(*)
		  into _cnt_ren
		  from emipomae a, emipouni b
		 where a.no_poliza = b.no_poliza
		   and a.no_documento = _no_documento
		   and b.no_unidad = _no_unidad
		   and a.nueva_renov = 'R'
		   and a.actualizado = 1;
		   
		if _cnt_ren is null then
			let _cnt_ren = 0;
		end if
		
		let _cnt_ren = _cnt_ren + 1; -- Se agrega 1 porque el registro temporal no está actualizado
		   
		if _cnt_ren = 2 and _nuevo = 1 then
			let _resultado = 1;
		elif _cnt_ren >= 3 and _nuevo = 1 then
			let _resultado = 3;
		end if
		
		if _cnt_ren >= 1 and _nuevo = 0 then
			let _resultado = 3;
		end if	

        -- SD #15456 Ajuste Programa de Renovaciones Automóvil -- Amado 20-11-2025
		-- si la unidad es nueva y es su renovación 1, no deprecia suma asegurada y debe mantener el mismo valor de PRIMA
		
		if _cnt_ren = 1 and _nuevo = 1 then
			let _resultado = 0;
		end if
	
	   { select nueva_renov
		  into _nueva_renov
		  from emipomae
		 where no_poliza = a_no_poliza_ant;
		 
		if _nueva_renov = "N" and _nuevo = 0 then
			let _resultado = 3;
		end if
		}
		
		select porc_depre
		  into _ld_porc_depr
		  from emidepre
		 where uso_auto  = _uso_auto
		   and _resultado between ano_desde and ano_hasta;
		   
		if  _ld_porc_depr is null then
			let _ld_porc_depr = 0;
		end if
		  		  
		-- Para prueba Amado 03-04-2025
		--if  _ld_porc_depr = 20 then
		--	let _ld_porc_depr = 15;
		--else
		--	let _ld_porc_depr = 10;
		--end if
		   
		--update emivehic
		--   set nuevo = 0
		-- where no_motor   = _no_motor;		   
	else
		let _ld_porc_depr = 0;
	end if
	
	if _cod_grupo in ('00068','77978') then
		let _ld_porc_depr = 20;
	end if

	--busqueda del numero de motor si existe.
	call sp_proe23(a_no_poliza,_no_motor,_vig_ini) returning _error, _no_doc,_vig_fin_otr,_no_unidad_otr; --07/08/2013
	if _error <> 0 then
		return 3;
	end if

	--*******calcula la nueva suma asegurada
	if 	_ld_sum_aseg_2 is null then
		let _ld_sum_aseg_2  = 0;
	end if

	let _ld_sum_aseg_1 = _ld_sum_aseg_2 - (_ld_sum_aseg_2 *  (_ld_porc_depr/100));
	
	--Busqueda de producto nuevo
	let _cod_prod_new = null;
	let _cambio_a_00313 = 0;
	
	select producto_nuevo
	  into _cod_prod_new
	  from prdnewpro3
	 where cod_producto = _cod_prod
	   and activo = 1;
	   
	select cambio_a_00313
      into _cambio_a_00313
      from prdpreren
     where no_documento = _no_documento
	   and periodo = _periodo
	   and tipo_ren = 1;
	   
	if _cambio_a_00313 is null then
		let _cambio_a_00313 = 0;
	end if
	
	if _cambio_a_00313 = 1 then
		let _cod_prod_new = '00313';
	end if
	 
	if _cod_prod_new is not null then
		let _cod_prod = _cod_prod_new;
		let _cambio_producto = 1;
		
		update emipouni
		   set cod_producto = _cod_prod	 
		 where no_poliza      = a_no_poliza
		   and no_unidad      = _no_unidad;	
		   
		-- Cambiar el texto porque cambió el producto
		FOREACH
			select descripcion
			  into _texto
			  from prddesc
			 where cod_producto = _cod_prod
			EXIT FOREACH;
		END FOREACH
			
        if _texto is not null then			
			update emipode2 
			   set descripcion = _texto
			 where no_poliza   = a_no_poliza
			   and no_unidad   = _no_unidad;
		end if
		
		-- Caso SD 10411 - Eliminacion Beneficio Odontológico Planes Auto - SIGMA DENTAL
		if _cod_prod in ('10460','10461','10462','10463') then
			delete from emipocob 
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in ('01579','01577');
		end if
	else	
		FOREACH
			select descripcion
			  into _texto
			  from prddesc
			 where cod_producto = _cod_prod
			EXIT FOREACH;
		END FOREACH
			
        if _texto is not null then			
			update emipode2 
			   set descripcion = _texto
			 where no_poliza   = a_no_poliza
			   and no_unidad   = _no_unidad;
		end if		
	end if
	
	--Proceso de Cambio de Producto por depreciacion o años del auto 15/03/2016
	{call sp_pro384(a_no_poliza,_no_unidad,_resultado,_ld_sum_aseg_1) returning _error;

	if _error <> 0 then
		return _error;
	end if}

	--Actualizar la suma en emipouni para los calculos para que tome nuevo valor en caso de que se haya depreciado
	update emipouni
	   set suma_asegurada = _ld_sum_aseg_1	 
	 where no_poliza      = a_no_poliza
	   and no_unidad      = _no_unidad;	

	select cod_marca
  	  into _cod_marca
  	  from emivehic
 	 where no_motor = _no_motor;

	--if _cod_ramo <> '020' then
	/**/
	let _max_orden = 0;
	--	if a_no_poliza_ant = '958800' then

			if _cod_prod = '01961' or _cod_prod = '02993' then
			
			    select count(*)
				  into _cnt_cober
				  from emipocob
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad
				   and cod_cobertura = '01579';
				   
				if _cnt_cober = 0 or _cnt_cober IS NULL then
					select max(orden)
					  into _max_orden
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad;
					
					let _max_orden = _max_orden + 1;
					Insert Into emipocob(no_poliza, no_unidad, cod_cobertura,orden,deducible,prima_neta,descuento,subir_bo)
									  Values(a_no_poliza,_no_unidad,'01579',_max_orden,0,5,0,1);
				end if
				if _cod_prod = '01961' then
					select count(*)
					  into _cnt_cober
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad
					   and cod_cobertura = '01115'; --Asistencia Vial
					   
					if _cnt_cober = 0 or _cnt_cober IS NULL then
						select max(orden)
						  into _max_orden
						  from emipocob
						 where no_poliza = a_no_poliza
						   and no_unidad = _no_unidad;
						
						let _max_orden = _max_orden + 1;
						Insert Into emipocob(no_poliza, no_unidad, cod_cobertura,orden,deducible,prima_neta,descuento,subir_bo)
										  Values(a_no_poliza,_no_unidad,'01115',_max_orden,0,28.30,0,1);
					end if
				end if	
			end if
		--end if
	/**/
	    if _cod_prod in ('00313','07159') then
			let _cnt_descu = 0; 
			 
			select count(*) 
			  into _cnt_descu
			  from emiunide
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '001';
			   
			if _cnt_descu is null then
				let _cnt_descu = 0;
			end if	
			
			select count(*) 
			  into _cnt_descu_otro
			  from emiunide
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen <> '001';
			
			if _cnt_descu_otro is null then
				let _cnt_descu_otro = 0;
			end if	
			
			if _cnt_descu_otro > 0 then
				let _cambio_producto = 1;
			end if
			   
			if _cnt_descu > 0 then   			
				update emiunide
				   set porc_descuento = 9
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad
				   and cod_descuen = '001';
			else	
				insert into emiunide
				values (a_no_poliza,
						_no_unidad,
					   '001',
					   9,
					   1);
			end if	
            delete from emiunide
             where no_poliza = a_no_poliza
               and no_unidad = _no_unidad
			   and cod_descuen <> '001';			 

            delete from emiunire
             where no_poliza = a_no_poliza
               and no_unidad = _no_unidad;	
		end if
	

------ cambio usando el simulador desde deivid	
	if _cambio_producto = 1 or _cod_prod in ('00313','07159') then --Cambio Amado 08-05-2025
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from emipocob
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad

			let _ld_prima_deduc = 0.00;
			let _ld_prima_anter = 0.00;
			let _ld_deduc_nuevo = 0.00;
			let _ld_deduc_anter = 0.00;
			let _ld_limite_1    = 0.00;
			let _ld_limite_2    = 0.00;

			select deducible,
				   prima_neta, 
				   limite_1,
				   limite_2,
				   orden
			  into _ld_deduc_anter,
				   _ld_prima_anter,
				   _ld_limite_1,
				   _ld_limite_2,
				   _ld_orden
			  from emipocob
			 where no_poliza     = a_no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;

			if _ld_deduc_anter is null then
				let _ld_deduc_anter = 0;
			end if
						
			call sp_pro51g(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_tarifa;       --prima anual
			call sp_pro51z(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_prima_deduc;	--prima neta
			call sp_pro51h(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _cod_marca, _ld_sum_aseg_1, _ld_tarifa, _uso_auto) returning _ld_deduc_nuevo;	--deducible
			
			select acepta_desc
			  into _acep_desc
			  from prdcobpd
			 where cod_cobertura = _cod_cobertura
			   and cod_producto  = _cod_prod;

			if _acep_desc is null then
			   let _acep_desc = 0 ;
			end if
					
			if (_ld_deduc_nuevo = 0.00 or _ld_deduc_nuevo is null) and _cod_prod_new is null then
				if _cod_prod not in('01961', '02993') then
					let _ld_deduc_nuevo = _ld_deduc_anter;
				end if	
			end if

			if _cod_cobertura in ("00119", "00118", "00120", "00121", "00606", "00900", "00103", "00901", "00902", "00903", "00904") then
			   let _ld_limite_1 = _ld_sum_aseg_1;
			elif _cod_cobertura in('00123') then  --Muerte accidental
			  foreach
				select rango_monto1,
				       rango_monto2 
				  into _ld_limite_1,
				       _ld_limite_2
				  from prdtasec
				 where cod_producto  = _cod_prod
				   and cod_cobertura = _cod_cobertura

                 let _ld_deduc_nuevo = 0;

			   	exit foreach;
			  end foreach
			elif _cod_cobertura = '00107' then
				let _ld_deduc_nuevo = _ld_deduc_nuevo || " " || "P/E";
			end if

			if  _ld_prima_deduc is null then
				let _ld_prima_deduc = 0.00;
			end if

			let _ld_limite_1   = trunc(_ld_limite_1,0);
			let _ld_limite_2   = trunc(_ld_limite_2,0);
			let _ld_sum_aseg_1 = trunc(_ld_sum_aseg_1,0);
			
			if _ld_tarifa > 0 and _ld_prima_deduc = 0 then	--Control para evitar coberturas sin el valor de la prima neta 03/07/2015
				return 4;
			end if
			
			update emipocob
			   set deducible     = _ld_deduc_nuevo,
				   prima_neta    = _ld_prima_deduc,
				   limite_1	     = _ld_limite_1,
				   limite_2	     = _ld_limite_2,
				   prima_anual   = _ld_tarifa,
				   prima		 = _ld_tarifa
			 where no_poliza     = a_no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;
		end foreach
		
	---------------------------
	else
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from emipocob
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad

			let _ld_prima_deduc = 0.00;
			let _ld_prima_anter = 0.00;
			let _ld_deduc_nuevo = 0.00;
			let _ld_deduc_anter = 0.00;
			let _ld_limite_1    = 0.00;
			let _ld_limite_2    = 0.00;
			let _ld_prima_neta_anter  = 0.00;
			let _ld_prima_anual_anter = 0.00;

			select deducible,
				   prima_neta, 
				   limite_1,
				   limite_2,
				   orden,
				   prima,
				   prima_anual
			  into _ld_deduc_anter,
				   _ld_prima_neta_anter,
				   _ld_limite_1,
				   _ld_limite_2,
				   _ld_orden,
				   _ld_prima_anter,
				   _ld_prima_anual_anter
			  from emipocob
			 where no_poliza     = a_no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;

			if _ld_deduc_anter is null then
				let _ld_deduc_anter = 0;
			end if
			if _ld_prima_neta_anter is null then
				let _ld_prima_neta_anter = 0;
			end if
			if _ld_prima_anter is null then
				let _ld_prima_anter = 0;
			end if
			if _ld_prima_anual_anter is null then
				let _ld_prima_anual_anter = 0;
			end if

			let _ld_tarifa = _ld_prima_anual_anter; 
					
			call sp_pro51h(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _cod_marca, _ld_sum_aseg_1, _ld_tarifa, _uso_auto) returning _ld_deduc_nuevo;	--deducible		
			
			-- Buscar si la poliza a renovar tuvo endoso de modificacion de unidades que afectaron las coberturas de Lesiones, Asistencia Medica o DPA 
			let _cnt_end_mu = sp_pro1118(a_no_poliza_ant, _cod_cobertura);
			
            if _cnt_end_mu = 0 then			
				if (_ld_deduc_nuevo = 0.00 or _ld_deduc_nuevo is null) and _cod_prod_new is null then
					if _cod_prod not in('01961', '02993') then
						let _ld_deduc_nuevo = _ld_deduc_anter;
					end if	
				end if				
			
				if _cod_cobertura in ("00119", "00118", "00120", "00121", "00606", "00900", "00103", "00901", "00902", "00903", "00904") then
				   let _ld_limite_1 = _ld_sum_aseg_1;
				   --if _cod_cobertura in ("00119", "00121") then
				   --     let _ld_deduc_nuevo_dec = _ld_deduc_nuevo;
				   --	let _ld_deduc_nuevo_dec = _ld_deduc_nuevo_dec + (_ld_deduc_nuevo_dec * 20 / 100);
					--	let _ld_deduc_nuevo = _ld_deduc_nuevo_dec;
				   --end if
				elif _cod_cobertura in('00123') then  --Muerte accidental
				  foreach
					select rango_monto1,
						   rango_monto2 
					  into _ld_limite_1,
						   _ld_limite_2
					  from prdtasec
					 where cod_producto  = _cod_prod
					   and cod_cobertura = _cod_cobertura

					 let _ld_deduc_nuevo = 0;

					exit foreach;
				  end foreach
				elif _cod_cobertura = '00107' then
					let _ld_deduc_nuevo = _ld_deduc_nuevo || " " || "P/E";
				elif _cod_cobertura = '01535' then --Endoso extra plus
					select valor_tar_unica
					  into _ld_tarifa
					  from prdcobpd
					 where cod_producto  = _cod_prod
					   and cod_cobertura = _cod_cobertura;

					update emipocob
					   set prima_neta    = _ld_tarifa,
						   prima_anual   = _ld_tarifa,
						   prima		 = _ld_tarifa
					 where no_poliza     = a_no_poliza
					   and no_unidad     = _no_unidad
					   and cod_cobertura = _cod_cobertura;
				end if

				let _ld_limite_1   = trunc(_ld_limite_1,0);
				let _ld_limite_2   = trunc(_ld_limite_2,0);
				let _ld_sum_aseg_1 = trunc(_ld_sum_aseg_1,0);
				
				
				update emipocob
				   set deducible     = _ld_deduc_nuevo,
				       limite_1	     = _ld_limite_1,
					   limite_2	     = _ld_limite_2
				 where no_poliza     = a_no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;
			else
				call sp_pro51g(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_tarifa;       --prima anual
				call sp_pro51z(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_prima_deduc;	--prima neta
				call sp_pro51h(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _cod_marca, _ld_sum_aseg_1, _ld_tarifa, _uso_auto) returning _ld_deduc_nuevo;	--deducible
			
				select acepta_desc
				  into _acep_desc
				  from prdcobpd
				 where cod_cobertura = _cod_cobertura
				   and cod_producto  = _cod_prod;

				if _acep_desc is null then
				   let _acep_desc = 0 ;
				end if
						
				if (_ld_deduc_nuevo = 0.00 or _ld_deduc_nuevo is null) and _cod_prod_new is null then
					if _cod_prod not in('01961', '02993') then
						let _ld_deduc_nuevo = _ld_deduc_anter;
					end if	
				end if

				if _cod_cobertura in ("00119", "00118", "00120", "00121", "00606", "00900", "00103", "00901", "00902", "00903", "00904") then
				   let _ld_limite_1 = _ld_sum_aseg_1;
				elif _cod_cobertura in('00123') then  --Muerte accidental
				  foreach
					select rango_monto1,
						   rango_monto2 
					  into _ld_limite_1,
						   _ld_limite_2
					  from prdtasec
					 where cod_producto  = _cod_prod
					   and cod_cobertura = _cod_cobertura

					 let _ld_deduc_nuevo = 0;

					exit foreach;
				  end foreach
				elif _cod_cobertura = '00107' then
					let _ld_deduc_nuevo = _ld_deduc_nuevo || " " || "P/E";
				end if

				if  _ld_prima_deduc is null then
					let _ld_prima_deduc = 0.00;
				end if

				let _ld_limite_1   = trunc(_ld_limite_1,0);
				let _ld_limite_2   = trunc(_ld_limite_2,0);
				let _ld_sum_aseg_1 = trunc(_ld_sum_aseg_1,0);
				
				if _ld_tarifa > 0 and _ld_prima_deduc = 0 then	--Control para evitar coberturas sin el valor de la prima neta 03/07/2015
					return 4;
				end if
				
				update emipocob
				   set deducible     = _ld_deduc_nuevo,
					   prima_neta    = _ld_prima_deduc,
					   limite_1	     = _ld_limite_1,
					   limite_2	     = _ld_limite_2,
					   prima_anual   = _ld_tarifa,
					   prima		 = _ld_tarifa
				 where no_poliza     = a_no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;
				
			end if
		end foreach
	end if

	select sum(prima),
	       sum(prima_neta),
		   sum(descuento),
		   sum(recargo)
	  into _ld_tarifa,
		   _ld_prima_deduc,
		   _ld_descuento,
		   _ld_recargo
	  from emipocob
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	--****actualizar valores de impuesto****
	foreach
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = a_no_poliza

		select factor_impuesto
		  into _factor_imp
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

		update emipolim
		   set monto        = (_ld_prima_deduc * _factor_imp) / 100
		 where no_poliza    = a_no_poliza
		   and cod_impuesto = _cod_impuesto;
	end foreach

	select sum(monto)
	  into _monto_impuesto
	  from emipolim
	 where no_poliza    = a_no_poliza;

	if _monto_impuesto is null then
		let _monto_impuesto = 0;
	end if

	let _ld_prima_bruta = 0;
	let _ld_prima_bruta = _ld_prima_deduc + _monto_impuesto;

    call sp_pro323(a_no_poliza,_no_unidad, _ld_sum_aseg_1,'001') returning _valor;	--actualiza emifacon

	SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;
	  
	let _desc_vehic = 0.00;
	 
	select sum(porc_descuento)
	  into _desc_vehic
	  from emicobde
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad
	   and cod_descuen = '007';
	   
	if _desc_vehic > 0.00 then
		let _cod_tipo_tar = '008'; -- Tarifa autos Vehiculos Clasificados 2017
	else	
		SELECT cod_tipo_tar
		  INTO _cod_tipo_tar
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad;
		   
		let _tipo_auto = sp_proe75(a_no_poliza, _no_unidad);
		
		call sp_sis470c(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
		if _tipo_auto = 1 and _cod_tipo_tar in ('001','006') and _no_sinis_ult = 0 then	--'002'
			let _cod_tipo_tar = '006'; -- 
		else	
			let _cod_tipo_tar = '001'; -- Tarifa normales
		
			-- Definir el codigo de tarifa para las unidades
			let _desc_comb = 0.00;
			let _desc_modelo = 0.00;
			let _desc_sini = 0.00;
			let _cod_tipo_tar = '001'; -- Tarifa normales
			
			select sum(porc_descuento)
			  into _desc_comb
			  from emicobde
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '004';
			   
			if _desc_comb > 0.00 then
				let _cod_tipo_tar = '002'; -- Tarifa autos julio 2014
			end if

			select sum(porc_descuento)
			  into _desc_modelo
			  from emicobde
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '005';

			if _desc_modelo > 0.00 then
				let _cod_tipo_tar = '004'; -- Tarifa por modelo
			end if
			   
			select sum(porc_descuento)
			  into _desc_sini
			  from emicobde
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '006';

			if _desc_sini > 0.00 then
				let _cod_tipo_tar = '005'; -- Tarifa por siniestralidad
			end if
		end if
	end if
	--****actualizar valores de unidad****
	update emipouni
	   set suma_asegurada = _ld_sum_aseg_1,
	       prima          = _ld_tarifa,
		   prima_neta     = _ld_prima_deduc,
		   descuento      = _ld_descuento,
		   recargo        = _ld_recargo,
		   impuesto       = _monto_impuesto,
		   prima_bruta    = _ld_prima_bruta,
		   cod_tipo_tar   = _cod_tipo_tar
	 where no_poliza      = a_no_poliza
	   and no_unidad      = _no_unidad;

	--update emivehic
	--   set valor_auto = _ld_sum_aseg_1
	-- where no_motor   = _no_motor;

end foreach
return 0;
end
end procedure;	