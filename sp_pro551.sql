--Procedure que procesa la carga de pólizas de Coaseguro Minoritario
-- 30/03/2016 - Autor: Román Gordón.
-- execute procedure sp_pro551('005',1,'DEIVID')

drop procedure sp_pro551;
create procedure sp_pro551(a_cod_coasegur char(3),a_num_carga integer,a_user_proceso char(8),a_renglon smallint)
returning integer, varchar(100);

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _no_poliza_coaseg	varchar(30);
define _cedula				varchar(30);
define _ramo				varchar(30);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _tipo_factura		char(3);
define _cod_sucursal		char(3);
define _cod_tipocan			char(3);
define _cod_ramo			char(3);
define _total_a_pagar		dec(16,2);
define _gastos_manejo		dec(16,2);
define _prima_ancon			dec(16,2);
define _prima_total			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define _porc_partic_ancon	dec(7,4);
define v_saldo				dec(16,2);
define _cnt_existe			smallint;
define _renglon				smallint;
define r_error				smallint;
define _vigencia_inic_fe	date;
define _vigencia_final		date;
define _fecha_factura		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _error_isam			integer;
define _error				integer;

set lock mode to wait;

begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_pro551.trc"; 
--trace on;

let a_cod_coasegur = a_cod_coasegur;
let a_num_carga = a_num_carga;
let a_user_proceso = a_user_proceso;
let a_renglon = a_renglon;
let _cod_sucursal = '001';
let _cod_tipocan = '021';
let _fecha_hoy = today;
let _no_endoso = '00000';

foreach with hold
	select no_poliza_coaseg,
		   cedula,
		   nom_cliente,
		   tipo_factura,
		   fecha_factura,
		   vigencia_inic_fe,
		   cod_ramo,
		   ramo_coaseguro,
		   vigencia_inic,
		   vigencia_final,
		   prima,
		   impuesto,
		   total_a_pagar,
		   porc_partic_ancon,
		   renglon
	  into _no_poliza_coaseg,
		   _cedula,
		   _nom_cliente,
		   _tipo_factura,
		   _fecha_factura,
		   _vigencia_inic_fe,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_total,
		   _impuesto,
		   _total_a_pagar,
		   _porc_partic_ancon,
		   _renglon
	  from emicacoami
	 where cod_coasegur = a_cod_coasegur
	   and num_carga = a_num_carga
	   and renglon = a_renglon
	   and procesado = 0
	   --and tipo_factura = 'EMI'
	   --and cod_ramo = '002'
	   --and prima > 0
	 order by prima desc

	--begin work;

	select count(*)
	  into _cnt_existe
	  from emipomae
	 where no_poliza_coaseg = _no_poliza_coaseg
	   and actualizado = 1;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if
	
	if _cnt_existe > 0 and _tipo_factura in ('EMI','EMR') then
		let _tipo_factura = 'MOD';
	end if

	if _tipo_factura in ('EMI','EMR') then --Emisión, Renovación
		call sp_pro551a(a_cod_coasegur,a_num_carga,_renglon,a_user_proceso) returning _error, _error_desc;

		if _error <> 0 then
			let _error_desc = 'Póliza: ' || trim(_no_poliza_coaseg) || trim(_error_desc);
			return _error, _error_desc with resume;
			--rollback work;
			--commit work;
			continue foreach;
		end if

		select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = _error_desc;
		
		update emicacoami
		   set no_documento = _no_documento
		 where cod_coasegur = a_cod_coasegur
		   and num_carga = a_num_carga
		   and renglon = _renglon;

	elif _tipo_factura in ('MOD') then --Emisión, Endoso
		if _cnt_existe = 0 then
			call sp_pro551a(a_cod_coasegur,a_num_carga,_renglon,a_user_proceso) returning _error, _error_desc;

			if _error <> 0 then
				let _error_desc = 'Póliza: ' || trim(_no_poliza_coaseg) || trim(_error_desc);
				return _error, _error_desc with resume;
				--rollback work;
				continue foreach;
			end if
			
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = _error_desc;
			
			update emicacoami
			   set no_documento = _no_documento
			 where cod_coasegur = a_cod_coasegur
			   and num_carga = a_num_carga
			   and renglon = _renglon;
		else
			foreach
				select no_documento
				  into _no_documento
				  from emipomae
				 where no_poliza_coaseg = _no_poliza_coaseg
				exit foreach;
			end foreach
		
			let _no_poliza = sp_sis21(_no_documento);
		
			if _no_poliza is null then
				--commit work;
				continue foreach;
			end if
			
			let _prima_ancon = (_total_a_pagar * (_porc_partic_ancon/100));

			call sp_pro551c(_no_poliza,a_user_proceso,_prima_ancon,'001') returning _error, _error_desc,_no_endoso;

			if _error <> 0 then
				let _error_desc = 'Póliza: ' || trim(_no_poliza_coaseg) || trim(_error_desc);
				return _error, _error_desc with resume;
				--rollback work;
				continue foreach;
			end if
		end if
	elif _tipo_factura in ('ANU') then --Cancelación/Anulación
		
		if _cnt_existe = 0 then
			commit work;
			continue foreach;
		end if
		
		foreach
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza_coaseg = _no_poliza_coaseg
			exit foreach;
		end foreach

		let _no_poliza = sp_sis21(_no_documento);
		
		if _no_poliza is null then
			commit work;
			continue foreach;
		end if
		
		--Se debe cambiar a positivo porque el procedure que hace la cancelación lo cambia a negativo internamente
		let _prima_ancon = (_total_a_pagar * (_porc_partic_ancon/100)) * -1;

		--Endoso de Cancelación por Solicitud del Coasegurador
		call sp_par342(_no_poliza,a_user_proceso,_prima_ancon,_cod_sucursal,_cod_tipocan,_fecha_hoy) returning _error,_error_desc,_no_endoso;

		if _error <> 0 then
			let _error_desc = 'Poliza: ' || trim(_no_poliza_coaseg) || trim(_error_desc);
			--rollback work;
			return _error, _error_desc with resume;
			continue foreach;
		end if
	else
		--commit work;
		continue foreach;
	end if
	
	call sp_sis21(_no_documento) returning _no_poliza;

	select no_factura
	  into _no_factura
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update emicacoami
	   set no_documento = _no_documento,
		   no_endoso = _no_endoso,
		   no_factura = _no_factura,
		   procesado = 1,
		   date_proceso = _fecha_hoy,
		   user_proceso = a_user_proceso
	 where cod_coasegur = a_cod_coasegur
	   and num_carga = a_num_carga
	   and renglon = _renglon;
	
	--commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;