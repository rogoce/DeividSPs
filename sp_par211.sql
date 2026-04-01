-- Conversion de la tabla de CAJS

drop procedure sp_par211; 
create procedure sp_par211(a_poliza CHAR(10), a_usuario CHAR(8) default null)
returning integer,
          char(50);

define _numero			integer;
define _nombre			char(50);
define _apellido		char(50);
define _nombre_razon	char(100);
define _cedula			char(30);
define _fecha_nac		date;
define _codigo			char(10);
define _sexo            char(1);
define _ced_prov		varchar(7);
define _ced_av			char(2);
define _ced_av_nf			char(2);
define _ced_tomo		char(7);
define _ced_folio		char(7);
define _pasaporte       char(30);
define _direccion       char(50);
define _telefono1       char(10);
define _telefono2       char(10);
define _celular         char(10);
define _email           char(50);
define _fax             char(10);
define _apartado        char(20);
define _tipo_asegurado  char(2);
define _producto        char(5);
define _no_lote         char(10);
define _cod_cliente     char(10);
define _segundo_nombre  char(40);
define _segundo_apellido char(40);

define _ced_prov_int	integer;
define _ced_av_int	  	integer;
define _ced_tomo_int  	integer;
define _ced_folio_int 	integer;

define _error_int		integer;
define _error_desc		char(50);
define _contador		integer;
define _contstring      char(5);
define _es_pasaporte	smallint;
define _digito_ver      char(2);


--set debug file to "sp_par211.trc";
--trace on;

set isolation to dirty read;
let _contstring = "";

begin
on exception set _error_int
	--rollback work;
	return _error_int, trim(_contstring) || " " || trim(_error_desc);
end exception

let _error_desc = "Lectura de la Tabla uni_salud";

let _contador = 0;
let _es_pasaporte = 0;
let _segundo_nombre = null;
let _segundo_apellido = null;

foreach
 select nombre,
		apellido,
		sexo,
		fecha,
		ced_provincia,
		ced_tomo,
		ced_asiento,
		ced_inicial,
		pasaporte,     
		direccion,     
		telefono1,     
		telefono2,     
		celular,       
		email,         
		fax,           
		apartado,      
		tipo_asegurado,
		producto,
		digito_ver,
		segundo_nombre,
		segundo_apellido
  into  _nombre,
		_apellido,
		_sexo,            
		_fecha_nac,
		_ced_prov,
		_ced_tomo,
		_ced_folio,
		_ced_av,
		_pasaporte,     
		_direccion,     
		_telefono1,     
		_telefono2,     
		_celular,       
		_email,         
		_fax,           
		_apartado,      
		_tipo_asegurado,
		_producto,
		_digito_ver,
		_segundo_nombre,
		_segundo_apellido
   from clisalde
  where cod_cliente is null

 let _ced_prov_int     = null;
 let _ced_av_int       = null;
 let _ced_tomo_int     = null;
 let _ced_folio_int    = null;

  If _apellido Is Null Then
	let _apellido = "";
 End If
 
 let _nombre_razon = trim(_nombre) || " " || trim(_apellido);

 If _ced_prov Is Null Then
	let _ced_prov = "";
 End If
 If _ced_tomo Is Null Then
	let _ced_tomo = "";
 End If
 If _ced_folio Is Null Then
	let _ced_folio = "";
 End If

If (_pasaporte Is Null Or trim(_pasaporte) = "")   Then	 	 
	 if _ced_prov <> "" then
	 	let _cedula = trim(_ced_prov) || "-" || trim(_ced_tomo) || "-" || trim(_ced_folio);
 		If _ced_prov <> "" Then
			let _ced_prov_int     =	_ced_prov;
		End if
 		If _ced_tomo <> "" Then
			let _ced_tomo_int     =	_ced_tomo;
		End if
 		If _ced_folio <> "" Then
			let _ced_folio_int    =	_ced_folio;
		End if
			let _es_pasaporte = 0;
	 else
	 	--let _cedula = trim(_ced_prov) || "-" || trim(_ced_av) || "-" || trim(_ced_tomo) || "-" || trim(_ced_folio);
 		--If _ced_prov <> "" Then
		--	let _ced_prov_int     =	_ced_prov;
		--End if		
		let _cedula = trim(_ced_av) || "-" || trim(_ced_tomo) || "-" || trim(_ced_folio);		
 		--If _ced_av <> "" Then
		--	let _ced_av_int     =	_ced_av;
		--End if		
 		If _ced_tomo <> "" Then
			let _ced_tomo_int     =	_ced_tomo;
		End if
 		If _ced_folio <> "" Then
			let _ced_folio_int    =	_ced_folio;
		End if
	
	    --Se corrige creacion del cliente porque no es pasaporte SD 9737 Amado 14-03-2024
		--let _es_pasaporte = 1;  --SD#5323 Solicitud AMORENO 05/01/2023 Extranjero = 1

 
	 end if
	--let _es_pasaporte = 0;  se inactiva esta linea
 Else
	let _cedula = trim(_pasaporte);
	let _es_pasaporte = 1;
 End If

	let _contador = _contador + 1;
	let _contstring = _contador;

	let _error_int  = 0;
	let _error_desc = "Procesando Cliente " || _cedula;

	let _codigo = null;

   foreach
	select cod_cliente
	  into _codigo
	  from cliclien
	 where cedula = _cedula
		exit foreach;
	end foreach

	if _codigo is null then
	
		if _es_pasaporte = 1 then    --SD#5323 Solicitud AMORENO 05/01/2023 Extranjero = 1
			 let _ced_prov     = "";
			 let _ced_av_nf    = "";
			 let _ced_tomo     = "";
			 let _ced_folio    = "";
		else
			let _ced_av_nf = _ced_av; 
		end if
		
		call sp_par213(
		_nombre, 
		_apellido, 
		_nombre_razon, 
		_cedula, 
		_fecha_nac, 
		_ced_prov, 
		_ced_av_nf,  --_ced_av, 
		_ced_tomo, 
		_ced_folio,
		_direccion,     
		_telefono1,     
		_telefono2,     
		_celular,       
		_email,         
		_fax,           
		_apartado,      
		_es_pasaporte,
		_sexo,
		_digito_ver,
		a_usuario,
		_segundo_nombre,
		_segundo_apellido
		)
		returning _error_int, _error_desc, _codigo;
	else
		--SD#9061 JEPEREZ 27/01/2024 
	end if
	if _error_int = 0 then
		if _es_pasaporte = 0 Then
	 		 if _ced_prov <> "" then
		  		update clisalde									      
				   set cod_cliente = _codigo,
				       no_lote = a_poliza
				 where ced_provincia  = _ced_prov_int
				   and ced_tomo	= _ced_tomo_int
				   and ced_asiento = _ced_folio_int;
			else
                  If _ced_prov <> "" Then				
			  		update clisalde									      
					   set cod_cliente = _codigo,
					       no_lote = a_poliza
					 where ced_provincia  = _ced_prov_int
					   and ced_tomo	= _ced_tomo_int
					   and ced_asiento = _ced_folio_int
					   and ced_inicial = _ced_av;  
   			    Else
			  		update clisalde									      
					   set cod_cliente = _codigo,
					       no_lote = a_poliza
					 where ced_tomo	= _ced_tomo_int
					   and ced_asiento = _ced_folio_int
					   and ced_inicial = _ced_av;
                End If

			end if
		else
			If _ced_av <> ""  Then				   
				update clisalde									      
				   set cod_cliente = _codigo,
					   no_lote = a_poliza
				 where ced_tomo	= _ced_tomo_int
				   and ced_asiento = _ced_folio_int
				   and ced_inicial = _ced_av;
			Else
			
				update clisalde									      
				   set cod_cliente = _codigo,
					   no_lote = a_poliza
				 where pasaporte = _cedula;
			end if
		end if
	else
		return _error_int, trim(_contstring) || " " || trim(_error_desc);
	end if
end foreach          		
end
return 0, "Actualizacion Exitosa";

end procedure
