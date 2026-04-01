-- Informaci¢n: para Panam  Asistencia Ramo Automovil 
-- Creado     : 22/02/2011 - Autor: Roman Gordon

DROP PROCEDURE sp_pro347;

create procedure sp_pro347()
returning int,			 			--1id_aseg,
		  varchar(30),	 			--2_no_documento
		  char(5),					--3_no_unidad
		  char(20),					--3_fecha_suscripcion
		  char(1),		 			--4_status
		  char(1),		 			--5_tipo_persona
		  varchar(60),	 			--6_nom_acreedor
		  char(3),		 			--7_tipo_id
		  varchar(27),	 			--8_aseg_id
		  varchar(80),	 			--9_aseg_nombre
		  varchar(25),	 			--10_aseg_seg_nombre			
		  varchar(25),	 			--11_aseg_apellido			
		  varchar(25),	 			--12_aseg_seg_apellido
		  varchar(25),	 			--13_aseg_apellido_cas
		  varchar(9),	 			--14_placa
		  varchar(25),	 			--15_nom_marca	
		  varchar(25),				--16_nom_modelo	
		  varchar(25),				--17_nom_tipo_veh
		  integer,					--18_ano_auto
		  varchar(20),				--19_no_motor
		  varchar(20),				--20_no_chasis	
		  varchar(20),				--21_vin			
		  char(20),					--22_fecha_extraccion
		  char(20),					--23_fecha_cancelacion
		  char(20),					--24_fecha_modificacion
		  varchar(15),				--25_user_added
		  varchar(15),				--26_user_modificacion
		  char(20),					--27_fecha_registro
		  char(20);					--28_fecha_hoydatetime_char


Define _aseg_nombre				varchar(80);
Define _nom_acreedor			varchar(60);
Define _no_documento			varchar(30);
Define _aseg_id					varchar(27);
Define _aseg_apellido			varchar(25);
Define _aseg_seg_nombre			varchar(25);
Define _aseg_seg_apellido		varchar(25);
Define _aseg_apellido_cas		varchar(25);
Define _nom_marca				varchar(25);
Define _nom_modelo				varchar(25);
Define _nom_tipo_veh			varchar(25);
Define _no_chasis				varchar(20);
Define _no_motor				varchar(20);
Define _vin						varchar(20);
Define _user_added				varchar(15);
Define _user_modificacion		varchar(15);
Define _placa					varchar(9);
Define v_filtros				char(255);
Define _fecha_cancelacion_char	char(20);
Define _fecha_suscripcion_char	char(20);
Define _fecha_renov_char		char(20);
Define _fecha_hoy_datetime_char	char(20);
Define _fecha_extraccion_char	char(20);
Define _fecha_modificacion_char	char(20);
Define _fecha_registro_char		char(20);
Define _fecha_hoy_char			char(20);
Define _no_poliza				char(10);
Define _cod_cliente				char(10);
Define _cod_marca				char(5);
Define _cod_modelo				char(5);
Define _cod_acreedor			char(5);
Define _no_unidad				char(5);
Define _anio					char(4);
Define _cod_tipoveh				char(3);
Define _tipo_id					char(3);
Define _dia						char(2);
Define _mes						char(2);
Define _tipo_persona			char(1);
Define _aseg_tipo_persona		char(1);
Define _status 					char(1);
Define _ano_auto				integer;
Define _estatus_poliza			smallint;
Define _cont_acreedor			smallint;
Define _pasaporte				smallint;
Define _fecha_cancelacion		datetime year to second;
Define _fecha_suscripcion		datetime year to second;
Define _fecha_renov				datetime year to second;
Define _fecha_hoy_datetime		datetime year to second;
Define _fecha_extraccion		datetime year to second;
Define _fecha_modificacion		datetime year to second;
Define _fecha_registro			datetime year to second;
Define _fecha_hoy				date;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pro347.trc";
--trace on;
let _aseg_nombre				= '';		
let _nom_acreedor				= '';
let _no_documento				= '';
let _aseg_id					= '';	
let _aseg_apellido				= '';
let _aseg_seg_nombre			= '';	
let _aseg_seg_apellido			= '';
let _aseg_apellido_cas			= '';
let _nom_marca					= '';
let _nom_modelo					= '';
let _nom_tipo_veh				= '';
let _no_chasis					= '';
let _no_motor					= '';
let _vin						= '';	
let _user_added					= '';
let _user_modificacion			= '';
let _placa						= '';
let v_filtros					= '';
let _no_poliza					= '';
let _cod_cliente				= '';	
let _cod_marca					= '';
let _cod_modelo					= '';
let _cod_acreedor				= '';
let _anio						= '';
let _cod_tipoveh				= '';	
let _tipo_id					= '';	
let _dia						= '';	
let _mes						= '';	
let _tipo_persona				= '';
let _aseg_tipo_persona			= '';
let _status						= '';
let	_fecha_cancelacion_char		= '';
let	_fecha_suscripcion_char		= '';
let	_fecha_renov_char			= '';
let	_fecha_hoy_datetime_char	= '';
let	_fecha_extraccion_char		= '';
let	_fecha_modificacion_char	= '';
let	_fecha_registro_char		= '';
let	_fecha_hoy_char				= '';
let _ano_auto					= 0;	
let _estatus_poliza				= 0;	
let _pasaporte					= 0;	
let _fecha_cancelacion			= null;	
let _fecha_suscripcion			= null;	
let _fecha_renov				= null;
let _fecha_hoy_datetime			= null;
let	_fecha_extraccion			= null;	
let	_fecha_modificacion			= null;
let _fecha_registro 	= current;		
let _fecha_hoy	= today;
let v_filtros	= sp_pro03('001','001',_fecha_hoy,'002,020;');


--trace on;
foreach
	Select no_poliza,
		   no_documento,
		   cod_contratante,
		   usuario
	  into _no_poliza,
		   _no_documento,
		   _cod_cliente,
		   _user_added
	  from temp_perfil
	 where seleccionado = 1
	

		--let _datetime	= _fecha_suscripcion[]
				
		let _aseg_id			= '';
		let _tipo_persona		= '';
		let _aseg_nombre		= '';
		let _aseg_seg_nombre	= '';
		let _aseg_apellido		= '';
		let _aseg_seg_apellido	= '';
		let _aseg_apellido_cas	= '';
		let _pasaporte			= '';

		Select cedula,
			   tipo_persona,
			   aseg_primer_nom,
			   aseg_segundo_nom,
			   aseg_primer_ape,
			   aseg_segundo_ape,
			   aseg_casada_ape,
			   pasaporte
		  into _aseg_id,
			   _tipo_persona,
			   _aseg_nombre,
			   _aseg_seg_nombre,
			   _aseg_apellido,			   
			   _aseg_seg_apellido,
			   _aseg_apellido_cas,
			   _pasaporte
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _tipo_persona = 'J' then
			let _aseg_tipo_persona = 'J';
			let _tipo_id = 'RUC';
		elif _tipo_persona = 'N' then
			let _aseg_tipo_persona = 'N';
			if _pasaporte = 1 then
				let _tipo_id = 'PAS';
			else
				let _tipo_id = 'CIP';						
			end if
		else
		   --	continue foreach;
		end if
		
		Select estatus_poliza,
			   fecha_cancelacion,
			   fecha_renov,
			   user_no_renov,
			   ind_fecha_emi
		  into _estatus_poliza,
			   _fecha_cancelacion,
			   _fecha_renov,
			   _user_modificacion,
			   _fecha_suscripcion
		  from emipomae
		 where no_poliza = _no_poliza;
			
		if _estatus_poliza = 1 then
			let _status = 'V';
		elif _estatus_poliza = 2 then
			let _status = 'C';
		elif _estatus_poliza = 3 then
			let _status = 'E';
		end if
		
		let _no_motor	 = '';
		let _cod_tipoveh = '';
		let _no_unidad	 = '';
			   		
		foreach

			Select no_motor,
				   cod_tipoveh,
				   no_unidad
			  into _no_motor,
				   _cod_tipoveh,
				   _no_unidad
			  from emiauto
			 where no_poliza = _no_poliza
			
			let _cod_acreedor = '';
			let	_nom_acreedor = '';

			Select cod_acreedor
			  into _cod_acreedor
			  from emipoacr
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			 
			if _cod_acreedor <> '' or _cod_acreedor is not null then
				Select nombre
				  into _nom_acreedor
				  from emiacre
				 where cod_acreedor = _cod_acreedor;
			end if

			let _cod_marca	 = '';
			let	_cod_modelo	 = '';
			let	_ano_auto	 = '';
			let	_no_chasis	 = '';
			let	_vin		 = '';
			let	_placa		 = '';			 
			
			Select cod_marca,
				   cod_modelo,
				   ano_auto,
				   no_chasis,
				   vin,
				   placa
			  into _cod_marca,
			  	   _cod_modelo,
			  	   _ano_auto,
			  	   _no_chasis,
			  	   _vin,
			  	   _placa
			  from emivehic
			 where no_motor = _no_motor;
		
			if _aseg_id is null or _aseg_id = '' or _aseg_id = 'P/D' then
				let _aseg_id = 'N/C';
			end if
  
			let _nom_marca = '';
			let _nom_tipo_veh = '';
			let _nom_modelo = '';

			Select nombre
			  into _nom_marca
			  from emimarca
			 where cod_marca = _cod_marca;
						Select nombre
			  into _nom_modelo
			  from emimodel
			 where cod_modelo = _cod_modelo;
			
			Select nombre
			  into _nom_tipo_veh
			  from emitiveh
			 where cod_tipoveh = _cod_tipoveh;

			let _fecha_extraccion			= current;
			let _aseg_nombre				= trim(sp_sis10a(_aseg_nombre));
			let _nom_acreedor				= trim(sp_sis10a(_nom_acreedor));
			let _no_documento				= trim(_no_documento);
			let _aseg_id					= trim(sp_sis10a(_aseg_id));
			let _aseg_apellido				= trim(sp_sis10a(_aseg_apellido));
			let _aseg_seg_nombre			= trim(sp_sis10a(_aseg_seg_nombre));
			let _aseg_seg_apellido			= trim(sp_sis10a(_aseg_seg_apellido));
			let _aseg_apellido_cas			= trim(sp_sis10a(_aseg_apellido_cas));
			let _nom_marca					= trim(sp_sis10a(_nom_marca));
			let _nom_modelo					= trim(sp_sis10a(_nom_modelo));
			let _nom_tipo_veh				= trim(sp_sis10a(_nom_tipo_veh));
			let _no_chasis					= trim(sp_sis10a(_no_chasis));
			let _no_motor					= trim(sp_sis10a(_no_motor));
			let _vin						= trim(sp_sis10a(_vin));
			let _user_added					= trim(_user_added);
			let _user_modificacion			= trim(_user_modificacion);
			let _placa						= trim(sp_sis10a(_placa));
			let v_filtros					= trim(v_filtros);
			let _no_poliza					= trim(_no_poliza);
			let _cod_cliente				= trim(sp_sis10a(_cod_cliente));
			let _cod_marca					= trim(sp_sis10a(_cod_marca));
			let _cod_modelo					= trim(sp_sis10a(_cod_modelo));
			let _cod_acreedor				= trim(sp_sis10a(_cod_acreedor));
			let _anio						= trim(_anio);
			let _cod_tipoveh				= trim(sp_sis10a(_cod_tipoveh));
			let _tipo_id					= trim(_tipo_id);
			let _dia						= trim(_dia);
			let _mes						= trim(_mes);
			let _tipo_persona				= trim(_tipo_persona);
			let _aseg_tipo_persona			= trim(_aseg_tipo_persona);
			let _status						= trim(_status);
			let	_fecha_cancelacion_char		= trim(to_char(_fecha_cancelacion));	
			let	_fecha_suscripcion_char		= trim(to_char(_fecha_suscripcion));	
			--let	_fecha_renov_char		= trim(to_char(_fecha_renov_char));
			let	_fecha_hoy_datetime_char	= trim(to_char(_fecha_hoy_datetime));	
			let	_fecha_extraccion_char		= trim(to_char(_fecha_extraccion));	
			let	_fecha_modificacion_char	= trim(to_char(_fecha_modificacion));		
			let	_fecha_registro_char		= trim(to_char(_fecha_registro));		
			--let	_fecha_hoy_char			= trim(to_char(_fecha_hoy));



			return '8',						  --1id_aseg,
				   _no_documento,			  --2_no_documento
				   _no_unidad,				  --no_unidad
				   _fecha_suscripcion_char,	  --3_fecha_suscripcion
				   _status,					  --4_status
				   _tipo_persona,			  --5_tipo_persona
				   _nom_acreedor,			  --6_nom_acreedor
				   _tipo_id,				  --7_tipo_id
				   _aseg_id,				  --8_aseg_id
				   _aseg_nombre,			  --9_aseg_nombre
				   _aseg_seg_nombre,		  --10_aseg_seg_nombre			
				   _aseg_apellido,			  --11_aseg_apellido		
				   _aseg_seg_apellido,		  --12_aseg_seg_apellido
				   _aseg_apellido_cas,		  --13_aseg_apellido_cas
				   _placa,					  --14_placa
				   _nom_marca,				  --15_nom_marca	
				   _nom_modelo,				  --16_nom_modelo	
				   _nom_tipo_veh,			  --17_nom_tipo_veh
				   _ano_auto,				  --18_ano_auto
				   _no_motor,				  --19_no_motor
				   _no_chasis,				  --20_no_chasis	
				   _vin,					  --21_vin			
				   _fecha_extraccion_char,	  --22_fecha_extraccion
				   _fecha_cancelacion_char,	  --23_fecha_cancelacion
				   _fecha_modificacion_char,  --24_fecha_modificacion
				   _user_added,		  		  --25_user_added
				   _user_modificacion,	  	  --26_user_modificacion
				   _fecha_registro_char,	  --27_fecha_registro
				   _fecha_hoy_datetime_char	  --28_fecha_hoy_datetime_char	
				   with resume;	
			 
		end foreach
end foreach
end procedure