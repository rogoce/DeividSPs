-- Conversion de la tabla de CAJS

drop procedure sp_par211a; 

create procedure "informix".sp_par211a(a_poliza CHAR(10), a_usuario CHAR(8) default null)
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

define _ls_ramo			char(3);
define v_fecha_nac		date;
define v_direccion       char(50);
define v_telefono1       char(10);
define v_telefono2       char(10);
define v_celular         char(10);
define v_email           char(50);	
define _flag	smallint;

set debug file to "sp_par211.trc";
trace on;

set isolation to dirty read;
let _contstring = "";
--begin work;

begin
on exception set _error_int
	rollback work;
	return _error_int, trim(_contstring) || " " || trim(_error_desc);
end exception

let _error_desc = "Lectura de la Tabla uni_salud";
let _ls_ramo = '';
let _contador = 0;
let _es_pasaporte = 0;
let _flag = 0;

-- buscar tipo de ramo
select cod_ramo
  into _ls_ramo
  from emipomae
 where no_poliza = a_poliza;

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
		digito_ver      
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
		_digito_ver
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

 If _pasaporte Is Null Or trim(_pasaporte) = "" Then
	 if _ced_av is null or trim(_ced_av) = "" then
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
	 else
	 	let _cedula = trim(_ced_prov) || "-" || trim(_ced_av) || "-" || trim(_ced_tomo) || "-" || trim(_ced_folio);
		
		 if _ls_ramo in ('018','004','016') then 
			let _cedula = trim(_ced_av) || "-" || trim(_ced_tomo) || "-" || trim(_ced_folio);		--SD9061 JEPEREZ solo pérsonas
		 end if		
	 	
 		{If _ced_av <> "" Then
			let _ced_av_int     =	_ced_av;
		End if	}	
 		If _ced_prov <> "" Then
			let _ced_prov_int     =	_ced_prov;
		End if
 		If _ced_tomo <> "" Then
			let _ced_tomo_int     =	_ced_tomo;
		End if
 		If _ced_folio <> "" Then
			let _ced_folio_int    =	_ced_folio;
		End if
		--let _ced_av_int       =	_ced_av;
	 end if
	let _es_pasaporte = 0;
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
		call sp_par213(
		_nombre, 
		_apellido, 
		_nombre_razon, 
		_cedula, 
		_fecha_nac, 
		_ced_prov, 
		_ced_av, 
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
		a_usuario
		)
		returning _error_int, _error_desc, _codigo;
	end if

	if _error_int = 0 then
		if _es_pasaporte = 0 Then
	 		if _ced_av is null or trim(_ced_av) = "" then
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
{		  		update clisalde									      
				   set cod_cliente = _codigo,
				       no_lote = a_poliza
				 where cedula = _cedula;
{		  		update clisalde									      
				   set cod_cliente = _codigo,
				       no_lote = a_poliza
				 where ced_provincia  = _ced_prov_int
				   and ced_tomo	= _ced_tomo_int
				   and ced_asiento = _ced_folio_int
				   and ced_inicial = _ced_av;}
			end if
			
			 if _ls_ramo in ('018','004','016') then 
				let _cedula = trim(_cedula);		--SD9061 JEPEREZ solo pérsonas 
				
				drop table if exists tmp_cliente2;	
				select *
				  from cliclien
				 where trim(cedula) = trim(_cedula)
				  into temp tmp_cliente2;	
				  
			       let _flag = 0;
				select fecha_aniversario,
				       direccion_1,
					   telefono1,
					   telefono2,
					   celular,
					   e_mail
				  into v_fecha_nac,
				       v_direccion,
					   v_telefono1,
					   v_telefono2,
					   v_celular,
					   v_email           
				  from tmp_cliente2
				 where cedula = _cedula;				
				
				{ If v_fecha_nac Is Null or v_fecha_nac = "" Then	
					let v_fecha_nac = _fecha_nac ;
					let _flag = 1;
				 End If  }				 
				 If v_direccion Is Null or v_direccion = "" Then	
					let v_direccion = trim(_direccion);
					let _flag = 1;
				 End If 				 
				 If v_email Is Null or v_email = "" Then	
					let v_email = _email ;
					let _flag = 1;
				 End If  				 
				 if (v_telefono1 Is Null or v_telefono1 = "" )  then
					let v_telefono1 = _telefono1;
					let _flag = 1;
				 End If	
				 if (v_telefono2 Is Null or v_telefono2 = "" )  then
					let v_telefono2 = _telefono2;
					let _flag = 1;
				 End If					 
				 if (v_celular Is Null or v_celular = "" ) then
					let v_celular = _celular ;
					let _flag = 1;
				 End If	

				if _flag = 1 then
					update cliclien								      
					   set fecha_aniversario = v_fecha_nac,
						   direccion_1 = v_direccion,
						   telefono1 = v_telefono1,
						   telefono2 = v_telefono2,
						   celular = v_celular,
						   e_mail = v_email
					 where cedula = _cedula;
				end if				 
				 
			 end if					
		else
	  		update clisalde									      
			   set cod_cliente = _codigo,
			       no_lote = a_poliza
			 where pasaporte = _cedula;
		end if
	else
			
  --		rollback work;
		return _error_int, trim(_contstring) || " " || trim(_error_desc);

	end if

{	if _contador > 1000 then
		exit foreach;
	end if}

end foreach          		

end

--commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure
