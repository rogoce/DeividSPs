-- Ingreso a parmailsend para ser enviado por correo
-- CARTA DE POLIZA NUEVA Y RENOVACION
-- ANGEL TELLO 04/12/2013
--se excluye coas min  Armando, 14/04/2015
--execute procedure sp_pro867('','N')


drop procedure ap_pro867;
create procedure ap_pro867()
returning	smallint,
			char(30);

define ls_e_mail		char(384);
define _html_body		char(100);
define r_descripcion	char(30);
define _corredor		char(5);
define _cod_tipoprod	char(3);
define _cod_ramo		char(3);
define _cod_contratante char(10);
define _no_documento    char(20);
define v_tipo_envio		char(10);
define r_error_isam		smallint;
define _carta_bienv		smallint;
define r_error			smallint;
define _fronting	    smallint;
define _tipo_notif		smallint;
define _adj_file        smallint;
define _adjunto         smallint;
define _cnt             smallint;	
define _secuencia2		integer;
define _secuencia		integer;
define _no_poliza       char(10);

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

LET r_error       = 0;
LET _cnt          = 0;
LET _adjunto      = 0;
LET _adj_file     = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

foreach
	select secuencia 
	  into _secuencia
	  from parmailsend 
	  where cod_tipo in ('00030','00031') 
		and secuencia >= 2812190 and email = ""

	select no_remesa
	  into _no_poliza
	  from parmailcomp
	 where mail_secuencia = _secuencia;
	
	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let ls_e_mail = '';

	call sp_sis163(_cod_contratante) returning ls_e_mail;

	if ls_e_mail is null or ls_e_mail = '' then
		continue foreach;
	end if

	update parmailsend
	   set email = ls_e_mail,
	       enviado = 0
     where secuencia = _secuencia;
end foreach

return r_error, r_descripcion;

end
end procedure;