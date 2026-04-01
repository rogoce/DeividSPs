-- Procedimiento que Realiza la Carga a la tabla de cliclien desde Cotizacion

-- Creado    : 04/12/2018 - Autor: Federico Coronado

drop procedure sp_web50;

create procedure "informix".sp_web50(
ls_valor_nuevo 			char(10),	 --requerido de cotizacion
ll_nrocotizacion 		int,  
ls_tipopersona 			char(1),   	 --requerido de cotizacion
ls_tipocliente 			char(1),   
ls_primernombre 		char(40),  	 --requerido de cotizacion
ls_segundonombre 		char(40), 
ls_primerapellido 		char(40),  --requerido de cotizacion
ls_segundoapellido 		char(40),
ls_apellidocasada 		char(40),
ls_razonsocial 			char(100),    --requerido de cotizacion
ls_cedula 				char(30),        	 --requerido de cotizacion
ls_ruc 					char(30),           	 --requerido de cotizacion
ls_pasaporte 			char(30),     	 --requerido de cotizacion
ls_direccion 			char(50),     	 --requerido de cotizacion
ls_apartado 			char(20),      	 --requerido de cotizacion
ls_telefono1 			char(10),     	 --requerido de cotizacion
ls_telefono2 			char(10),     
ls_fax 					char(10),           
ls_email 				char(50),         
ld_fechaaniversario		date,
ls_sexo 				char(1),   
ls_usuario 				char(8),
ls_compania				char(3),
ls_agencia 				char(3),
ls_provincia 			char(2),
ls_inicial 				char(2),
ls_tomo 				char(7),
ls_folio 				char(7),
ls_asiento 				char(7),
ls_direccion2 			varchar(50) default null,
ls_celular 				varchar(10) default null,
ls_pais_residencia 		char(50),
ls_nacionalidad    		char(20),
ls_direccion_laboral	char(80),
ls_representante_legal  char(80),
ls_nombre_comercial     char(80),
ls_aviso_operacion		char(20),
ls_actividad_dedica     char(30),
ls_profesion	        char(50) default null,
ls_ocupacion     		char(3) default null,
ls_cliente_pep	     	smallint default 0,
ls_digito_ver           char(2) default null) 
RETURNING INTEGER;
--}

define _llave char(30);
define _nombre char(100);
define _espasaporte smallint;
define v_fecha_r date;
define _error smallint;


--- Actualizacion de Polizas

				
--SET DEBUG FILE TO "sp_sis372.trc"; 
--trace on;
SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

LET v_fecha_r = current;
if ls_segundonombre is null then
	let ls_segundonombre = " ";
end if 

if ls_segundoapellido is null then
	let ls_segundoapellido = " ";
end if 

if ls_apellidocasada is null then
	let ls_apellidocasada = " ";
end if 

let _espasaporte = 0;
let ls_primernombre = trim(ls_primernombre);
let ls_segundonombre = trim(ls_segundonombre);
let ls_primerapellido = trim(ls_primerapellido);
let ls_segundoapellido = trim(ls_segundoapellido);
let ls_apellidocasada = trim(ls_apellidocasada);
let _llave = null;

 IF ls_tipopersona = 'N' THEN
	IF ls_cedula IS NOT NULL AND ls_cedula <> '' THEN
	   LET _llave = trim(ls_cedula);
       let _espasaporte = 0;
	END IF
	IF ls_pasaporte IS NOT NULL AND ls_pasaporte <> '' THEN
	   LET _llave = trim(ls_pasaporte);
       let _espasaporte = 1;
	END IF
	let _nombre = trim(ls_primernombre) || ' ' || trim(ls_segundonombre) || ' ' || trim(ls_primerapellido) || ' ' || trim(ls_segundoapellido) || ' ' || trim(ls_apellidocasada);
	let ls_razonsocial = _nombre;
 ELSE
 	LET _llave = trim(ls_ruc);
	let _nombre = trim(ls_razonsocial);
	LET ls_primernombre = trim(ls_razonsocial);
 END IF 

if ls_tipocliente is null or  ls_tipocliente = '' Then
   let ls_tipocliente = '3';
end if

if ls_sexo is null or ls_sexo = '' Then
   let ls_sexo = 'M';
end if

IF ls_tipopersona = 'J' THEN
   let ls_sexo = 'N';
END IF

if ls_telefono1 is not null and trim(ls_telefono1) <> '' Then
   let ls_telefono1 = trim(ls_telefono1);
   let ls_telefono1 = ls_telefono1[1,3]||"-"||ls_telefono1[4,8];
end if

if ls_telefono2 is not null and trim(ls_telefono2) <> '' Then
   let ls_telefono2 = trim(ls_telefono2);
   let ls_telefono2 = ls_telefono2[1,3]||"-"||ls_telefono2[4,8];
end if

if ls_celular is not null and trim(ls_celular) <> '' Then
   let ls_celular = trim(ls_celular);
   let ls_celular = ls_celular[1,4]||"-"||ls_celular[5,8];
end if

if ls_ocupacion is null or ls_ocupacion = '' Then
   let ls_ocupacion = '038';
end if

if ls_cliente_pep is null or ls_cliente_pep = '' Then
   let ls_cliente_pep = 0;
end if

INSERT INTO cliclien(
	   cod_cliente,
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
	   direccion_cob,		
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
	   pais_residencia,
	   nacionalidad,
	   direccion_laboral,
	   representante_legal,
	   nombre_comercial,
	   aviso_operacion,
	   actividad_dedica,
	   cliente_pep,
	   profesion
	   )
VALUES(ls_valor_nuevo,		--cod_cliente
	   ls_compania,			--cod_compania
	   ls_agencia,			--cod_sucursal
	   '001',				--cod_origen
	   '00001',				--cod_grupo
	   '001',				--cod_clasehosp
	   '001',				--cod_espmedica
	   ls_ocupacion,		--cod_ocupacion
	   '029',				--cod_trabajo
	   '001',				--cod_actividad
	   '001',				--code_pais
	   '01',				--code_provincia
	   '01',				--code_ciudad
	   '01',				--code_distrito
	   '01',				--code_correg
	   _nombre,				--nombre
	   ls_razonsocial,		--nombre_razon
	   ls_direccion,		--direccion_1		null
	   ls_direccion2,  		--direccion_2		null
	   ls_apartado,			--apartado			null
	   ls_tipopersona,		--tipo_persona
	   ls_tipocliente,		--actual_potencial
	   _llave,			    --cedula			null
	   ls_telefono1,		--telefono1			null
	   ls_telefono2,		--telefono2			null
	   ls_email,    		--e_mail			null
	   ls_fax,				--fax				null
	   v_fecha_r,			--date_added
	   ls_usuario,			--user_added
	   0,					--de_la_red
	   0,					--mala_referencia
	   null,				--desc_mala_ref		null
	   ld_fechaaniversario, --fecha_aniversario	null
	   ls_sexo,				--sexo
	   ls_digito_ver,		--digito_ver		null
	   null,				--date_changed		null
	   null,				--user_changed		null
	   _nombre,				--nombre_original	null
	   trim(ls_provincia), 	--ced_provincia		null
	   trim(ls_inicial),   	--ced_inicial		null
	   trim(ls_tomo),		--ced_tomo			null
	   trim(ls_folio),		--ced_folio			null
	   trim(ls_asiento),	--ced_asiento		null
	   ls_primernombre,		--aseg_primer_nom	null
	   ls_segundonombre,	--aseg_segundo_nom	null
	   ls_primerapellido, 	--aseg_primer_ape	null
	   ls_segundoapellido,  --aseg_segundo_ape	null
	   ls_apellidocasada, 	--aseg_casada_ape	null
	   1,					--ced_correcta
	   _espasaporte,		--pasaporte			null
	   ll_nrocotizacion,	--cotizacion		null
	   1,					--de_cotizacion     null
	   ls_celular,
	   ls_pais_residencia,
	   ls_nacionalidad,
	   ls_direccion_laboral,
	   ls_representante_legal,
	   ls_nombre_comercial,
	   ls_aviso_operacion,
	   ls_actividad_dedica,
	   ls_cliente_pep,
	   ls_profesion
	   );
END
RETURN 0;
end procedure;