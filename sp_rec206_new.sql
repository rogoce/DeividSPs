-- Procedimiento que Prepara la Información de los Reclamos de la Carga de Pma Asistencias
-- Creado    : 20/06/2013 - Autor: Román Gordón
-- Modificado 20/01/2014 Autor: Federico Coronado
-- Modificado 29/08/2023 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec206_new;		
create procedure "informix".sp_rec206_new()
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
			varchar(50),                    --64
			varchar(10),					--65
			char(1),						--66
			char(1),                       	--67
			char(1),						--68
			char(1),						--69
			char(1);						--70

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
define _veredicto           varchar(20);
define _cober_afectada      varchar(5);  
define _yoseguro            smallint;
define _reserva             varchar(10);
define _tipo_dano           varchar(20); 
define _g_tipo_dano         smallint;
define _g_nu_Liviano		char(1);
define _g_nu_Mediano		char(1);
define _g_nu_Fuerte			char(1);

set isolation to dirty read;
--set debug file to "sp_rec206.trc";
--trace on;

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
let _veredicto          = '';
let _tipo_dano          = '';
let _g_tipo_dano        = 0;
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
let _reserva            = '';

let _fecha_reclamo		= _fecha_hoy;
-- Reseteo de contador
update insuser
   set orden_pma_asist = 0;
--let _fecha_reclamo		= "31/05/2019";
foreach
	select no_documento,                  --1
		   no_unidad,                      --2
		   parte_policivo,                --3
		   tiene_audiencia,               --4
		   fecha_siniestro,               --5
		   hora_siniestro,                --6
		   fecha_audiencia,               --7
		   hora_audiencia,                --8
		   lower(formato_unico),          --9
		   perdida_total,				 --10			
		   no_resolucion,                --11
		   narracion,                    --12
		   asis_legal,                   --13
		   nom_conductor,                --14
		   cedula_conductor,             --15
		   sexo_conductor,               --16
		   fecha_nac_conducto,           --17
		   email_conductor,              --18
		   direccion_conducto,           --19
		   cons_legal,                   --20
		   licencia_conductor,           --21
		   telefono_conductor,           --22
		   celular_conductor,            --23
		   tipo_vehiculo,                --24        
		   no_chasis,                    --25
		   tipo_siniestro,               --26
		   lugar_siniestro,              --27
		   no_asiges,                    --28
		   estado,						 --29
		   lower(veredicto),			 --30
		   yoseguro,					 --31
		   numrecla,                     --32
		   reserva,                      --33 
		   no_tramite,                   --34
		   lower(tipo_dano)
	  into _no_documento,                    --1
		   _no_unidad,                       --2
		   _parte_policivo,                  --3
		   _tiene_audiencia,                 --4
		   _fecha_siniestro,			     --5	
		   _hora_siniestro,	                 --6
		   _fecha_audiencia,	             --7
		   _hora_audiencia,	                 --8
		   _formato_unico,                   --9
		   _perdida_total,                  --10
		   _no_resolucion,                  --11
		   _narracion,                      --12
		   _asist_legal,                    --13
		   _nom_conductor,                  --14
		   _cedula_conductor,               --15
		   _sexo,                           --16
		   _fecha_aniversario,              --17
		   _email_conductor,                --18
		   _direccion,                      --19
		   _cons_legal,                     --20
		   _licencia_conductor,             --21
		   _telefono1,                      --22
		   _telefono2,                      --23
		   _tipo_vehiculo,                  --24
		   _no_chasis,                      --25
		   _tipo_siniestro,                 --26
		   _lugar_siniestro,                --27
		   _no_asiges,                      --28
		   _estado,							--29
		   _veredicto,						--30
		   _yoseguro,			            --31
		   _numrecla,                     	--32
		   _reserva,                      	--33 
		   _no_tramite,                    	--34
           _tipo_dano		                --35
	  from recpanasi
	 where procesado = 0
	   and date_added = _fecha_reclamo
	   --and no_documento in('0213-00140-01')
	   
	let _no_poliza = "";
	let _email_consulta		= '';
	let _email_asistencia   = '';
	let _status_audiencia	= 2;
	let _g_nu_Liviano		= 0;
	let _g_nu_Mediano		= 0;
	let _g_nu_Fuerte		= 0;	
	
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

/*	if _no_unidad is null or trim(_no_unidad) = "" then
		select count(*)
		  into _cnt_unidad
		  from emipouni
		 where no_poliza = _no_poliza;
		if _cnt_unidad = 1 then
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza;
		end if
	end if
*//*4 Poliza no esta en vigencia o el no documento enviado no es correcto*/

	if _no_poliza is null or trim(_no_poliza) = "" then
			update recpanasi
			   set procesado = 4
		     where no_documento = _no_documento
			   and no_unidad = _no_unidad
			   and procesado = 0
			   and date_added = _fecha_reclamo;
		continue foreach;
	end if
	
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
		
	if _yoseguro = 0 then	-- Solo entra si los reclamos llegan por el txt 
		let _reserva = '';
		let _no_tramite = '';
		let _numrecla = '';
		/*----------- a Partir del martes 6 de mayo por orden del Sr. demetrio   Federico Coronado----------*/
		/*if _tipo_siniestro in(1,3,7,8,9) then -- 1 COLISION, 3 ROBO PARCIAL, 7 ROTURA, 8 CAIDA DE OBJETO, 9 PROPIEDAD AJENA
			let _tipo = 1;
			foreach
				 select cod_cobertura
				   into _cod_cobertura
				   from emipocob
				  where no_poliza = _no_poliza
					and no_unidad = _no_unidad
			   order by orden desc
					------ comprensivo colision y vuelco
					if (_cod_cobertura = "00118" or 
					   _cod_cobertura = "00119" or
					   _cod_cobertura = "01307" or 			   
					   _cod_cobertura = "00121") then
					   
						if _tipo_dano = 'fuerte' then
							let _tipo = 2;
						else
							if _formato_unico = 's' and _veredicto = 'culpable' then
								let _tipo = 3;
								let _status_audiencia	= 8;
							else	
								--Aplican para Notificaciones Polizas Completas que no tienen FUD y no son culpables no se abren
								update recpanasi
								   set procesado = 6
								 where no_documento = _no_documento
								   and no_unidad = _no_unidad
								   and procesado = 0
								   and date_added = _fecha_reclamo;
								   
								   call sp_pro534c(_no_asiges, _no_poliza) returning _error,_descripcion;
								   
							end if
						end if
						exit foreach;
					elif _cod_cobertura = "00113" or 
						 _cod_cobertura = "01022" or
						 _cod_cobertura = "01304" or
						 _cod_cobertura = "01651"then
						 
						if _formato_unico = 's' and _veredicto = 'culpable' then
							let _tipo = 3;
							let _status_audiencia	= 8;						   
							exit foreach;
						end if
					end if
			end foreach
				if _tipo = 1 then 
					update recpanasi
					   set procesado = 3
					 where no_documento = _no_documento
					   and no_unidad = _no_unidad
					   and procesado = 0
					   and date_added = _fecha_reclamo;
						continue foreach;
				end if
		end if
		*/
	end if
		/*------------------------------------------------------------------------------*/
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
	/*
    if _cod_ramo = '023' then
		let _cod_ramo = '002';
	end if
	*/
	CALL sp_rec206a_new(_tipo_siniestro, _cod_ramo, _cod_producto, _no_poliza, _no_unidad, _tipo_dano) RETURNING _cod_evento, _cod_cobertura, _nom_ramo;
	/*5 El tipo de siniestro enviado no tiene cobertura definida*/
	if _cod_cobertura is null or trim(_cod_cobertura) = "" then
			update recpanasi
			   set procesado = 5
		     where no_documento = _no_documento
			   and no_unidad = _no_unidad
			   and procesado = 0
			   and date_added = _fecha_reclamo;
		continue foreach;
	end if

	select nombre,
	       deducible
	  into _nombre_cobertura, 
	       _deducible
	  from emipocob a inner join prdcober b on a.cod_cobertura = b.cod_cobertura
     where no_poliza = trim(_no_poliza)
       and no_unidad = trim(_no_unidad)
       and a.cod_cobertura = trim(_cod_cobertura);
	   
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
				'DEIVID',	   		--ls_usuario char(8),
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
	
	if _tipo_dano = 'fuerte' then
		let _g_tipo_dano = 3;
		let _g_nu_Fuerte = 1;	
	elif _tipo_dano = 'mediano' then
		let _g_tipo_dano = 2;
		let _g_nu_Mediano = 1;	
	else
		let _g_tipo_dano = 1;
		let _g_nu_Liviano = 1;
	end if
	
	if _parte_policivo = 'N' then
		let _parte_policivo = '';
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
			v_email_corredor,   --64
			_reserva,			--65
			_yoseguro,          --66
			_g_tipo_dano,		--67
			_g_nu_Liviano,		--68	
			_g_nu_Mediano,		--69
			_g_nu_Fuerte		--70	
			with resume;
end foreach

end procedure