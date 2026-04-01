-- Procedure que actualiza la información del cliente 
-- 
-- Creado    : 13/07/2021 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite04;		

create procedure "informix".sp_emite04(	a_cod_cliente char(10),
										a_representante_legal char(80), 	
										a_nombre_comercial char(80),
										a_aviso_operacion char(20),
										a_actividad_dedica char(30),		
										a_nombre char(100),
										a_nombre_razon char(100),	
										a_tipo_persona	char(1),	
										a_nombre_original char(100),		
										a_aseg_primer_nom char(100),		
										a_aseg_segundo_nom char(40),		
										a_aseg_primer_ape char(40),		
										a_aseg_segundo_ape char(40),		
										a_aseg_casada_ape char(40),		
										a_cliente_pep smallint,		
										a_profesion varchar(50),				
										a_nacionalidad char(20),		
										a_cod_ocupacion char(3),         
										a_ced_provincia	char(2),		
										a_ced_inicial char(2),			
										a_ced_tomo char(9),				
										a_ced_folio	char(9),			
										a_ced_asiento char(7),			
										a_digito_ver char(2),				
										a_pais_residencia varchar(20),		
										a_direccion_laboral varchar(80),		
										a_fecha_aniversario	date,	
										a_e_mail char(50),					
										a_sexo char(1),		
										a_direccion_1 varchar(50),		
										a_direccion_cob varchar(200),         
										a_telefono1 char(10),				
										a_telefono2 char(10),				
										a_celular  char(10),
										a_celular2 char(10) default null)
								returning integer,
										  char(100);

define _error_desc	char(100);
define _error_char	char(7);
define _error_isam	integer;
define _error		integer;

begin
on exception set _error, _error_isam, _error_desc
	let _error_char = cast(_error as char(7));
	return _error, _error_desc;									   
end exception

set isolation to dirty read;

	Update cliclien 
	   SET representante_legal		    = a_representante_legal, 
           nombre_comercial				= a_nombre_comercial,
           aviso_operacion				= a_aviso_operacion,
           actividad_dedica				= a_actividad_dedica,	
           nombre						= a_nombre,
           nombre_razon					= a_nombre_razon,	
           tipo_persona					= a_tipo_persona,	
           nombre_original				= a_nombre_original,	
           aseg_primer_nom				= a_aseg_primer_nom,	
           aseg_segundo_nom				= a_aseg_segundo_nom,	
           aseg_primer_ape				= a_aseg_primer_ape,		
           aseg_segundo_ape				= a_aseg_segundo_ape,	
           aseg_casada_ape				= a_aseg_casada_ape,		
           cliente_pep					= a_cliente_pep,		
           profesion					= a_profesion,		
           nacionalidad					= a_nacionalidad,		
           cod_ocupacion                = a_cod_ocupacion,         
           ced_provincia				= a_ced_provincia,		
           ced_inicial					= a_ced_inicial,			
           ced_tomo						= a_ced_tomo,				
           ced_folio					= a_ced_folio,			
           ced_asiento					= a_ced_asiento,			
           digito_ver					= a_digito_ver,			
           pais_residencia				= a_pais_residencia,	
           direccion_laboral			= a_direccion_laboral,
           /*fecha_aniversario			= a_fecha_aniversario,*/	
           e_mail						= a_e_mail,				
           sexo							= a_sexo,		
           direccion_1					= a_direccion_1,		
           direccion_cob                = a_direccion_cob,   
		   direccion_2                  = a_direccion_cob,  		   
           telefono1 					= a_telefono1,			
           telefono2 					= a_telefono2,			
           celular						= a_celular,
		   fax                          = a_celular2
	 Where cod_cliente 					= a_cod_cliente;		

end
return 0, "Actualizacion exitosa";	
end procedure;