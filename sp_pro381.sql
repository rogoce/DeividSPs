----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------

--execute procedure sp_pro381('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_pro381;
create procedure sp_pro381(
a_compania			char(3),
a_agencia			char(3),
a_periodo1			char(7),
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


set isolation to dirty read;

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

call sp_sis470(a_periodo1, a_tipo_ren) returning _error,_error_isam,_error_desc;

--set debug file to "sp_pro381.trc";
--trace on;

if _error <> 0 then
	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
	return _error,_error_desc;
end if

let _incremento = 0.00;
let _descuento = 0.00;
let _nueva_prima_neta = 0.00;

foreach with hold
	select a.no_poliza,
		   a.no_documento,
		   a.suma_asegurada,
		   b.saldo,
		   b.diezporc,
		   b.incremento,
		   b.descuento
	  into _no_poliza,
		   _no_documento,
		   _suma_aseg_ant,
		   _saldo,
		   _diezporc,
		   _incremento,
		   _descuento
	  from emipomae a, tmp_sim_auto b
	 where a.no_poliza = b.no_poliza
	--   and a.no_documento = '0223-00562-05'
	 
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
           cod_grupo		   
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_grupo
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
		
		let _nueva_prima_neta = _prima_neta - (_prima_neta * (_descuento / 100));

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
				cod_producto_ant)	
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
				0,
				0,
				null,
				0,
				null,
				0,
				_descuento,
				_opcion,
				_cod_grupo,
				trim(trim(_climalare) || " " || trim(_desc_mala_ref)),
				_nota_poliza_sal,
				_cod_producto_ant);

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

drop table tmp_sim_auto;

return 0,'Generación de Datos Exitosa';

end
end procedure;