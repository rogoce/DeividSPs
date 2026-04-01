-- Extraer datos del rutero para insertar en tablas para los (cobros moviles).
-- 
-- Creado    : 09/09/2005 - Autor: Armando Moreno M.
-- Modificado: 13/09/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob165bk;

CREATE PROCEDURE "informix".sp_cob165bk()
Returning integer,char(50);

DEFINE v_saldo     		 DEC(16,2);
DEFINE v_a_pagar	 	 DEC(16,2);
DEFINE v_por_vencer	 	 DEC(16,2);
DEFINE v_exigible	 	 DEC(16,2);
DEFINE v_corriente	 	 DEC(16,2);
DEFINE v_monto_30	 	 DEC(16,2);
DEFINE v_monto_60	 	 DEC(16,2);
DEFINE v_monto_90	 	 DEC(16,2);
DEFINE v_monto_120		 DEC(16,2);
DEFINE v_saldo1			 DEC(16,2);
define _prima_orig		 DEC(16,2);
DEFINE _poliza		     CHAR(20);
DEFINE _cod_motiv	     CHAR(3);
DEFINE _area		     CHAR(5);
DEFINE _cedula		     CHAR(25);
DEFINE _un_blank	     CHAR(1);
DEFINE _relacion	     CHAR(10);
DEFINE _orden_visita     CHAR(3);
DEFINE _campo		     CHAR(349);
DEFINE _campo2		     CHAR(349);
DEFINE v_documento  	 CHAR(20);
DEFINE _descripcion		 CHAR(100);
DEFINE _cod_ramo		 CHAR(3);
DEFINE _cod_banco	     CHAR(3);
DEFINE _cod_cliente      CHAR(10);
DEFINE v_no_poliza       CHAR(10);
DEFINE _cod_cobrador	 CHAR(3);
DEFINE _code_pais		 CHAR(3);
DEFINE v_ciudad          CHAR(30);
DEFINE _code_provincia 	 CHAR(2);
DEFINE _code_ciudad		 CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg	     CHAR(5);
DEFINE _mes_char         CHAR(2);
DEFINE _letra	         CHAR(4);
DEFINE _signo	         CHAR(1);
DEFINE _imp		         CHAR(1);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);
DEFINE _cod_pagador		 CHAR(10);
define _tel_pag1		 CHAR(10);
define _tel_pag2		 CHAR(10);
define _tel_grupo		 CHAR(10);
DEFINE _nombre_pagador	 CHAR(100);
define _nombre			 CHAR(100);
DEFINE _direccion_cob    CHAR(100);
define _nombre_grupo	 CHAR(40);
DEFINE _cod_grupo		 CHAR(5);
DEFINE _cod_grupocl	 	 CHAR(5);
DEFINE _tipo_pol		 CHAR(2);
DEFINE _modo			 CHAR(1);
DEFINE _m_visita		 CHAR(8);
define _cobrar_sn		 CHAR(1);
DEFINE _fecha_ult_dia    DATE;
DEFINE _fecha		     DATE;
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _fecha_registro   datetime year to fraction(5);
DEFINE _tipo_labor       smallint;
DEFINE _dia_cobros1		 smallint;
DEFINE _dia_cobros2		 smallint;
define _orden_2			 smallint;
DEFINE _dia				 INTEGER;
DEFINE _cant			 INTEGER;
define _error   		 integer;
define _fecha_time       datetime year to fraction(5);
define _nombre_usuario   varchar(50);
define _alias			 varchar(50);
define _usuario			 varchar(10);
define _cod_agente		 CHAR(5);
define _corr_cedula		 varchar(30);
define _tipo_cte		 integer;
DEFINE v_corredor		 CHAR(50);
DEFINE v_direccion1		 CHAR(50);
DEFINE v_direccion2		 CHAR(50);
DEFINE v_telefono1,v_telefono2   CHAR(10);
define _id				 integer;
define _abrev			 char(1);
define _tipo_pag		 char(50);
define _id_turno         integer;
define _id_transaccion   integer;
define _secuencia		 integer;
define _existe			 integer;
define _existe2			 integer;
define _contacto		 CHAR(50);
define _mensaje          CHAR(50);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,_mensaje;         
END EXCEPTION

CALL sp_sis26() RETURNING _fecha;

let _fecha_time = current;

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(_fecha) < 10 THEN
	LET _mes_char = '0'||MONTH(_fecha);
ELSE
	LET _mes_char = MONTH(_fecha);
END IF

let _dia      = day(_fecha);
LET _ano_char = YEAR(_fecha);
LET _periodo  = _ano_char || "-" || _mes_char;

--fecha con el ultimo dia del periodo actual
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

DELETE FROM cdmusuarios;   		--usuarios
DELETE FROM cdmrutas; 	   		--rutas
DELETE FROM cdmclientes;   		--clientes
DELETE FROM cdmtipocuenta; 		--tipocuenta
DELETE FROM cdmcuentas;    		--cuentas
DELETE FROM cdmmotivoabandono;  --motivoabandono
DELETE FROM cdmbancos;	 		--bancos

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
	   AND tipo_cobrador = 3

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
	SELECT cod_cobrador
	  INTO _cod_cobrador
	  FROM cobcobra
	 WHERE activo        = 1
	   AND tipo_cobrador = 3

	foreach
		SELECT code_correg,
		       nombre
		  INTO _code_correg,
		       _nombre
		  FROM gencorr
		 WHERE cod_cobrador = _cod_cobrador

	  	INSERT INTO cdmrutas(
		id_usuario,
		id_ruta,
		nombre,
		last_download
		)
	  	VALUES(
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
	SELECT cod_motiv,
	       nombre
	  INTO _cod_motiv,
		   _nombre
	  FROM cobmotiv

  	INSERT INTO cdmmotivoabandono(
	id_motivo_abandono,
	nombre,
	continuar_sn
	)
  	VALUES(
	_cod_motiv,
	_nombre,
	'S'
  	);

end foreach

let _mensaje = 'Insertando cdmbancos;';

foreach
	SELECT cod_banco,
		   alias
	  INTO _cod_banco,
		   _alias
	  FROM chqbanco

  	INSERT INTO cdmbancos(
	id_banco,
	nombre
	)
  	VALUES(
	_cod_banco,
	_alias
  	);

end foreach

let _id = 0;

let _mensaje = 'Insertando cdmtipocuenta;';

FOREACH
	SELECT tipo_cuenta,
		   abreviatura
	  INTO _tipo_pag,
		   _abrev
	  FROM tipopago
	 
	let _id = _id + 1;

	FOREACH
		SELECT cod_cobrador
		  INTO _cod_cobrador
		  FROM cobcobra
		 WHERE activo        = 1
		   AND tipo_cobrador = 3


	  	INSERT INTO cdmtipocuenta(
		id_usuario,
		id_tipo_cuenta,
		nombre,
		abreviatura,
		last_download
		)
	  	VALUES(
		_cod_cobrador,
		_id,
		_tipo_pag,
		_abrev,
		_fecha_time
	  	);

	END FOREACH

END FOREACH

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
  where cod_cobrador not in("059","030","029")
  order by 1

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

	   SELECT nombre,
			  direccion_1,
			  direccion_2,
			  telefono1,
			  telefono2,
			  cedula	
	     INTO v_corredor,
			  v_direccion1,
			  v_direccion2,
			  v_telefono1,
			  v_telefono2,
			  _corr_cedula
	     FROM agtagent
	    WHERE cod_agente = _cod_agente;

		IF v_direccion1 IS NULL THEN
		   LET v_direccion1 = " ";
		END IF

		IF v_direccion2 IS NULL THEN
		   LET v_direccion2 = " ";
		END IF

	    LET _direccion_cob = v_direccion1 ||  v_direccion2;

	    IF v_telefono1 IS NULL THEN
		  LET v_telefono1 = " ";
	    END IF
	    IF v_telefono2 IS NULL THEN
		  LET v_telefono2 = " ";
	    END IF

	    LET _tel_pag1  = v_telefono1 || "/" || v_telefono2;

		if _dia_cobros1 = _dia or _dia_cobros2 = _dia then
			let _cobrar_sn = "S";
		else
			let _cobrar_sn = "N";
		end if 

		let _mensaje = 'Insertando cdmclientes (1);';

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
		_cod_agente,
		_area,
		"001",			 --compania
		v_corredor,
		_corr_cedula,
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

		let _mensaje = 'Insertando cdmcuentas (1);';

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
		 where cod_pagador = _cod_pagador;

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

	    SELECT cedula,
			   nombre,
			   direccion_cob,
			   telefono1,
			   telefono2,
			   cod_grupo
	      INTO _cedula,
			   _nombre_pagador,
			   _direccion_cob,
			   _tel_pag1,
			   _tel_pag2,
			   _cod_grupocl
	      FROM cliclien
	     WHERE cod_cliente = _cod_pagador;

		if _nombre_pagador is null then
			let _nombre_pagador = "S/N";
		end if

		if _cedula is null then
			let _cedula = "S/C";
		end if

		let _mensaje = 'Insertando cdmclientes;';

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

	 	update cobcapen
		   set por_vencer = 0,
			   exigible   = 0,
			   corriente  = 0,
			   monto_30   = 0,
			   monto_60   = 0,
			   monto_90   = 0,
			   saldo	  = 0
	     where cod_cliente = _cod_pagador;

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
			 where no_documento = v_documento;

			 update cobcapen
			    set por_vencer = por_vencer + v_por_vencer,
					exigible   = exigible   + v_exigible,
					corriente  = corriente  + v_corriente,
					monto_30   = monto_30   + v_monto_30,
					monto_60   = monto_60   + v_monto_60,
					monto_90   = monto_90   + v_monto_90,
					saldo	   = saldo	    + v_saldo
		      where cod_cliente = _cod_pagador;

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
  where cod_cobrador not in ("059", "030", "029")

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

 	 update cascliente
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

	  {	call sp_cob33(
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
			 where no_documento = v_documento;

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