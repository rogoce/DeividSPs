
-- Procedure que registra un reclamo en Deivid

-- Creado: 10/07/2019 - Autor: Federico Coronado

drop procedure sp_web55;

create procedure "informix".sp_web55(a_no_documento varchar(21), a_no_unidad varchar(5), a_cod_cobertura varchar(5))
returning	char(3),						--1  
			char(3),						--2  
			char(3),						--3  
			char(10),						--4  
			char(10),						--5  
			smallint,						--6  
			date,							--7  
			char(1),						--8  
			smallint,						--9  
			char(1),						--10
			char(7),						--11
			char(1),						--12	
			dec(16,2),						--13
			smallint,						--14
			smallint,						--15
			char(1),						--16
			char(1),						--17
			datetime hour to second,		--18	
			char(8),						--19
			date,							--20
			date,							--21		
			char(5),						--22
			char(10),						--23
			char(3),						--24		
			char(21),						--25
			date,							--26
			char(10),						--27
			datetime hour to second,		--28
			char(30),						--29
			varchar(255),					--30	
			char(8),						--31		
			char(10),						--32
			integer,						--33
			char(18),						--34
			varchar(50),					--35
			varchar(100),					--36 		
			date,							--37 	
			char(3),						--38 			
			char(10),						--39 	
			datetime hour to second,		--40 	
			varchar(20),					--41 		
			smallint,						--42 
			char(10),						--43		
			varchar(200),					--44		
			char(10),						--45	
			char(1),						--46 		
			char(10),						--47 		
			char(30),						--48 
			char(10),						--49
			varchar(255),					--50 		
			char(3),						--51		
			char(5),						--52	
			char(10),						--53				
			varchar(50),					--54 			
			char(30),						--55 	
			varchar(20),					--56 
			char(3),                        --57 
			varchar(10),                    --58 
			char(1),                        --59
			varchar(20),                    --60    g_no_asiges
			varchar(50),                    --61
			varchar(50),                    --62
			varchar(50),                    --63
			varchar(50);                    --64

define _descripcion_t		varchar(255);
define _descripcion			varchar(255);
define _narracion			varchar(255);
define _nom_conductor		varchar(100);
define _nom_ajustador		varchar(100);
define _razon_social		varchar(100);
define _nom_cliente			varchar(100);
define _reclamante			varchar(100);
define _direccion			varchar(100);
define _email_conductor		varchar(50);
define _email_ajust			varchar(50);
define _direccion1			varchar(50);
define _direccion2			varchar(50);
define _cedula_conductor	varchar(30);
define _cedula				varchar(30);
define _no_resolucion		varchar(20);
define _telefono1			varchar(10);
define _telefono2			varchar(10);
define _telefono3			varchar(10);
define _celular				varchar(10);
define _bandera				varchar(10);
define _no_chasis_t			char(30);
define _no_motor_t			char(30);
define _no_chasis			char(30);
define _no_motor			char(30);
define _no_documento		char(21);
define _numrecla			char(18);
define _cod_conductor_t		char(10);										   
define _parte_policivo		char(10);										   
define _cod_reclamante		char(10);										   
define _cod_conductor		char(10);										   
define _cod_asegurado		char(10);
define _cod_tercero			char(10);										   
define _no_tramite			char(10);										   
define _no_reclamo			char(10);										   
define _no_poliza			char(10);										   
define _placa_t				char(10);										   
define _placa				char(10);										   
define _user_ajustador		char(8);										   
define _user_added			char(8);										   
define _asiento				char(7);										   
define _periodo				char(7);										   
define _tomo				char(7);										   
define _cod_cobertura		varchar(200);										   
define _cod_modelo_t		char(5);										   
define _cod_modelo			char(5);										   
define _no_unidad			char(5);										   
define _sucursal_origen		char(3);										   
define _cod_ajustador		char(3);										   
define _cod_sucursal		char(3);										   
define _cod_compania		char(3);										   
define _cod_marca_t			char(3);										   
define _cod_evento			char(3);										   
define _cod_marca			char(3);
define _cod_lugci			char(3);
define _cod_ramo			char(3);
define _es_propietario		char(2);
define _provincia			char(2);
define _inicial				char(2);
define _status_reclamo		char(1);
define _sexo				char(1);
define _null				char(1);
define _suma_asegurada		dec(16,2);
define _status_audiencia	smallint;
define _cord_beneficios		smallint;
define _posible_recobro		smallint;
define _tiene_audiencia		char(1);
define _status_poliza		smallint;
define _perdida_total		char(1);
define _tiene_saldo			dec(16,2);
define _actualizado			smallint;
define _asist_legal			char(1);
define _cons_legal			char(1);
define _ano_auto_t			smallint;
define _cnt_cober			smallint;
define _ano_auto			smallint;
define _evento				smallint;
define _existe				smallint;
define _formato_unico		char(1);
define _incidente			integer;
define _error				integer;
define _hora_siniestro		datetime hour to second;
define _hora_tramite		datetime hour to second;
define _hora_audiencia		datetime hour to second;
define _fecha_aniversario	date;
define _fecha_documento		date;
define _fecha_siniestro		date;
define _fecha_audiencia		date;
define _fecha_tramite		date;
define _fecha_reclamo		date;
define _fecha_hoy			date;

define _licencia_conductor  char(15);
define _tipo_vehiculo       char(20);
define _tipo_siniestro      integer;
define _lugar_siniestro     varchar(50);
define _code_provincia      char(3);
define _nombre_cobertura    varchar(50);
--define _deducible           dec(16,2);
define _deducible           varchar(10);
define _nom_ramo            varchar(20);
define _cod_agente          varchar(10);
define _cod_producto        varchar(5);
define _return              smallint;
define _existe_conductor    smallint;
define _tipo                smallint;
define _no_asiges           varchar(20);
define _estado              char(1);
define _email_consulta      varchar(50);
define _email_asistencia    varchar(50);
define v_nombre_corredor    varchar(50);
define v_email_corredor     varchar(50);
define _cnt_unidad          smallint;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

--SET DEBUG FILE TO "sp_web55.trc";
--TRACE ON ;

begin work;

let _cedula_conductor	= '';
let _sucursal_origen	= '';
let _tiene_audiencia	= 'N';
let _email_conductor	= '';	
let _status_reclamo		= 'A';
let _parte_policivo		= '';
let _cod_reclamante		= '';
let _user_ajustador		= '';
let _nom_ajustador		= '';
let _no_resolucion		= '';
let _nom_conductor		= '';
let _cod_ajustador		= '';
let _cod_conductor		= '';
let _no_documento		= '';
let _cod_sucursal		= '';
let _cod_compania		= '001';
let _razon_social		= '';
let _nom_cliente		= '';
let _descripcion		= '';
let _email_ajust		= '';
let _cod_tercero		= '';
let _reclamante			= '';
let _direccion1			= '';
let _direccion2			= '';
let _no_tramite			= '';
let _no_reclamo			= '';
let _user_added			= 'informix';
let _cod_modelo			= '';
let _cod_evento			= '';
let _cod_marca			= '';
let _cod_lugci			= '';
let _no_unidad			= '';
let _narracion			= '';
let _telefono1			= '';
let _telefono2			= '';
let _telefono3			= '';
let _no_chasis			= '';
let _no_poliza			= '';
let _provincia			= '';
let _no_motor			= '';
let _numrecla			= '';
let _cod_ramo			= '';
let _bandera			= 'Asegurado';
let _asiento			= '';
let _celular			= '';
let _inicial			= '';
let _cedula				= '';
let _placa				= '';
let _tomo				= '';
let _sexo				= '';
let _null				= null;
let _fecha_hoy			= current;
let _fecha_documento	= _fecha_hoy;
let _fecha_tramite		= _fecha_hoy;
let _periodo			= sp_sis39(_fecha_hoy);
let _status_audiencia	= 2;
let _posible_recobro	= 0;
let _cord_beneficios	= 0;
let _status_poliza		= 0;
let _perdida_total		= 'N';
let _formato_unico		= 'N';
let _tiene_saldo		= 0;
let _actualizado		= 0;
let _asist_legal		= 'N';
let _cons_legal			= 'N';
let _incidente			= '';
let _cnt_cober			= 0;
let _ano_auto			= 0;
let _evento				= 0;
let _existe				= 0;
let _error				= 0;
let _suma_asegurada		= 0.00;
let _cod_cobertura		= _null;

let _cod_conductor_t	= _null;
let _descripcion_t		= _null;
let _cod_modelo_t		= _null;
let _cod_tercero		= _null;
let _no_chasis_t		= _null;
let _cod_marca_t		= _null;
let _no_motor_t			= _null;
let _ano_auto_t			= _null;
let _placa_t			= _null;
let _licencia_conductor = _null;
let _tipo_vehiculo      = _null;
let _tipo_siniestro     = 0;
let _lugar_siniestro    = _null;
let _code_provincia     = _null;
let _cod_agente         = _null;
let _hora_tramite       = '00:00:00';

let _fecha_reclamo		= _fecha_hoy;

let _no_poliza = "";
let _email_consulta		= '';
let _email_asistencia   = '';
	
	foreach
		select no_poliza,
			   cod_ramo,
		       estatus_poliza,
		       sucursal_origen
		  into _no_poliza,
			   _cod_ramo,
		       _status_poliza,
		       _sucursal_origen
		  from emipomae
		 where no_documento = _no_documento
		   and _fecha_siniestro between vigencia_inic and vigencia_final
		   and actualizado = 1
		 order by fecha_suscripcion desc
		exit foreach;
	end foreach
	
	FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
	EXIT FOREACH;
	END FOREACH

		SELECT nombre,
			   email_reclamo
		  INTO v_nombre_corredor,
			   v_email_corredor        
		  FROM agtagent
		WHERE cod_agente = _cod_agente;
		
		if v_email_corredor is null	then
			let v_email_corredor = "";
		end if

	let _tiene_saldo = sp_cob174(_no_documento);
	if _tiene_saldo > 0 then
		let _tiene_saldo = 1;
	else
		let _tiene_saldo = 0;
	end if	

	select no_motor
      into _no_motor
      from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	select cod_asegurado,
		   suma_asegurada,
		   cod_producto
	  into _cod_reclamante,
		   _suma_asegurada,
		   _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	
	let _cod_asegurado = _cod_reclamante;

	select nombre,
	       deducible
	  into _nombre_cobertura, 
	       _deducible
	  from emipocob a inner join prdcober b on a.cod_cobertura = b.cod_cobertura
     where no_poliza = trim(_no_poliza)
       and no_unidad = trim(_no_unidad)
       and a.cod_cobertura = trim(a_cod_cobertura);
	   
	let _cod_cobertura = trim(_cod_cobertura)||'^'||trim(_nombre_cobertura)||'^'||_deducible||'^Si^~';
	
	select nombre_razon,
		   cedula,
		   direccion_1,
		   direccion_2,
		   code_provincia,
		   telefono1,
		   telefono2,
		   telefono3,
		   celular
	  into _reclamante,
		   _cedula,
		   _direccion1,
		   _code_provincia,
		   _direccion2,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	select no_chasis,
		   placa,
		   ano_auto,
		   cod_marca,
		   cod_modelo
	  into _no_chasis,
		   _placa,
		   _ano_auto,
		   _cod_marca,
		   _cod_modelo
	  from emivehic
	 where no_motor = _no_motor;

	--let _tipo_doc = 1;
	if _cedula_conductor is not null and trim(_cedula_conductor) <> '' then
		call sp_sis108(_cedula_conductor,1) returning _existe,_cod_conductor;
	else
		--continue foreach;
		let _cod_conductor = "";--_cod_reclamante;
		let _existe = 1;
	end if
		if _existe = 0 then
			call sp_sis400(_cedula_conductor) returning _provincia,_inicial,_tomo,_asiento;																	   
			let _null = null;

			let _razon_social = trim(_nom_conductor); --|| trim(_cliente_ape) || trim(_cliente_ape_casada);
			call sp_sis175(_telefono1) returning _telefono1;
			call sp_sis175(_telefono2) returning _telefono2;
			call sp_sis175(_celular) returning _celular;

			call sp_sis372( _cod_conductor,		--ls_valor_nuevo char(10),
				0,					--ll_nrocotizacion int,
				'N',					--ls_tipopersona char(1),
				'A',					--ls_tipocliente char(1),
				_nom_conductor,		--ls_primernombre char(40),
				'',					--ls_segundonombre char(40),
				'',					--ls_primerapellido char(40),
				'',					--ls_segundoapellido char(40),
				'',					--ls_apellidocasada char(40),
				_razon_social,  	--ls_razonsocial char(100),
				_cedula_conductor,	--ls_cedula char(30),
				'',		   			--ls_ruc char(30),
				'',		   			--ls_pasaporte char(30),
				_direccion,		   	--ls_direccion char(50),
				_null,		   		--ls_apartado char(20), 
				_telefono1,		   	--ls_telefono1 char(10),
				_telefono2,		   	--ls_telefono2 char(10),
				_null,		   		--ls_fax char(10),
				_email_conductor,  	--ls_email char(50),
				_fecha_aniversario,	--ld_fechaaniversario,
				_sexo,		   		--ls_sexo char(1),
				'informix',	   		--ls_usuario char(8),
				'001',		   		--ls_compania	char(3),
				'001',		   		--ls_agencia char(3),
				_provincia,	   		--ls_provincia char(2),
				_inicial,	   		--ls_inicial char(2),
				_tomo,		   		--ls_tomo char(7),
				'',			   		--ls_folio char(7),
				_asiento,	   		--ls_asiento char(7),
				'',			   		--ls_direccion2 varchar(50),
				_celular)	   		--ls_celular varchar(10),
				returning _error;
				if _error <> 0 then
					continue foreach;
				end if
		end if
		
	/*Validar cod_conductor*/
	select count(*)
	  into _existe_conductor
	  from cliclien
	 where cod_cliente = _cod_conductor;
/*2 La cedula del conductor esta vacia*/	
		if _existe_conductor = 0 then
			update recpanasi
			   set procesado = 2
		     where no_documento = _no_documento
			   and no_unidad = _no_unidad
			   and procesado = 0;
			continue foreach;
		end if
	
	if trim(_tiene_audiencia) = 'N' or trim(_tiene_audiencia) = '' then
		let _tiene_audiencia = '0';
	else 
		let _tiene_audiencia = '1';
	end if
	if trim(_formato_unico) = 'N' or trim(_formato_unico) = '' then
		let _formato_unico = '0';
	else
		let _formato_unico = '1';
	end if
	if trim(_asist_legal) = 'N' or trim(_asist_legal) = '' then
		let _asist_legal = '0';
	else
		select email
		  into _email_asistencia
		  from parcocue 
		 where cod_correo = '013' 
		   and activo = 1;
		let _asist_legal = '1';
	end if
	if trim(_cons_legal) = 'N' or trim(_cons_legal) = '' then
		let _cons_legal = '0';
	else
		select email
		  into _email_consulta
		  from parcocue 
		 where cod_correo = '014' 
		   and activo = 1;
		let _cons_legal = '1';
	end if
	if trim(_perdida_total) = 'N' or trim(_perdida_total) = '' then
		let _perdida_total = '0';
	else
		let _perdida_total = '1';
	end if
	
	return	_cod_ajustador,		--1  g_no_CodAjustador    
			_sucursal_origen,	--2  g_no_CodSucursal
			_cod_evento,		--3  g_no_CodEvento
			_cod_reclamante,	--4  g_no_CodReclamante
			_no_poliza,			--5  g_no_NumPoliza
			_posible_recobro,	--6  g_no_PosibleRecobro
			_fecha_documento,	--7  g_fe_Documento
			_tiene_audiencia,	--8  g_no_TieneAudiencia
			_actualizado,		--9  g_no_Actualizado
			_status_reclamo,	--10 g_no_StatusReclamo
			_periodo,			--11 g_no_Periodo
			_perdida_total,		--12 g_no_PerdTotal
			_suma_asegurada,	--13 g_nu_SumaAsegurada
			_cord_beneficios,	--14 g_no_CordBeneficios
			_tiene_saldo,		--15 g_no_TieneSaldo
			_asist_legal,		--16 g_no_AsisLegal
			_cons_legal,		--17 g_no_ConsLegal
			_hora_siniestro,	--18 g_no_HoraSiniestro
			_user_added,		--19 g_no_useradded
			_fecha_siniestro,	--20 g_fe_Siniestro
			_fecha_reclamo,		--21 g_fe_FechaReclamo
			_no_unidad,			--22 g_nu_Unidad
			_no_reclamo,		--23 g_nu_Reclamo         
			_cod_compania,		--24 g_no_CodCompania
			_no_documento,		--25 g_no_Documento
			_fecha_tramite,		--26 u_date
			_no_tramite,		--27 g_nu_Tramite         
			_hora_tramite,		--28 g_no_HoraTramite
			_no_motor,			--29 g_no_NoMotor
			_narracion,			--30 g_no_Narracion
			_user_ajustador,	--31 g_no_UserActualiza
			_bandera,			--32 g_no_reclamante 
			_incidente,			--33 SYS_INCIDENT         
			_numrecla,			--34 g_no_reclamoexterno  
			_email_ajust,		--35 g_no_EmailAjust      
			_reclamante,		--36 g_no_NomCompleto     
			_fecha_audiencia,	--37 g_fe_Audiencia       
			_cod_lugci,			--38 g_no_CodLugCi        
			_parte_policivo,	--39 g_no_PartePolicivo   
			_hora_audiencia,	--40 g_no_HoraAudiencia   
			_no_resolucion,		--41 g_no_Resolucion      
			_status_audiencia,	--42 g_no_EstatusAudiencia
			_cod_conductor,		--43 g_no_CodConductor    
			_cod_cobertura,		--44 g_lst_coberturas
			_cod_asegurado,		--45 g_no_CodAsegurado
			_formato_unico,		--46 g_nu_FormatoUnico
			_cod_tercero,		--47 g_no_t_tercero       
			_no_motor_t,		--48 g_no_t_motor         
			_cod_conductor,		--49 g_no_t_conductor     
			_descripcion_t,		--50 g_no_t_descripcion   
			_cod_marca_t,		--51 g_no_t_marca         
			_cod_modelo_t,		--52 g_no_t_modelo        
			_placa_t,			--53 g_no_t_placa         
			_ano_auto_t,		--54 g_nu_t_agno          
			_no_chasis_t,		--55 g_no_t_chasis        
			_nom_ramo,          --56
			_cod_ramo,          --57
			_cod_agente,        --58
			_estado,            --59
			_no_asiges,         --60
			_email_consulta,    --61
			_email_asistencia,  --62
			v_nombre_corredor,  --63
			v_email_corredor    --64
			with resume;

/*	let a_cod_evento 		= '016';
	--let a_cod_sucursal 	= '001';
	let _fecha_actual 		= today;
	let _hora         		= current;
	let _estatus_reclamo 	= 'A';
	let _tiene_audiencia  	= 1;
	let _perd_total			= 0;
	let _tiene_saldo        = 1;
	call sp_sis39(_fecha_actual) RETURNING _periodo;
	foreach
		select no_poliza,
			   cod_ramo,
			   estatus_poliza,
			   sucursal_origen
		  into _no_poliza,
			   _cod_ramo,
			   _status_poliza,
			   _sucursal_origen
		  from emipomae
		 where no_documento = a_no_documento
		   and a_fecha_siniestro between vigencia_inic and vigencia_final
		   and actualizado = 1
		 order by fecha_suscripcion desc
		exit foreach;
	end foreach
	-- Preguntar si el reclamo se abrira desde la sucursal de la poliza o del usuario que la esta insertando
	let v_no_reclamo		= sp_sis13(_cod_compania, 'REC', '02', 'par_reclamo');
	CALL sp_rwf86(_sucursal_origen,_no_poliza) returning _cod_ajustador, _usuario,_windows_user,_e_mail, _error, _error_desc;
	call sp_sis39(_fecha_actual) RETURNING _periodo;
	
	select no_motor
      into _no_motor
      from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = a_no_unidad;

	select cod_asegurado,
		   suma_asegurada,
		   cod_producto
	  into _cod_reclamante,
		   _suma_asegurada,
		   _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	Insert into recrcmae (ajust_interno, 
						  cod_sucursal, 
						  cod_evento, 
						  cod_reclamante, 
						  no_poliza, 
						  fecha_documento, 
						  tiene_audiencia, 
						  actualizado, 
						  estatus_reclamo, 
						  periodo, 
						  perd_total, 
						  suma_asegurada,  
						  tiene_saldo, 
						  asis_legal, 
						  cons_legal, 
						  hora_siniestro, 
						  user_added, 
						  fecha_siniestro, 
						  fecha_reclamo, 
						  no_unidad, 
						  no_reclamo, 
						  cod_compania, 
						  pendiente, 
						  no_documento, 
						  fecha_tramite, 
						  no_tramite, 
						  no_motor, 
						  cod_asegurado, 
						  user_windows, 
						  incidente, 
						  numrecla, 
						  hora_tramite, 
						  fecha_audiencia, 
						  cod_lugci, 
						  parte_policivo, 
						  hora_audiencia, 
						  no_resolucion, 
						  estatus_audiencia, 
						  cod_conductor, 
						  formato_unico) 
				   values (_cod_ajustador, 
						   _sucursal_origen, 
						   a_cod_evento, 
						   _cod_reclamante,
						   _no_poliza, 
						   _fecha_actual,						   
						   _tiene_audiencia, 
						   1, 
						   _estatus_reclamo, 
						   _periodo, 
						   _perd_total, 
						   _suma_asegurada,
						   _tiene_saldo, 
						   a_asis_legal, 
						   a_cons_legal,
						   a_hora_siniestro, 
						   a_user_added,
						   a_fecha_siniestro,
						   a_fecha_reclamo,
						   a_no_unidad, 
						   v_no_reclamo, 
						   _cod_compania, 
						   0, 
						   a_nro_documento, 
						   a_fecha_tramite,
						   a_nro_tramite, 
						   _no_motor,
						   a_cod_asegurado,  
						   a_user_windows, 
						   a_incidente,  
						   a_numrecla,
						   a_hora_tramite,
						   a_fecha_audiencia,
						   a_cod_lugci,
                           a_parte_policivo,
						   a_hora_audiencia,
                           a_resolucion,
                           a_estatus_audiencia, 
				           a_cod_conductor,
				           a_formato_unico);
*/
	commit work;
return 0, "Exito";
end
end procedure