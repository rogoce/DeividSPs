-- Procedimiento que genera la información para cargar las tablas de sql factura electrónica
-- Creado:	14/12/2022 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_fe01;
create procedure sp_fe01(a_fecha date)
returning VARCHAR(10) as no_poliza,
		  VARCHAR(20) as no_documento,
		  char(5) as no_endoso,
		  decimal(16,2) as prima_neta,
		  decimal(16,2) as impuesto,
		  decimal(16,2) as prima_bruta,
		  char(1) as tipo_persona,
		  varchar(30)	as cedula, 
		  varchar(100) as nombre, 
		  varchar(50) as direccion,  
		  varchar(10) as celular,  
		  varchar(50) as e_mail,  
		  varchar(10) as telefono1,  
		  varchar(10) as telefono2,
		  varchar(100) as descripcion,
		  varchar(50) as nacionalidad,
		  char(5) as corregimiento,
		  char(2) as provincia,
		  char(2) as distrito,
		  char(2) as digito_verificador,
		  varchar(250) as comentario,
		  varchar(12) as no_factura, 
		  varchar(3) as cod_formapag; 
		  
define _no_documento 		char(20);
define _no_poliza 			char(10);
define _cod_endomov			char(3);
define _prima_neta			decimal(16,2);			 
define _impuesto			decimal(16,2); 
define _prima_bruta			decimal(16,2); 
define _cod_contratante		char(10);
define _tipo_persona		char(1);
define _cedula				varchar(30);
define _nombre_razon		varchar(100); 
define _direccion_1			varchar(50); 
define _celular				varchar(10); 
define _e_mail				varchar(50);  
define _telefono1			varchar(10); 
define _telefono2			varchar(10);
define _descripcion         varchar(100);
define _no_endoso			char(5);
define _nacionalidad		char(50);
define _code_correg			char(5);
define _code_provincia		char(2);
define _code_distrito		char(2);
define _digito_ver          char(2);
define _cod_tipoprod		char(3);
define _coanombre			varchar(100);
define _mayporccoas			decimal(16,2);
define _comentario          varchar(250);
define _no_factura          varchar(12);
define _cod_formapag        varchar(3);

--set debug file to "sp_fe01.trc";
--trace on;
set isolation to dirty read;
foreach 
	select a.no_poliza,
		   a.no_endoso,
		   a.no_documento, 
		   a.cod_endomov, 
		   a.prima_neta, 
		   a.impuesto, 
		   a.prima_bruta, 
		   cod_contratante,
		   a.cod_tipoprod,
		   a.no_factura,
		   a.cod_formapag
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,
		   _cod_endomov,
		   _prima_neta, 
		   _impuesto, 
		   _prima_bruta, 
		   _cod_contratante,
		   _cod_tipoprod,
		   _no_factura,
		   _cod_formapag
	from endedmae a
    inner join emipomae b on a.no_poliza = b.no_poliza
    inner join cliclien c on b.cod_contratante = c.cod_cliente
		where a.cod_tipoprod in ('001','005')
		and a.actualizado = 1
		and envio_fe = 0
		and a.prima_neta > 0
        and a.impuesto > 0
        --and c.tipo_persona <> 'N'
        and c.cedula not in('8-NT-1-12528','8-NT-2-10513','8-NT-1-22686','8-NT-2-4093','8-NT-1-13623','3-NT-1-6906','8-NT-2-10783','8-NT-2-8918')
		and a.no_documento in('1825-00142-01','1625-00027-01','1625-00030-01')
		and (fecha_emision >= '08/09/2025' and fecha_emision <= '22/09/2025')
		--and((a.vigencia_inic >= '01/09/2025' and a.vigencia_inic <= '03/09/2025') or (fecha_emision >= '01/09/2025' and fecha_emision <= '03/09/2025') or (fecha_emision >= '01/09/2025' and a.vigencia_inic <= '03/09/2025'))
		--and((a.vigencia_inic >= '03/09/2025' and a.vigencia_inic <= '03/09/2025') or (fecha_emision >= '03/09/2025' and a.vigencia_inic <= '03/09/2025'))
	
	let _comentario = "";
	let _mayporccoas = 0;
	let _coanombre = "";
	
	select nombre
	  into _descripcion
	  from endtimov 
	 where cod_endomov = _cod_endomov;	
	   
	select tipo_persona, 
	       cedula, 
		   nombre_razon, 
		   direccion_1, 
		   celular, 
		   e_mail,  
		   telefono1, 
		   telefono2,
		   nacionalidad,
		   code_correg,
           code_provincia,
           code_distrito,
		   digito_ver
	  into _tipo_persona,
		   _cedula,
		   _nombre_razon, 
		   _direccion_1, 
		   _celular, 
		   _e_mail,  
		   _telefono1, 
		   _telefono2,
		   _nacionalidad,
		   _code_correg,	
		   _code_provincia,	
		   _code_distrito,
           _digito_ver		   
	  from cliclien 
	 where cod_cliente = _cod_contratante;
	
	let _telefono1 = replace(_telefono1,'-','');
	let _telefono2 = replace(_telefono2,'-','');
	let _celular = replace(_celular,'-','');
	
	if _telefono1 is not null and trim(_telefono1) <> '' Then
	   let _telefono1 = trim(_telefono1);
	   let _telefono1 = _telefono1[1,3]||"-"||_telefono1[4,8];
	end if

	if _telefono2 is not null and trim(_telefono2) <> '' Then
	   let _telefono2 = trim(_telefono2);
	   let _telefono2 = _telefono2[1,3]||"-"||_telefono2[4,8];
	end if

	if _celular is not null and trim(_celular) <> '' Then
	   let _celular = trim(_celular);
	   let _celular = _celular[1,4]||"-"||_celular[5,8];
	end if
	 
	if _telefono1 is not null then
		if _telefono1[1] not between "0" and "9" or 
		   _telefono1[2] not between "0" and "9" or
		   _telefono1[3] not between "0" and "9" or
		   _telefono1[4] <> "-" or
		   _telefono1[5] not between "0" and "9" or
		   _telefono1[6] not between "0" and "9" or
		   _telefono1[7] not between "0" and "9" or
		   _telefono1[8] not between "0" and "9" or
		   _telefono1[9] <> " " or
		   _telefono1[10] <> " " then
			let _telefono1 = "";
		end if
	end if 
	
	if _telefono2 is not null then
		if _telefono2[1] not between "0" and "9" or 
		   _telefono2[2] not between "0" and "9" or
		   _telefono2[3] not between "0" and "9" or
		   _telefono2[4] <> "-" or
		   _telefono2[5] not between "0" and "9" or
		   _telefono2[6] not between "0" and "9" or
		   _telefono2[7] not between "0" and "9" or
		   _telefono2[8] not between "0" and "9" or
		   _telefono2[9] <> " " or
		   _telefono2[10] <> " " then
			let _telefono2 = "";
		end if
	end if
	
	if _celular is not null then
		if _celular[1] not between "0" and "9" or 
		   _celular[2] not between "0" and "9" or
		   _celular[3] not between "0" and "9" or
		   _celular[4] not between "0" and "9" or
		   _celular[5] <> "-" or
		   _celular[6] not between "0" and "9" or
		   _celular[7] not between "0" and "9" or
		   _celular[8] not between "0" and "9" or
		   _celular[9] not between "0" and "9" or
		   _celular[10] <> " " then
			let _celular = "";
		end if
	end if
	
	if trim(_digito_ver) = '' or _digito_ver is null then
		let _digito_ver = '00';
	end if
	 
	 if _nacionalidad is null or trim(_nacionalidad) = '' then
		select nacionalidad
		  into _nacionalidad
		  from ponderacion
		 where cod_cliente = _cod_contratante;
	 end if
	 
	if _cod_tipoprod = "001" then
		foreach
		 select a.nombre,
		        y.porc_partic_coas
		   into _coanombre, 
			    _mayporccoas
		   from endcoama y
		  inner join emicoase a on a.cod_coasegur = y.cod_coasegur
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		  order by y.porc_partic_coas desc
		  
		  let _comentario = trim(_comentario)|| " " ||trim(_coanombre) ||" " ||_mayporccoas|| "%. ";
		  
		end foreach;
	end if

	return _no_poliza,
		   _no_documento,
		   _no_endoso,
		   _prima_neta, 
		   _impuesto, 
		   _prima_bruta, 
		   _tipo_persona,
		   _cedula,
		   _nombre_razon, 
		   _direccion_1, 
		   _celular, 
		   _e_mail,  
		   _telefono1, 
		   _telefono2,
		   _descripcion,
		   _nacionalidad,
		   _code_correg,		
		   _code_provincia,	
		   _code_distrito,
		   _digito_ver,
		   _comentario,
		   _no_factura,
		   _cod_formapag
		WITH RESUME;
end foreach;
end procedure