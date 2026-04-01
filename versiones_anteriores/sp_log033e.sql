-- Registra excel envio de parmailsend y parmailcomp
-- Creado    : 21/08/2020 -- Henry Girón
-- Execute procedure sp_log033('01708_20200819')

drop procedure sp_log033e;
create procedure sp_log033e(
a_cod_tipo		    char(5),
a_cod_acreedor		char(5),
a_email       	    varchar(50),
a_desde             date,
a_hasta             date
)

returning smallint, varchar(30);

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

if a_cod_acreedor is null then
	return 0,'';  -- condicion de si no esta completo con el correo no se envia. JEPEREZ 01/10/2020.
end if

let _cnt = 0;
select count(*)
  into _cnt
  from emiacre
 where email is not null
   and cod_acreedor = a_cod_acreedor;

if _cnt is null then
	let _cnt = 0;
end if
   
if _cnt = 0 then
	return 0,'';  -- condicion de si no esta completo con el correo no se envia. JEPEREZ 01/10/2020.
end if      

drop table if exists temp_acreedor_html;
select *
  from temp_acreedor
  into temp temp_acreedor_html;
  
--set debug file to "sp_log033.trc";  
--trace on;
let a_html_body = '';
let _html_body1 = '';
let _error       = 0;
let _renglon = 0;
let _descripcion = 'Actualizacion Exitosa ...';
call sp_sis40() returning _fecha_hoy;
let _fecha_hoy_char = to_char(_fecha_hoy,"%Y%m%d");

select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

	select trim(html),trim(sender)
	  into _html,a_email_cc
	  from parmailtipo
	 where cod_tipo = a_cod_tipo;
	 
	 if a_cod_tipo = '00044' then
		--Let  _html_body1 = trim(_html_body1) ||'%_nombre%</p><p></p></td></tr><tr><td>';
		--Let  _html_body1 = trim(_html_body1) ||'<p>Reciba(n) saludos cordiales de parte de Aseguradora Anc&oacute;n, S.A.; en base a la informaci&oacute;n contenida en las p&oacute;lizas atendiendo a la Acreencia Hipotecaria, adjuntamos el REPORTE DE POLIZAS - ACREEDOR, en el que podr&aacute; encontrar las p&oacute;lizas renovadas y emitidas nuevas DESDE %_desde% - HASTA %_hasta% .</p>';
		Let  _html_body1 = '%_nombre%</span></p><p></p></td></tr><tr><td><p>Reciba(n) saludos cordiales de parte de Aseguradora Anc&oacute;n, S.A.; en base a la informaci&oacute;n contenida en las p&oacute;lizas atendiendo a la Acreencia Hipotecaria, adjuntamos el <b>REPORTE DE POLIZAS - ACREEDOR</b>, en el que podr&aacute; encontrar el listado de p&oacute;lizas renovadas <b>DESDE %_desde% HASTA %_hasta%</b> .</p>';
	else
		--Let  _html_body1 = trim(_html_body1) ||'%_nombre%</p><p></p></td></tr><tr><td>';
		--Let  _html_body1 = trim(_html_body1) ||'<p>Reciba(n) saludos cordiales de parte de Aseguradora Anc&oacute;n, S.A.; en base a la informaci&oacute;n contenida en las p&oacute;lizas atendiendo a la Acreencia Hipotecaria, adjuntamos el REPORTE DE ENDOSOS - ACREEDOR, en el que podr&aacute; encontrar los endosos emitidos DESDE %_desde% - HASTA %_hasta% .</p>';
		Let  _html_body1 = '%_nombre%</span></p><p></p></td></tr><tr><td><p>Reciba(n) saludos cordiales de parte de Aseguradora Anc&oacute;n, S.A.; en base a la informaci&oacute;n contenida en las p&oacute;lizas atendiendo a la Acreencia Hipotecaria, adjuntamos el <b>REPORTE DE ENDOSOS - ACREEDOR</b>, en el que podr&aacute; encontrar el listado de endosos emitidos <b>DESDE %_desde% HASTA %_hasta%</b> .</p>';
	end if
	
	foreach
	select trim(nom_acreedor)
	into _nom_acreedor
	from temp_acreedor_html		
	where cod_acreedor = a_cod_acreedor
	exit foreach;
	end foreach
	
	let a_adjunto = 1;

	let _html_body1 = replace(trim(_html_body1),'%_nombre%',trim(_nom_acreedor));	
	let _html_body1 = replace(trim(_html_body1),'%_desde%',trim(cast(a_desde as varchar(10))));	
	let _html_body1 = replace(trim(_html_body1),'%_hasta%',trim(cast(a_hasta as varchar(10))));	

	let a_html_body = trim(_html_body1);
	let a_email_cc = 'cod_106@asegurancon.com';

 
insert into parmailsend(
		cod_tipo,
		email,
		enviado,
		adjunto,
		html_body,
		secuencia,
		sender)
values(	a_cod_tipo,
		a_email,
		0,
		a_adjunto,
		a_html_body,
		_secuencia,
		a_email_cc);		
let _renglon = 0;		
foreach
select  no_documento,   
		n_ramo,
		no_factura,   
		n_cliente,
		cedula,
		n_corredor,
		no_poliza,
		no_endoso		
	into  _no_documento,   
		_n_ramo,
		_no_factura,   
		_n_cliente,
		_cedula,
		_n_corredor,
		_no_poliza,
		_no_endoso		
	from temp_acreedor_html	
   where cod_acreedor = a_cod_acreedor	
	order by n_ramo,n_cliente	

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
			a_cod_acreedor,
			_n_cliente,
			_no_documento,
			_fecha_hoy);
			
	Update endpool0
		Set estado_pro     = 2,   -- impreso desde logistica : 0-Adicion, 1-Produccion, 2-Logistica, 3-ReimpresionLog, 4-ReimpresionPro, 5-EliminoLog
			estado_log     = 2   -- cambia el estado de imrpesion de endosos de la polizas : 0-Ninguno, 1-Cliente, 2-Acreedor y 3-Ambos, 4-Botn Acreedor		        
		Where no_poliza    = _no_poliza
		  and no_endoso    = _no_endoso;
	  
end foreach	

return _error, _descripcion;
end
end procedure;