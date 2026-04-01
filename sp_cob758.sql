-- Procedimiento para cargar AVICANC luego de Activar los Avisos de Cancelacion
-- Creado    : 28/12/2010 - Autor:Henry Giron
-- DEIVID, S.A.

drop procedure sp_cob758;
create procedure sp_cob758(
a_cod_avican	char(10),
a_user_proceso	CHAR(15))
returning smallint,
       	  char(100)	     

define _nombre_cliente	varchar(100);
define _error_desc		char(100);
define _motivo_desmarca	char(50);
define _nombre_acreedor	char(50);
define _nombre_formapag	char(50);
define _nombre_subramo	char(50);  
define _nombre_agente	char(50);
define _nombre_ramo     char(50);  
define _email_acre		char(50);
define _email_agt		char(50);
define _email_cli		char(50);
define _nombre1			char(50); 
define _nombre2			char(50); 
define _cargo1			char(50); 
define _cargo2			char(50); 
define _cedula			char(30);
define _no_documento	char(20);
define _apart_acre		char(20);
define _apart_cli		char(20);
define _apart_agt		char(20);
define _apartado		char(20);
define _cod_contratante	char(10);
define _user_cobrador	char(15);
define _user_desmarca	char(15);
define _user_proceso	char(15);
define _usuario2		char(10);
define _cod_cliente		char(10);
define _cod_pagador		char(10);
define _referencia		char(10);
define _no_poliza		char(10);
define _usuario1		char(10); 
define _no_aviso		char(10);
define _telefono		char(10);
define _tel1_cli		char(10);
define _tel2_cli		char(10);
define _fax_cli			char(10);
define _cod_ase         char(10);
define _periodo_ult		char(7);
define _periodo			char(7);
define _cod_acreedor	char(10);  --char(5); 11/03/2019 HG
define _cod_agente		char(5);
define _cod_grupo		char(5);
define _relleno			char(5);
define _cod_tipoprod	char(3);
define _cod_formapag	char(3);
define _cod_cobrador	char(3);
define _cod_vendedor	char(3);
define _cod_agencia		char(3);
define _cod_subramo		char(3);
define _cod_pagos		char(3);
define _ramo_sis		smallint;
define _cod_ramo		char(3);  
define _estatus_poliza	char(1); 
define _marcar_entrega	char(1);
define _cobra_poliza	char(1);
define _estatus			char(1);
define _desmarca		char(1);
define _prima_orig_tot  dec(16,2);
define _prima_orig      dec(16,2);
define _porcentaje      dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _dias_180		dec(16,2);
define _dias_150		dec(16,2);
define _dias_120		dec(16,2);
define _dias_90			dec(16,2);
define _dias_60			dec(16,2);
define _dias_30			dec(16,2);
define _a_pagar			dec(16,2); 
define _saldo			dec(16,2);
define _tiene_email		smallint;
define _tiene_apart		smallint;
define _tiene_acree		smallint;
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _error_isam		smallint;
define _cancela			smallint;
define _renglon			smallint;
define _impreso			smallint;
define _ano,_valor		smallint;
define _secuencia       integer;
define _largo			integer;
define _error			integer;
define _cont			integer;
define _hay 			integer;
define _i				integer;
define _vigencia_final	date;
define _fecha_desmarca	date;
define _fecha_ult_pro	date;
define _vigencia_inic	date;
define _fecha_proceso	date;
define _fecha_vence		date;
define _fecha_hoy		date;
define _leasing			smallint;

on exception set _error
    --rollback work;
	return _error, "Error al Ingresar los Registro en Avicanc";
end exception

set isolation to dirty read;
delete from avisocanc where no_aviso = a_cod_avican;
delete from avicanbit where no_aviso = a_cod_avican;

let _leasing = 0;

--set debug file to "sp_cob758.trc";
--trace on;

let _no_aviso = null;
let _marcar_entrega = "0";
let _fecha_hoy = sp_sis26();
let _user_proceso = a_user_proceso;
let _renglon = 0;
let _cancela = 0;
let _impreso = 0;

-- SET DEBUG FILE TO "sp_cob747.trc";
-- TRACE ON;

-- Estatus
-- G - Proceso
-- R - Clasificar (Email,Apartado,Otros)
-- I - Imprimir	o Enviar
-- M X- Marcar Aviso
-- E X- Marcar Conservacion
-- X - Procesar a Quince dias
-- Y - Desmarcar Poliza x Pagos
-- Z - Cancelar	Poliza

-- CLASE
-- 1 - Email
-- 2 - Apartado
-- 3 - Otros								    

foreach											
	select no_documento,					   
		   exigible,						   
		   dia_cobros1,						   
		   dia_cobros2,						   
		   corriente,						   
		   monto_30,						   
		   monto_60,						   
		   monto_90,						   
		   monto_120,						   
		   monto_150,						   
		   monto_180,						   
		   saldo,							   
		   por_vencer,						   
		   cod_pagos						   
	  into _no_documento, 
	  	   _exigible, 
	  	   _dia_cobros1, 
	  	   _dia_cobros2, 
		   _corriente, 
		   _dias_30, 
		   _dias_60,						   
		   _dias_90, 
		   _dias_120, 
		   _dias_150, 
		   _dias_180, 
		   _saldo, 
		   _por_vencer, 
		   _cod_pagos 
	  from avicanpoliza
	 where cod_avican = a_cod_avican
	 order by cod_zona

	let _no_documento = trim(_no_documento);
	let _no_poliza = sp_sis21(_no_documento);
	let _a_pagar = 0;
	let _fecha_ult_pro = current;

	select cod_pagador
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	let _a_pagar = _a_pagar + _exigible;

	select nombre1,  
		   cargo1,   
		   usuario1, 
		   nombre2,  
		   cargo2,   
		   usuario2 	
	  into _nombre1,  
		   _cargo1,   
		   _usuario1, 
		   _nombre2,  
		   _cargo2,   
		   _usuario2 
	  from avicanpar
	 where cod_avican = a_cod_avican;

	select estatus_poliza,
		   cod_grupo,
		   cod_ramo,
		   cod_pagador,
		   cod_contratante,
		   cod_tipoprod,
		   sucursal_origen,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   cod_formapag,
		   cobra_poliza,
		   prima_bruta,
		   periodo,
		   leasing
	  into _estatus_poliza,
		   _cod_grupo,
		   _cod_ramo,
		   _cod_pagador,
		   _cod_contratante,
		   _cod_tipoprod,
		   _cod_agencia,
		   _cod_subramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_formapag,
		   _cobra_poliza,
		   _prima_orig_tot,
		   _periodo,		   
		   _leasing
	  from emipomae
	 where no_poliza   = _no_poliza
	   and actualizado = 1;
	   --30/01/2020;CASO: 33717 USER: RGORDON AGREGAR EL GRUPO 77850 - TRASPASO ASSA GENERALI BANISI A LA EXCEPCIÓN DE LA GENERACIÓN DE AVISOS DE CANCELACIÓN  ---,'148' sd06078
		if _cod_grupo in ('124','125','1122','77850','77960','77982','78020') then -- SCOTIA BANK y BAGATRAC,Se agrega a Liszenell Bernal Banisi 26/02/2018 8:46 am Ducruet 15/01/2019 CASO: 30140 USER: ASTANZIO   -- SD#5708 23/02/2023 HG
			continue foreach;   --CASO: 30140 USER: ASTANZIO grupo: 148  desde: 18/12/2018 5pm    -- SD#3010 07/04/2022 4:00pm
		end if	   

	select nombre
	  into _nombre_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;     

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- En SALUD todas las Polizas VENCIDAS deben ser cambiadas a VIGENTES. Sr. Carlos Berrocal, Fec.: 01/01/2012
	if _ramo_sis in (5,6,7)  then
		let _estatus_poliza = '1' ;
	end if

	--if _estatus_poliza <> 1 then
		--continue foreach;
	--end if
	if _dias_30 is null then
		let _dias_30 = 0;
	end if

	if _dias_60 is null then
		let _dias_60 = 0;
	end if

	if _dias_90 is null then
		let _dias_90 = 0;
	end if

	if _dias_120 is null then
		let _dias_120 = 0;
	end if

	if _dias_150 is null then
		let _dias_150 = 0;
	end if

	if _dias_180 is null then
		let _dias_180 = 0;
	end if

	-- Para salud la morosidad es a 31 dias y para los demas a 91 dias
	{if _cod_ramo in ("018")  then
		let _saldo = _dias_30 +	_dias_60 +  _dias_90 + _dias_120 + _dias_150 + _dias_180;
	else
		let _saldo = _dias_60 + _dias_90 + _dias_120 + _dias_150 + _dias_180;
	end if}

	if _saldo <= 0  then  --se puso para que saldos negativos no los tome 19/01/2015
		continue foreach;
	end if

	let _apart_cli  = " ";
	let _email_cli  = " ";  
	let _apart_agt  = " ";  
	let _email_agt  = " "; 
	let _no_aviso   = a_cod_avican;

	--if _no_aviso is null then
		-- crea y actualiza el contador
		--let _no_aviso = sp_sis13("001", "COB", "02", "par_aviso_canc");  -- Crear en parcont
	--end if

	-- Datos del cliente de la poliza
	select cedula,
		   nombre,
		   trim(fax),
		   telefono1,
		   telefono2,
		   apartado,
		   e_mail
	  into _cedula,
		   _nombre_cliente,
		   _fax_cli,
		   _tel1_cli,
		   _tel2_cli,
		   _apart_cli,
		   _email_cli
	  from cliclien
	 where cod_cliente = _cod_contratante;

	let _cod_acreedor = null;

	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza

		if _cod_acreedor is not null then
			select nombre
			  into _nombre_acreedor
			  from emiacre
			 where cod_acreedor = _cod_acreedor;
			exit foreach;
		end if
	end foreach

	-- Datos del acreedor de la poliza
	if _cod_acreedor is null then
		if _leasing = 1 then	--La poliza es leasing
			foreach
				select cod_asegurado
				  into _cod_ase
				  from emipouni
				 where no_poliza = _no_poliza
				
				select nombre
				  into _nombre_acreedor
				  from cliclien
				 where cod_cliente = _cod_ase;
					 
				let _cod_acreedor = _cod_ase;  
			end foreach
		else
			let _cod_acreedor = '';
			let _nombre_acreedor = '... SIN ACREEDOR ...';
		end if	
	end if

	foreach
		select cod_agente, 
			   porc_partic_agt 
		  into _cod_agente, 
			   _porcentaje
		  from emipoagt
		 where no_poliza = _no_poliza

		if _cod_agente is not null then
			let _porcentaje = 100;
			exit foreach;
		end if
	end foreach

	-- Prima 
	let _prima_orig = _prima_orig_tot / 100 * _porcentaje;

	if _prima_orig is null then
		let _prima_orig = 0.00;
	end if

	-- Datos del acreedor de la poliza
	select nombre,
		   telefono1,
		   cod_cobrador,
		   cod_vendedor,
		   apartado,
		   e_mail
	  into _nombre_agente,
		   _telefono,
		   _cod_cobrador,
		   _cod_vendedor,
		   _apart_agt,
		   _email_agt
	  from agtagent
	 where cod_agente = _cod_agente;

	select usuario
	  into _user_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	--  Fechas de Procesos
	--let _fecha_vence      = _fecha_proceso + 10 ; --se inabilita para colocar fecha vencimiento una vez se imprima la carta
	let _fecha_proceso = _fecha_hoy ;
	let _ano = year(_vigencia_inic);
	let _marcar_entrega = "0";
	let _desmarca = "1";
	let _motivo_desmarca = "";
	let _fecha_desmarca = "";
	let _user_desmarca = "";
	let _fecha_vence = null;

	--  Estatus
	let _estatus = "G" ;	       -- Estatus: Generar Data
	let _renglon = _renglon + 1;
	
	{
	if (_cod_grupo = '00068' and _cod_contratante = '699702') or  (_cod_grupo = '00068' and trim(_cedula) = '3-NT-1-690') or  (_cod_grupo = '00068' and trim(_cedula) = '3-1-6906') then --Serafin Niño  CASO SD#5362:RGORDON:10/01/2023_: Ajustes en Proceso de Aviso de Cancelación para Cartera de Serafin Niño
		foreach
				select uni.cod_asegurado
				  into _cod_contratante
				  from emipouni uni
				 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
				 where no_poliza = _no_poliza
				  -- and no_unidad = '00001'
				  
				-- Datos del cliente de la poliza cuando es serafin toma el primer asegurado de la unidad
				select cedula,
					   nombre,
					   apartado,					   
					   telefono2,					   					   
					   telefono1							   
				  into _cedula,
					   _nombre_cliente,	
					   _apart_cli,					   					   
					   _tel2_cli,
					   _tel1_cli					   
				  from cliclien
				 where cod_cliente = _cod_contratante;	
				 
					let _email_cli = 'gerencia@serafinnino.com.pa';
					
				   exit foreach;
			   
	    end foreach
	end if
	}
	if (_cod_grupo = '00068' or _cod_grupo = '77978' ) then --CASO SD#6889:JEPEREZ:Proximo Tiraje: Ajustes en Proceso de Aviso de Cancelación para Cartera de Serafin Niño solo a grupos :  00068  SERAFIN NIÑO o 77978  ASOCIADOS SERAFIN NIÑO
			let _email_cli = 'gerencia@serafinnino.com.pa';
	end if
	
	let _valor = sp_sis265(_no_documento);
	if _valor = 1 then		--*****Poliza debe ser procesada por proceso de Nulidad, No debe entrar a Avisos.
		continue foreach;
	end if

	insert into avisocanc(
			no_aviso,
			no_documento,
			no_poliza,
			periodo,
			vigencia_inic,
			vigencia_final,
			cod_ramo,
			nombre_ramo,
			nombre_subramo,
			cedula,
			nombre_cliente,
			saldo,
			por_vencer,
			exigible,
			corriente,
			dias_30,
			dias_60,
			dias_90,
			dias_120,
			dias_150,
			dias_180,
			cod_acreedor,
			nombre_acreedor,
			cod_agente,							    
			nombre_agente,					    
			porcentaje,							    
			telefono,							    
			cod_cobrador,						    
			cod_vendedor,						    
			apartado,
			fax_cli,
			tel1_cli,
			tel2_cli,
			apart_cli,
			email_cli,
			cod_formapag,   
			nombre_formapag,
			cobra_poliza,
			cod_contratante,
			estatus,
			user_proceso,
			fecha_proceso,
			fecha_vence,
			prima,
			ano,
			user_cobrador,
			desmarca,       
			user_desmarca,  
			motivo_desmarca,
			fecha_desmarca,
			renglon,
			estatus_poliza,
			marcar_entrega,
			nombre1,  
			cargo1,   
			usuario1, 
			nombre2,  
			cargo2,   
			usuario2, 											 																			 					       		    
			cancela,
			impreso)
	values(	_no_aviso,
			_no_documento,
			_no_poliza,
			_periodo,
			_vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_nombre_ramo,
			_nombre_subramo,
			_cedula,
			_nombre_cliente,
			_saldo,
			_por_vencer,
			_exigible,
			_corriente,
			_dias_30,
			_dias_60,
			_dias_90,
			_dias_120,
			_dias_150,
			_dias_180,
			_cod_acreedor,
			_nombre_acreedor,   	
			_cod_agente,							    
			_nombre_agente,					    
			_porcentaje,							    
			_telefono, 
			_cod_cobrador, 
			_cod_vendedor, 
			_apart_agt, 
			_fax_cli, 
			_tel1_cli, 
			_tel2_cli, 
			_apart_cli, 
			_email_cli, 
			_cod_formapag, 
			_nombre_formapag,
			_cobra_poliza,
			_cod_contratante,
			_estatus,
			_user_proceso,
			_fecha_proceso,
			_fecha_vence,
			_prima_orig,
			_ano,
			_user_cobrador, 
			_desmarca, 
			_user_desmarca,
			_motivo_desmarca, 
			_fecha_desmarca, 
			_renglon, 
			_estatus_poliza, 
			_marcar_entrega,
			_nombre1,  
			_cargo1,   
			_usuario1, 
			_nombre2,  
			_cargo2,   
			_usuario2,
			_cancela,
			_impreso						 											 																			 					       		    						 
			);
end foreach
--commit work;
return 0,"Actualizacion Exitosa";
end procedure;