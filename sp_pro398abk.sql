-- Procedimiento que carga la tabla de prima no devengada
-- Creado    : 29/07/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro398a;

create procedure sp_pro398a(a_periodo_desde date, a_periodo_hasta date)
returning integer,
	      char(100);

define _error_desc		char(100);
define _no_poliza		char(10);
define _cod_contrato	char(5);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _prima_suscrita	dec(16,2);
define _prima_no_dev	dec(16,2);
define _monto_reas		dec(16,2);
define _prima_dif		dec(16,2);
define _ajuste			dec(16,2);
define _existe			smallint;
define _dias			smallint;
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
  rollback work;	
  return _error,_error_desc;
end exception

create temp table tmp_info_reas
   (no_poliza	char(10),
	no_endoso	char(10),
	prima		dec(16,2),
	comision	dec(16,2),
	impuesto	dec(16,2),
primary key(no_poliza,no_endoso)) with no log;

let _prima_suscrita	= 0.00;
let _prima_no_dev	= 0.00;
let _prima_dif		= 0.00;

foreach	with hold
	select no_poliza,
		   no_endoso,
		   prima_suscrita,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
		   _no_endoso,
		   _prima_suscrita,
		   _vigencia_inic,
		   _vigencia_final
	  from endedmae
	 where periodo >= a_periodo_desde
	   and periodo <= a_periodo_hasta
	   and prima_suscrita <> 0.00
	   and actualizado = 1
	   --and no_poliza = '100164'

	begin work;
	
	select count(*)
	  into _existe
	  from sac999:prdprinode
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _existe > 0 then
		select sum(prima_no_devengada)
		  into _prima_no_dev
		  from sac999:prdprinode
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		 group by no_poliza,no_endoso; 
		
		if _prima_suscrita = _prima_no_dev then
			let _prima_no_dev = 0.00;
			commit work;
			continue foreach;
		else
			delete from sac999:prdprinode
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
		end if
	end if
	
	let _dias = (_vigencia_final - _vigencia_inic);
	
	if _dias = 0 then
		insert into sac999:prdprinode(
				no_poliza,
				no_endoso,
				fecha,
				prima_no_devengada,
				sac_asientos)
		values	(_no_poliza,
				_no_endoso,
				_vigencia_final,
				_prima_suscrita,
				0);
		let _prima_dif = _prima_suscrita;
	else	
		let _prima_no_dev = _prima_suscrita / _dias;
		let _fecha = _vigencia_inic;

		while _fecha < _vigencia_final
			insert into sac999:prdprinode(
					no_poliza,
					no_endoso,
					fecha,
					prima_no_devengada,
					sac_asientos)
			values	(_no_poliza,
					_no_endoso,
					_fecha,
					_prima_no_dev,
					0);
			let _prima_dif = _prima_dif + _prima_no_dev;
			let _fecha = _fecha + 1 units day;
		end while
	end if
	
	if _prima_dif <> _prima_suscrita then
		if _prima_dif > _prima_suscrita then
			let _ajuste = -0.01;
		else
			let _ajuste = 0.01;
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
			 order by fecha desc

			update sac999:prdprinode
			   set prima_no_devengada = prima_no_devengada + _ajuste
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and fecha	 = _fecha;

			let _prima_dif = _prima_dif + _ajuste;
			if _prima_dif = _prima_suscrita then
				exit foreach;
			end if		
		end foreach
	end if
	
	let _prima_no_dev = 0.00;
	let _prima_dif = 0.00;
	
	-- Luego de Calculada la prima de cada dia se procede a calcular el resto de los valores
	-- Comision Corredor
	-- Impuesto
	-- Reseguro Cedido
	-- Impuesto Reaseguro
	-- Comision Reaseguro
	
	call sp_sis415(_no_poliza,_no_endoso) returning _error,_error_desc
	
	if _error <> 0 then
		rollback work;
		return _error,_error_desc;
	end if
	
	commit work;
end foreach

return 0,'Inserción Exitosa';
end
end procedure 