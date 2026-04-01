-- Procedimiento que Prepara la Información para crear un cliente de temis cod_tercero
-- Creado    : 04/12/2024 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_webtemis01;		
create procedure "informix".sp_webtemis01( a_cedula varchar(30), 
										   a_nombreI varchar(40), 
										   a_nombreII varchar(40), 
										   a_apellidoI varchar(40), 
										   a_apellidoII varchar(40), 
										   a_razon_social varchar(100), 
										   a_fecha_nac date, 
										   a_sexo char(1), 
										   a_email varchar(30), 
										   a_tipo_cliente char(1),
										   a_telefono1 char(10),
										   a_celular char(10),
										   a_direccion varchar(50))
returning	varchar(10);

define _existe 				int;
define _cod_cliente     	varchar(10);
define _provincia			char(2);
define _inicial				char(2);
define _asiento				char(7);										   										   
define _tomo				char(7);
define _null                char(5);
define _error               smallint;	


set isolation to dirty read;
--set debug file to "sp_webtemis01.trc";
--trace on;

if a_cedula is not null and trim(a_cedula) <> '' then
	call sp_sis108(a_cedula,1) returning _existe, _cod_cliente;
end if
if _existe = 0 then
	call sp_sis400(a_cedula) returning _provincia,_inicial,_tomo,_asiento;																	   
	let _null = null;

	let a_razon_social = trim(a_razon_social);
	call sp_sis175(a_telefono1) returning a_telefono1;
	--call sp_sis175(a_telefono2) returning a_telefono2;
	call sp_sis175(a_celular) returning a_celular;

	call sp_sis372( _cod_cliente,	--ls_valor_nuevo char(10),
		0,							--ll_nrocotizacion int,
		'N',						--ls_tipopersona char(1),
		'A',						--ls_tipocliente char(1),
		a_nombreI,					--ls_primernombre char(40),
		a_nombreII,					--ls_segundonombre char(40),
		a_apellidoI,				--ls_primerapellido char(40),
		a_apellidoII,				--ls_segundoapellido char(40),
		'',							--ls_apellidocasada char(40),
		a_razon_social,  			--ls_razonsocial char(100),
		a_cedula,					--ls_cedula char(30),
		'',		   					--ls_ruc char(30),
		'',		   					--ls_pasaporte char(30),
		a_direccion,				--ls_direccion char(50),
		_null,		   				--ls_apartado char(20), 
		a_telefono1,				--ls_telefono1 char(10),
		'',							--ls_telefono2 char(10),
		_null,		   				--ls_fax char(10),
		a_email,  					--ls_email char(50),
		a_fecha_nac,				--ld_fechaaniversario,
		a_sexo,		   				--ls_sexo char(1),
		'DEIVID',	   				--ls_usuario char(8),
		'001',		   				--ls_compania	char(3),
		'001',		   				--ls_agencia char(3),
		_provincia,	   				--ls_provincia char(2),
		_inicial,	   				--ls_inicial char(2),
		_tomo,		   				--ls_tomo char(7),
		'',			   				--ls_folio char(7),
		_asiento,	   				--ls_asiento char(7),
		'',			   				--ls_direccion2 varchar(50),
		a_celular)	   				--ls_celular varchar(10),
		returning _error;
		if _error <> 0 then
			return -1;
		end if
end if
return _cod_cliente;
end procedure