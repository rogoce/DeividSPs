-- Para validar import de excel a carga de unidades en emision
-- Creado    : 06/03/2020 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A. execute procedure sp_par211v('0001450552','HGIRON') 

drop procedure sp_par211v;
create procedure sp_par211v(a_poliza CHAR(10), a_usuario CHAR(8) default null)
returning integer, char(50);

define _nombre			char(50);
define _apellido		char(50);
define _cedula			char(30);
define _fecha_nac		date;
define _sexo            char(1);
define _ced_prov		varchar(7);
define _ced_av			char(2);
define _ced_tomo		char(9);
define _ced_folio		char(9);
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
define _error_int		integer;
define _error_desc		char(50);
define _contador		integer;
define _contstring      char(5);
define _es_pasaporte	smallint;
define _digito_ver      char(2);

define _ced_prov_int	integer;
define _ced_av_int	  	integer;
define _ced_tomo_int  	integer;
define _ced_folio_int 	integer;

define _ls_ramo			char(3);
define v_fecha_nac		date;
define v_direccion      char(50);
define v_telefono1      char(10);
define v_telefono2      char(10);
define v_celular        char(10);
define v_email          char(50);	
define _flag	        smallint;

--set debug file to "sp_par211v.trc";
--trace on;

set isolation to dirty read;
let _contstring = "";
--begin work;

begin
on exception set _error_int
	--rollback work;
	return _error_int, trim(_contstring) || " " || trim(_error_desc);
end exception

let _error_desc = "Lectura del Archivo de Excel ";
let _contador = 0;
let _es_pasaporte = 0;
let _error_int = 0;
let _seg_apellido = "";
let _seg_nombre = "";

let _ls_ramo = '';
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

	let _ced_prov_int     = null;
	let _ced_av_int       = null;
	let _ced_tomo_int     = null;
	let _ced_folio_int    = null;
 
	let _contador = _contador + 1;
	let _contstring = _contador;
	 
	If _nombre Is Null or _nombre = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato del Nombre.';
		exit foreach;
	End If
	 
	If _apellido Is Null or _apellido = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato de Apellido.';
		exit foreach;
	End If 

	If _ced_prov Is Null  or _ced_prov = ""  Then
		let _ced_prov = "";
	End If
	If _ced_tomo Is Null  or _ced_tomo = ""  Then
		let _ced_tomo = "";
	End If
	If _ced_folio Is Null  or _ced_folio = ""  Then
		let _ced_folio = "";
	End If
	If _ced_av Is Null  or _ced_av = ""  Then
		let _ced_av = "";
	End If

	If (_pasaporte Is Null Or trim(_pasaporte) = "")   Then	 	 
		 if _ced_prov <> "" then
			--let _cedula = trim(_ced_prov) || trim(_ced_tomo) || trim(_ced_folio);  ---anterior no se guardaba sin guion		
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
			--let _cedula = trim(_ced_prov) || trim(_ced_av) || trim(_ced_tomo) || trim(_ced_folio); ---anterior no se guardaba sin guion		
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
			--let _ced_av_int       =	_ced_av;
			let _es_pasaporte = 1;  --SD#5323 Solicitud AMORENO 05/01/2023 Extranjero = 1
			let _cedula = trim(_cedula);
			
		 end if
		--let _es_pasaporte = 0; se inhabilita por nuevo cambio
	Else
		let _cedula = trim(_pasaporte);
		let _es_pasaporte = 1;
	End If
	 
	If trim(_cedula) Is Null or trim(_cedula) = "" Then	
		If _es_pasaporte = 0 Then
			let _error_int = 1;
			let _error_desc = 'Falta dato de la Cedula.';
			exit foreach;
		else
			let _error_int = 1;
			let _error_desc = 'Falta dato del Passaporte.';
			exit foreach;	
		End If	
	End If 
	 
	  If _sexo Is Null or _sexo = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato del Sexo.';
		exit foreach;
	End If
	 
	If _fecha_nac Is Null or _fecha_nac = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato de Fecha Nacimiento.';
		exit foreach;
	 End If  
	 
	 If _producto Is Null or _producto = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato del Producto.';
		exit foreach;
	 End If

	 If _tipo_asegurado Is Null or _tipo_asegurado = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato del Tipo de Asegurado.';
		exit foreach;
	 End If 
	 

 if _ls_ramo not in ('018','004','016') then 	 
 
	 If _direccion Is Null or _direccion = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato de la Direccion.';
		exit foreach;
	 End If 
	 
	 If _email Is Null or _email = "" Then	
		let _error_int = 1;
		let _error_desc = 'Falta dato de Email.';
		exit foreach;
	 End If  
	 
	 if (_telefono1 Is Null or _telefono1 = "" ) and (_telefono2 Is Null or _telefono2 = "" ) and (_celular Is Null or _celular = "" ) then
		let _error_int = 1;
		let _error_desc = 'Falta dato de Telefono o Celular.';
		exit foreach;
	 End If

 end if
 end foreach          		
end
return _error_int, trim(_error_desc)|| " - Fila: " || trim(_contstring) ;
end procedure