create procedure "informix".sp_rec206()
returning	char(3),						--1
			char(3),						--2
			char(3),						--3
			char(10),						--4
			char(10),						--5
			char(10),						--6
			char(10),						--7
			char(3),						--8
			char(3),						--9
			char(10),						--10
			char(5),						--11
			char(10),						--12
			char(10),						--13
			char(18),						--14
			char(8),						--15
			char(8),						--16
			date,							--17
			datetime hour to second,		--18
			integer,						--19
			char(7),						--20
			varchar(50),					--21
			char(5),						--22
			varchar(100),					--23
			char(5),						--24
			char(10),						--25
			char(30),						--26
			char(5),						--27
			smallint,						--28
			varchar(10),					--29
			smallint,						--30
			dec(16,2),						--31
			char(30),						--32
			varchar(255),					--33
			date,							--34
			char(21),						--35
			char(10),						--36
			char(30),						--37
			date,							--38
			date,							--39
			date,							--40
			datetime hour to second,		--41
			datetime hour to second,		--42
			integer,						--43
			varchar(20),					--44
			varchar(255),					--45
			smallint,						--46
			char(2),						--47
			char(10),						--48
			smallint,						--49
			smallint,						--50
			smallint,						--51
			smallint,						--52
			varchar(50),					--53
			varchar(50);					--54

define _descripcion_t		varchar(255);
define _descripcion			varchar(255);
define _narracion			varchar(255);
define _nom_conductor		varchar(100);
define _razon_social		varchar(100);
define _nom_cliente			varchar(100);
define _reclamante			varchar(100);
define _email_conductor		varchar(50);
define _cord_beneficios		varchar(50);
define _posible_recobro		varchar(50);
define _email_ajust			varchar(50);
define _direccion1			varchar(50);
define _direccion2			varchar(50);
define _cedula_conductor	varchar(30);
define _cedula				varchar(30);
define _no_resolucion		varchar(20);
define _status_reclamo		varchar(10);
define _telefono1			varchar(10);
define _telefono2			varchar(10);
define _telefono3			varchar(10);
define _celular				varchar(10);
define _no_motor_t			char(30);
define _no_chasis			char(30);
define _no_motor			char(30);
define _no_documento		char(21);
define _numrecla			char(18);
define _cod_conductor_t		char(10);
define _parte_policivo		char(10);
define _cod_reclamante		char(10);
define _cod_conductor		char(10);
define _cod_tercero			char(10);
define _no_tramite			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _bandera				char(10);
define _placa_t				char(10);
define _placa				char(10);
define _user_windows		char(8);
define _user_added			char(8);
define _asiento				char(7);
define _periodo				char(7);
define _tomo				char(7);
define _cod_cobertura		char(5);
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
define _tiene_audiencia		char(2);
define _provincia			char(2);
define _inicial				char(2);
define _sexo				char(1);
define _null				char(1);
define _suma_asegurada		dec(16,2);
define _status_audiencia	smallint;
define _status_poliza		smallint;
define _perdida_total		smallint;
define _tiene_saldo			smallint;
define _actualizado			smallint;
define _asist_legal			smallint;
define _cons_legal			smallint;
define _cnt_cober			smallint;
define _ano_auto			smallint;
define _evento				smallint;
define _existe				smallint;
define _formato_unico		integer;
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

set isolation to dirty read;
--set debug file to "sp_rec62b.trc";
--trace on;
let _cedula_conductor	= '';
let _sucursal_origen	= '';
let _tiene_audiencia	= '';
let _cod_conductor_t	= '';
let _email_conductor	= '';	
let _cord_beneficios	= '';
let _posible_recobro	= '';
let _status_reclamo		= '';
let _parte_policivo		= '';
let _cod_reclamante		= '';
let _no_resolucion		= '';
let _nom_conductor		= '';
let _descripcion_t		= '';
let _cod_cobertura		= '';
let _cod_ajustador		= '';
let _cod_conductor		= '';
let _no_documento		= '';
let _cod_sucursal		= '';
let _cod_compania		= '';
let _razon_social		= '';
let _user_windows		= '';
let _cod_modelo_t		= '';
let _nom_cliente		= '';
let _descripcion		= '';
let _email_ajust		= '';
let _cod_tercero		= '';
let _cod_marca_t		= '';
let _no_motor_t			= '';
let _reclamante			= '';
let _direccion1			= '';
let _direccion2			= '';
let _no_tramite			= '';
let _no_reclamo			= '';
let _user_added			= '';
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
let _bandera			= '';
let _placa_t			= '';
let _asiento			= '';
let _celular			= '';
let _inicial			= '';
let _cedula				= '';
let _placa				= '';
let _tomo				= '';
let _sexo				= '';
let _null				= null;
let _fecha_hoy			= current;
let _periodo			= sp_sis39(_fecha_hoy);
let _status_audiencia	= 0;
let _status_poliza		= 0;
let _perdida_total		= 0;
let _formato_unico		= 0;
let _tiene_saldo		= 0;
let _actualizado		= 0;
let _asist_legal		= 0;
let _cons_legal			= 0;
let _incidente			= 0;
let _cnt_cober			= 0;
let _ano_auto			= 0;
let _evento				= 0;
let _existe				= 0;
let _error				= 0;
let _suma_asegurada		= 0.00;

foreach
	select no_documento,
		   no_motor,
		   bandera,
		   descripcion,
		   parte_policivo,
		   tiene_audiencia,
		   fecha_tramite,
		   fecha_documento,
		   fecha_siniestro,
		   fecha_reclamo,
		   hora_siniestro,
		   hora_audiencia,
		   formato_unico,
		   perdida_total,
		   no_resolucion,
		   narracion,
		   tiene_saldo,
		   asist_legal,
		   status_audiencia,
		   evento,
		   cedula,
		   nombre_conductor,
		   cedula_conductor,
		   sexo_conductor,
		   fecha_nac_conductor,
		   email_conductor
	  into _no_documento,
		   _no_motor,
		   _bandera,
		   _descripcion,
		   _parte_policivo,
		   _tiene_audiencia,
		   _fecha_tramite,
		   _fecha_documento,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _hora_siniestro,
		   _hora_audiencia,
		   _formato_unico,
		   _perdida_total,
		   _no_resolucion,
		   _narracion,
		   _tiene_saldo,
		   _asist_legal,
		   _status_audiencia,
		   _evento,
		   _cedula,
		   _nom_conductor,
		   _cedula_conductor,
		   _sexo,
		   _fecha_aniversario,
		   _email_conductor
	  from recpanasi
	 where procesado = 0
	
	foreach
		select no_poliza
		  into _no_poliza
		  from emipomae
		 where no_documento = _no_documento
		   and _fecha_siniestro between vigencia_inic and vigencia_final
		   and actualizado = 1
		 order by fecha_suscripcion desc
		exit foreach;
	end foreach
	
	if _no_poliza is null then
		continue foreach;
	end if
	
	select cod_ramo,
		   estatus_poliza,
		   sucursal_origen
	  into _cod_ramo,
		   _status_poliza,
		   _sucursal_origen
	  from emipomae
	 where no_poliza	= _no_poliza;
	
	foreach
		select no_unidad
		  into _no_unidad
		  from emiauto
		 where no_poliza	= _no_poliza
		   and no_motor		= _no_motor
		exit foreach;
	end foreach
	
	select cod_asegurado,
		   suma_asegurada
	  into _cod_reclamante,
		   _suma_asegurada
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _cod_ramo = '002' then
		let _cod_cobertura = '00119';
		let _cnt_cober = 0;
		
		select count(*)
		  into _cnt_cober
		  from emipocob
		 where no_poliza		= _no_poliza
		   and no_unidad		= _no_unidad
		   and cod_cobertura	= _cod_cobertura;
		   
		if _cnt_cober = 0 then
			let _cod_cobertura = '00121';
		end if
	elif _cod_ramo = '020' then
		let _cod_cobertura = '01022';
	end if
			   
	select nombre_razon,
		   cedula,
		   direccion_1,
		   direccion_2,
		   code_provincia,
		   telefono1,
		   telefono2,
		   telefono3,
		   celular
	  into _nom_cliente,
		   _cedula,
		   _direccion1,
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
	
	if upper(_bandera) = 'TERCERO' then
		let _cod_marca_t	= _cod_marca;
		let _cod_modelo_t	= _cod_modelo;
		let _placa_t		= _placa;
		
		--let _tipo_doc = 1;
		if _cedula_conductor is not null and _cedula_conductor <> '' then
			call sp_sis108(_cedula_conductor,1) returning _existe,_cod_conductor;
		end if
		
		if _existe = 0 then
			call sp_sis400(_cedula_conductor) returning _provincia,_inicial,_tomo,_asiento;																	   
			let _null = null;

			let _razon_social = trim(_nom_conductor); --|| trim(_cliente_ape) || trim(_cliente_ape_casada);
			call sp_sis175(_telefono1) returning _telefono1;
			call sp_sis175(_telefono2) returning _telefono2;
			call sp_sis175(_celular) returning _celular;

			{call sp_sis372( _cod_conductor,		--ls_valor_nuevo char(10),
							0,						--ll_nrocotizacion int,
							'N',					--ls_tipopersona char(1),
							'A',					--ls_tipocliente char(1),
							_cliente_nom,			--ls_primernombre char(40),
							'',						--ls_segundonombre char(40),
							_cliente_ape,			--ls_primerapellido char(40),
							'',						--ls_segundoapellido char(40),
							_cliente_ape_casada,	--ls_apellidocasada char(40),
							_razon_social,  		--ls_razonsocial char(100),
							_cedula,		   		--ls_cedula char(30),
							_ruc,		   			--ls_ruc char(30),
							_pasaporte,		   		--ls_pasaporte char(30),
							_direccion,		   		--ls_direccion char(50),
							_null,		   			--ls_apartado char(20), 
							_telefono1,		   		--ls_telefono1 char(10),
							_telefono2,		   		--ls_telefono2 char(10),
							_null,		   			--ls_fax char(10),
							_email_conductor,  		--ls_email char(50),
							_fecha_aniversario,		--ld_fechaaniversario,
							_sexo,		   			--ls_sexo char(1),
							'informix',	   			--ls_usuario char(8),
							'001',		   			--ls_compania	char(3),
							'001',		   			--ls_agencia char(3),
							_provincia,	   			--ls_provincia char(2),
							_inicial,	   			--ls_inicial char(2),
							_tomo,		   			--ls_tomo char(7),
							'',			   			--ls_folio char(7),
							_asiento,	   			--ls_asiento char(7),
							'',			   			--ls_direccion2 varchar(50),
							_celular)	   			--ls_celular varchar(10),
							returning _error;}
			if _error <> 0 then
				continue foreach;
			end if
		end if
	end if
	
	let _cod_evento = '000';
	
	if _evento > 99 then
		let _cod_evento[1,3] = _evento;
	elif _evento > 9 then
		let _cod_evento[2,3] = _evento;
	else
		let _cod_evento[3,3] = _evento;
	end if	
	
	return	_cod_lugci,
			_cod_ajustador,
			_cod_compania,
			_cod_reclamante,
			_cod_conductor,
			_cod_tercero,
			_cod_conductor_t,
			_cod_evento,
			_sucursal_origen,
			_no_poliza,
			_no_unidad,
			_no_reclamo,
			_no_tramite,
			_numrecla,
			_user_added,
			_user_windows,
			_hora_tramite,
			_incidente,
			_periodo,
			_email_ajust,
			_cod_cobertura,
			_reclamante,
			_cod_modelo,
			_placa,
			_no_chasis,
			_cod_marca_t,
			_ano_auto,
			_status_reclamo,
			_actualizado,
			_suma_asegurada,
			_no_motor_t,
			_descripcion_t,
			_fecha_audiencia,
			_fecha_documento,
			_no_documento,
			_parte_policivo,
			_no_motor,
			_fecha_tramite,
			_fecha_siniestro,
			_fecha_reclamo,
			_hora_siniestro,
			_hora_audiencia,
			_formato_unico,
			_no_resolucion,
			_narracion,
			_perdida_total,
			_tiene_audiencia,
			_bandera,
			_tiene_saldo,
			_asist_legal,
			_status_audiencia,
			_cons_legal,
			_cord_beneficios,
			_posible_recobro
			with resume;

end foreach
end procedure
                                    
