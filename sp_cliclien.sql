-- Reporte para Jesus
-- creado:	16/10/2023 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cliclien;

CREATE PROCEDURE "informix".sp_cliclien()
		RETURNING CHAR(10) as cod_cliente,
		          CHAR(3) as  cod_compania,
		          CHAR(3) as  cod_sucursal,
		          CHAR(3) as  cod_origen,
		          CHAR(5) as  cod_grupo,
		          CHAR(3) as  cod_clasehosp,
		          CHAR(3) as  cod_espmedica,
		          CHAR(3) as  cod_ocupacion,
		          CHAR(3) as  cod_trabajo,
		          CHAR(3) as  cod_actividad,
		          CHAR(3) as  code_pais,
		          CHAR(2) as  code_provincia,
		          CHAR(2) as  code_ciudad,
		          CHAR(2) as  code_distrito,
		          CHAR(5) as  code_correg,
		          VARCHAR(100) as nombre,
		          VARCHAR(100) as nombre_razon,
		          VARCHAR(50) as direccion_1,
		          VARCHAR(50) as direccion_2,
		          CHAR(20) as apartado,
		          CHAR(1) as  tipo_persona,
		          CHAR(1) as  actual_potencial,
		          VARCHAR(30) as cedula, 
		          CHAR(10) as telefono1,
		          CHAR(10) as telefono2,
		          CHAR(50) as e_mail,
		          CHAR(10) as fax,
		          DATE as date_added,
		          CHAR(8)as user_added,
		          SMALLINT as de_la_red,
		          SMALLINT as mala_referencia,
		          VARCHAR(250) as desc_mala_ref,
		          DATE as fecha_aniversario,
		          CHAR(1) as sexo,
		          CHAR(2) as digito_ver,
		          DATE as date_changed,
		          CHAR(8) as user_changed,
		          CHAR(100) as nombre_original,
		          CHAR(2) as ced_provincia,
		          CHAR(2) as ced_inicial,
		          CHAR(9) as ced_tomo,
		          CHAR(9) as ced_folio,
		          CHAR(7) as ced_asiento,
		          CHAR(100) as aseg_primer_nom,
		          CHAR(40) as aseg_segundo_nom,
		          CHAR(40) as aseg_primer_ape,
		          CHAR(40) as aseg_segundo_ape,
		          CHAR(40) as aseg_casada_ape,
		          SMALLINT as ced_correcta,
		          SMALLINT as pasaporte,
		          CHAR(10) as cotizacion,
		          SMALLINT as de_cotizacion ,
		          CHAR(10) as celular ,
		          INTEGER as dia_cobros1,
		          INTEGER as dia_cobros2, 
		          CHAR(50) as contacto, 
		          CHAR(10) as telefono3, 
		          VARCHAR(200) as direccion_cob, 
		          SMALLINT as  es_taller, 
		          SMALLINT as proveedor_autorizado, 
		          CHAR(30) as ip_number, 
		          CHAR(10) as no_beeper,
		          CHAR(3) as cod_beeper,
		          SMALLINT as periodo_pago,
		          CHAR(1) as tipo_cuenta,
		          CHAR(17) as cod_cuenta,
		          CHAR(3) as cod_banco,
		          SMALLINT as tipo_pago,
		          CHAR(2) as cod_ruta,
		          DATE as fecha_contratacion,
		          DATE as fecha_cancelacion,
		          INTEGER as consultorio_numero,
		          INTEGER as piso_numero,
		          CHAR(10) as cosultorio_tel,
		          CHAR(10) as consultorio_fax,
		          CHAR(20) as dias_atencion,
		          DATETIME HOUR TO FRACTION(5) as horario_atencion_de,
		          DATETIME HOUR TO FRACTION(5) as horario_atencion_a,
		          INTEGER as consultorio_numero2,
		          INTEGER as piso_numero2,
		          CHAR(10) as consultorio_tel2 ,
		          CHAR(10) as consultorio_fax2,
		          CHAR(20) as dias_atencion2,
		          DATETIME HOUR TO FRACTION(5) as horario_atencion_de2,
		          DATETIME HOUR TO FRACTION(5) as horario_atencion_a2,
		          VARCHAR(60) as universidad,
		          DATE as fecha_graduacion,
		          VARCHAR(20) as pais,
		          VARCHAR(20) as ciudad,
		          VARCHAR(60) as hospital_residencia,
		          DATE as fecha_residencia_desde,
		          DATE as fecha_residencia_hasta,
		          CHAR(50) as pais_residencia,
		          VARCHAR(20) as ciudad_residencia,
		          SMALLINT as cliente_web,
		          SMALLINT as reset_password,
		          CHAR(30) as password_web,
		          CHAR(10) as consultorio_1,
		          CHAR(10) as consultorio_2,
		          SMALLINT as paga_impuesto,
		          SMALLINT as leasing,
		          SMALLINT as conoce_cliente,
		          SMALLINT as cliente_pep,
		          SMALLINT as fumador,
		          SMALLINT as pago_externo,
		          CHAR(3) as cod_mala_refe,
		          CHAR(8) as user_mala_refe,
		          SMALLINT as ttcorp_act,
		          CHAR(4) as cod_estafeta,
		          SMALLINT as formulario_apc,
		          CHAR(50) as nacionalidad,
		          CHAR(80) as direccion_laboral,
		          CHAR(80) as representante_legal,
		          CHAR(80) as nombre_comercial,
		          CHAR(20) as aviso_operacion,
		          CHAR(30) as actividad_dedica,
		          CHAR(8) as user_correo,
		          DATETIME YEAR TO FRACTION(5) as date_correo,
		          CHAR(8) as user_celular,
		          DATETIME YEAR TO FRACTION(5) as date_celular,
		          CHAR(8) as user_dir,
		          DATETIME YEAR TO FRACTION(5) as date_dir,
		          VARCHAR(50) as profesion,
		          SMALLINT as bloqueo_auto,
		          VARCHAR(50) as siglas;
		
DEFINE _cod_cliente 			CHAR(10);
DEFINE _cod_compania 			CHAR(3);
DEFINE _cod_sucursal 			CHAR(3);
DEFINE _cod_origen 				CHAR(3);
DEFINE _cod_grupo 				CHAR(5);
DEFINE _cod_clasehosp 			CHAR(3);
DEFINE _cod_espmedica 			CHAR(3);
DEFINE _cod_ocupacion 			CHAR(3);
DEFINE _cod_trabajo 			CHAR(3);
DEFINE _cod_actividad 			CHAR(3);
DEFINE _code_pais 				CHAR(3);
DEFINE _code_provincia 			CHAR(2);
DEFINE _code_ciudad 			CHAR(2);
DEFINE _code_distrito 			CHAR(2);
DEFINE _code_correg 			CHAR(5);
DEFINE _nombre 					VARCHAR(100);
DEFINE _nombre_razon 			VARCHAR(100);
DEFINE _direccion_1 			VARCHAR(50);
DEFINE _direccion_2 			VARCHAR(50);
DEFINE _apartado 				CHAR(20);
DEFINE _tipo_persona 			CHAR(1);
DEFINE _actual_potencial 		CHAR(1);
DEFINE _cedula 					VARCHAR(30);
DEFINE _telefono1 				CHAR(10);
DEFINE _telefono2 				CHAR(10);
DEFINE _e_mail 					CHAR(50);
DEFINE _fax 					CHAR(10);
DEFINE _date_added 				DATE;
DEFINE _user_added 				CHAR(8);
DEFINE _de_la_red 				SMALLINT;
DEFINE _mala_referencia 		SMALLINT;
DEFINE _desc_mala_ref 			VARCHAR(250);
DEFINE _fecha_aniversario 		DATE;
DEFINE _sexo 					CHAR(1);
DEFINE _digito_ver 				CHAR(2);
DEFINE _date_changed 			DATE;
DEFINE _user_changed 			CHAR(8);
DEFINE _nombre_original 		CHAR(100);
DEFINE _ced_provincia 			CHAR(2);
DEFINE _ced_inicial 			CHAR(2);
DEFINE _ced_tomo 				CHAR(9);
DEFINE _ced_folio 				CHAR(9);
DEFINE _ced_asiento 			CHAR(7);
DEFINE _aseg_primer_nom 		CHAR(100);
DEFINE _aseg_segundo_nom 		CHAR(40);
DEFINE _aseg_primer_ape 		CHAR(40);
DEFINE _aseg_segundo_ape 		CHAR(40);
DEFINE _aseg_casada_ape 		CHAR(40);
DEFINE _ced_correcta 			SMALLINT;
DEFINE _pasaporte 				SMALLINT;
DEFINE _cotizacion 				CHAR(10);
DEFINE _de_cotizacion 			SMALLINT;
DEFINE _celular 				CHAR(10);
DEFINE _dia_cobros1 			INTEGER;
DEFINE _dia_cobros2 			INTEGER;
DEFINE _contacto 				CHAR(50);
DEFINE _telefono3 				CHAR(10);
DEFINE _direccion_cob 			VARCHAR(200);
DEFINE _es_taller 				SMALLINT; 
DEFINE _proveedor_autorizado 	SMALLINT; 
DEFINE _ip_number 				CHAR(30);
DEFINE _no_beeper 				CHAR(10);
DEFINE _cod_beeper 				CHAR(3);
DEFINE _periodo_pago 			SMALLINT;
DEFINE _tipo_cuenta 			CHAR(1);
DEFINE _cod_cuenta 				CHAR(17); 
DEFINE _cod_banco 				CHAR(3);
DEFINE _tipo_pago 				SMALLINT;
DEFINE _cod_ruta 				CHAR(2);
DEFINE _fecha_contratacion 		DATE;
DEFINE _fecha_cancelacion 		DATE;
DEFINE _consultorio_numero 		INTEGER;
DEFINE _piso_numero 			INTEGER;
DEFINE _cosultorio_tel 			CHAR(10);
DEFINE _consultorio_fax 		CHAR(10);
DEFINE _dias_atencion 			CHAR(20);
DEFINE _horario_atencion_de 	DATETIME HOUR TO FRACTION(5);
DEFINE _horario_atencion_a 		DATETIME HOUR TO FRACTION(5);
DEFINE _consultorio_numero2 	INTEGER;
DEFINE _piso_numero2 			INTEGER;
DEFINE _consultorio_tel2 		CHAR(10);
DEFINE _consultorio_fax2 		CHAR(10);
DEFINE _dias_atencion2 			CHAR(20);
DEFINE _horario_atencion_de2 	DATETIME HOUR TO FRACTION(5);
DEFINE _horario_atencion_a2 	DATETIME HOUR TO FRACTION(5);
DEFINE _universidad 			VARCHAR(60);
DEFINE _fecha_graduacion 		DATE;
DEFINE _pais 					VARCHAR(20);
DEFINE _ciudad 					VARCHAR(20);
DEFINE _hospital_residencia 	VARCHAR(60);
DEFINE _fecha_residencia_desde 	DATE;
DEFINE _fecha_residencia_hasta 	DATE;
DEFINE _pais_residencia 		CHAR(50);
DEFINE _ciudad_residencia 		VARCHAR(20);
DEFINE _cliente_web 			SMALLINT;
DEFINE _reset_password 			SMALLINT;
DEFINE _password_web 			CHAR(30);
DEFINE _consultorio_1 			CHAR(10);
DEFINE _consultorio_2 			CHAR(10);
DEFINE _paga_impuesto 			SMALLINT;
DEFINE _leasing 				SMALLINT;
DEFINE _conoce_cliente 			SMALLINT;
DEFINE _cliente_pep 			SMALLINT;
DEFINE _fumador 				SMALLINT;
DEFINE _pago_externo 			SMALLINT;
DEFINE _cod_mala_refe 			CHAR(3); 
DEFINE _user_mala_refe 			CHAR(8); 
DEFINE _ttcorp_act 				SMALLINT; 
DEFINE _cod_estafeta 			CHAR(4); 
DEFINE _formulario_apc 			SMALLINT; 
DEFINE _nacionalidad 			CHAR(50); 
DEFINE _direccion_laboral 		CHAR(80);
DEFINE _representante_legal 	CHAR(80);
DEFINE _nombre_comercial 		CHAR(80); 
DEFINE _aviso_operacion 		CHAR(20);
DEFINE _actividad_dedica 		CHAR(30);
DEFINE _user_correo 			CHAR(8);
DEFINE _date_correo 			DATETIME YEAR TO FRACTION(5);
DEFINE _user_celular 			CHAR(8);
DEFINE _date_celular 			DATETIME YEAR TO FRACTION(5);
DEFINE _user_dir 				CHAR(8);
DEFINE _date_dir 				DATETIME YEAR TO FRACTION(5);
DEFINE _profesion 				VARCHAR(50);
DEFINE _bloqueo_auto 			SMALLINT; 
DEFINE _siglas 					VARCHAR(50);
 
SET ISOLATION TO DIRTY READ; 
foreach

	select 
		cod_cliente,
		cod_compania,
		cod_sucursal,
		cod_origen,
		cod_grupo,
		cod_clasehosp,
		cod_espmedica,
		cod_ocupacion,
		cod_trabajo,
		cod_actividad,
		code_pais,
		code_provincia,
		code_ciudad,
		code_distrito,
		code_correg,
		nombre,
		nombre_razon,
		direccion_1,
		direccion_2,
		apartado,
		tipo_persona,
		actual_potencial,
		cedula,
		telefono1,
		telefono2,
		e_mail,
		fax,
		date_added,
		user_added,
		de_la_red,
		mala_referencia,
		desc_mala_ref,
		fecha_aniversario,
		sexo,
		digito_ver,
		date_changed,
		user_changed,
		nombre_original,
		ced_provincia,
		ced_inicial,
		ced_tomo,
		ced_folio,
		ced_asiento,
		aseg_primer_nom,
		aseg_segundo_nom,
		aseg_primer_ape,
		aseg_segundo_ape,
		aseg_casada_ape,
		ced_correcta,
		pasaporte,
		cotizacion,
		de_cotizacion ,
		celular ,
		dia_cobros1,
		dia_cobros2,
		contacto,
		telefono3,
		direccion_cob,
		es_taller,
		proveedor_autorizado,
		ip_number,
		no_beeper,
		cod_beeper,
		periodo_pago,
		tipo_cuenta,
		cod_cuenta,
		cod_banco,
		tipo_pago,
		cod_ruta,
		fecha_contratacion,
		fecha_cancelacion,
		consultorio_numero,
		piso_numero,
		cosultorio_tel,
		consultorio_fax,
		dias_atencion,
		horario_atencion_de,
		horario_atencion_a,
		consultorio_numero2,
		piso_numero2,
		consultorio_tel2 ,
		consultorio_fax2,
		dias_atencion2,
		horario_atencion_de2,
		horario_atencion_a2,
		universidad,
		fecha_graduacion,
		pais,
		ciudad,
		hospital_residencia,
		fecha_residencia_desde,
		fecha_residencia_hasta,
		pais_residencia,
		ciudad_residencia,
		cliente_web,
		reset_password,
		password_web,
		consultorio_1,
		consultorio_2,
		paga_impuesto,
		leasing,
		conoce_cliente,
		cliente_pep,
		fumador,
		pago_externo,
		cod_mala_refe,
		user_mala_refe,
		ttcorp_act,
		cod_estafeta,
		formulario_apc,
		nacionalidad,
		direccion_laboral,
		representante_legal,
		nombre_comercial,
		aviso_operacion,
		actividad_dedica,
		user_correo,
		date_correo,
		user_celular,
		date_celular,
		user_dir,
		date_dir,
		profesion,
		bloqueo_auto,
		siglas 
	into _cod_cliente,
		 _cod_compania,
		 _cod_sucursal,
		 _cod_origen,
		 _cod_grupo,
		 _cod_clasehosp,
		 _cod_espmedica,
		 _cod_ocupacion,
		 _cod_trabajo,
		 _cod_actividad,
		 _code_pais,
		 _code_provincia,
		 _code_ciudad,
		 _code_distrito,
		 _code_correg,
		 _nombre,
		 _nombre_razon,
		 _direccion_1,
		 _direccion_2,
		 _apartado,
		 _tipo_persona,
		 _actual_potencial,
		 _cedula,
		 _telefono1,
		 _telefono2,
		 _e_mail,
		 _fax,
		 _date_added,
		 _user_added,
		 _de_la_red,
		 _mala_referencia,
		 _desc_mala_ref,
		 _fecha_aniversario,
		 _sexo,
		 _digito_ver,
		 _date_changed,
		 _user_changed,
		 _nombre_original,
		 _ced_provincia,
		 _ced_inicial,
		 _ced_tomo,
		 _ced_folio,
		 _ced_asiento,
		 _aseg_primer_nom,
		 _aseg_segundo_nom,
		 _aseg_primer_ape,
		 _aseg_segundo_ape,
		 _aseg_casada_ape,
		 _ced_correcta,
		 _pasaporte,
		 _cotizacion,
		 _de_cotizacion ,
		 _celular ,
		 _dia_cobros1,
		 _dia_cobros2,
		 _contacto,
		 _telefono3,
		 _direccion_cob,
		 _es_taller,
		 _proveedor_autorizado,
		 _ip_number,
		 _no_beeper,
		 _cod_beeper,
		 _periodo_pago,
		 _tipo_cuenta,
		 _cod_cuenta,
		 _cod_banco,
		 _tipo_pago,
		 _cod_ruta,
		 _fecha_contratacion,
		 _fecha_cancelacion,
		 _consultorio_numero,
		 _piso_numero,
		 _cosultorio_tel,
		 _consultorio_fax,
		 _dias_atencion,
		 _horario_atencion_de,
		 _horario_atencion_a,
		 _consultorio_numero2,
		 _piso_numero2,
		 _consultorio_tel2 ,
		 _consultorio_fax2,
		 _dias_atencion2,
		 _horario_atencion_de2,
		 _horario_atencion_a2,
		 _universidad,
		 _fecha_graduacion,
		 _pais,
		 _ciudad,
		 _hospital_residencia,
		 _fecha_residencia_desde,
		 _fecha_residencia_hasta,
		 _pais_residencia,
		 _ciudad_residencia,
		 _cliente_web,
		 _reset_password,
		 _password_web,
		 _consultorio_1,
		 _consultorio_2,
		 _paga_impuesto,
		 _leasing,
		 _conoce_cliente,
		 _cliente_pep,
		 _fumador,
		 _pago_externo,
		 _cod_mala_refe,
		 _user_mala_refe,
		 _ttcorp_act,
		 _cod_estafeta,
		 _formulario_apc,
		 _nacionalidad,
		 _direccion_laboral,
		 _representante_legal,
		 _nombre_comercial,
		 _aviso_operacion,
		 _actividad_dedica,
		 _user_correo,
		 _date_correo,
		 _user_celular,
		 _date_celular,
		 _user_dir,
		 _date_dir,
		 _profesion,
		 _bloqueo_auto,
		 _siglas 
	from cliclien where  cod_cliente in
		(select cod_contratante from emipomae where no_poliza in (select no_poliza from migrarpolizas)
		union
		select cod_cliente from endmoase where no_poliza in (select no_poliza from migrarpolizas)
		union
		select cod_pagador from emipomae where no_poliza in (select no_poliza from migrarpolizas)
		union
		select cod_asegurado from emipouni where no_poliza in (select no_poliza from migrarpolizas)
		union
		select distinct cod_cliente from endeduni where no_poliza in (select no_poliza from migrarpolizas)
		union
		select cod_tercero from recterce where no_reclamo in (select no_reclamo from migrarreclamos)
		union
		select cod_cliente from chqchmae where no_requis in
			(select no_requis from rectrmae where no_reclamo in (select no_reclamo from migrarreclamos) and no_requis is not null)
		union
		select distinct cod_cliente from chqchmae where no_requis in
		(select no_requis from rectrmae where no_reclamo in (select no_reclamo from migrarreclamos) and no_requis is not null)
		union
		select cod_conductor from recrcmae where no_reclamo in (select no_reclamo from migrarreclamos))


		let _nombre_razon 			= sp_cleaner(_nombre_razon);
		let _nombre 				= sp_cleaner(_nombre);
		let _direccion_1 			= sp_cleaner(_direccion_1);
		let _direccion_2 			= sp_cleaner(_direccion_2);
		let _nombre_original 		= sp_cleaner(_nombre_original);
		let _aseg_primer_nom 		= sp_cleaner(_aseg_primer_nom);
		let _aseg_segundo_nom 		= sp_cleaner(_aseg_segundo_nom);
		let _aseg_primer_ape 		= sp_cleaner(_aseg_primer_ape);
		let _aseg_segundo_ape 		= sp_cleaner(_aseg_segundo_ape);
		let _aseg_casada_ape 		= sp_cleaner(_aseg_casada_ape);
		let _nacionalidad 			= sp_cleaner(_nacionalidad);
		let _direccion_laboral 		= sp_cleaner(_direccion_laboral);
		let _representante_legal 	= sp_cleaner(_representante_legal);
		let _nombre_comercial 		= sp_cleaner(_nombre_comercial);
		let _aviso_operacion 		= sp_cleaner(_aviso_operacion);
		let _actividad_dedica 		= sp_cleaner(_actividad_dedica);		
		let _cedula 				= sp_cleaner(_cedula);
		let _ced_provincia			= sp_cleaner(_ced_provincia);
		let _ced_inicial			= sp_cleaner(_ced_inicial);
		let _ced_tomo				= sp_cleaner(_ced_tomo);
		let _ced_folio				= sp_cleaner(_ced_folio);
		let _ced_asiento			= sp_cleaner(_ced_asiento);

	RETURN	_cod_cliente,
			_cod_compania,
			_cod_sucursal,
			_cod_origen,
			_cod_grupo,
			_cod_clasehosp,
			_cod_espmedica,
			_cod_ocupacion,
			_cod_trabajo,
			_cod_actividad,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_nombre,
			_nombre_razon,
			_direccion_1,
			_direccion_2,
			_apartado,
			_tipo_persona,
			_actual_potencial,
			_cedula,
			_telefono1,
			_telefono2,
			_e_mail,
			_fax,
			_date_added,
			_user_added,
			_de_la_red,
			_mala_referencia,
			_desc_mala_ref,
			_fecha_aniversario,
			_sexo,
			_digito_ver,
			_date_changed,
			_user_changed,
			_nombre_original,
			_ced_provincia,
			_ced_inicial,
			_ced_tomo,
			_ced_folio,
			_ced_asiento,
			_aseg_primer_nom,
			_aseg_segundo_nom,
			_aseg_primer_ape,
			_aseg_segundo_ape,
			_aseg_casada_ape,
			_ced_correcta,
			_pasaporte,
			_cotizacion,
			_de_cotizacion ,
			_celular ,
			_dia_cobros1,
			_dia_cobros2,
			_contacto,
			_telefono3,
			_direccion_cob,
			_es_taller,
			_proveedor_autorizado,
			_ip_number,
			_no_beeper,
			_cod_beeper,
			_periodo_pago,
			_tipo_cuenta,
			_cod_cuenta,
			_cod_banco,
			_tipo_pago,
			_cod_ruta,
			_fecha_contratacion,
			_fecha_cancelacion,
			_consultorio_numero,
			_piso_numero,
			_cosultorio_tel,
			_consultorio_fax,
			_dias_atencion,
			_horario_atencion_de,
			_horario_atencion_a,
			_consultorio_numero2,
			_piso_numero2,
			_consultorio_tel2 ,
			_consultorio_fax2,
			_dias_atencion2,
			_horario_atencion_de2,
			_horario_atencion_a2,
			_universidad,
			_fecha_graduacion,
			_pais,
			_ciudad,
			_hospital_residencia,
			_fecha_residencia_desde,
			_fecha_residencia_hasta,
			_pais_residencia,
			_ciudad_residencia,
			_cliente_web,
			_reset_password,
			_password_web,
			_consultorio_1,
			_consultorio_2,
			_paga_impuesto,
			_leasing,
			_conoce_cliente,
			_cliente_pep,
			_fumador,
			_pago_externo,
			_cod_mala_refe,
			_user_mala_refe,
			_ttcorp_act,
			_cod_estafeta,
			_formulario_apc,
			_nacionalidad,
			_direccion_laboral,
			_representante_legal,
			_nombre_comercial,
			_aviso_operacion,
			_actividad_dedica,
			_user_correo,
			_date_correo,
			_user_celular,
			_date_celular,
			_user_dir,
			_date_dir,
			_profesion,
			_bloqueo_auto,
			_siglas 
			WITH RESUME;
end foreach

END PROCEDURE;		