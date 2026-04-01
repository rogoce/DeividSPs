-- Registra excel envio de parmailsend y parmailcomp
-- Creado    : 21/08/2020 -- Henry Girón
-- Execute procedure sp_log033('01708_20200819')

drop procedure ap_cod_tipo45;
create procedure ap_cod_tipo45(
)

returning integer, varchar(30);

Define _html_body1	 Lvarchar(max);
define _cod_acreedor		char(5);
define _nom_acreedor		varchar(50);
define _email       	    varchar(50);
define _descripcion			varchar(30);
define _email_aseg			char(384);

define _cod_cliente			char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _exigible			dec(10,2);
define _ramo_sis			smallint;
define _error				smallint;
define _error_isam			smallint;
define _secuencia			integer;
define _secuencia2			integer;
define _fecha_suspension	date;
define _fecha_hoy_char	    char(8);
define _fecha_hoy		    date;
define _html			    char(3000);

define _no_documento		char(20); 
define _n_ramo      	    varchar(50);
define _no_factura			char(10); 
define _n_cliente       	varchar(100);
define _cedula     	        varchar(50);
define _n_corredor      	varchar(50);
define _tipo_endoso      	varchar(50);
define v_filtros       	    varchar(255);

define a_html_body		    char(512);
define a_email_cc		    char(100);
define a_adjunto		    smallint;
define _renglon				smallint;
define _cnt                 smallint;
define _no_endoso			char(5); 


set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception

  
--set debug file to "sp_log033e_fail.trc";  
--trace on;

let a_html_body = '';
let _html_body1 = '';
let _error       = 0;
let _renglon = 0;
let _descripcion = 'Actualizacion Exitosa ...';
call sp_sis40() returning _fecha_hoy;


let _fecha_hoy = '27/09/2021';

foreach
select distinct a.secuencia, b.cod_acreedor
into _secuencia, _cod_acreedor
from parmailsend a,   emiacre b
where a.cod_tipo = '00045'  and a.enviado = 3
and date(a.date_added) = _fecha_hoy
and  b.activo = 1 and a.email = b.email
and  a.html_body like trim(b.nombre) || '%'
order by a.secuencia


	let _renglon = 0;	
	let _secuencia2 = 0;
	let _n_cliente = '';
	let _no_documento = '';
	

	select max(secuencia)
	  into _secuencia2
	  from parmailcomp;

	if _secuencia2 is null then
		let _secuencia2 = 0;
	end if

	let _secuencia2 = _secuencia2 + 1;
    let _renglon = _renglon + 1;
	
	insert into parmailcomp(
			secuencia,
			renglon,
			mail_secuencia,
			no_remesa,
			asegurado,
			no_documento,
			fecha)
	values(	_secuencia2,
	        _renglon,
			_secuencia,
			_cod_acreedor,
			_n_cliente,
			_no_documento,
			_fecha_hoy);
			
			
			
		return  _secuencia2,_cod_acreedor			
			with resume;			

	  
end foreach	

return _error, _descripcion;
end
end procedure;