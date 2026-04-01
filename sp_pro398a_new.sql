-- Procedimiento que carga la tabla de prima no devengada
-- Creado    : 29/07/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro398a;

create procedure sp_pro398a(a_periodo_desde char(7), a_periodo_hasta char(7))
returning integer,
	      char(255);

define _error_desc		char(255);
define _no_poliza		char(10);
define _cod_contrato	char(5);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _prima_suscrita	dec(16,2);
define _rcnd_pri_res	dec(16,2);
define _rcnd_com_res	dec(16,2);
define _rcnd_imp_res	dec(16,2);
define _psnd_imp_res	dec(16,2);
define _psnd_com_res	dec(16,2);
define _prima_nd_dif	dec(16,2);
define _monto_reas		dec(16,2);
define _prima_dif		dec(16,2);
define _prima_rea		dec(16,2);
define _comis_rea		dec(16,2);
define _comis_agt		dec(16,2);
define _impuesto		dec(16,2);
define _imp_reas		dec(16,2);
define _monto_rcnd_pri	dec(32,2);
define _monto_rcnd_com	dec(32,2);
define _monto_rcnd_imp	dec(32,2);
define _monto_psnd_imp	dec(32,2);
define _monto_psnd_com	dec(32,2);
define _rcnd_pri_dif	dec(32,2);
define _rcnd_com_dif	dec(32,2);
define _rcnd_imp_dif	dec(32,2);
define _psnd_imp_dif	dec(32,2);
define _psnd_com_dif	dec(32,2);
define _prima_no_dev	dec(32,2);
define _existe			smallint;
define _dias			integer;
define _error_isam		integer;
define _error			integer;
define _vigencia_inic 	date;
define _vigencia_final 	date;
define _fecha			date;

set isolation to dirty read;

--set debug file to "sp_pro398.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	rollback work;
	return _error,_error_desc;
end exception

let _prima_suscrita	= 0.00;
let _monto_rcnd_pri	= 0.00;
let _monto_rcnd_com	= 0.00;
let _monto_rcnd_imp	= 0.00;
let _monto_psnd_imp	= 0.00;
let _monto_psnd_com	= 0.00;
let _rcnd_pri_dif	= 0.00;
let _rcnd_com_dif	= 0.00;
let _rcnd_imp_dif	= 0.00;
let _psnd_imp_dif	= 0.00;
let _psnd_com_dif	= 0.00;
let _prima_no_dev	= 0.00;
let _prima_nd_dif	= 0.00;
let _monto_reas		= 0.00;
let _prima_dif		= 0.00;
let _prima_rea		= 0.00;
let _comis_rea		= 0.00;
let _comis_agt		= 0.00;
let _impuesto		= 0.00;
let _imp_reas		= 0.00;

foreach	with hold
	select no_poliza,
		   no_endoso,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
		   _no_endoso,
		   _vigencia_inic,
		   _vigencia_final
	  from endedmae
	 where periodo >= a_periodo_desde
	   and periodo <= a_periodo_hasta
	   and prima_suscrita <> 0.00
	   and actualizado = 1
	   --and no_poliza = '525912'--'99786'
	   --and fecha_emision < '03/01/2011'
	 order by 1,2

	begin work;

	-- Calculo Totalizado de los campos de:
	-- Comision Corredor, Impuesto,Reseguro Cedido,Impuesto Reaseguro,Comision Reaseguro
	call sp_sis415(_no_poliza,_no_endoso) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		return _error,_error_desc;
	end if

	select prima_suscrita,
		   impuesto,
		   prima_rea,
		   imp_reas,
		   comis_rea,
		   comis_agt
	  into _prima_suscrita,
		   _impuesto,
		   _prima_rea,
		   _imp_reas,
		   _comis_rea,
		   _comis_agt
	  from tmp_info_reas
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select count(*)
	  into _existe
	  from sac999:prdprinode
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _existe > 0 then
		{select sum(prima_no_devengada)
		  into _prima_no_dev
		  from sac999:prdprinode
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		 group by no_poliza,no_endoso; 
		
		if _prima_suscrita = _prima_no_dev then
			let _prima_no_dev = 0.00;
			drop table tmp_info_reas;
			commit work;
			continue foreach;
		else}
			delete from sac999:prdprinode
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
		--end if
	end if

	let _dias = (_vigencia_final - _vigencia_inic);
	let _fecha = _vigencia_inic;
	
	if _dias = 0 then
		insert into sac999:prdprinode(
				no_poliza,
				no_endoso,
				fecha,
				prima_no_devengada,
				sac_asientos,
				monto_rcnd_pri,
				monto_rcnd_com,
				monto_rcnd_imp,
				monto_psnd_imp,
				monto_psnd_com)
		values(	_no_poliza,
				_no_endoso,
				_fecha,
				_prima_suscrita,
				0,
				_prima_rea,
				_comis_rea,
				_imp_reas,
				_impuesto,
				_comis_agt);
	else	
		let _prima_no_dev	= _prima_suscrita / _dias;
		let _monto_rcnd_pri	= _prima_rea / _dias;
		let _monto_rcnd_com	= _comis_rea / _dias;
		let _monto_rcnd_imp	= _imp_reas / _dias;
		let _monto_psnd_imp	= _impuesto / _dias;
		let _monto_psnd_com	= _comis_agt / _dias;
		
		let _prima_dif		= _prima_suscrita;
		let _rcnd_pri_dif	= _prima_rea;
		let _rcnd_com_dif	= _comis_rea;
		let _rcnd_imp_dif	= _imp_reas;
		let _psnd_imp_dif	= _impuesto;
		let _psnd_com_dif	= _comis_agt;
		
		while _fecha < _vigencia_final
			insert into sac999:prdprinode(
					no_poliza,
					no_endoso,
					fecha,
					prima_no_devengada,
					sac_asientos,
					monto_rcnd_pri,
					monto_rcnd_com,
					monto_rcnd_imp,
					monto_psnd_imp,
					monto_psnd_com)
			values(	_no_poliza,
					_no_endoso,
					_fecha,
					_prima_no_dev,
					0,
					_monto_rcnd_pri,
					_monto_rcnd_com,
					_monto_rcnd_imp,
					_monto_psnd_imp,
					_monto_psnd_com);

			let _prima_dif		= _prima_dif	- _prima_no_dev;
			let _rcnd_pri_dif	= _rcnd_pri_dif - _monto_rcnd_pri;
			let _rcnd_com_dif	= _rcnd_com_dif - _monto_rcnd_com;
			let _rcnd_imp_dif	= _rcnd_imp_dif - _monto_rcnd_imp;
			let _psnd_imp_dif	= _psnd_imp_dif - _monto_psnd_imp;
			let _psnd_com_dif	= _psnd_com_dif - _monto_psnd_com;
			let _fecha = _fecha + 1 units day;
		end while
		
		if	abs(_prima_dif) + abs(_rcnd_pri_dif) + abs(_rcnd_com_dif) +
			abs(_rcnd_imp_dif)+ abs(_psnd_imp_dif)+ abs(_psnd_com_dif) <> 0 then
			
			if _prima_dif < 0 then
				let _prima_nd_dif = -0.01;
			elif _prima_dif > 0 then
				let _prima_nd_dif = 0.01;
			end if
			
			if _rcnd_pri_dif < 0 then
				let  _rcnd_pri_res= -0.01;
			elif _rcnd_pri_dif > 0 then
				let _rcnd_pri_res = 0.01;
			end if
			
			if _rcnd_com_dif < 0 then
				let _rcnd_com_res = -0.01;
			elif _rcnd_com_dif > 0 then
				let _rcnd_com_res = 0.01;
			end if
			
			if _rcnd_imp_dif < 0 then
				let _rcnd_imp_res = -0.01;
			elif _rcnd_imp_dif > 0 then
				let _rcnd_imp_res = 0.01;
			end if
			
			if _psnd_imp_dif < 0 then
				let _psnd_imp_res = -0.01;
			elif _psnd_imp_dif > 0 then
				let _psnd_imp_res = 0.01;
			end if
			
			if _psnd_com_dif < 0 then
				let _psnd_com_res = -0.01;
			elif _psnd_com_dif > 0 then
				let _psnd_com_res = 0.01;
			end if

			foreach
				select no_poliza,
					   no_endoso,
					   fecha
				  into _no_poliza,
					   _no_endoso,
					   _fecha
				  from sac999:prdprinode
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				 order by fecha asc
				 
				if abs(_prima_dif) <> 0 then
					let _prima_dif = _prima_dif	- _prima_nd_dif;
				else
					let _prima_nd_dif = 0;
				end if
				if abs(_rcnd_pri_dif) <> 0 then
					let _rcnd_pri_dif = _rcnd_pri_dif - _rcnd_pri_res;
				else
					let _rcnd_pri_res = 0;
				end if
				if abs(_rcnd_com_dif) <> 0 then
					let _rcnd_com_dif = _rcnd_com_dif - _rcnd_com_res;
				else
					let _rcnd_com_res = 0;
				end if
				if abs(_rcnd_imp_dif) <> 0 then
					let _rcnd_imp_dif = _rcnd_imp_dif - _rcnd_imp_res;
				else
					let _rcnd_imp_res = 0;
				end if
				if abs(_psnd_imp_dif) <> 0 then
					let _psnd_imp_dif = _psnd_imp_dif - _psnd_imp_res;
				else
					let _psnd_imp_res = 0;
				end if
				if abs(_psnd_com_dif) <> 0 then
					let _psnd_com_dif = _psnd_com_dif - _psnd_com_res;
				else
					let _psnd_com_res = 0;
				end if

				update sac999:prdprinode
				   set prima_no_devengada	= prima_no_devengada + _prima_nd_dif,
					   monto_rcnd_pri		= monto_rcnd_pri + _rcnd_pri_res,
					   monto_rcnd_com		= monto_rcnd_com + _rcnd_com_res,
					   monto_rcnd_imp		= monto_rcnd_imp + _rcnd_imp_res,
					   monto_psnd_imp		= monto_psnd_imp + _psnd_imp_res,
					   monto_psnd_com		= monto_psnd_com + _psnd_com_res
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and fecha	 = _fecha;
				
				if	abs(_prima_dif) + abs(_rcnd_pri_dif) + abs(_rcnd_com_dif) +
					abs(_rcnd_imp_dif)+ abs(_psnd_imp_dif)+ abs(_psnd_com_dif) = 0 then
					exit foreach;
				end if
			end foreach
		end if
	end if

	let _prima_suscrita	= 0.00;
	let _monto_rcnd_pri	= 0.00;
	let _monto_rcnd_com	= 0.00;
	let _monto_rcnd_imp	= 0.00;
	let _monto_psnd_imp	= 0.00;
	let _monto_psnd_com	= 0.00;
	let _rcnd_pri_dif	= 0.00;
	let _rcnd_com_dif	= 0.00;
	let _rcnd_imp_dif	= 0.00;
	let _psnd_imp_dif	= 0.00;
	let _psnd_com_dif	= 0.00;
	let _prima_nd_dif	= 0.00;
	let _prima_no_dev	= 0.00;
	let _monto_reas		= 0.00;
	let _prima_dif		= 0.00;
	let _prima_rea		= 0.00;
	let _comis_rea		= 0.00;
	let _comis_agt		= 0.00;
	let _impuesto		= 0.00;
	let _imp_reas		= 0.00;
	
	drop table tmp_info_reas;
	commit work;
end foreach

return 0,'Inserción Exitosa';
end
end procedure 