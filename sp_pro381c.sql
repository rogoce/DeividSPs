----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------

--execute procedure sp_pro381('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_pro381c;
create procedure sp_pro381c(
a_no_poliza			char(10),
a_saldo  			dec(16,2),
a_diezporc			dec(16,2),
a_incremento		dec(5,2),
a_descuento         dec(5,2),
a_periodo1          char(7),
a_tipo_ren		    smallint	default 0)
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _porc_desc_modelo	dec(16,2);
define _prima_bruta_ant		dec(16,2);
define _monto_descuento		dec(16,2);
define _porc_desc_flota		dec(16,2);
define _porc_desc_tabla		dec(16,2);
define _porc_desc_sinis		dec(16,2);
define _monto_impuesto		dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_aseg_ant		dec(16,2);
define _porc_desc_rc		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_total			dec(16,2);
define _prima_neta			dec(16,2);
define _valor_auto			dec(16,2);
define _porc_desc			dec(16,2);
define _factor_impuesto		dec(5,2);
define _porc_descuento		dec(5,2); 
define _porc_impuesto		dec(5,2); 
define _no_chasis			char(30);
define _no_motor			char(30);
define _vin					char(30);
define _no_documento		char(20);
define _no_poliza_maestro	char(10);
define _cod_contratante		char(10);
define _cod_asegurado		char(10);
define _no_poliza_e			char(10);
define _placa_taxi			char(10);
define _no_poliza			char(10);
define _placa				char(10);
define _usuario				char(8);
define _periodo				char(7);
define _cod_producto		char(5);
define _cod_acreedor		char(5);
define _cod_agente			char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_impuesto		char(3);
define _cod_tipoveh			char(3);
define _cod_descuen			char(3);
define _cod_subramo			char(3);
define _cod_color			char(3);
define _cod_ramo			char(3);
define _uso_auto			char(1);
define _null				char(1);
define _cnt_existe			smallint;
define _ano_tarifa			smallint;
define _ano_auto			smallint;
define _nuevo				smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _saldo               dec(16,2);
define _diezporc     		dec(16,2);
define _incremento			dec(5,2);
define _descuento   		dec(5,2);
define _nueva_prima_neta	dec(16,2);
define _opcion              char(1);
define _cod_grupo           char(5);
define _climalare           varchar(50);
define _desc_mala_ref       varchar(250);
define _cod_mala_refe       char(3);
define _nota_poliza         varchar(255);
define _nota_poliza_sal     varchar(255);
define _cod_producto_ant	char(5);
define _error_eli			integer;
define _procesado           integer;
define _desc_error          varchar(255);
define _cnt_cob_col         smallint;
define _cnt_acree           smallint; 
define _limite_1            dec(16,2);
define _cnt_prod_exc        smallint;
define _desc_calculado		dec(16,2);
define _flag_jb				smallint;
define _ano_actual			smallint;
define _resultado			smallint;
define _retorno				smallint;
define _cnt_ren				smallint;
define _ld_porc_depr		smallint;
define _cod_formapag    	char(3);

set isolation to dirty read;

--set debug file to "sp_pro381c.trc";
--trace on;


begin
on exception set _error,_error_isam,_error_desc
	begin
		on exception in(-255)
		end exception
	    --rollback work; --Amado 23-09-2024
	end 
	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
	return _error,_error_desc;
end exception


--let _no_poliza_maestro = sp_sis13(a_compania, 'PRO', '02', 'par_no_poliza');
--let _fecha_desde = sp_sis36b(a_periodo1);
--let _fecha_hasta = sp_sis36(a_periodo2);
let _usuario = 'DEIVID';
let _null = null;

--call sp_sis470(a_periodo1, a_tipo_ren) returning _error,_error_isam,_error_desc;

--if a_no_poliza = '2633807' then
--	set debug file to "sp_pro381c.trc";
--	trace on;
--end if

--if _error <> 0 then
--	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
--	return _error,_error_desc;
--end if

let _incremento = 0.00;
let _descuento = 0.00;
let _nueva_prima_neta = 0.00;

let _no_poliza = a_no_poliza;
let _saldo = a_saldo;
let _diezporc = a_diezporc;
let _incremento = a_incremento;
let _descuento = a_descuento;

foreach with hold
	select a.no_documento
	  into _no_documento
	  from emipomae a
	 where a.no_poliza = _no_poliza
	   and a.no_documento not in ('0225-00574-03','0225-00454-05','0223-00964-03','0216-01044-03','0224-01446-01') -- Mayo 2026
--	   and a.no_documento not in ('0225-00356-03','0220-00317-03','0223-01122-01','0219-02006-09','0222-01383-09','0219-01771-09','0223-03404-09')
--	   and a.no_documento not in ('0225-00226-05','0223-00803-01','0221-00459-01','0215-00429-03') -- Marzo 2026 Comercial 
--	   and a.no_documento not in ('0217-00629-01','0220-00370-01','0207-00430-04','0217-00176-06','0223-03797-01','0225-01784-09') -- Marzo 2026 Particular 
--	   and a.no_documento not in ('0224-00616-01','0224-00630-01','0224-01547-09','0219-00649-09','0223-00503-01') -- Febrero 2026 Particular
--	   and a.no_documento not in ('0223-00006-01','0213-00080-09') -- Enero 2026 Particular
--	   and a.no_documento not in ('0225-00027-01','0225-00036-01','0224-00061-05','0225-00081-09') -- Enero 2026 Comercial
--	   and a.no_documento not in ('0224-02927-01','0224-02974-01','0223-01359-05','0220-00610-11','0223-09514-09','0222-00991-10','0212-00749-03','0222-07193-09','0222-03773-01') -- Diciembre 2025 Particular
--	   and a.no_documento not in ('0223-03652-01','0219-05151-09','0216-01024-11','0218-01003-10') -- Noviembre 2025 Particular
--	   and a.no_documento not in ('0217-00549-07') -- Octubre 2025 Comercial
--	   and a.no_documento not in ('0209-01239-03','0218-01819-01','0214-03420-01','0221-01306-03','0222-05268-09','0217-02120-01','0218-04006-09','0216-00005-20') -- Particular Octubre 2025
--	   and a.no_documento not in ('0222-02502-01','0222-02498-01','0223-02686-01') -- Agosto 2025 Comercial
--	   and a.no_documento not in ('0222-04296-09','0219-00725-06','0222-02994-01') -- Particular septiembre 2025
--	   and a.no_documento not in ('0222-01181-03','0224-02359-01') -- Comercial septiembre 2025
--	   and a.no_documento not in ('0219-01688-01','0219-15168-47','0214-00909-03','0224-05488-09') -- julio 2025
--	   and a.no_documento not in ('0219-04284-09','0223-06285-09') -- Agosto 2025 Particular--------	   
--	   and a.no_documento not in ('0222-03523-09','0219-00631-06','0222-04011-09','0223-00762-47','0219-04284-09','0223-06285-09') -- Agosto 2025 Particular
--	   and a.no_documento not in ('0219-00985-90','0218-03198-09') -- Agosto 2025 Banisi
	   
	 
	select count(*) -- Buscando los excluidos Amado 08-05-2025
	  into _cnt_existe
	  from prdpreren
	 where no_documento = _no_documento
	   and periodo = a_periodo1
	   and renovada = 0
	   and procesado = 9;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe > 0 then
		continue foreach;
	end if	 
	 
	let _cnt_existe = 0; 

	select count(*) -- Buscando ya pre-renovados Amado 08-05-2025
	  into _cnt_existe
	  from prdpreren
	 where no_documento = _no_documento
	   and periodo = a_periodo1
	   and renovada = 0
	   and pre_renovado = 1;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe > 0 then
		continue foreach;
	end if	 
	 
	let _cnt_existe = 0; 
	 
	let _no_poliza_maestro  = 'S' || trim(_no_poliza);

	--begin work; --Amado 23-09-2024
	
	--Proceso de Renovación Automática
	--drop table if exists prueba;
	-- call sp_pro320c(_usuario, _no_poliza, _no_poliza_maestro) returning _error,_error_desc;
	if a_tipo_ren = 1 then -- Subramo Particular
		call sp_pro320dSimu(_usuario, _no_poliza, _no_poliza_maestro) returning _error,_error_desc;
	elif a_tipo_ren = 2 then -- Subramo Comercial
		call sp_pro320dComSimu(_usuario, _no_poliza, _no_poliza_maestro) returning _error,_error_desc;
	elif a_tipo_ren = 3 then -- Banisi
		call sp_pro320gSim(_usuario, _no_poliza, _no_poliza_maestro) returning _error,_error_desc;
	else
		continue foreach;
	end if
		
	
	if _error <> 0 then
		--rollback work;
		--Elminación de Registros Temporales en Estructura de Emisión
		
		call sp_sis61b(_no_poliza_maestro) returning _error_eli,_no_poliza_e;

		if _error_eli <> 0 then
			--rollback work; --Amado 23-09-2024
			return _error_eli,'Error Eliminación de información Temporal. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
		end if

		update emipomae
		   set renovada = 0
		 where no_poliza = _no_poliza;

		--commit work; --Amado 23-09-2024
		return _error,'Error Cáculo de Renovación. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc with resume;
		continue foreach;
	end if

	--Información General de la Póliza luego del cálculo de la Renovación
	select cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final,
           cod_grupo,
           year(vigencia_inic),
		   cod_formapag
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_grupo,
		   _ano_actual,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza_maestro;

	--Determinar Periodo de la Renovación
	let _periodo = sp_sis39(_vigencia_inic);

	select count(*)
	  into _cnt_existe
	  from prdpreren
	 where no_documento = _no_documento
	   and periodo = _periodo
	   and renovada = 0
	   and procesado = 0;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe > 0 then
		delete from prdpreren
		 where no_documento = _no_documento
		   and periodo = _periodo
		   and renovada = 0
		   and procesado = 0;
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza_maestro
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	--Información del Impuesto de la Póliza
	let _porc_impuesto = 0;

	foreach
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = _no_poliza_maestro

		select factor_impuesto
		  into _factor_impuesto
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

		let _porc_impuesto = _porc_impuesto + _factor_impuesto;
	end foreach

	--Información de cada Unidad en la Póliza
	foreach
		select no_unidad,
			   cod_asegurado,
			   cod_producto,
			   suma_asegurada,
			   prima,
			   prima_neta,
			   descuento,
			   impuesto,
			   prima_bruta
		  into _no_unidad,
			   _cod_asegurado,
			   _cod_producto,
			   _suma_asegurada,
			   _prima_total,
			   _prima_neta,
			   _monto_descuento,
			   _monto_impuesto,
			   _prima_bruta
		  from emipouni
		 where no_poliza = _no_poliza_maestro
		 
		if _cod_producto in ('00313','07159','00318') then --AUTORC y AUTORC WEB solo aplicar su porcentaje de 9% de aumento, el USADITO no lleva incremento, ni descuento -- Amado 13-06-2025
			let _incremento = 0;
			let _descuento = 0;
		end if		

		if _prima_total = 0 then
			--rollback work;
			update emipomae
			  set renovada = 0
			 where no_poliza = _no_poliza;

			continue foreach;
		end if

		--Información del % de Descuento
		let _porc_descuento = (_monto_descuento / _prima_total) * 100;

		--Información del Acreedor con mayor Participación		
		let _cod_acreedor = _null;
		foreach
			select cod_acreedor
			  into _cod_acreedor
			  from emipoacr
			 where no_poliza = _no_poliza_maestro
			   and no_unidad = _no_unidad
			 order by limite desc
			exit foreach;
		end foreach

		if _cod_acreedor is null then
			let _cod_acreedor = '';
		end if		

		let _prima_bruta_ant = 0.00;

		select prima_bruta,
		       cod_producto,
			   suma_asegurada
		  into _prima_bruta_ant,
		       _cod_producto_ant,
			   _suma_aseg_ant
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _prima_bruta_ant is null then
			let _prima_bruta_ant = 0.00;
		end if

		--Información del Auto en la Póliza
		select no_motor,
			   cod_tipoveh,
			   uso_auto,
			   ano_tarifa,
			   opcion
		  into _no_motor,
			   _cod_tipoveh,
			   _uso_auto,
			   _ano_tarifa,
			   _opcion
		  from emiauto
		 where no_poliza = _no_poliza_maestro
		   and no_unidad = _no_unidad;

		--Información del Vehiculo
		select cod_color,
			   cod_marca,
			   cod_modelo,
			   valor_auto,
			   ano_auto,
			   vin,
			   no_chasis,
			   placa,
			   placa_taxi,
			   nuevo
		  into _cod_color,
			   _cod_marca,
			   _cod_modelo,
			   _valor_auto,
			   _ano_auto,
			   _vin,
			   _no_chasis,
			   _placa,
			   _placa_taxi,
			   _nuevo
		  from emivehic
		 where no_motor = _no_motor;

		if _vin is null then
			let _vin = '';
		end if

		if _placa is null then
			let _placa = '';
		end if

		if _no_chasis is null then
			let _no_chasis = '';
		end if
		
		--------------------
		if a_tipo_ren = 1 then
			let _resultado = 0;

			let _resultado = _ano_actual - _ano_auto;

			if (_resultado <= 0) or (_resultado = 1) then
				let _resultado = 1;
			else
				if _nuevo <> 1 then
					let _resultado = _resultado + 1;
				end if	
			end if

		   --*** porcentaje de depreciacion
			let _retorno = sp_pro511(_no_poliza, _no_unidad, _cod_producto); --> endoso beneficio ancon plus, si retorna 1 no debe depreciar
			
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
					
				select porc_depre
				  into _ld_porc_depr
				  from emidepre
				 where uso_auto  = _uso_auto
				   and _resultado between ano_desde and ano_hasta;
				   
				if  _ld_porc_depr is null then
					let _ld_porc_depr = 0;
				end if
						  
			else
				let _ld_porc_depr = 0;
			end if
			
			if _cod_grupo in ('00068','77978') then
				let _ld_porc_depr = 20;
			end if
			
			-- SD #15456 Ajuste Programa de Renovaciones Automóvil -- Amado 20-11-2025
			-- Si la unidad refleja siniestralidad, debe aplicar recargo, segun la tabla de recargos establecida. A estas unidades no se les aplica descuento cuando no se deprecia la suma asegurada. 
			if _ld_porc_depr = 0 then
				let _descuento = 0; 
			end if
		end if
		--------------------
		
		--  JUSTINIANO BALLESTEROS
		let _cnt_prod_exc = 0;
		let _flag_jb = 0;
	    let _desc_calculado = 0.00;		
			
		select count(*)
		  into _cnt_prod_exc
		  from emipoagt
		 where no_poliza = _no_poliza
		   and (cod_agente in (select cod_agente from agtagent where nombre like 'JUSTINIANO%BALLESTER%'));
		 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then
 			let _desc_calculado = _prima_neta - (_prima_neta * (_descuento / 100));
			
			let _desc_calculado = _desc_calculado + (_desc_calculado * (6 / 100));
			
			if (_prima_bruta_ant - _desc_calculado) > 20.00 then
				let _flag_jb = 1;
			end if
		end if
		
		if _flag_jb = 1 then
			let _desc_calculado = _prima_bruta_ant - 20;
			let _nueva_prima_neta = _desc_calculado / 1.06;
		else
			let _nueva_prima_neta = _prima_neta - (_prima_neta * (_descuento / 100));
		end if

		
		let _nueva_prima_neta = _nueva_prima_neta + (_nueva_prima_neta * (_incremento / 100));
		
		
		----**************************************************
	--selecciona los nombres de clientes
	select cod_mala_refe,
	       desc_mala_ref
	  into _cod_mala_refe,
	       _desc_mala_ref
	  from cliclien
	 where cod_cliente = _cod_contratante;

	-- Notas relevantes
	select nombre
	  into _climalare
	  from climalare
	 where cod_mala_refe = _cod_mala_refe;

	if _climalare is null then	
		let _climalare = "";
	end if

	if _desc_mala_ref is null then	
		let _desc_mala_ref = "";
	end if
	
	-- Notas Poliza
	let _nota_poliza_sal = "";
	let _nota_poliza = "";
	foreach 
		select trim(descripcion)
		  into _nota_poliza
		  from eminotas
		 where no_documento = _no_documento
		   and procesado = 0

		if _nota_poliza is null then
			let _nota_poliza = "";
		end if
		
		let _nota_poliza = REPLACE(_nota_poliza,"|","");
		   
		if length(trim(_nota_poliza_sal)  || " " || trim(_nota_poliza)) > 255 then
			exit foreach;
		end if
				
		let _nota_poliza_sal = trim(trim(_nota_poliza_sal) || " " || trim(_nota_poliza));
    end foreach
	
	let _nota_poliza_sal = REPLACE(_nota_poliza_sal,"|","");
	
	let _procesado = 0;
	let _desc_error = '';
	
	if a_tipo_ren = 1 then -- SD # 13869 -- Amado 30-05-2025
	
		-- Verificar Si producto actual = 00318 y Suma Aseg Dep < 4k, excluir del proceso y reportar.  
		if _suma_asegurada < 4000 and _cod_producto = '00318' AND a_tipo_ren = 1 then
			let _procesado = 9;
			let _desc_error = 'Producto actual = 00318 y Suma Aseg Depreciada < 4000 *';
		end if
		
		--Si la unidad tiene Coberturas COV, Verificar que la OPCIÓN no sea = NULL o Vacío, si no Excluir y reportar.  
		let _cnt_cob_col = 0;
	
		select count(*)
		  into _cnt_cob_col
		  from emipocob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_poliza = _no_poliza_maestro
		   and a.no_unidad = _no_unidad
		   and b.nombre like '%COLISI%';
		   
		if _cnt_cob_col is null then
			let _cnt_cob_col = 0;
		end if
		
		if _cnt_cob_col > 0 and (_opcion is null or trim(_opcion) = "") then
			let _procesado = 9;
			let _desc_error = trim(_desc_error) || 'Verificar que la OPCION no sea = NULL o Vacío *';
		end if
		
		if _cnt_cob_col > 0 then
			select limite_1
			  into _limite_1
			  from emipocob a, prdcober b
			 where a.cod_cobertura = b.cod_cobertura
			   and a.no_poliza = _no_poliza_maestro
			   and a.no_unidad = _no_unidad
			   and b.nombre like '%COLISI%';
			if _limite_1 = 0.00 then   
				let _procesado = 9;
				let _desc_error = trim(_desc_error) || 'Limite Colision en cero *';
			end if
		end if		

		--Si Acreedor = Vacío, Año Uso => 10 y Suma Aseg Depreciada < 5k, excluir y reportar. -- Se excluye lo del acreedor -- Amado 12-06-2025
		{let _cnt_acree = 0;
		
		select count(*)
		  into _cnt_acree
		  from emipoacr 
		 where no_poliza = _no_poliza_maestro
		   and no_unidad = _no_unidad;
		   
		if _cnt_acree is null then
			let _cnt_acree = 0;
		end if
	}	
		if _ano_auto >= 10 and _suma_asegurada < 4000 and _cod_producto not in ('00313','07159','00318') then
			let _procesado = 9;
			let _desc_error = trim(_desc_error) || 'Uso >= 10, suma < 4000 *';
        end if		
		
		-- Excluir ALTA GAMA
		if _suma_asegurada >= 40000 then
			let _procesado = 9;
			let _desc_error = trim(_desc_error) || 'ALTAGAMA REVISAR CON TECNICO *';
        end if		
		
		--Excluir las que tienen notas relevantes por ALTA SINIESTRALIDAD -- DRN - 15456 Ajuste Programa de Renovaciones Automóvil -- Amado 26-11-2025
		if _cod_mala_refe = '008' then
			let _procesado = 9;
			let _desc_error = trim(_desc_error) || trim(_climalare) || ' *';
		end if
		
	end if	   
	
	
	
	
		----****************************************************

		insert into prdpreren(
				no_documento,
				no_unidad,
				cod_ramo,
				cod_subramo,
				cod_contratante,
				cod_agente,
				vigencia_inic,
				vigencia_final,
				cod_asegurado,
				prima,
				prima_neta,
				porc_descuento,
				descuento,
				porc_impuesto,
				impuesto,
				prima_bruta,
				suma_asegurada,
				prima_bruta_ant,
				suma_aseg_ant,
				cod_producto,
				cod_acreedor,
				no_motor,
				cod_tipoveh,
				uso_auto,
				ano_tarifa,
				cod_color,
				cod_marca,
				cod_modelo,
				valor_auto,
				ano_auto,
				no_chasis,
				vin,
				placa,
				placa_taxi,
				nuevo,
				periodo,
				saldo,
				diezporc,
				incremento,
				tipo_ren,
				incremento_neto,
				procesado,
				actualizado,
				no_poliza_r,
				error,
				desc_error,
				prima_resultado,
				descuento_x_sini,
				opcion,
				cod_grupo,
				notas_relevantes,
				notas_polizas,
				cod_producto_ant,
				pre_renovado,
				no_poliza_ant,
				cod_formapag)	
		values(	_no_documento,
				_no_unidad,
				_cod_ramo,
				_cod_subramo,
				_cod_contratante,
				_cod_agente,
				_vigencia_inic,
				_vigencia_final,
				_cod_asegurado,
				_prima_total,
				_prima_neta,
				_porc_descuento,
				_monto_descuento,
				_porc_impuesto,
				_monto_impuesto,
				_prima_bruta,
				_suma_asegurada,
				_prima_bruta_ant,
				_suma_aseg_ant,
				_cod_producto,
				_cod_acreedor,
				_no_motor,
				_cod_tipoveh,
				_uso_auto,
				_ano_tarifa,
				_cod_color,
				_cod_marca,
				_cod_modelo,
				_valor_auto,
				_ano_auto,
				_no_chasis,
				_vin,
				_placa,
				_placa_taxi,
				_nuevo,
				_periodo,
				_saldo,
				_diezporc,
				_incremento,
				a_tipo_ren,
				_nueva_prima_neta,
				_procesado,
				0,
				null,
				0,
				_desc_error,
				0,
				_descuento,
				_opcion,
				_cod_grupo,
				trim(trim(_climalare) || " " || trim(_desc_mala_ref)),
				_nota_poliza_sal,
				_cod_producto_ant,
				1,
				_no_poliza,
				_cod_formapag);

		--Actualización de campos de coberturas
		call sp_pro381a(_no_poliza_maestro,_no_unidad) returning _error,_error_desc;
		
		if _error <> 0 then
			--rollback work; --Amado 23-09-2024
			return _error,'Error Carga de Coberturas. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
		end if

		let _porc_desc_modelo = 0.00;
		let _porc_desc_flota = 0.00;
		let _porc_desc_sinis = 0.00;
		let _porc_desc_tabla = 0.00;
		let _porc_desc_rc = 0.00;
		let _porc_desc = 0.00;

		--Verificación de Descuentos por Cobertura
		foreach
			select cod_cober_reas,
				   cod_descuen,
				   porc_descuento
			  into _cod_cober_reas,
				   _cod_descuen,
				   _porc_desc
			  from emicobde d, prdcober c
			 where d.cod_cobertura = c.cod_cobertura
			   and d.no_poliza = _no_poliza_maestro
			   and d.no_unidad = _no_unidad
			 group by 1,2,3
			 order by 1,2,3

			if _cod_descuen in ('001','004') and _cod_cober_reas in ('002','033') then
				let _porc_desc_rc = _porc_desc;
			elif _cod_descuen in ('001','004') and _cod_cober_reas in ('031','034') then
				let _porc_desc_tabla = _porc_desc;
			elif _cod_descuen = '002' then
				let _porc_desc_flota = _porc_desc;
			elif _cod_descuen = '005' then
				let _porc_desc_modelo = _porc_desc;
			elif _cod_descuen = '006' then
				let _porc_desc_sinis = _porc_desc;
			end if
		end foreach

		let _porc_desc = 0.00;

		--Verificación de Descuentos por Unidad
		foreach
			select cod_descuen,
				   porc_descuento
			  into _cod_descuen,
				   _porc_desc
			  from emiunide
			 where no_poliza = _no_poliza_maestro
			   and no_unidad = _no_unidad
			 group by 1,2
			 order by 1,2

			if _cod_descuen in ('001') then
				let _porc_desc_rc = _porc_desc;
			elif _cod_descuen in ('002') then
				let _porc_desc_flota = _porc_desc;
			elif _cod_descuen in ('003') then
				let _porc_desc_tabla = _porc_desc;
			end if
		end foreach

		update prdpreren
		   set porc_desc_rc = _porc_desc_rc,
			   porc_desc_flota = _porc_desc_flota,
			   porc_desc_tabla = _porc_desc_tabla,
			   porc_desc_modelo = _porc_desc_modelo,
			   porc_desc_sinis = _porc_desc_sinis
		 where no_documento = _no_documento
		   and periodo = _periodo;
	end foreach

	--Elminación de Registros Temporales en Estructura de Emisión
	call sp_sis61b(_no_poliza_maestro) returning _error,_no_poliza_e;

	if _error <> 0 then
		--rollback work; --Amado 23-09-2024
		return _error,'Error Eliminación de información Temporal. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
	end if

	update emipomae
	   set renovada = 0
	 where no_poliza = _no_poliza;

	--commit work; --Amado 23-09-2024
end foreach

drop table if exists tmp_sim_auto;

return 0,'Generación de Datos Exitosa';

end
end procedure;