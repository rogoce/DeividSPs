drop procedure mig_cliclien;
create procedure "informix".mig_cliclien()
RETURNING char(10) as cod_cliente,
	char(3) as cod_compania,
	char(3) as cod_sucursal,
	char(3) as cod_origen,
	char(5) as cod_grupo,
	char(3) as cod_clasehosp,
	char(3) as cod_espmedica,
	char(3) as cod_ocupacion,
	char(3) as cod_trabajo,
	char(3) as cod_actividad,
	char(3) as code_pais,
	char(2) as code_provincia,
	char(2) as code_ciudad,
	char(2) as code_distrito,
	char(5) as code_correg,
	varchar(100,0) as nombre,
	varchar(100,0) as nombre_razon,
	varchar(50,0) as direccion_1,
	varchar(50,0) as direccion_2,
	char(20) as apartado,
	char(1) as tipo_persona,
	char(1) as actual_potencial,
	varchar(30,0) as cedula,
	char(10) as telefono1,
	char(10) as telefono2,
	char(50) as e_mail,
	char(10) as fax,
	date as date_added,
	char(8) as user_added,
	smallint as de_la_red,
	smallint as mala_referencia,
	varchar(250,0) as desc_mala_ref,
	date as fecha_aniversario,
	char(1) as sexo,
	char(2) as digito_ver,
	date as date_changed,
	char(8) as user_changed,
	char(100) as nombre_original,
	char(2) as ced_provincia,
	char(2) as ced_inicial,
	char(9) as ced_tomo,
	char(9) as ced_folio,
	char(7) as ced_asiento,
	char(100) as aseg_primer_nom,
	char(40) as aseg_segundo_nom,
	char(40) as aseg_primer_ape,
	char(40) as aseg_segundo_ape,
	char(40) as aseg_casada_ape,
	smallint as ced_correcta,
	smallint as pasaporte,
	char(10) as cotizacion,
	smallint as de_cotizacion,
	char(10) as celular,
	integer as dia_cobros1,
	integer as dia_cobros2,
	char(50) as contacto,
	char(10) as telefono3,
	varchar(200,0) as direccion_cob,
	smallint as es_taller,
	smallint as proveedor_autorizado,
	char(30) as ip_number,
	char(10) as no_beeper,
	char(3) as cod_beeper,
	smallint as periodo_pago,
	char(1) as tipo_cuenta,
	char(17) as cod_cuenta,
	char(3) as cod_banco,
	smallint as tipo_pago,
	char(2) as cod_ruta,
	date as fecha_contratacion,
	date as fecha_cancelacion,
	integer as consultorio_numero,
	integer as piso_numero,
	char(10) as cosultorio_tel,
	char(10) as consultorio_fax,
	char(20) as dias_atencion,
	datetime hour to fraction(5) as horario_atencion_de,
	datetime hour to fraction(5) as horario_atencion_a,
	integer as consultorio_numero2,
	integer as piso_numero2,
	char(10) as consultorio_tel2,
	char(10) as consultorio_fax2,
	char(20) as dias_atencion2,
	datetime hour to fraction(5) as horario_atencion_de2,
	datetime hour to fraction(5) as horario_atencion_a2,
	varchar(60,0) as universidad,
	date as fecha_graduacion,
	varchar(20,0) as pais,
	varchar(20,0) as ciudad,
	varchar(60,0) as hospital_residencia,
	date as fecha_residencia_desde,
	date as fecha_residencia_hasta,
	char(50) as pais_residencia,
	varchar(20,0) as ciudad_residencia,
	smallint as cliente_web,
	smallint as reset_password,
	char(30) as password_web,
	char(10) as consultorio_1,
	char(10) as consultorio_2,
	smallint as paga_impuesto,
	smallint as leasing,
	smallint as conoce_cliente,
	smallint as cliente_pep,
	smallint as fumador,
	smallint as pago_externo,
	char(3) as cod_mala_refe,
	char(8) as user_mala_refe,
	smallint as ttcorp_act,
	char(4) as cod_estafeta,
	smallint as formulario_apc,
	char(50) as nacionalidad,
	char(80) as direccion_laboral,
	char(80) as representante_legal,
	char(80) as nombre_comercial,
	char(20) as aviso_operacion,
	char(30) as actividad_dedica,
	char(8) as user_correo,
	datetime year to fraction(5) as date_correo,
	char(8) as user_celular,
	datetime year to fraction(5) as date_celular,
	char(8) as user_dir,
	datetime year to fraction(5) as date_dir,
	varchar(50,0) as profesion,
	smallint as es_asegurado;

define _cod_cliente          char(10);
define _cod_compania         char(3);
define _cod_sucursal         char(3);
define _cod_origen           char(3);
define _cod_grupo            char(5);
define _cod_clasehosp        char(3);
define _cod_espmedica        char(3);
define _cod_ocupacion        char(3);
define _cod_trabajo          char(3);
define _cod_actividad        char(3);
define _code_pais            char(3);
define _code_provincia       char(2);
define _code_ciudad          char(2);
define _code_distrito        char(2);
define _code_correg          char(5);
define _nombre               varchar(100,0);
define _nombre_razon         varchar(100,0);
define _direccion_1          varchar(50,0);
define _direccion_2          varchar(50,0);
define _apartado             char(20);
define _tipo_persona         char(1);
define _actual_potencial     char(1);
define _cedula               varchar(30,0);
define _telefono1            char(10);
define _telefono2            char(10);
define _e_mail               char(50);
define _fax                  char(10);
define _date_added           date;
define _user_added           char(8);
define _de_la_red            smallint;
define _mala_referencia      smallint;
define _desc_mala_ref        varchar(250,0);
define _fecha_aniversario    date;
define _sexo                 char(1);
define _digito_ver           char(2);
define _date_changed         date;
define _user_changed         char(8);
define _nombre_original      char(100);
define _ced_provincia        char(2);
define _ced_inicial          char(2);
define _ced_tomo             char(9);
define _ced_folio            char(9);
define _ced_asiento          char(7);
define _aseg_primer_nom      char(100);
define _aseg_segundo_nom     char(40);
define _aseg_primer_ape      char(40);
define _aseg_segundo_ape     char(40);
define _aseg_casada_ape      char(40);
define _ced_correcta         smallint;
define _pasaporte            smallint;
define _cotizacion           char(10);
define _de_cotizacion        smallint;
define _celular              char(10);
define _dia_cobros1          integer;
define _dia_cobros2          integer;
define _contacto             char(50);
define _telefono3            char(10);
define _direccion_cob        varchar(200,0);
define _es_taller            smallint;
define _proveedor_autorizado   smallint;
define _ip_number            char(30);
define _no_beeper            char(10);
define _cod_beeper           char(3);
define _periodo_pago         smallint;
define _tipo_cuenta          char(1);
define _cod_cuenta           char(17);
define _cod_banco            char(3);
define _tipo_pago            smallint;
define _cod_ruta             char(2);
define _fecha_contratacion   date;
define _fecha_cancelacion    date;
define _consultorio_numero   integer;
define _piso_numero          integer;
define _cosultorio_tel       char(10);
define _consultorio_fax      char(10);
define _dias_atencion        char(20);
define _horario_atencion_de   datetime hour to fraction(5);
define _horario_atencion_a   datetime hour to fraction(5);
define _consultorio_numero2  integer;
define _piso_numero2         integer;
define _consultorio_tel2     char(10);
define _consultorio_fax2     char(10);
define _dias_atencion2       char(20);
define _horario_atencion_de2   datetime hour to fraction(5);
define _horario_atencion_a2   datetime hour to fraction(5);
define _universidad          varchar(60,0);
define _fecha_graduacion     date;
define _pais                 varchar(20,0);
define _ciudad               varchar(20,0);
define _hospital_residencia   varchar(60,0);
define _fecha_residencia_desde   date;
define _fecha_residencia_hasta   date;
define _pais_residencia      char(50);
define _ciudad_residencia    varchar(20,0);
define _cliente_web          smallint;
define _reset_password       smallint;
define _password_web         char(30);
define _consultorio_1        char(10);
define _consultorio_2        char(10);
define _paga_impuesto        smallint;
define _leasing              smallint;
define _conoce_cliente       smallint;
define _cliente_pep          smallint;
define _fumador              smallint;
define _pago_externo         smallint;
define _cod_mala_refe        char(3);
define _user_mala_refe       char(8);
define _ttcorp_act           smallint;
define _cod_estafeta         char(4);
define _formulario_apc       smallint;
define _nacionalidad         char(50);
define _direccion_laboral    char(80);
define _representante_legal   char(80);
define _nombre_comercial     char(80);
define _aviso_operacion      char(20);
define _actividad_dedica     char(30);
define _user_correo          char(8);
define _date_correo          datetime year to fraction(5);
define _user_celular         char(8);
define _date_celular         datetime year to fraction(5);
define _user_dir             char(8);
define _date_dir             datetime year to fraction(5);
define _profesion            varchar(50,0);
define _cnt                  integer;
define _es_asegurado         smallint;
define _no_documento         char(20);
define _estatus_poliza       smallint;
define _vigencia_final       date;

CREATE TEMP TABLE tmp_poliza(
no_documento char(20),
estatus_poliza smallint,
vigencia_final date,
PRIMARY KEY (no_documento)) WITH NO LOG;

set isolation to dirty read;

foreach
 select cod_cliente,
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
		de_cotizacion,
		celular,
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
		consultorio_tel2,
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
		profesion
  INTO  _cod_cliente,
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
		_de_cotizacion,
		_celular,
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
		_consultorio_tel2,
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
		_profesion
   from cliclien
   where cod_cliente = '24568'
 
   -- Asegurado
    LET _no_documento = NULL;
	LET _cnt = 0;
	LET _es_asegurado = 0;
	
	DELETE FROM tmp_poliza;
	
	FOREACH
		SELECT b.no_documento,
			   b.estatus_poliza,
			   b.vigencia_final
		  INTO _no_documento,
			   _estatus_poliza,
               _vigencia_final			   
		  FROM emipouni a, emipomae b  
		 WHERE a.cod_asegurado = _cod_cliente
		   AND a.no_poliza = b.no_poliza
		   AND b.actualizado = 1
	  ORDER BY b.vigencia_final desc
	  
	    BEGIN
		ON EXCEPTION
		END EXCEPTION
		INSERT INTO tmp_poliza		
		VALUES(
		_no_documento,
		_estatus_poliza,
		_vigencia_final
		);
		END
	END FOREACH
 
	FOREACH
		SELECT no_documento,
			   estatus_poliza,
			   vigencia_final
		  INTO _no_documento,
			   _estatus_poliza,
               _vigencia_final			   
		  FROM emipomae 
		 WHERE actualizado = 1
		   AND (cod_pagador     = _cod_cliente or
		        cod_contratante = _cod_cliente)
	  ORDER BY vigencia_final desc
	  
	    BEGIN
		ON EXCEPTION
		END EXCEPTION
		INSERT INTO tmp_poliza		
		VALUES(
		_no_documento,
		_estatus_poliza,
		_vigencia_final
		);
		END
	END FOREACH
   
   -- Vigentes y Anuladas
   
    SELECT COUNT(*)  
	  INTO _cnt
	  FROM tmp_poliza
	 WHERE estatus_poliza in (1, 4);
	 
	IF _cnt IS NULL THEN
		LET _cnt = 0;
	END IF
	 
    IF _cnt > 0 THEN
		LET _es_asegurado = 1;
	END IF

	-- Canceladas con saldo
	
	let _saldo = 0.00;
		
	FOREACH
		SELECT no_documento
		  INTO _no_documento
		  FROM tmp_poliza
		 WHERE estatus_poliza = 2
		 
		 let _saldo = sp_cob115b("001", "001", _no_documento, "");
		 
		 IF _saldo > 0 THEN
			LET _es_asegurado = 1;
		 END IF
	END FOREACH

    -- Vencidas hasta 2 años con saldo
  
	let _saldo = 0.00;
 
	FOREACH
		SELECT no_documento,
		       vigencia_final
		  INTO _no_documento,
		       _vigencia_final
		  FROM tmp_poliza
		 WHERE estatus_poliza = 3
		 
		 let _saldo = sp_cob115b("001", "001", _no_documento, "");
		 
		 IF _saldo > 0 THEN
			LET _es_asegurado = 1;
		 END IF
	END FOREACH
 
 return _cod_cliente,
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
		_de_cotizacion,
		_celular,
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
		_consultorio_tel2,
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
		_es_asegurado with resume;
end foreach 

DROP TABLE tmp_poliza;
END PROCEDURE