-- Extraer datos del rutero para insertar en tablas para los (cobros moviles).
-- 
-- Creado    : 09/09/2005 - Autor: Armando Moreno M.
-- Modificado: 13/09/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob165;

create procedure "informix".sp_cob165()
returning integer,char(50);

define _nombre_usuario	varchar(50);
define _alias			varchar(50);
define _corr_cedula		varchar(30);
define _usuario			varchar(10);
define _campo2			char(349);
define _campo			char(349);
define _nombre_pagador	char(100);
define _direccion_cob	char(100);
define _descripcion		char(100);
define _nombre			char(100);
define v_direccion1		char(50);
define v_direccion2		char(50);
define v_corredor		char(50);
define _tipo_pag		char(50);
define _contacto		char(50);
define _mensaje			char(50);
define _nombre_grupo	char(40);
define v_ciudad			char(30);
define _cedula			char(25);
define v_documento		char(20);
define _poliza			char(20);
define _cod_cliente		char(10);
define _cod_pagador		char(10);
define v_telefono2		char(10);
define v_telefono1   	char(10);
define v_no_poliza		char(10);
define _tel_grupo		char(10);
define _tel_pag1		char(10);
define _tel_pag2		char(10);
define _relacion		char(10);
define _m_visita		char(8);
define _periodo			char(7);
define _code_correg		char(5);
define _cod_grupocl		char(5);
define _cod_agente		char(5);
define _cod_grupo		char(5);
define _area			char(5);
define _ano_char		char(4);
define _letra			char(4);
define _cod_motiv		char(3);
define _orden_visita	char(3);
define _cod_ramo		char(3);
define _cod_banco		char(3);
define _cod_cobrador	char(3);
define _code_pais		char(3);
define _code_provincia	char(2);
define _code_distrito	char(2);
define _code_ciudad		char(2);
define _mes_char		char(2);
define _tipo_pol		char(2);
define _signo			char(1);
define _imp				char(1);
define _cobrar_sn		char(1);
define _modo			char(1);
define _abrev			char(1);
define v_por_vencer		dec(16,2);
define v_corriente		dec(16,2);
define _prima_orig		dec(16,2);
define v_monto_120		dec(16,2);
define v_monto_90		dec(16,2);
define v_monto_60		dec(16,2);
define v_monto_30		dec(16,2);
define v_exigible		dec(16,2);
define _sum_moros		dec(16,2);
define v_a_pagar		dec(16,2);
define v_saldo1			dec(16,2);
define v_saldo			dec(16,2);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _tipo_labor		smallint;
define _orden_2,_estatus_pol smallint;
define _id_transaccion	integer;
define _secuencia		integer;
define _tipo_cte		integer;
define _id_turno		integer;
define _existe2			integer;
define _existe3			integer;
define _existe			integer;
define _error			integer;
define _cant			integer;
define _dia				integer;
define _id				integer;
define _vigencia_final	date;
define _fecha_ult_dia	date;
define _vigencia_inic	date;
define _fecha			date;
define _fecha_registro	datetime year to fraction(5);
define _fecha_time		datetime year to fraction(5);
define _cod_f           char(3);



set isolation to dirty read;

--set debug file to "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

begin

on exception set _error 
 	return _error,_mensaje;         
end exception

call sp_sis26() returning _fecha;

let _fecha_time = current;

--armar varibale que contiene el periodo(aaaa-mm)
if  month(_fecha) < 10 then
	let _mes_char = '0'||month(_fecha);
else
	let _mes_char = month(_fecha);
end if

let _dia      = day(_fecha);
let _ano_char = year(_fecha);
let _periodo  = _ano_char || "-" || _mes_char;

--fecha con el ultimo dia del periodo actual
call sp_sis36(_periodo) returning _fecha_ult_dia;

delete from cdmusuarios;   		--usuarios
delete from cdmrutas; 	   		--rutas
delete from cdmclientes;   		--clientes
delete from cdmtipocuenta; 		--tipocuenta
delete from cdmcuentas;    		--cuentas
delete from cdmmotivoabandono;  --motivoabandono
delete from cdmbancos;	 		--bancos

let _mensaje = 'Insertando cdmusuarios;';

FOREACH
	SELECT cod_cobrador,
	       nombre,
		   usuario
	  INTO _cod_cobrador,
		   _nombre_usuario,
		   _usuario
	  FROM cobcobra
	 WHERE activo        = 1
	   AND tipo_cobrador = 3	--Rutero

	SELECT max(id_turno)
	  INTO _id_turno
	  FROM cdmturno
	 WHERE id_usuario = _cod_cobrador;

	SELECT max(id_transaccion)
	  INTO _id_transaccion
	  FROM cdmtransacciones
	 WHERE id_usuario = _cod_cobrador;

	SELECT max(secuencia)
	  INTO _secuencia
	  FROM cdmtransacciones
	 WHERE id_usuario = _cod_cobrador;

	if _id_turno is null then
		let _id_turno = 0;
	end if
	if _id_transaccion is null then
		let _id_transaccion = 0;
	end if
	if _secuencia is null then
		let _secuencia = 0;
	end if

	set lock mode to wait;

  	INSERT INTO cdmusuarios(
	id_usuario,
	id_turno,
	id_transaccion,
	usuario,
	pass,
	nombre,
	secuencia
	)
  	VALUES(
	_cod_cobrador,
	_id_turno,
	_id_transaccion,
	_usuario,
	"123",
	_nombre_usuario,
	_secuencia
  	);
END FOREACH

let _mensaje = 'Insertando cdmrutas;';

foreach
  	select cod_cobrador
	  into _cod_cobrador
	  from cobcobra
	 where activo        = 1
	   and tipo_cobrador = 3

	foreach
		select code_correg,
		       nombre
		  into _code_correg,
		       _nombre
		  from gencorr
		 where cod_cobrador = _cod_cobrador

	  	insert into cdmrutas(
		id_usuario,
		id_ruta,
		nombre,
		last_download
		)
	  	values(
		_cod_cobrador,
		_code_correg,
		_nombre,
		_fecha_time
	  	);

    end foreach
	
end foreach

--lectura de Motivo de abandono
let _mensaje = 'Insertando cdmmotivoabandono;';

foreach
   	select cod_motiv,
	       nombre
	  into _cod_motiv,
		   _nombre
	  from cobmotiv

  	insert into cdmmotivoabandono(
	id_motivo_abandono,
	nombre,
	continuar_sn
	)
  	values(
	_cod_motiv,
	_nombre,
	's'
  	);

end foreach

let _mensaje = 'Insertando cdmbancos;';

foreach
	select cod_banco,
		   alias
	  into _cod_banco,
		   _alias
	  from chqbanco

  	insert into cdmbancos(
	id_banco,
	nombre
	)
  	values(
	_cod_banco,
	_alias
  	);

end foreach

let _id = 0;

let _mensaje = 'Insertando cdmtipocuenta;';

foreach
	select tipo_cuenta,
		   abreviatura
	  into _tipo_pag,
		   _abrev
	  from tipopago
	 
	let _id = _id + 1;

	foreach
		select cod_cobrador
		  into _cod_cobrador
		  from cobcobra
		 where activo        = 1
		   and tipo_cobrador = 3


	  	insert into cdmtipocuenta(
		id_usuario,
		id_tipo_cuenta,
		nombre,
		abreviatura,
		last_download
		)
	  	values(
		_cod_cobrador,
		_id,
		_tipo_pag,
		_abrev,
		_fecha_time
	  	);

	end foreach

end foreach

--***************************
--****Clientes y Cuentas*****
--***************************

foreach
 select cod_cobrador,
	    cod_pagador,
	    cod_agente,
	    fecha,
	    code_correg,
	    dia_cobros1,
	    dia_cobros2,
	    descripcion,
	    orden_2
   into _cod_cobrador,
	    _cod_pagador,
	    _cod_agente,
	    _fecha_registro,
	    _area,
	    _dia_cobros1,
	    _dia_cobros2,
	    _descripcion,
	    _orden_2
   from cobruter1
  where cod_cobrador not in("059","030")
  order by 1

 --where cod_cobrador not in("059","030","029")

	if _cod_cobrador is null then
		continue foreach;
	end if

    --Esta parte es para cuando es corredor

    if _cod_pagador is null then

		select count(*)
		  into _cant
		  from cdmclientes
		 where id_usuario = _cod_cobrador
		   and id_cliente = _cod_agente;

		if _cant <> 0 then
			continue foreach;
		end if

       let _tipo_cte = 1;	--identifica que es un corredor

	   select nombre,
			  direccion_1,
			  direccion_2,
			  telefono1,
			  telefono2,
			  cedula	
	     into v_corredor,
			  v_direccion1,
			  v_direccion2,
			  v_telefono1,
			  v_telefono2,
			  _corr_cedula
	     from agtagent
	    where cod_agente = _cod_agente;

		if v_direccion1 is null then
		   let v_direccion1 = " ";
		end if

		if v_direccion2 is null then
		   let v_direccion2 = " ";
		end if

	    let _direccion_cob = v_direccion1 ||  v_direccion2;

	    if v_telefono1 is null then
		  let v_telefono1 = " ";
	    end if
	    if v_telefono2 is null then
		  let v_telefono2 = " ";
	    end if

	    let _tel_pag1  = v_telefono1 || "/" || v_telefono2;

		if _dia_cobros1 = _dia or _dia_cobros2 = _dia then
			let _cobrar_sn = "S";
		else
			let _cobrar_sn = "N";
		end if 

		let _mensaje = 'Insertando cdmclientes (1);';

	  	insert into cdmclientes(
		id_usuario,
		id_cliente,
		id_ruta,
		id_compania,
		nombre,
		identificacion,
		direccion,
		telefono,
		departamento,
		id_estado,
		cobrar_sn,
		secuencia,
		observaciones,
		dir_cobro,
		prog,
		last_download,
		tipocliente
		)
	  	values(
		_cod_cobrador,
		_cod_agente,
		_area,
		"001",			 --compania
		v_corredor,
		_corr_cedula,
		_direccion_cob,
		_tel_pag1,
		"",				 --departamento
		3,				 --id_estado
		"s",
		_orden_2,		 --secuencia
		_descripcion,
		"c",
		_cobrar_sn,
		_fecha_time,
		_tipo_cte
	  	);

		let _mensaje = 'Insertando cdmcuentas (1);';

 	  	insert into cdmcuentas(
		id_usuario,
		id_cliente,
		cuenta,
		id_tipo_cuenta,
		saldo,
		estado_prestamo,
		porc_manejo,
		monto_cobro,
		fecha_cobro,
		saldo_corriente,
		saldo_30_dias,
		saldo_60_dias,
		saldo_90_dias,
		saldo_120_dias,
		last_download
		)
	  	values(
		_cod_cobrador,
		_cod_agente,
		"VER DETALLE ADJ.",
		1,			 	--id_tipo_cuenta
		0,
		0,			 	--estado_prestamo
		0,
		0,
		_fecha_registro,
		0,
		0,
		0,
		0,
		0,
		_fecha_time
	  	);

		continue foreach;

	else

		let _tipo_cte = 0;		--identifica que es un pagador

		foreach
			select fecha,
				   code_correg,
				   dia_cobros1,
				   dia_cobros2,
				   descripcion,
				   orden_2
			  into _fecha_registro,
				   _area,
				   _dia_cobros1,
				   _dia_cobros2,
				   _descripcion,
				   _orden_2
			  from cobruter1
			 where cod_pagador  = _cod_pagador
			   and cod_cobrador = _cod_cobrador
			 order by fecha desc
			exit foreach;
		end foreach

		select count(*)
		  into _cant
		  from cdmclientes
		 where id_usuario = _cod_cobrador
		   and id_cliente = _cod_pagador;
		   
		if _cant <> 0 then
			continue foreach;
		end if

		if _dia_cobros1 = _dia or _dia_cobros2 = _dia then
			let _cobrar_sn = "S";
		else
			let _cobrar_sn = "N";
		end if 

	    let _cedula         = null;
	    let _nombre_pagador = null;
	    let _direccion_cob  = null;
	    let _tel_pag1		= null;
		let _tel_pag2		= null;

	    select cedula,
			   nombre,
			   direccion_cob,
			   telefono1,
			   telefono2,
			   cod_grupo
	      into _cedula,
			   _nombre_pagador,
			   _direccion_cob,
			   _tel_pag1,
			   _tel_pag2,
			   _cod_grupocl
	      from cliclien
	     where cod_cliente = _cod_pagador;

		if _nombre_pagador is null then
			let _nombre_pagador = "S/N";
		end if

		if _cedula is null then
			let _cedula = "S/C";
		end if

		let _mensaje = 'Insertando cdmclientes;';

	  	insert into cdmclientes(
		id_usuario,
		id_cliente,					
		id_ruta,
		id_compania,
		nombre,
		identificacion,
		direccion,
		telefono,
		departamento,
		id_estado,
		cobrar_sn,
		secuencia,
		observaciones,
		dir_cobro,
		prog,
		last_download,
		tipocliente
		)
	  	values(
		_cod_cobrador,
		_cod_pagador,
		_area,
		"001",			 --compania
		_nombre_pagador,
		_cedula,
		_direccion_cob,
		_tel_pag1,
		"",				 --departamento
		3,				 --id_estado
		"S",
		_orden_2,		 --secuencia
		_descripcion,
		"C",
		_cobrar_sn,
		_fecha_time,
		_tipo_cte
	  	);

	 	let v_saldo  = 0;

	 	{update cobcapen
		   set por_vencer = 0,
			   exigible   = 0,
			   corriente  = 0,
			   monto_30   = 0,
			   monto_60   = 0,
			   monto_90   = 0,
			   saldo	  = 0
	     where cod_cliente = _cod_pagador; }

		foreach
		 select a_pagar,
		        no_documento
		   into v_a_pagar,     
		        v_documento
		   from cobruter2
		  where cod_pagador = _cod_pagador

			select count(*)
			  into _existe
			  from cdmcuentas
			 where id_usuario = _cod_cobrador
			   and id_cliente = _cod_pagador
			   and cuenta	  = v_documento;

			if _existe <> 0 then
				continue foreach;
			end if

			let v_no_poliza = sp_sis21(v_documento);

			select cod_formapag,estatus_poliza
			  into _cod_f,_estatus_pol
			  from emipomae
			 where no_poliza = v_no_poliza;
			 
            if _estatus_pol in(2,4) then
				continue foreach;
			end if	
			if _cod_f = '087' then --cobranza externa no debe entrar a cobrar por rutero
				continue foreach;
			end if

			{ call sp_cob33(
			 "001",
			 "001",
			 v_documento,
			 _periodo,
			 _fecha_ult_dia
			 ) returning v_por_vencer,
					     v_exigible,  
					     v_corriente, 
					     v_monto_30,  
					     v_monto_60,  
					     v_monto_90,
					     v_saldo; }

			let v_saldo      = 0;
			let v_corriente  = 0;
			let v_monto_30   = 0;
			let v_monto_60   = 0;
			let	v_monto_90	 = 0;
			let v_monto_120  = 0;
			let v_por_vencer = 0;
			let	v_exigible 	 = 0;

			foreach
				select por_vencer,
					   exigible,
				       corriente,
				       monto_30,
				       monto_60,
				       monto_90,
					   monto_120,
				       saldo
				  into v_por_vencer,
					   v_exigible,  
					   v_corriente, 
					   v_monto_30,  
					   v_monto_60,  
					   v_monto_90,
					   v_monto_120,
					   v_saldo
		          from emipoliza
				 where no_documento = v_documento
				exit foreach;
			end foreach

			if v_saldo <= 0 then
				update cdmclientes set cobrar_sn = 'N'
				 where id_cliente = _cod_pagador;
			else
				update cdmclientes set cobrar_sn = 'S'
				 where id_cliente = _cod_pagador;
			end if  
			 {update cobcapen
			    set por_vencer = por_vencer + v_por_vencer,
					exigible   = exigible   + v_exigible,
					corriente  = corriente  + v_corriente,
					monto_30   = monto_30   + v_monto_30,
					monto_60   = monto_60   + v_monto_60,
					monto_90   = monto_90   + v_monto_90,
					saldo	   = saldo	    + v_saldo
		      where cod_cliente = _cod_pagador;}

	 	   	insert into cdmcuentas(
			id_usuario,
			id_cliente,
			cuenta,
			id_tipo_cuenta,
			saldo,
			estado_prestamo,
			porc_manejo,
			monto_cobro,
			fecha_cobro,
			saldo_corriente,
			saldo_30_dias,
			saldo_60_dias,
			saldo_90_dias,
			saldo_120_dias,
			last_download
			)
		  	values(
			_cod_cobrador,
			_cod_pagador,
			v_documento,
			1,			 	--id_tipo_cuenta
			v_saldo,
			0,			 	--estado_prestamo
			0,
			v_a_pagar,
			_fecha_registro,
			v_corriente,
			v_monto_30,
			v_monto_60,
			v_monto_90,
			v_monto_120,
			_fecha_time
		  	);

	     end foreach
    end if

end foreach

--******************************************
--****Clientes y Cuentas no programados*****
--******************************************

let _cobrar_sn = "N";
let _tipo_cte  = 0;

foreach
 select cod_cliente
   into _cod_pagador
   from cascliente
  where cod_cobrador not in ("059", "030")

	if _cod_cobrador is null then
		continue foreach;
	end if

	select count(*)
	  into _existe
	  from cliclien
	 where cod_cliente  = _cod_pagador
	   and cod_sucursal <> '003';

	if _existe = 0 then
		continue foreach;
	end if

	select count(*)
	  into _existe
	  from cobruter1
	 where cod_pagador = _cod_pagador;

	if _existe <> 0 then
		continue foreach;
	end if
	
	select count(*)
	  into _existe2
	  from cdmclientes
	 where id_cliente = _cod_pagador;

	if _existe2 <> 0 then
		continue foreach;
	end if

    let _cedula         = null;
    let _nombre_pagador = null;
    let _direccion_cob  = null;
    let _tel_pag1		= null;
	let _tel_pag2		= null;

    select cedula,
		   nombre,
		   direccion_cob,
		   telefono1,
		   telefono2,
		   cod_grupo,
		   code_pais,
		   code_provincia,
		   code_ciudad,
		   code_distrito,
		   code_correg,
		   contacto
      into _cedula,
		   _nombre_pagador,
		   _direccion_cob,
		   _tel_pag1,
		   _tel_pag2,
		   _cod_grupocl,
		   _code_pais,
		   _code_provincia,
		   _code_ciudad,
		   _code_distrito,
		   _code_correg,
		   _contacto
      from cliclien
     where cod_cliente = _cod_pagador;

	select cod_cobrador
	  into _cod_cobrador
	  from gencorr
	 where code_pais      = _code_pais
	   and code_provincia =	_code_provincia
	   and code_ciudad	  = _code_ciudad
	   and code_distrito  = _code_distrito
	   and code_correg	  = _code_correg
	   and cod_sucursal   = "001";
																									   
	if _code_correg = "01" then
		continue foreach;
	end if

	if _contacto is null then
		let _contacto = "";
	end if
	if _nombre_pagador is null then
		let _nombre_pagador = "S/N";
	end if

	if _cedula is null then
		let _cedula = "S/C";
	end if

	if _cod_cobrador is null then
		let _cod_cobrador = '45';
	end if

	let _mensaje = 'Insertando cdmclientes No prog;';

  	INSERT INTO cdmclientes(
	id_usuario,
	id_cliente,
	id_ruta,
	id_compania,
	nombre,
	identificacion,
	direccion,
	telefono,
	departamento,
	id_estado,
	cobrar_sn,
	secuencia,
	observaciones,
	dir_cobro,
	prog,
	last_download,
	tipocliente
	)
  	VALUES(
	_cod_cobrador,
	_cod_pagador,
	_code_correg,
	"001",			 --compania
	_nombre_pagador,
	_cedula,
	_direccion_cob,
	_tel_pag1,
	"",				 --departamento
	3,				 --id_estado
	"S",
	0,		 		 --secuencia
	_contacto,
	"C",
	_cobrar_sn,
	_fecha_time,
	_tipo_cte
  	);

 	 update cobcapen
	    set por_vencer = 0,
			exigible   = 0,
			corriente  = 0,
			monto_30   = 0,
			monto_60   = 0,
			monto_90   = 0,
			saldo	   = 0
      where cod_cliente = _cod_pagador;

	foreach
	 select a_pagar,
	        no_documento
	   into v_a_pagar,     
	        v_documento
	   from caspoliza
	  where cod_cliente = _cod_pagador

		let v_no_poliza = sp_sis21(v_documento);

			let v_saldo      = 0;
		    let v_corriente  = 0;
		    let v_monto_30   = 0;
			let v_monto_60   = 0;
			let	v_monto_90	 = 0;
			let v_monto_120  = 0;
			let v_por_vencer = 0;
			let	v_exigible 	 = 0;

			select cod_formapag,estatus_poliza
			  into _cod_f,_estatus_pol
			  from emipomae
			 where no_poliza = v_no_poliza;
			 
			if _estatus_pol in(2,4) then
				continue foreach;
			end if	
			if _cod_f = '087' then --cobranza externa no debe entrar a cobrar por rutero  Demetrio 20/06/2014
				continue foreach;
			end if

			foreach
				select por_vencer,
					   exigible,
				       corriente,
				       monto_30,
				       monto_60,
				       monto_90,
					   monto_120,
				       saldo
				  into v_por_vencer,
					   v_exigible,  
					   v_corriente, 
					   v_monto_30,  
					   v_monto_60,  
					   v_monto_90,
					   v_monto_120,
					   v_saldo
		          from emipoliza
				 where no_documento = v_documento
				exit foreach;
			end foreach

		 update cobcapen
		    set por_vencer = por_vencer + v_por_vencer,
				exigible   = exigible   + v_exigible,
				corriente  = corriente  + v_corriente,
				monto_30   = monto_30   + v_monto_30,
				monto_60   = monto_60   + v_monto_60,
				monto_90   = monto_90   + v_monto_90,
				saldo	   = saldo	    + v_saldo
	      where cod_cliente = _cod_pagador;

		let _mensaje = 'Insertando cdmcuentas no prog;';

		select count(*)		
		  into _existe3
		  from cdmcuentas
		 where id_usuario = _cod_cobrador
		   and id_cliente = _cod_pagador
		   and cuenta	  = v_documento;

		if _existe3 <> 0 then
			continue foreach;
		end if
		

 	  	INSERT INTO cdmcuentas(
		id_usuario,
		id_cliente,
		cuenta,
		id_tipo_cuenta,
		saldo,
		estado_prestamo,
		porc_manejo,
		monto_cobro,
		fecha_cobro,
		saldo_corriente,
		saldo_30_dias,
		saldo_60_dias,
		saldo_90_dias,
		saldo_120_dias,
		last_download
		)
	  	VALUES(
		_cod_cobrador,
		_cod_pagador,
		v_documento,
		1,			 	--id_tipo_cuenta
		v_saldo,
		0,			 	--estado_prestamo
		0,
		v_a_pagar,
		_fecha_time,
		v_corriente,
		v_monto_30,
		v_monto_60,
		v_monto_90,
		v_monto_120,
		_fecha_time
	  	);

	 end foreach

end foreach

return 0, "Actualizacion Exitosa";

end

end procedure