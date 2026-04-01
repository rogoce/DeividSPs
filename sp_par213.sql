--Conversion de la fecha de la tabla de CAJS

drop procedure sp_par213;
create procedure sp_par213(a_nombre 		char(50), 
						   a_apellido 		char(50),
						   a_nombre_razon 	char(100), 
						   a_cedula 		char(30), 
						   a_fecha_nac 		date, 
						   a_ced_prov 		char(2),
						   a_ced_av 		char(2),
						   a_ced_tomo 		char(4),
						   a_ced_folio		char(5),
						   a_direccion 		char(50), 
						   a_telefono1 		char(10), 
						   a_telefono2 		char(10),
						   a_celular 		char(10),
						   a_email 			char(50),
						   a_fax 			char(10), 
						   a_apartado 		char(20),
						   a_pasaporte 		smallint,
						   a_sexo 			char(1)	default null, 
						   a_digito_ver 	char(2) default null, 
						   a_usuario 		char(8) default null,
						   a_aseg_segundo_nom char(40) default null,
						   a_aseg_segundo_ape char(40) default null)
						  returning integer,
									char(50),
									char(10);
define _cod_cliente	char(10);
define _error_int	integer;
define _error_desc	char(50);

--set debug file to "sp_par213.trc";
--trace on;

begin
on exception set _error_int
	return _error_int, _error_desc, _cod_cliente;
end exception

let _error_desc  = "Buscando Numero del Cliente";
let _cod_cliente = sp_sis13("001", "PAR", "02", "par_cliente");

let _error_desc = "Creando el esquema del cliente";
let _error_int  = sp_sis81();

if _error_int <> 0 then
	drop table tmp_cliente;
	return _error_int, _error_desc, _cod_cliente;
end if

let _error_desc = "Actualizando datos del Cliente";

if a_usuario is null or trim(a_usuario) = "" then
	let a_usuario = "informix";
end if

if a_sexo is null or trim(a_sexo) = "" then
	let a_sexo = "M";
end if

if a_digito_ver is null or trim(a_digito_ver) = "" then
	let a_digito_ver = "0";
end if

update tmp_cliente
   set cod_cliente       = _cod_cliente,
       nombre            = a_nombre_razon,
       nombre_razon      = a_nombre_razon,
	   cedula            = a_cedula,
	   user_added        = a_usuario,
	   fecha_aniversario = a_fecha_nac,
	   user_changed      = a_usuario,
       nombre_original   = a_nombre_razon,
       aseg_primer_nom   = a_nombre,
       aseg_primer_ape   = a_apellido,
	   ced_provincia	 = a_ced_prov,
	   ced_inicial		 = a_ced_av,
	   ced_tomo			 = a_ced_tomo,
	   ced_asiento		 = a_ced_folio,
	   sexo              = a_sexo,
	   direccion_1		 = a_direccion,
	   telefono1		 = a_telefono1,
	   telefono2		 = a_telefono2,
	   celular  		 = a_celular,  
	   e_mail    		 = a_email,    
	   fax      		 = a_fax,      
	   apartado 		 = a_apartado, 
	   pasaporte		 = a_pasaporte,
	   digito_ver        = a_digito_ver,
	   aseg_segundo_nom  = a_aseg_segundo_nom,
	   aseg_segundo_ape  = a_aseg_segundo_ape;

let _error_desc = "Creando el cliente";
let _error_int  = sp_sis82();

if _error_int <> 0 then
	drop table tmp_cliente;
	return _error_int, _error_desc, _cod_cliente;
end if

end

drop table tmp_cliente;
let _error_desc  = "Actualizacion Exitosa";
return _error_int, _error_desc, _cod_cliente;

end procedure
