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
a_periodo2			char(7),
a_sucursal			char(255)	default '*',
a_ramo				char(255)	default '*',
a_grupo				char(255)	default '*',
a_usuario			char(255)	default '*',
a_reaseguro			char(255)	default '*',
a_agente			char(255)	default '*',
a_saldo_cero		smallint,
a_cod_cliente		char(255)	default '*',
a_no_documento		char(255)	default '*',
a_opcion_renovar	smallint	default 0,
a_tipo_prod			char(255)	default '*',
a_cod_vendedor		char(255)	default '*',
a_status_pool		char(255)	default '*')
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

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	begin
		on exception in(-255)
		end exception
		rollback work;
	end 
	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
	return _error,_error_desc;
end exception

--set debug file to "sp_pro381.trc";
--trace on;

let _no_poliza_maestro = sp_sis13(a_compania, 'PRO', '02', 'par_no_poliza');
let _fecha_desde = sp_sis36b(a_periodo1);
let _fecha_hasta = sp_sis36(a_periodo2);
let _usuario = 'DEIVID';
let _null = null;

foreach with hold
	select no_poliza,
		   no_documento,
		   suma_asegurada
	  into _no_poliza,
		   _no_documento,
		   _suma_aseg_ant
	  from emipomae
	 where vigencia_final >= _fecha_desde
	   and vigencia_final <= _fecha_hasta
	   and actualizado = 1
	   and renovada    = 0
	   and no_renovar  = 0
	   and incobrable  = 0
	   and abierta     = 0
	   and estatus_poliza in (1,3)
	   and cod_ramo in ('002','020','023')
	   and no_documento not in ('0213-00563-03','0213-00835-04','0213-00891-04','0213-00805-04','0213-00865-04','2014-00725-09','2015-00649-06','0209-00313-56','0209-01381-01','0212-00894-01','2015-00648-09','0213-00617-09','0212-00146-07','2015-00664-09',
								'0213-00999-04','2015-00692-09','0215-00366-10','0213-00944-04','2015-00705-09','2015-00708-09','2315-00091-01')
	   {and no_documento in ('0203-00331-01','0204-00120-23','0204-90075-47','0205-00023-23','0205-00041-04','0205-20058-56','0205-20105-56','0206-10049-59','0207-00504-04','0207-00568-01','0208-00179-02','0208-00235-01','0209-00062-07','0209-00097-02',
	                        '0209-00127-04','0209-00156-03','0209-00306-01','0209-00341-01','0209-10347-59','0209-90012-47','0210-00028-02','0210-00043-02','0210-00054-09','0210-00169-01','0210-00258-01','0210-00335-01','0210-10035-47','0210-10187-47',
							'0210-90029-47','0210-90041-47','0210-90367-47','0211-00044-03','0211-00098-09','0211-00109-09','0211-00137-09','0211-10003-47','0211-10210-47','0211-10213-47','0211-10221-47','0211-20005-47','0211-90390-47','0211-90400-47',
							'0211-90406-47','0211-90409-47','0211-90418-47','0212-00012-72','0212-00017-72','0212-00018-72','0212-00020-72','0212-00023-72','0212-00024-72','0212-00025-72','0212-00026-72','0212-00027-72','0212-00028-72','0212-00073-03',
							'0212-00101-09','0212-00103-09','0212-00110-09','0212-00231-01','0212-00244-01','0213-00039-11','0213-00047-07','0213-00048-06','0213-00106-02','0213-00111-06','0213-00181-03','0213-00188-03','0213-00190-03','0213-00195-04',
							'0213-00202-09','0213-00206-09','0213-00211-09','0213-00214-09','0213-00226-09','0213-00228-09','0213-00247-04','0213-00257-04','0213-00282-04','0213-00374-01','0213-00403-01','0213-00405-01','0213-00423-01','0213-00440-01',
							'0213-00469-01','0213-00506-01','0213-00553-01','0213-00564-01','0213-00606-01','0213-00630-01','0213-00634-01','0213-00645-01','0213-00651-01','0213-00653-01','0213-16265-47','0213-16266-47','0213-16267-47','0213-16274-47',
							'0213-16275-47','0213-16280-47','0213-16288-47','0213-16289-47','0213-16291-47','0213-16298-47','0213-16300-47','0213-16301-47','0213-16304-47','0213-16308-47','0213-16313-47','0213-16314-47','0213-16315-47','0213-16319-47',
							'0213-16328-47','0213-16338-47','0213-16340-47','0213-16342-47','0213-16348-47','0213-16352-47','0213-16354-47','0213-16374-47','0213-16376-47','0213-16386-47','0213-16390-47','0213-16399-47','0213-16401-47','0213-16404-47',
							'0213-16412-47','0213-16417-47','0213-16456-47','0213-16462-47','0213-16463-47','0213-16464-47','0213-16465-47','0213-16466-47','0213-16478-47','0213-16480-47','0213-16482-47','0213-16484-47','0213-16491-47','0213-16514-47',
							'0213-16515-47','0213-16520-47','0213-16548-47','0213-20291-47','0213-20292-47','0213-20313-47','0213-91132-47','0213-91164-47','0213-91175-47','0213-91207-47','0213-91221-47','0213-91240-47','0213-91247-47','0213-91248-47',
							'0213-91249-47','0213-91257-47','0213-91260-47','0213-91264-47','0213-91271-47','0213-91283-47','0213-91295-47','0213-91302-47','0213-91303-47','0213-91304-47','0213-91307-47','0213-91309-47','0213-91312-47','0213-91319-47',
							'0214-00167-11','0214-00206-05','0214-00223-03','0214-00224-03','0214-00251-03','0214-00254-06','0214-00284-06','0214-00321-03','0214-00337-03','0214-00387-09','0214-00423-09','0214-00464-09','0214-00503-09','0214-00507-09',
							'0214-00510-09','0214-00514-09','0214-00534-09','0214-00551-09','0214-00649-01','0214-00676-01','0214-00681-01','0214-00694-01','0214-00700-01','0214-00721-01','0214-00725-01','0214-00731-01','0214-00774-01','0214-00784-01',
							'0214-00840-01','0214-00843-01','0214-00859-01','0214-00862-01','0214-00863-01','0214-00890-01','0214-00920-01','0214-00938-01','0214-00965-01','0214-01123-01','0214-10186-47','0214-10188-47','0214-10190-47','0214-10192-47',
							'0214-10196-47','0214-10198-47','0214-10377-47','0214-10417-47','0214-110038-47','0214-110041-47','0214-110050-47','0214-110055-47','0214-110063-47','0214-110066-47','0214-110073-47','0214-110077-47','0214-110081-47','0214-110082-47',
							'0214-110084-47','0214-110089-47','0214-110090-47','0214-110096-47','0214-110100-47','0214-110101-47','0214-110106-47','0214-110110-47','0214-110114-47','0214-110118-47','0214-110120-47','0214-110124-47','0214-110128-47',
							'0214-110130-47','0214-110133-47','0214-110136-47','0214-110140-47','0214-110142-47','0214-110145-47','0214-110146-47','0214-110161-47','0214-110162-47','0214-110169-47','0214-110171-47','0214-110172-47','0214-110173-47',
							'0214-110175-47','0214-110185-47','0214-110190-47','0214-110197-47','0214-110198-47','0214-110202-47','0214-110204-47','0214-110206-47','0214-110215-47','0214-110221-47','0214-110223-47','0214-110224-47','0214-110235-47',
							'0214-110243-47','0214-110245-47','0214-110246-47','0214-110247-47','0214-110254-47','0214-110262-47','0214-110269-47','0214-110277-47','0214-110281-47','0214-110286-47','0214-110287-47','0214-110293-47','0214-110303-47',
							'0214-110326-47','0214-110332-47','0214-110347-47','0214-110352-47','0214-110370-47','0214-110373-47','0214-110379-47','0214-110383-47','0214-110386-47','0214-110393-47','0214-110399-47','0214-110419-47','0214-110428-47',
							'0214-110430-47','0214-92915-47','0214-92921-47','0214-92922-47','0214-92927-47','0214-92933-47','0214-92935-47','0214-92938-47','0214-92939-47','0214-92940-47','0214-92947-47','0214-92948-47','0214-92950-47','0214-92951-47',
							'0214-92952-47','0214-92959-47','0214-92962-47','0214-92963-47','0214-92969-47','0214-93003-47','0214-93004-47','0214-93007-47','0214-93016-47','0214-93019-47','0214-93022-47','0214-93026-47','0214-93028-47','0215-00028-10',
							'0215-00042-10','0215-00051-10','0215-00056-02','0215-00058-02','0215-00062-02','0215-00063-11','0215-00069-02','0215-00079-06','0215-00091-11','0215-00107-09','0215-00118-05','0215-00131-06','0215-00133-01','0215-00142-06',
							'0215-00154-05','0215-00164-01','0215-00178-05','0215-00187-03','0215-00195-05','0215-00214-03','0215-00235-03','0215-00242-01','0215-00258-03','0215-00275-01','0215-00276-01','0215-00277-01','0215-00280-01','0215-00292-01',
							'0215-00308-01','0215-00323-01','0215-00331-01','0215-00332-01','0215-00333-01','0215-00336-01','0215-00342-05','0215-00353-01','0215-00399-01','0215-00410-01','0215-00416-01','0215-00421-01','0215-00422-01','0215-00426-01',
							'0215-00433-01','0215-00435-01','0215-00459-01','0215-00625-01','0215-93158-47','0215-93162-47','0215-93164-47')}

	begin work;
	--Proceso de Renovación Automática
	--drop table if exists prueba;
	call sp_pro320c(_usuario, _no_poliza, _no_poliza_maestro) returning _error,_error_desc;

	if _error <> 0 then
		--rollback work;
		--Elminación de Registros Temporales en Estructura de Emisión
		call sp_sis61b(_no_poliza_maestro) returning _error,_no_poliza_e;

		if _error <> 0 then
			rollback work;
			return _error,'Error Eliminación de información Temporal. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
		end if

		update emipomae
		   set renovada = 0
		 where no_poliza = _no_poliza;

		commit work;
		return _error,'Error Cáculo de Renovación. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc with resume;
		continue foreach;
	end if

	--Información General de la Póliza luego del cálculo de la Renovación
	select cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final		   
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza_maestro;

	--Determinar Periodo de la Renovación
	let _periodo = sp_sis39(_vigencia_inic);

	select count(*)
	  into _cnt_existe
	  from prdpreren
	 where no_documento = _no_documento
	   and periodo = _periodo
	   and renovada = 0;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe > 0 then
		delete from prdpreren
		 where no_documento = _no_documento
		   and periodo = _periodo
		   and renovada = 0;
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

		select prima_bruta
		  into _prima_bruta_ant
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
			   ano_tarifa
		  into _no_motor,
			   _cod_tipoveh,
			   _uso_auto,
			   _ano_tarifa
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
				periodo)	
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
				_periodo);

		--Actualización de campos de coberturas
		call sp_pro381a(_no_poliza_maestro,_no_unidad) returning _error,_error_desc;
		
		if _error <> 0 then
			rollback work;
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
		rollback work;
		return _error,'Error Eliminación de información Temporal. Póliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
	end if

	update emipomae
	   set renovada = 0
	 where no_poliza = _no_poliza;

	commit work;
end foreach

return 0,'Generación de Datos Exitosa';

end
end procedure;