-- Reporte de las Comisiones por Corredor - Detallado (Corredores con pago anticipado de comisiones)
-- Creado    : 03/01/2013 - Autor: Román Gordón

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

drop procedure sp_che34a;

create procedure sp_che34a(a_compania char(3), a_cod_agente char(5)) 
returning	char(20),	-- 1. poliza
			char(100),	-- 2. asegurado
			char(10),	-- 3. recibo
			date,		-- 4. fecha
			dec(16,2),	-- 5. prima_neta
			dec(16,2),	-- 6. monto
			dec(16,2),	-- 7. prima
			dec(5,2),	-- 8. % partic
			dec(5,2),	-- 9. % comis
			dec(16,2),	-- 10. comision de adelanto
			dec(16,2),	-- 11. comision
			dec(16,2),	-- 12. comision_devengada
			dec(16,2),	-- 13. comision_saldo
			char(50),   -- 14. agente
			char(50),	-- 15. compania
			date,		-- 16. fecha_desde
			date;		-- 17. fecha_hasta

define v_nombre_clte		char(100);
define v_nombre_agt			char(50);
define v_nombre_cia			char(50);
define v_no_documento		char(20);
define _cod_cliente			char(10);
define v_no_recibo			char(10);
define v_no_poliza			char(10);
define _no_recibo			char(10);
define v_cod_agente			char(5);
define _cod_endomov			char(3);
define _tipo				char(1);
define _comision_devengada	dec(16,2);
define _comision_saldo_ac	dec(16,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_neta			dec(16,2);
define v_comision			dec(16,2);
define v_monto				dec(16,2);
define v_prima				dec(16,2);
define v_porc_partic		dec(5,2);
define v_porc_comis			dec(5,2);
define _cnt_existe			smallint;
define v_fecha_desde		date;
define v_fecha_hasta		date;
define _fecha_comis			date;
define v_fecha				date;

--set debug file to "sp_che34a.trc";
--trace on;

-- Nombre de la Compania
set isolation to dirty read;

select agt_fecha_comis
  into _fecha_comis
  from parparam 
 where cod_compania = a_compania;

let  v_nombre_cia = sp_sis01(a_compania); 
let _comision_saldo_ac = 0.00;

foreach
	select cod_agente,
		   no_poliza,
		   no_recibo,
		   fecha,
		   monto,
		   prima,
		   porc_partic,
		   porc_comis,
		   comision,
		   nombre,
		   no_documento,
		   fecha_desde,
		   fecha_hasta
	  into v_cod_agente,
		   v_no_poliza,
		   v_no_recibo,
		   v_fecha,
		   v_monto,
		   v_prima,
		   v_porc_partic,
		   v_porc_comis,
		   v_comision,
		   v_nombre_agt,
		   v_no_documento,
		   v_fecha_desde,
		   v_fecha_hasta
	  from chqcomis
	 where cod_agente   = a_cod_agente
	   and seleccionado = 0
	   and fecha_hasta = _fecha_comis
	 order by nombre, fecha, no_recibo, no_documento
	
	let _comision_devengada = 0.00;
	let	_comision_adelanto	= 0.00;
	let	_comision_ganada	= 0.00;
	let	_comision_saldo		= 0.00;
	let _prima_neta			= 0.00;
	let	_no_recibo			= 0.00;
	let _cnt_existe			= 0;
	
	if v_no_poliza = '00000' then -- comision descontada
		let v_nombre_clte = 'COMISION DESCONTADA ...';
		
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where no_documento = v_no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if
		
		if _cnt_existe <> 0 then
			select cod_endomov,
				   prima_neta	
			  into _cod_endomov,
				   _prima_neta	
			  from endedmae
			 where no_factura	= v_no_recibo
			   and no_documento	= v_no_documento;

			let _comision_adelanto	= v_comision;
			let _comision_saldo		= 0.00;

			if _cod_endomov in ('004','005','006') then
			 
				select comision_saldo
				  into _comision_saldo
				  from cobadeco
				 where cod_agente	= v_cod_agente
				   and no_documento = v_no_documento;

				let _comision_saldo = _comision_saldo + _comision_adelanto; 
			end if			
				 
			{select comision_saldo
			  into _comision_saldo
			  from cobadeco
			 where cod_agente	= v_cod_agente
			   and no_documento = v_no_documento;

			let _comision_devengada	= v_comision * -1;
			let _comision_saldo		= _comision_saldo - _comision_devengada -_comision_saldo_ac;
			let _comision_saldo_ac	= _comision_devengada;
			let _prima_neta			= 0.00;
			let _comision_adelanto	= 0.00; } 
		end if
	else
		select cod_contratante
		  into _cod_cliente
		  from emipomae
		 where no_poliza = v_no_poliza;

		select nombre
		  into v_nombre_clte
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where no_documento = v_no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe <> 0 then
			
			select prima_neta,
				   comision_adelanto,
				   comision_ganada,
				   comision_saldo,
				   no_recibo
			  into _prima_neta,
			  	   _comision_adelanto,
			  	   _comision_ganada,	
			  	   _comision_saldo,	
			  	   _no_recibo
			  from cobadeco
			 where cod_agente	= v_cod_agente
			   and no_documento = v_no_documento;

			if v_no_recibo = _no_recibo then
				let _comision_devengada = v_prima * (v_porc_partic / 100) * (v_porc_comis / 100);
				let v_comision			= _comision_adelanto;
			else
				let _comision_devengada = v_prima * (v_porc_partic / 100) * (v_porc_comis / 100);
				let v_comision			= 0.00;
				let _comision_saldo		= _comision_saldo - _comision_devengada;
				let _prima_neta			= 0.00;
				let _comision_adelanto	= 0.00;				 
			end if
		else
			select count(*)
			  into _cnt_existe
			  from cobadecoh
			 where no_documento = v_no_documento;

			if _cnt_existe <> 0 then
				select comision_ganada,
					   comision_saldo,
					   no_recibo
				  into _comision_ganada,	
				  	   _comision_saldo,	
				  	   _no_recibo
				  from cobadecoh
				 where cod_agente	= v_cod_agente
				   and no_documento = v_no_documento
				   and poliza_cancelada = 1;

				if v_no_recibo = _no_recibo then
					let _comision_devengada	= v_comision;
					let v_comision			= _comision_adelanto;
				else
					let _comision_devengada	= v_comision;
					let v_comision			= 0.00;
					let _comision_saldo		= _comision_saldo - _comision_devengada -_comision_saldo_ac;
					let _comision_saldo_ac	= _comision_saldo_ac + _comision_devengada;
					let _prima_neta			= 0.00;
					let _comision_adelanto	= 0.00; 
				end if
			end if
		end if
	end if
			
	return  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			_prima_neta,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			_comision_adelanto,
			v_comision,
			_comision_devengada,	
			_comision_saldo,
			v_nombre_agt,
			v_nombre_cia,
			v_fecha_desde,
			v_fecha_hasta
			with resume;		
end foreach
set lock mode to wait;

update chqcomis
   set seleccionado = 1
 where cod_agente = a_cod_agente
   and seleccionado = 0;   
end procedure;