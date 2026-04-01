-- Procedimiento que muestra clientes duplicados
-- Creado    : 06/10/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par308;
CREATE PROCEDURE "informix".sp_par308(a_cliente1 CHAR(10),a_cliente2 CHAR(10),a_cedula CHAR(30))
RETURNING SMALLINT,					 -- seleccion						 							
		  CHAR(10),					 -- cod_cliente					    		
		  VARCHAR(100),				 -- nombre									
		  CHAR(1),					 -- tipo_persona							
		  VARCHAR(30),				 -- cedula									
		  VARCHAR(100),				 -- nombre_razon						
		  VARCHAR(50),				 -- direccion_1									
		  VARCHAR(50),				 -- direccion_2									
		  CHAR(10),					 -- telefono1								
		  CHAR(10),					 -- telefono2								
		  CHAR(10),					 -- telefono3								
		  CHAR(10),					 -- celular										
		  CHAR(10),					 -- fax											
		  CHAR(20),					 -- apartado								
		  CHAR(50),					 -- e_mail									
		  DATE,						 -- fecha_aniversario			
		  CHAR(2),					 -- digito_ver									
		  CHAR(50),					 -- contacto								
		  SMALLINT,					 -- de_la_red								
		  VARCHAR(100),				 -- direccion_cob							
		  SMALLINT,					 -- ced_correcta							
		  SMALLINT,					 -- pasaporte								
		  CHAR(1),					 -- sexo							
		  SMALLINT,					 -- es_taller						
		  SMALLINT,					 -- paga_impuesto					
		  SMALLINT,					 -- leasing								
		  SMALLINT,					 -- conoce_cliente						
		  CHAR(1),					 -- actual_potencial				
		  SMALLINT,					 -- cliente_pep							
		  SMALLINT,					 -- fumador								
		  CHAR(30),					 -- ip_number						
		  CHAR(10),					 -- no_beeper						
		  CHAR(3),					 -- cod_beeper							
		  SMALLINT,					 -- periodo_pago					
		  CHAR(1),					 -- tipo_cuenta							
		  CHAR(17),					 -- cod_cuenta							
		  CHAR(3),					 -- cod_banco						
		  SMALLINT,					 -- tipo_pago						
		  CHAR(2),					 -- cod_ruta						
		  SMALLINT,					 -- mala_referencia						
		  VARCHAR(250),				 -- desc_mala_ref					
		  DATE,						 -- date_changed					
		  CHAR(8),					 -- user_changed					
		  CHAR(10),					 -- cotizacion							
		  SMALLINT,					 -- cliente_web							
		  CHAR(5),					 -- cod_grupo					
		  CHAR(3),					 -- cod_clasehosp				
		  CHAR(3),					 -- cod_origen				
		  CHAR(3),					 -- cod_ocupacion				
		  CHAR(3),					 -- cod_trabajo						
		  CHAR(3),					 -- cod_actividad				
		  CHAR(3),					 -- code_pais					
		  CHAR(2),					 -- code_provincia				
		  CHAR(2),					 -- code_ciudad					
		  CHAR(2),					 -- code_distrito				
		  CHAR(5),					 -- code_correg					
		  CHAR(2),					 -- ced_provincia				
		  CHAR(2),					 -- ced_inicial						
		  CHAR(7),					 -- ced_tomo					
		  CHAR(7),					 -- ced_folio					
		  CHAR(7),					 -- ced_asiento						
		  CHAR(100),				 -- aseg_primer_nom					
		  CHAR(40),					 -- aseg_segundo_nom			
		  CHAR(40),					 -- aseg_primer_ape					
		  CHAR(40),					 -- aseg_segundo_ape			
		  CHAR(40);					 -- aseg_casada_ape																						

  
DEFINE _cod_cliente					  CHAR(10);
DEFINE _cod_compania				  CHAR(3);
DEFINE _cod_sucursal				  CHAR(3);
DEFINE _cod_origen					  CHAR(3);
DEFINE _cod_grupo					  CHAR(5);
DEFINE _cod_clasehosp				  CHAR(3);
DEFINE _cod_espmedica				  CHAR(3);
DEFINE _cod_ocupacion				  CHAR(3);
DEFINE _cod_trabajo					  CHAR(3);
DEFINE _cod_actividad				  CHAR(3);
DEFINE _code_pais					  CHAR(3);
DEFINE _code_provincia				  CHAR(2);
DEFINE _code_ciudad					  CHAR(2);
DEFINE _code_distrito				  CHAR(2);
DEFINE _code_correg					  CHAR(5);
DEFINE _nombre						  VARCHAR(100);
DEFINE _nombre_razon				  VARCHAR(100);
DEFINE _direccion_1					  VARCHAR(50);
DEFINE _direccion_2					  VARCHAR(50);
DEFINE _apartado					  CHAR(20);
DEFINE _tipo_persona				  CHAR(1);
DEFINE _actual_potencial			  CHAR(1);
DEFINE _cedula						  VARCHAR(30);
DEFINE _telefono1					  CHAR(10);
DEFINE _telefono2					  CHAR(10);
DEFINE _e_mail						  CHAR(50);
DEFINE _fax							  CHAR(10);
DEFINE _date_added					  DATE;
DEFINE _user_added					  CHAR(8);
DEFINE _de_la_red					  SMALLINT;
DEFINE _mala_referencia				  SMALLINT;
DEFINE _desc_mala_ref				  VARCHAR(250);
DEFINE _fecha_aniversario			  DATE;
DEFINE _sexo						  CHAR(1);
DEFINE _digito_ver					  CHAR(2);
DEFINE _date_changed				  DATE;
DEFINE _user_changed				  CHAR(8);
DEFINE _nombre_original				  CHAR(100);
DEFINE _ced_provincia				  CHAR(2);
DEFINE _ced_inicial					  CHAR(2);
DEFINE _ced_tomo					  CHAR(7);
DEFINE _ced_folio					  CHAR(7);
DEFINE _ced_asiento					  CHAR(7);
DEFINE _aseg_primer_nom				  CHAR(100);
DEFINE _aseg_segundo_nom			  CHAR(40);
DEFINE _aseg_primer_ape				  CHAR(40);
DEFINE _aseg_segundo_ape			  CHAR(40);
DEFINE _aseg_casada_ape				  CHAR(40);
DEFINE _ced_correcta				  SMALLINT;
DEFINE _pasaporte					  SMALLINT;
DEFINE _cotizacion					  CHAR(10);
DEFINE _de_cotizacion				  SMALLINT;
DEFINE _celular						  CHAR(10);
DEFINE _dia_cobros1					  INTEGER;
DEFINE _dia_cobros2					  INTEGER;
DEFINE _contacto					  CHAR(50);
DEFINE _telefono3					  CHAR(10);
DEFINE _direccion_cob				  VARCHAR(100);
DEFINE _es_taller					  SMALLINT;
DEFINE _proveedor_autorizado		  SMALLINT;
DEFINE _ip_number					  CHAR(30);
DEFINE _no_beeper					  CHAR(10);
DEFINE _cod_beeper					  CHAR(3);
DEFINE _periodo_pago				  SMALLINT;
DEFINE _tipo_cuenta					  CHAR(1);
DEFINE _cod_cuenta					  CHAR(17);
DEFINE _cod_banco					  CHAR(3);
DEFINE _tipo_pago					  SMALLINT;
DEFINE _cod_ruta					  CHAR(2);
DEFINE _fecha_contratacion			  DATE;
DEFINE _fecha_cancelacion			  DATE;
DEFINE _consultorio_numero			  INTEGER;
DEFINE _piso_numero					  INTEGER;
DEFINE _cosultorio_tel				  CHAR(10);
DEFINE _consultorio_fax				  CHAR(10);
DEFINE _dias_atencion				  CHAR(20);
DEFINE _horario_atencion_de			  DATE;
DEFINE _horario_atencion_a			  DATE;
DEFINE _consultorio_numero2			  INTEGER;
DEFINE _piso_numero2				  INTEGER;
DEFINE _consultorio_tel2			  CHAR(10);
DEFINE _consultorio_fax2			  CHAR(10);
DEFINE _dias_atencion2				  CHAR(20);
DEFINE _horario_atencion_de2		  DATE;
DEFINE _horario_atencion_a2			  DATE;
DEFINE _universidad					  VARCHAR(60);
DEFINE _fecha_graduacion			  DATE;
DEFINE _pais						  VARCHAR(20);
DEFINE _ciudad						  VARCHAR(20);
DEFINE _hospital_residencia			  VARCHAR(60);
DEFINE _fecha_residencia_desde		  DATE;
DEFINE _fecha_residencia_hasta		  DATE;
DEFINE _pais_residencia				  VARCHAR(20);
DEFINE _ciudad_residencia			  VARCHAR(20);
DEFINE _cliente_web					  SMALLINT;
DEFINE _reset_password				  SMALLINT;
DEFINE _password_web				  CHAR(30);
DEFINE _consultorio_1				  CHAR(10);
DEFINE _consultorio_2				  CHAR(10);
DEFINE _paga_impuesto				  SMALLINT;
DEFINE _leasing						  SMALLINT;
DEFINE _conoce_cliente				  SMALLINT;
DEFINE _cliente_pep					  SMALLINT;
DEFINE _fumador						  SMALLINT;
DEFINE _seleccion				      SMALLINT;
DEFINE _cedula_seteo				  VARCHAR(30);

-- Crear la tabla temp que llama los registros clientes
		CREATE TEMP TABLE tmp_cli(
		cod_cliente					  CHAR(10),
		cod_compania				  CHAR(3),
		cod_sucursal				  CHAR(3),
		cod_origen					  CHAR(3),
		cod_grupo					  CHAR(5),
		cod_clasehosp				  CHAR(3),
		cod_espmedica				  CHAR(3),
		cod_ocupacion				  CHAR(3),
		cod_trabajo					  CHAR(3),
		cod_actividad				  CHAR(3),
		code_pais					  CHAR(3),
		code_provincia				  CHAR(2),
		code_ciudad					  CHAR(2),
		code_distrito				  CHAR(2),
		code_correg					  CHAR(5),
		nombre						  VARCHAR(100),
		nombre_razon				  VARCHAR(100),
		direccion_1					  VARCHAR(50),
		direccion_2					  VARCHAR(50),
		apartado					  CHAR(20),
		tipo_persona				  CHAR(1),
		actual_potencial			  CHAR(1),
		cedula						  VARCHAR(30),
		telefono1					  CHAR(10),
		telefono2					  CHAR(10),
		e_mail						  CHAR(50),
		fax							  CHAR(10),
		date_added					  DATE,
		user_added					  CHAR(8),
		de_la_red					  SMALLINT,
		mala_referencia				  SMALLINT,
		desc_mala_ref				  VARCHAR(250),
		fecha_aniversario			  DATE,
		sexo						  CHAR(1),
		digito_ver					  CHAR(2),
		date_changed				  DATE,
		user_changed				  CHAR(8),
		nombre_original				  CHAR(100),
		ced_provincia				  CHAR(2),
		ced_inicial					  CHAR(2),
		ced_tomo					  CHAR(7),
		ced_folio					  CHAR(7),
		ced_asiento					  CHAR(7),
		aseg_primer_nom				  CHAR(100),
		aseg_segundo_nom			  CHAR(40),
		aseg_primer_ape				  CHAR(40),
		aseg_segundo_ape			  CHAR(40),
		aseg_casada_ape				  CHAR(40),
		ced_correcta				  SMALLINT,
		pasaporte					  SMALLINT,
		cotizacion					  CHAR(10),
		de_cotizacion				  SMALLINT,
		celular						  CHAR(10),
		dia_cobros1					  INTEGER,
		dia_cobros2					  INTEGER,
		contacto					  CHAR(50),
		telefono3					  CHAR(10),
		direccion_cob				  VARCHAR(100),
		es_taller					  SMALLINT,
		proveedor_autorizado		  SMALLINT,
		ip_number					  CHAR(30),
		no_beeper					  CHAR(10),
		cod_beeper					  CHAR(3),
		periodo_pago				  SMALLINT,
		tipo_cuenta					  CHAR(1),
		cod_cuenta					  CHAR(17),
		cod_banco					  CHAR(3),
		tipo_pago					  SMALLINT,
		cod_ruta					  CHAR(2),
		fecha_contratacion			  DATE,
		fecha_cancelacion			  DATE,
		consultorio_numero			  INTEGER,
		piso_numero					  INTEGER,
		cosultorio_tel				  CHAR(10),
		consultorio_fax				  CHAR(10),
		dias_atencion				  CHAR(20),
		horario_atencion_de			  DATE,
		horario_atencion_a			  DATE,
		consultorio_numero2			  INTEGER,
		piso_numero2				  INTEGER,
		consultorio_tel2			  CHAR(10),
		consultorio_fax2			  CHAR(10),
		dias_atencion2				  CHAR(20),
		horario_atencion_de2		  DATE,
		horario_atencion_a2			  DATE,
		universidad					  VARCHAR(60),
		fecha_graduacion			  DATE,
		pais						  VARCHAR(20),
		ciudad						  VARCHAR(20),
		hospital_residencia			  VARCHAR(60),
		fecha_residencia_desde		  DATE,
		fecha_residencia_hasta		  DATE,
		pais_residencia				  VARCHAR(20),
		ciudad_residencia			  VARCHAR(20),
		cliente_web					  SMALLINT,
		reset_password				  SMALLINT,
		password_web				  CHAR(30),
		consultorio_1				  CHAR(10),
		consultorio_2				  CHAR(10),
		paga_impuesto				  SMALLINT,
		leasing						  SMALLINT,
		conoce_cliente				  SMALLINT,
		cliente_pep					  SMALLINT,
		fumador						  SMALLINT,
		seleccion				      SMALLINT
		);

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "sp_par308.trc";      
-- TRACE ON;                                                                     

INSERT INTO tmp_cli				  (
		cod_cliente				  ,	  
		cod_compania			  ,	  
		cod_sucursal			  ,	  
		cod_origen				  ,	  
		cod_grupo				  ,	  
		cod_clasehosp			  ,	  
		cod_espmedica			  ,	  
		cod_ocupacion			  ,	  
		cod_trabajo				  ,	  
		cod_actividad			  ,	  
		code_pais				  ,	  
		code_provincia			  ,	  
		code_ciudad				  ,	  
		code_distrito			  ,	  
		code_correg				  ,	  
		nombre					  ,	  
		nombre_razon			  ,	  
		direccion_1				  ,	  
		direccion_2				  ,	  
		apartado				  ,	  
		tipo_persona			  ,	  
		actual_potencial		  ,	  
		cedula					  ,	  
		telefono1				  ,	  
		telefono2				  ,	  
		e_mail					  ,	  
		fax						  ,	  
		date_added				  ,	  
		user_added				  ,	  
		de_la_red				  ,	  
		mala_referencia			  ,	  
		desc_mala_ref			  ,	  
		fecha_aniversario		  ,	  
		sexo					  ,	  
		digito_ver				  ,	  
		date_changed			  ,	  
		user_changed			  ,	  
		nombre_original			  ,	  
		ced_provincia			  ,	  
		ced_inicial				  ,	  
		ced_tomo				  ,	  
		ced_folio				  ,	  
		ced_asiento				  ,	  
		aseg_primer_nom			  ,	  
		aseg_segundo_nom		  ,	  
		aseg_primer_ape			  ,	  
		aseg_segundo_ape		  ,	  
		aseg_casada_ape			  ,	  
		ced_correcta			  ,	  
		pasaporte				  ,	  
		cotizacion				  ,	  
		de_cotizacion			  ,	  
		celular					  ,	  
		dia_cobros1				  ,	  
		dia_cobros2				  ,	  
		contacto				  ,	  
		telefono3				  ,	  
		direccion_cob			  ,	  
		es_taller				  ,	  
		proveedor_autorizado	  ,	  
		ip_number				  ,	  
		no_beeper				  ,	  
	    cod_beeper				  ,	  
	    periodo_pago			  ,	  
	    tipo_cuenta				  ,	  
	    cod_cuenta				  ,	  
	    cod_banco				  ,	  
	    tipo_pago				  ,	  
	    cod_ruta				  ,	  
	    fecha_contratacion		  ,	  
	    fecha_cancelacion		  ,	  
	    consultorio_numero		  ,	  
	    piso_numero				  ,	  
	    cosultorio_tel			  ,	  
	    consultorio_fax			  ,	  
	    dias_atencion			  ,	  
	    horario_atencion_de		  ,	  
	    horario_atencion_a		  ,	  
	    consultorio_numero2		  ,	  
	    piso_numero2			  ,	  
	    consultorio_tel2		  ,	  
	    consultorio_fax2		  ,	  
	    dias_atencion2			  ,	  
	    horario_atencion_de2	  ,	  
	    horario_atencion_a2		  ,	  
	    universidad				  ,	  
	    fecha_graduacion		  ,	  
	    pais					  ,	  
	    ciudad					  ,	  
	    hospital_residencia		  ,	  
	    fecha_residencia_desde	  ,	  
	    fecha_residencia_hasta	  ,	  
	    pais_residencia			  ,	  
	    ciudad_residencia		  ,	  
	    cliente_web				  ,	  
	    reset_password			  ,	  
	    password_web			  ,	  
	    consultorio_1			  ,	  
	    consultorio_2			  ,	  
	    paga_impuesto			  ,	  
	    leasing					  ,	  
	    conoce_cliente			  ,	  
	    cliente_pep				  ,	  
	    fumador					  ,
	    seleccion)	  
SELECT 	cod_cliente	  			  ,	  
		cod_compania			  ,	  
		cod_sucursal			  ,	  
		cod_origen				  ,	  
		cod_grupo				  ,	  
		cod_clasehosp			  ,	  
		cod_espmedica			  ,	  
		cod_ocupacion			  ,	  
		cod_trabajo				  ,	  
		cod_actividad			  ,	  
		code_pais				  ,	  
		code_provincia			  ,	  
		code_ciudad				  ,	  
		code_distrito			  ,	  
		code_correg				  ,	  
		nombre					  ,	  
		nombre_razon			  ,	  
		direccion_1				  ,	  
		direccion_2				  ,	  
		apartado				  ,	  
		tipo_persona			  ,	  
		actual_potencial		  ,	  
		cedula					  ,	  
		telefono1				  ,	  
		telefono2				  ,	  
		e_mail					  ,	  
		fax						  ,	  
		date_added				  ,	  
		user_added				  ,	  
		de_la_red				  ,	  
		mala_referencia			  ,	  
		desc_mala_ref			  ,	  
		fecha_aniversario		  ,	  
		sexo					  ,	  
		digito_ver				  ,	  
		date_changed			  ,	  
		user_changed			  ,	  
		nombre_original			  ,	  
		ced_provincia			  ,	  
		ced_inicial				  ,	  
		ced_tomo				  ,	  
		ced_folio				  ,	  
		ced_asiento				  ,	  
		aseg_primer_nom			  ,	  
		aseg_segundo_nom		  ,	  
		aseg_primer_ape			  ,	  
		aseg_segundo_ape		  ,	  
		aseg_casada_ape			  ,	  
		ced_correcta			  ,	  
		pasaporte				  ,	  
		cotizacion				  ,	  
		de_cotizacion			  ,	  
		celular					  ,	  
		dia_cobros1				  ,	  
		dia_cobros2				  ,	  
		contacto				  ,	  
		telefono3				  ,	  
		direccion_cob			  ,	  
		es_taller				  ,	  
		proveedor_autorizado	  ,	  
		ip_number				  ,	  
		no_beeper				  ,	  
	    cod_beeper				  ,	  
	    periodo_pago			  ,	  
	    tipo_cuenta				  ,	  
	    cod_cuenta				  ,	  
	    cod_banco				  ,	  
	    tipo_pago				  ,	  
	    cod_ruta				  ,	  
	    fecha_contratacion		  ,	  
	    fecha_cancelacion		  ,	  
	    consultorio_numero		  ,	  
	    piso_numero				  ,	  
	    cosultorio_tel			  ,	  
	    consultorio_fax			  ,	  
	    dias_atencion			  ,	  
	    horario_atencion_de		  ,	  
	    horario_atencion_a		  ,	  
	    consultorio_numero2		  ,	  
	    piso_numero2			  ,	  
	    consultorio_tel2		  ,	  
	    consultorio_fax2		  ,	  
	    dias_atencion2			  ,	  
	    horario_atencion_de2	  ,	  
	    horario_atencion_a2		  ,	  
	    universidad				  ,	  
	    fecha_graduacion		  ,	  
	    pais					  ,	  
	    ciudad					  ,	  
	    hospital_residencia		  ,	  
	    fecha_residencia_desde	  ,	  
	    fecha_residencia_hasta	  ,	  
	    pais_residencia			  ,	  
	    ciudad_residencia		  ,	  
	    cliente_web				  ,	  
	    reset_password			  ,	  
	    password_web			  ,	  
	    consultorio_1			  ,	  
	    consultorio_2			  ,	  
	    paga_impuesto			  ,	  
	    leasing					  ,	  
	    conoce_cliente			  ,	  
	    cliente_pep				  ,	  
	    fumador					  ,
	    0	  
      FROM cliclien  
      WHERE cod_cliente = a_cliente1 
         OR cod_cliente = a_cliente2
         OR cedula like (a_cedula);	

FOREACH	
  SELECT cod_cliente	  ,	  
		cod_compania			  ,	  
		cod_sucursal			  ,	  
		cod_origen				  ,	  
		cod_grupo				  ,	  
		cod_clasehosp			  ,	  
		cod_espmedica			  ,	  
		cod_ocupacion			  ,	  
		cod_trabajo				  ,	  
		cod_actividad			  ,	  
		code_pais				  ,	  
		code_provincia			  ,	  
		code_ciudad				  ,	  
		code_distrito			  ,	  
		code_correg				  ,	  
		nombre					  ,	  
		nombre_razon			  ,	  
		direccion_1				  ,	  
		direccion_2				  ,	  
		apartado				  ,	  
		tipo_persona			  ,	  
		actual_potencial		  ,	  
		cedula					  ,	  
		telefono1				  ,	  
		telefono2				  ,	  
		e_mail					  ,	  
		fax						  ,	  
		date_added				  ,	  
		user_added				  ,	  
		de_la_red				  ,	  
		mala_referencia			  ,	  
		desc_mala_ref			  ,	  
		fecha_aniversario		  ,	  
		sexo					  ,	  
		digito_ver				  ,	  
		date_changed			  ,	  
		user_changed			  ,	  
		nombre_original			  ,	  
		ced_provincia			  ,	  
		ced_inicial				  ,	  
		ced_tomo				  ,	  
		ced_folio				  ,	  
		ced_asiento				  ,	  
		aseg_primer_nom			  ,	  
		aseg_segundo_nom		  ,	  
		aseg_primer_ape			  ,	  
		aseg_segundo_ape		  ,	  
		aseg_casada_ape			  ,	  
		ced_correcta			  ,	  
		pasaporte				  ,	  
		cotizacion				  ,	  
		de_cotizacion			  ,	  
		celular					  ,	  
		dia_cobros1				  ,	  
		dia_cobros2				  ,	  
		contacto				  ,	  
		telefono3				  ,	  
		direccion_cob			  ,	  
		es_taller				  ,	  
		proveedor_autorizado	  ,	  
		ip_number				  ,	  
		no_beeper				  ,	  
	    cod_beeper				  ,	  
	    periodo_pago			  ,	  
	    tipo_cuenta				  ,	  
	    cod_cuenta				  ,	  
	    cod_banco				  ,	  
	    tipo_pago				  ,	  
	    cod_ruta				  ,	  
	    fecha_contratacion		  ,	  
	    fecha_cancelacion		  ,	  
	    consultorio_numero		  ,	  
	    piso_numero				  ,	  
	    cosultorio_tel			  ,	  
	    consultorio_fax			  ,	  
	    dias_atencion			  ,	  
	    horario_atencion_de		  ,	  
	    horario_atencion_a		  ,	  
	    consultorio_numero2		  ,	  
	    piso_numero2			  ,	  
	    consultorio_tel2		  ,	  
	    consultorio_fax2		  ,	  
	    dias_atencion2			  ,	  
	    horario_atencion_de2	  ,	  
	    horario_atencion_a2		  ,	  
	    universidad				  ,	  
	    fecha_graduacion		  ,	  
	    pais					  ,	  
	    ciudad					  ,	  
	    hospital_residencia		  ,	  
	    fecha_residencia_desde	  ,	  
	    fecha_residencia_hasta	  ,	  
	    pais_residencia			  ,	  
	    ciudad_residencia		  ,	  
	    cliente_web				  ,	  
	    reset_password			  ,	  
	    password_web			  ,	  
	    consultorio_1			  ,	  
	    consultorio_2			  ,	  
	    paga_impuesto			  ,	  
	    leasing					  ,	  
	    conoce_cliente			  ,	  
	    cliente_pep				  ,	  
	    fumador					  ,
	    seleccion	  
	INTO _cod_cliente			  ,
		_cod_compania			  ,
		_cod_sucursal			  ,
		_cod_origen				  ,
		_cod_grupo				  ,
		_cod_clasehosp			  ,
		_cod_espmedica			  ,
		_cod_ocupacion			  ,
		_cod_trabajo			  ,
		_cod_actividad			  ,
		_code_pais				  ,
		_code_provincia			  ,
		_code_ciudad			  ,
		_code_distrito			  ,
		_code_correg			  ,
		_nombre					  ,
		_nombre_razon			  ,
		_direccion_1			  ,
		_direccion_2			  ,
		_apartado				  ,
		_tipo_persona			  ,
		_actual_potencial		  ,
		_cedula					  ,
		_telefono1				  ,
		_telefono2				  ,
		_e_mail					  ,
		_fax					  ,
		_date_added				  ,
		_user_added				  ,
		_de_la_red				  ,
		_mala_referencia		  ,
		_desc_mala_ref			  ,
		_fecha_aniversario		  ,
		_sexo					  ,
		_digito_ver				  ,
		_date_changed			  ,
		_user_changed			  ,
		_nombre_original		  ,
		_ced_provincia			  ,
		_ced_inicial			  ,
		_ced_tomo				  ,
		_ced_folio				  ,
		_ced_asiento			  ,
		_aseg_primer_nom		  ,
		_aseg_segundo_nom		  ,
		_aseg_primer_ape		  ,
		_aseg_segundo_ape		  ,
		_aseg_casada_ape		  ,
		_ced_correcta			  ,
		_pasaporte				  ,
		_cotizacion				  ,
		_de_cotizacion			  ,
		_celular				  ,
		_dia_cobros1			  ,
		_dia_cobros2			  ,
		_contacto				  ,
		_telefono3				  ,
		_direccion_cob			  ,
		_es_taller				  ,
		_proveedor_autorizado	  ,
		_ip_number				  ,
		_no_beeper				  ,
		_cod_beeper				  ,
		_periodo_pago			  ,
		_tipo_cuenta			  ,
		_cod_cuenta				  ,
		_cod_banco				  ,
		_tipo_pago				  ,
		_cod_ruta				  ,
		_fecha_contratacion		  ,
		_fecha_cancelacion		  ,
		_consultorio_numero		  ,
		_piso_numero			  ,
		_cosultorio_tel			  ,
		_consultorio_fax		  ,
		_dias_atencion			  ,
		_horario_atencion_de	  ,
		_horario_atencion_a		  ,
		_consultorio_numero2	  ,
		_piso_numero2			  ,
		_consultorio_tel2		  ,
		_consultorio_fax2		  ,
		_dias_atencion2			  ,
		_horario_atencion_de2	  ,
		_horario_atencion_a2	  ,
		_universidad			  ,
		_fecha_graduacion		  ,
		_pais					  ,
		_ciudad					  ,
		_hospital_residencia	  ,
		_fecha_residencia_desde	  ,
		_fecha_residencia_hasta	  ,
		_pais_residencia		  ,
		_ciudad_residencia		  ,
		_cliente_web			  ,
		_reset_password			  ,
		_password_web			  ,
		_consultorio_1			  ,
		_consultorio_2			  ,
		_paga_impuesto			  ,
		_leasing				  ,
		_conoce_cliente			  ,
		_cliente_pep			  ,
		_fumador				  ,
		_seleccion	  			   
    FROM tmp_cli
	order by cod_cliente

	let _cedula_seteo = a_cedula;

	RETURN 	_seleccion			  ,
		_cod_cliente			  ,
		_nombre					  ,
		_tipo_persona			  ,
		_cedula_seteo,  --_cedula ,
		_nombre_razon			  ,
		_direccion_1			  ,
		_direccion_2			  ,
		_telefono1				  ,
		_telefono2				  ,
		_telefono3				  ,
		_celular				  ,
		_fax					  ,
		_apartado				  ,
		_e_mail					  ,
		_fecha_aniversario		  ,
		_digito_ver				  ,
		_contacto				  ,
		_de_la_red				  ,
		_direccion_cob			  ,
		_ced_correcta			  ,
		_pasaporte				  ,
		_sexo					  ,
		_es_taller				  ,
		_paga_impuesto			  ,
		_leasing				  ,
		_conoce_cliente			  ,
		_actual_potencial		  ,
		_cliente_pep			  ,
		_fumador				  ,
		_ip_number				  ,
		_no_beeper				  ,
		_cod_beeper				  ,
		_periodo_pago			  ,
		_tipo_cuenta			  ,
		_cod_cuenta				  ,
		_cod_banco				  ,
		_tipo_pago				  ,
		_cod_ruta				  ,
		_mala_referencia		  ,
		_desc_mala_ref			  ,
		_date_changed			  ,
		_user_changed			  ,
		_cotizacion				  ,
		_cliente_web			  ,
		_cod_grupo				  ,
		_cod_clasehosp			  ,
		_cod_origen			      ,
		_cod_ocupacion			  ,
		_cod_trabajo			  ,
		_cod_actividad			  ,
		_code_pais				  ,
		_code_provincia			  ,
		_code_ciudad			  ,
		_code_distrito			  ,
		_code_correg			  ,
		_ced_provincia			  ,
		_ced_inicial			  ,
		_ced_tomo				  ,
		_ced_folio				  ,
		_ced_asiento			  ,
		_aseg_primer_nom		  ,
		_aseg_segundo_nom		  ,
		_aseg_primer_ape		  ,
		_aseg_segundo_ape		  ,
		_aseg_casada_ape		  
		WITH RESUME;

END FOREACH;


DROP TABLE tmp_cli;

							  
							  
END PROCEDURE					   
 
			   