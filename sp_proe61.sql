-- Cartas de  Corredor SALE (1),  Corredor SALE (2) y Acreedor (3)  - BITACORA
-- Creado    : 10/02/2012 
-- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe61;
create procedure sp_proe61(
a_documento	char(20),
a_compania	char(3)	default '001',
a_carta		char(1)	default '1',
a_valor		char(5),
a_user		char(15))
returning   varchar(100),	--desc_cia 
			char(1),		--carta				
			varchar(100),	--title_carta			
			char(20),		--poliza				
			char(3),		--compania			
			char(5),		--valor				
			date,			--fecha_actual      
			varchar(100),	--name_asegurado		
			varchar(100),	--agente_saliente		
			varchar(100),	--agente_nombrado		
			varchar(100),	--fecha_aniversario	
			varchar(100),	-- name_acredor		
			varchar(100),	-- fecha_aviso										 
			varchar(100),	--name_ramo			
			varchar(50),	--nombre1				
			char(50),		--cargo1				
			char(15),		--usuario ingreso				
			char(10),		-- no_poliza
			char(5);		-- no_endoso

define _fecha_aniversario	varchar(100);
define _agente_saliente		varchar(100);
define _agente_nombrado		varchar(100);
define _name_asegurado		varchar(100);
define _name_acredor		varchar(100);
define _fecha_aviso			varchar(100);
define _title_carta			varchar(100);
define _name_ramo			varchar(100);
define _desc_cia			varchar(100);
define _nombre1				varchar(50);
define _cargo1				char(50);		
define _windows_user		char(15);
define _arg_pol_firma		char(10);
define _contratante			char(10);
define _no_poliza			char(10);
define _poliza				char(10);
define _cod_agente_pol		char(5);
define _no_endoso			char(5);
define _valor				char(5);
define _cod_ramo			char(3);
define _compania			char(3);
define _carta				char(1);
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_actual		date;
define _fecha_15dh			date;
define _vig_salud			date;
define _fecha				date;
define _ramo_sis			smallint;
define _cnt					integer;

set isolation to dirty read;

-- Crear la tabla													
{CREATE TEMP TABLE tmp_proe61(										
		desc_cia				 CHAR(100),							
		carta					 CHAR(1),							
		title_carta				 CHAR(100),							
		poliza					 CHAR(20),							
		compania				 CHAR(3),							
		valor					 CHAR(5),							
		fecha_actual             DATE, 
		name_asegurado			 VARCHAR(100), 
		agente_saliente			 VARCHAR(100), 
		agente_nombrado			 VARCHAR(100), 
		fecha_aniversario		 VARCHAR(100), 
		name_acredor			 VARCHAR(100), 
		fecha_aviso				 VARCHAR(100),
		name_ramo				 VARCHAR(100), 
	    Nombre1					 VARCHAR(50),
	    Cargo1					 CHAR(50)		     				
		) WITH NO LOG;}

{define _error	   			     integer;
define  _error_isam 			 integer;
define  _error_desc 			 char(50);
set isolation to dirty read;
begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || ' ' || trim(_error_desc);
end exception}

--SET DEBUG FILE TO 'sp_proe61.trc'; 
--TRACE ON; 

set isolation to dirty read; 
let _cnt = 0;

select count(*) 
  into _cnt
  from emipomae
 where no_documento = a_documento
   and actualizado  = 1
   and nueva_renov = 'R'
   and serie > year(current);

if _cnt > 1 then
	let _no_poliza    = sp_sis398(a_documento);
else
	let _no_poliza    = sp_sis21(a_documento);
end if

let _fecha_actual = sp_sis26();
let _compania = a_compania;
let _desc_cia = sp_sis01(a_compania);
let _valor = trim(a_valor);
let _carta = a_carta;

let _fecha_aniversario = '';
let _agente_saliente = '';
let _agente_nombrado = '';
let _name_asegurado = '';
let _arg_pol_firma = '';
let _name_acredor = '';
let _title_carta = '';
let _fecha_aviso = '';
let _name_ramo = ''; 		
let _nombre1 = '';
let _cargo1 = '';
let _fecha_15dh = null;
let _fecha = null;

if a_carta = '1' then

	foreach with hold
		select cod_agente
		  into _cod_agente_pol
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
    end foreach

	let _title_carta = 'CORREDOR';

	select trim(nombre)
	  into _agente_nombrado
	  from agtagent
	 where cod_agente = _cod_agente_pol;

	select trim(nombre)
	  into _agente_saliente
	  from agtagent
	 where cod_agente = a_valor;
elif a_carta = '2' then

	foreach with hold
		select cod_agente
		  into _cod_agente_pol
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	let _title_carta = 'CORREDOR';

	select trim(nombre)
	  into _agente_nombrado
	  from agtagent
	 where cod_agente = a_valor;

	select trim(nombre)
	  into _agente_saliente
	  from agtagent
	 where cod_agente = _cod_agente_pol;
elif a_carta = '3' then

	let _title_carta = 'ACREEDOR';

	select trim(nombre)
	  into _name_acredor
	  from emiacre
	 where cod_acreedor = a_valor;

	call sp_sis397(_fecha_actual,15) returning _fecha_15dh; 		
	call sp_sis20(_fecha_15dh) returning _fecha_aviso;
end if

select cod_contratante,
	   cod_ramo,
	   vigencia_inic,
	   vigencia_final
  into _contratante,
	   _cod_ramo,
	   _vigencia_inic,
	   _vigencia_final 
  from emipomae
 where no_poliza = _no_poliza; 

select nombre
  into _name_asegurado
  from cliclien
 where cod_compania = a_compania
   and cod_cliente = _contratante; 

select trim(nombre),
	   ramo_sis
  into _name_ramo,
	   _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo; 

if _ramo_sis in (5,6,9) then
	let _vig_salud = mdy(month(_vigencia_inic),day(_vigencia_inic),year(_fecha_actual));
	let _fecha = _vig_salud;

	if _fecha <= today then
		let _fecha = mdy(month(_vigencia_inic),day(_vigencia_inic),year(today));
		let _fecha = _fecha + 1 units year;
	end if
else
	let _fecha = _vigencia_final;
end if 

call sp_sis20(_fecha) returning _fecha_aniversario;

select valor_parametro
  into _windows_user
  from inspaag
 where codigo_compania = a_compania
   and aplicacion = 'PRO'
   and version = '02'
   and codigo_parametro = 'firma_k_rta';

select trim(valor_parametro)
  into _arg_pol_firma
  from inspaag
 where codigo_compania = a_compania
   and aplicacion = 'PRO'
   and version = '02'
   and codigo_parametro = 'para_firma';

select cargo,
	   descripcion
  into _cargo1,
	   _nombre1
  from insuser
 where windows_user = _windows_user;

let _no_endoso = '00000';

insert into bitcarta(	  -- registra una bitacora
		desc_cia,				
		carta,				
		title_carta,			
		poliza,				
		compania,			
		valor,				
		fecha_actual,     	
		name_asegurado,			
		agente_saliente,			
		agente_nombrado,			
		fecha_aniversario,	
		name_acredor,			
		fecha_aviso,				
		name_ramo,				
		nombre1,					
		cargo1,
		f_aniversario,
		f_aviso_hipot,
		user_print)
values(	_desc_cia,				
		_carta,					
		_title_carta,				
		a_documento,					
		_compania,				
		_valor,					
		_fecha_actual,     		
		_name_asegurado,			
		_agente_saliente,			
		_agente_nombrado,			
		_fecha_aniversario,		
		_name_acredor,			
		_fecha_aviso, 				
		_name_ramo,	 			
		_nombre1,		 			
		_cargo1,
		_fecha,
		_fecha_15dh,
		a_user);

return	_desc_cia,			
		_carta,				
		_title_carta,		
		a_documento,				
		_compania,			
		_valor,				
		_fecha_actual,     		
		_name_asegurado,		
		_agente_saliente,	
		_agente_nombrado,	
		_fecha_aniversario,	
		_name_acredor,			
		_fecha_aviso, 			
		_name_ramo,	 		
		_nombre1,		 	
		_cargo1,
		a_user,
		_arg_pol_firma, --_no_poliza, solicitud: georgina que no refleje la firma de las sucursales sino siempre la de produccion.
		_no_endoso with resume;	
end procedure;