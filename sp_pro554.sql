-- Procedimiento que carga la provisión de Corredores.
-- 25/04/2016 - Autor: Román Gordón.
-- execute procedure sp_pro554('001','001','2018-05','2018-05')

drop procedure sp_pro554;
create procedure sp_pro554(a_compania char(3), a_sucursal char(3), a_periodo char(7), a_periodo2 char(7))
returning	integer,                  --1
			varchar(100);             --2


define _error_desc			varchar(100);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_tipoprod1		char(3);
define _cod_tipoprod2		char(3);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _porc_partic_coas	dec(7,4);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _monto_comision		dec(16,2);
define _porc_impuesto		dec(16,2);
define _prima_agente		dec(16,2);
define v_saldo_b			dec(16,2);
define v_saldo				dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _monto_120			dec(16,2);
define _monto_150			dec(16,2);
define _monto_180			dec(16,2);
define _exigible			dec(16,2);
define _saldo_pxc			dec(16,2);
define _estatus_poliza		smallint;
define _cnt_verif			smallint;
define _mes					smallint;
define _ano					smallint;
define _session_id			integer;
define _error_isam			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _ult_dia_periodo		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha				date;
define _cnt_rehab           smallint;
define _fecha_emision       date;

set isolation to dirty read;

--set debug file to 'sp_pro554.trc';
--trace on ;

begin
on exception set _error, _error_isam, _error_desc
	begin
		on exception in(-255)
	end exception
		--rollback work;
	end

	delete from con_corr
	 where sessionid = _session_id;

	return _error, _no_documento || trim(_error_desc);
end exception

let _session_id = DBINFO('sessionid');

select cod_tipoprod
  into _cod_tipoprod1
  from emitipro
 where tipo_produccion = 1;	-- sin coaseguro

select cod_tipoprod
  into _cod_tipoprod2
  from emitipro
 where tipo_produccion = 2;	-- coaseguro mayoritario

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
let _fecha = sp_sis36(a_periodo);
let _fecha = _fecha + 1 units day;
let _saldo_pxc = 0.00;

foreach with hold
	select c.no_documento,
		   c.saldo_pxc
	  into _no_documento,
		   v_saldo
	  from emipoliza e, deivid_cob:cobmoros2 c
	 where e.no_documento = c.no_documento
	   and c.saldo_pxc <> 0
	   and c.periodo = a_periodo

	foreach
		select no_poliza,
			   vigencia_inic,
			   estatus_poliza,
			   fecha_cancelacion
		  into _no_poliza,
			   _vigencia_inic,
			   _estatus_poliza,
			   _fecha_cancelacion
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado = 1
		 order by vigencia_final desc

		if _vigencia_inic < _fecha then
			exit foreach;
		end if
	end foreach

	let _cnt_verif = 0;

	select count(*)
	  into _cnt_verif
	  from prov_agt
	 where no_poliza = _no_poliza
	   and periodo = a_periodo;

	if _cnt_verif is null then
		let _cnt_verif = 0;
	end if

	if _cnt_verif > 0 then
		--commit work;
		continue foreach;
	end if

	select cod_tipoprod,
		   cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  into _cod_tipoprod,
		   _cod_ramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = _cod_tipoprod2 then
		{select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036'; --> Aseguradora Ancon

		let v_saldo = v_saldo * _porc_partic_coas / 100;}
	elif _cod_tipoprod = '004' then
		let v_saldo = 0.00;
	end if

	--Solicitud RGORDON, 12/01/2018 leer saldo_pxc de cobmoros2 y llenar con_corr	
	call sp_sis101a(_no_documento,_fecha,_fecha,_session_id) returning  _error;	
--	call ap_sis101a(_no_documento,_fecha,_fecha,_session_id) returning  _error;	

	--Solicitud RGORDON, 12/01/2018 tomar porcentaje, porc_comis_agt de  con_corr 
	foreach		 
		 select cod_agente,
			    porcentaje,
				porc_comis_agt
		   into _cod_agente,
			    _porc_partic_agt,
				_porc_comis_agt
		   from con_corr
		  where sessionid = _session_id

		let _prima_agente = v_saldo * (_porc_partic_agt/100);
		let _monto_comision = _prima_agente * (_porc_comis_agt/100);
		
		if _cod_agente in ('02915') then --Caso 15423 Zuleyka 17/11/25
			let _monto_comision = 0.00;
		end if
		
		
		if _cod_agente in ('03254') and _cod_ramo in ('002','020','023') then --Caso 15423 Zuleyka 17/11/25
			let _monto_comision = 0.00;
		end if
		
		
		
		if _estatus_poliza in (2,4) and _fecha_cancelacion <= _fecha then
		    foreach
				select fecha_emision
				  into _fecha_emision
				  from endedmae
				 where no_poliza = _no_poliza
				   and cod_endomov = '002'
				   and vigencia_inic = _fecha_cancelacion
				   and actualizado = 1
				exit foreach;
			end foreach
			   
			if _fecha_emision <= _fecha then   
				let _monto_comision = 0.00;
			end if
		elif _estatus_poliza = 1 then
			let _cnt_rehab = 0;
			select count(*)
			  into _cnt_rehab
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '003'
			   and actualizado = 1
			   and fecha_emision > _fecha;
			
			if _cnt_rehab > 0 then
				foreach
					select fecha_emision
					  into _fecha_emision
					  from endedmae
					 where no_poliza = _no_poliza
					   and cod_endomov = '003'
					   and actualizado = 1
					   and fecha_emision > _fecha
					order by fecha_emision desc
					exit foreach;
				end foreach

				let _cnt_rehab = 0;
				
				select count(*)
				  into _cnt_rehab
				  from endedmae
				 where no_poliza = _no_poliza
				   and cod_endomov = '002'
				   and actualizado = 1
				   and fecha_emision between _fecha and _fecha_emision;
			
				if _cnt_rehab = 0 then
					let _monto_comision = 0.00;
				end if
			end if
		end if

		insert into prov_agt(
				periodo,
				no_documento,
				cod_contratante,
				vigencia_inic,
				vigencia_final,
				cod_ramo,
				saldo_tot,
				no_poliza,
				cod_agente,
				porc_partic_agt,
				porc_comis_agt,
				comision)
		values(	a_periodo2,
				_no_documento,
				_cod_contratante,
				_vigencia_inic,
				_vigencia_final,
				_cod_ramo,
				_prima_agente,
				_no_poliza,
				_cod_agente,
				_porc_partic_agt,
				_porc_comis_agt,
				_monto_comision);
	end foreach
end foreach

delete from con_corr
 where sessionid = _session_id;

end
return 0, 'Exito';
end procedure;