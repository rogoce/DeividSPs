-- filtro de tipo
-- Creado    :01/09/2020 - Autor: Henry Giron 
drop procedure sp_log032;
create procedure "informix".sp_log032(a_secuencia integer)
returning char(3000),char(512),varchar(100);

define _cod_tipo		    char(5);
define _html			    char(3000);
define _html_body		    char(512);
define _no_documento	    varchar(20);
define _cod_pagador		    varchar(30);
define _no_remesa           char(10);
define _renglon             smallint;
define _fecha        		date;
define _fecha_hoy_char	    char(8);
define _ruta_file	        varchar(50);
define _ruta_completa	    char(512);
define _asunto              varchar(100);
define _opcion              varchar(100);
define _separador           char(8);


set isolation to dirty read;

begin

let _separador = "\";
--set debug file to "sp_log032.trc";      
--trace on;
let _asunto = '';
select cod_tipo,trim(html_body)
  into _cod_tipo,_html_body
  from parmailsend
 where secuencia = a_secuencia;
 
 let _opcion = '';
if _cod_tipo in ( '00044') then	
    let _opcion = 'POLIZAS';
end if
if _cod_tipo in ( '00045') then	
    let _opcion = 'ENDOSOS';
end if

select trim(html),asunto
  into _html,_asunto
  from parmailtipo
 where cod_tipo = _cod_tipo;
 
 select trim(valor_parametro)
   into _ruta_file
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion		= 'LOG'
   and version			= '02'
   and codigo_parametro	= 'bk_acre_log';

foreach
	select trim(no_documento),
		   asegurado,
		   fecha,
		   trim(no_remesa),
		   renglon
	  into _no_documento,
		   _cod_pagador,
		   _fecha,
		   _no_remesa,
		   _renglon
	  from parmailcomp
	 where mail_secuencia = a_secuencia
	 let _fecha_hoy_char = to_char(_fecha,"%Y%m%d"); 
	 let _opcion = trim(_opcion)||trim(_separador)||trim(_fecha_hoy_char)||trim(_separador);
	 let _ruta_completa = trim(_ruta_file)||trim(_opcion)||trim(_no_remesa)||'_'||trim(_fecha_hoy_char);
	 
	exit foreach;
end foreach  

if _cod_tipo in ( '00044','00045') then	
    let _html = replace(trim(_html),'%_filtro%',trim(_html_body));	
   	
end if

return _html,_ruta_completa,_asunto;

end
end procedure;