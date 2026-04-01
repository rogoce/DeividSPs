-- Procedure que Inserta las polizas que cumplan con las condiciones de pago anticipado de Comision en la estructra de pago antincipado de comision.
-- 
-- Creado    : 24/10/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che137a;		

create procedure "informix".sp_che137a(a_compania char(3), a_sucursal char(3), a_fecha_desde date, a_fecha_hasta date, a_cod_agente char(255))
returning	char(20),	-- 1. poliza
			char(100),	-- 2. asegurado
			char(10),	-- 3. recibo
			date,		-- 4. fecha
			dec(16,2),	-- 5. prima_neta
			dec(16,2),	-- 6. monto
			dec(16,2),	-- 7. prima
			dec(5,2),	-- 8. % partic
			dec(5,2),	-- 9. % comis
			dec(16,2),	-- 10.Adelanto_comision
			dec(16,2),	-- 11.comision
			dec(16,2),	-- 12.comision_devengada
			dec(16,2),	-- 13.saldo_comision
			char(50),   -- 14.agente
			char(50);	-- 15.compania

define v_nombre_clte		char(100);
define _error_desc			char(100);
define v_nombre_agt			char(50);
define v_nombre_cia			char(50);
define v_no_documento		char(20);
define _cod_cliente			char(10);
define v_no_poliza			char(10); 
define v_no_recibo			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define v_cod_agente			char(5);
define _cod_endomov			char(3);  
define _tipo_agente			char(1);
define _status_lic			char(1);
define _tipo				char(1);
define _comision_cancelada	dec(16,2);
define _comision_devengada	dec(16,2);			
define _comision_adelanto	dec(16,2);
define _comision_saldo_ac	dec(16,2);			
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_neta_pro		dec(16,2);
define _prima_suscrita		dec(16,2);			
define _monto_recibo		dec(16,2);			
define _prima_neta			dec(16,2);
define v_comision			dec(16,2);
define v_prima				dec(16,2);
define v_monto				dec(16,2);
define v_porc_partic		dec(5,2); 
define v_porc_comis			dec(5,2); 
define _poliza_cancelada	smallint;			
define _pago_comis_ade		smallint;			
define _adelanto_comis		smallint;			
define _status_poliza		smallint;
define _cnt_cobredet		smallint;			
define _cnt_existe			smallint;
define _comis_desc			smallint;			
define _no_pagos			smallint;			
define _aplica				smallint;			
define _error_isam			integer;
define _error				integer;
define _fecha_adelanto		date;
define v_fecha				date;

set isolation to dirty read;

let	_no_recibo			= '';
let	_no_poliza			= '';
let _comision_cancelada	= 0.00;
let _comision_devengada = 0.00;
let _comision_saldo_ac	= 0.00;
let	_comision_adelanto	= 0.00;
let	_comision_ganada	= 0.00;
let _prima_neta_cob		= 0.00;
let _prima_neta_pro		= 0.00;	
let	_comision_saldo		= 0.00;
let	_prima_suscrita		= 0.00;
let	_monto_recibo		= 0.00;
let	_prima_neta			= 0.00;
let _poliza_cancelada	= 0;
let _pago_comis_ade		= 0;
let	_adelanto_comis		= 0;
let	_status_poliza		= 0;
let	_cnt_existe			= 0;
let	_no_pagos			= 0;
let	_aplica				= 0;

--set debug file to "sp_che137.trc";
--trace on;

CREATE TEMP TABLE tmp_salida(
	no_documento	CHAR(20),
	nombre_clte		CHAR(100),
	no_recibo		CHAR(10),
	fecha			DATE,
	prima_neta      DEC(16,2),
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision_adelanto dec(16,2),
	comision		DEC(16,2),
	comision_devengada DEC(16,2),
	comision_saldo	DEC(16,2),
    nombre_agt      CHAR(50),
	nombre_cia      CHAR(50)
	) WITH NO LOG;

LET  v_nombre_cia = sp_sis01(a_compania); 

call sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta
);


--set debug file to "sp_che137.trc";
--trace on;

if a_cod_agente <> "*" then
	let _tipo = sp_sis04(a_cod_agente);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		update tmp_agente
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_agente
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if
--set debug file to "sp_che137.trc";
--trace on;
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
		   no_documento
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
		   v_no_documento
	  from tmp_agente
	 where seleccionado = 1
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

		if v_fecha >=  '03/01/2013' then		
			if _cnt_existe <> 0 then
				
				select prima_neta,
					   comision_adelanto,
					   comision_ganada,
					   comis_saldo_inic,
					   no_recibo,
					   fecha
				  into _prima_neta,
					   _comision_adelanto,
					   _comision_ganada,	
					   _comision_saldo,	
					   _no_recibo,
					   _fecha_adelanto
				  from cobadeco
				 where cod_agente	= v_cod_agente
				   and no_documento = v_no_documento;
				   
				if v_no_recibo = _no_recibo then
					let _comision_devengada	= v_comision;
					let v_comision			= _comision_adelanto;
				else			
					if _fecha_adelanto <= v_fecha then
						let _comision_devengada	= v_comision;
						let v_comision			= 0.00;
						let _comision_saldo		= _comision_saldo - _comision_devengada;
						let _prima_neta			= 0.00;
						let _comision_adelanto	= 0.00;
					else
						let _comision_saldo = 0.00;
						let _comision_adelanto = 0.00;
					end if
					{update cobadeco
					   set comision_saldo	= _comision_saldo
					 where no_documento		= v_no_documento;}
					 
				end if
			else
				select count(*)
				  into _cnt_existe
				  from cobadecoh
				 where no_documento = v_no_documento 
				   and fecha >= v_fecha
				   and poliza_cancelada = 1;

				if v_no_documento <> '0213-00946-04' then
					if _cnt_existe > 0 then
						select comision_ganada,
							   comision_saldo,
							   comision_adelanto,
							   no_recibo
						  into _comision_ganada,	
							   _comision_saldo,
							   _comision_adelanto,
							   _no_recibo
						  from cobadecoh
						 where cod_agente	= v_cod_agente
						   and no_documento = v_no_documento;
						   
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
		end if
	end if
    insert into tmp_salida(
	no_documento,
	nombre_clte,
	no_recibo,
	fecha,
	prima_neta,
	monto,
	prima,
	porc_partic,
	porc_comis,
	comision_adelanto,
	comision,
	comision_devengada,
	comision_saldo,
    nombre_agt,
	nombre_cia 
	)
	values(
	v_no_documento,			-- 1. poliza
	v_nombre_clte,			-- 2. asegurado
	v_no_recibo,			-- 3. recibo
	v_fecha,				-- 4. fecha
	_prima_neta,			-- 5. prima_neta
	v_monto,				-- 6. monto
	v_prima,				-- 7. prima
	v_porc_partic,			-- 8. % partic
	v_porc_comis,			-- 9. % comis
	_comision_adelanto,		-- 10.Adelanto_comision
	v_comision,				-- 11.comision
	_comision_devengada,	-- 12.comision_devengada
	_comision_saldo,		-- 13.saldo_comision
	v_nombre_agt,			-- 14.agente
	v_nombre_cia			-- 15.compania
	);
	{return  v_no_documento,			-- 1. poliza
			v_nombre_clte,			-- 2. asegurado
			v_no_recibo,			-- 3. recibo
			v_fecha,				-- 4. fecha
			_prima_neta,			-- 5. prima_neta
			v_monto,				-- 6. monto
			v_prima,				-- 7. prima
			v_porc_partic,			-- 8. % partic
			v_porc_comis,			-- 9. % comis
			_comision_adelanto,		-- 10.Adelanto_comision
			v_comision,				-- 11.comision
			_comision_devengada,	-- 12.comision_devengada
			_comision_saldo,		-- 13.saldo_comision
			v_nombre_agt,			-- 14.agente
			v_nombre_cia			-- 15.compania
			with resume;}	
end foreach
foreach

	SELECT cod_agente
	  into v_cod_agente
	  from tmp_agente
	 where seleccionado = 1
     group by cod_agente	 

    foreach
	
		select no_documento,
		       fecha,
			   comision,
			   no_recibo,
			   no_poliza,
			   nombre
		  into v_no_documento,
		       v_fecha,
			   v_comision,
			   v_no_recibo,
			   v_no_poliza,
			   v_nombre_agt
		  from chqcomis
		 where cod_agente = v_cod_agente
		   and fecha_desde = a_fecha_desde
		   and fecha_hasta = a_fecha_hasta
		   and bono_salud  = 1
		   
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	insert into tmp_salida(
		no_documento,
		nombre_clte,
		no_recibo,
		fecha,
		prima_neta,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision_adelanto,
		comision,
		comision_devengada,
		comision_saldo,
		nombre_agt,
		nombre_cia 
		)
		values(
		v_no_documento,
		v_nombre_clte,
		v_no_recibo,
		v_fecha,
		0,
		0,
		0,
		0,
		0,
		0,
		v_comision,
		0,
		0,
		v_nombre_agt,
		v_nombre_cia
		);
		   
	   { RETURN  v_no_documento,
				v_nombre_clte,
				v_no_recibo,
				v_fecha,
				0,
				0,
				0,
				0,
				0,
				0,
				v_comision,
				0,
				0,
				v_nombre_agt,
				v_nombre_cia
			WITH RESUME;}
	end foreach
end foreach

foreach
select 	no_documento,
		nombre_clte,
		no_recibo,
		fecha,
		prima_neta,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision_adelanto,
		comision,
		comision_devengada,
		comision_saldo,
		nombre_agt,
		nombre_cia
   into v_no_documento,			-- 1. poliza
		v_nombre_clte,			-- 2. asegurado
		v_no_recibo,			-- 3. recibo
		v_fecha,				-- 4. fecha
		_prima_neta,			-- 5. prima_neta
		v_monto,				-- 6. monto
		v_prima,				-- 7. prima
		v_porc_partic,			-- 8. % partic
		v_porc_comis,			-- 9. % comis
		_comision_adelanto,		-- 10.Adelanto_comision
		v_comision,				-- 11.comision
		_comision_devengada,	-- 12.comision_devengada
		_comision_saldo,		-- 13.saldo_comision
		v_nombre_agt,			-- 14.agente
		v_nombre_cia
   from tmp_salida
  order by nombre_agt, fecha, no_recibo, no_documento
end foreach
drop table tmp_agente;
drop table tmp_salida;

--return 0,'Exito';
end procedure