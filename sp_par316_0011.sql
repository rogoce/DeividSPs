-- Procedimiento: Genera el html body y la secuencia del envio de Avisos 
-- Solo para corredores: Permite adjuntar todos los avisos en archivo separado. 
-- Creado       : 15/11/2010 - Autor: Henry Giron 
-- execute procedure sp_par316_0011('00011','00014') 

DROP PROCEDURE sp_par316_0011;
CREATE PROCEDURE "informix".sp_par316_0011(
a_cod_tipo	   CHAR(5),
a_cod_avican   CHAR(10))
RETURNING      SMALLINT,
               CHAR(30);

Define _secuencia1		integer;
Define _secuencia2		integer;
Define _anexar			smallint;
Define _adjunto			smallint;
Define _ciclo           smallint;
Define _html_body		char(512);
Define _email_archivo   char(100);
Define _email_055       char(100);
define _error			integer; 
define _error_isam		integer; 
define _error_desc		char(100); 
Define _lenght			integer; 
Define _cantidad		smallint;
Define _renglon 		smallint;
Define _cod_agente      char(5);
Define _email_corr      char(100);

BEGIN
ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc; 
END EXCEPTION

SET ISOLATION TO DIRTY READ; 
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";

-- set debug file to "sp_par316.trc"; 
-- trace on;
LET _error       = 0; 
LET _error_desc = 'Actualizacion Exitosa ...'; 
{
00011	Aviso de cancelacion - Corredor  -- Para que cada carta salga en un PDF diferente en el mismo correo.
}
if a_cod_tipo = "00011" then
   let _anexar = 1;			-- Mensaje texto dinamico + Carta de Aviso 
end if

let _secuencia1 = 0;
let _secuencia2 = 0;
let _adjunto    = 0;
let _html_body  = "";
let _ciclo      = 1;
let _cantidad   = 0;

--datos de html_body
Select max(secuencia) + 1
  into _secuencia2
  from parmailsend;

foreach	
	select cod_agente, count(renglon) 
	  into _cod_agente, _anexar
      from avisocanc where no_aviso = a_cod_avican and estatus <> 'Y'  and desmarca = 1	and fecha_imprimir = today
	 group by cod_agente 
	 order by cod_agente desc

	select trim(e_mail)
	  into _email_corr
	  from agtagent
	 where cod_agente = _cod_agente;

	   let _email_corr = 'hgiron@asegurancon.com';
foreach	
	select renglon
	  into _renglon
      from avisocanc  
     where no_aviso = a_cod_avican
       and estatus <> 'Y' 
       and desmarca = 1
	   and cod_agente  = _cod_agente
	 order by renglon desc

	Select html_body,
		   adjunto
	  into _html_body,
		   _adjunto
	  from parmailsend
	 where cod_tipo  = a_cod_tipo
	   and email	 = _email_corr
	   and secuencia = _secuencia2
	   and enviado	 = 0;

		if _adjunto is null then
			let	_adjunto = 0;
       end if
		if _html_body is null then
			let	_html_body = "";
	   end if

	   let _adjunto = _adjunto + 1;

		if _adjunto > 1 then
			let _html_body = trim(_html_body) || '<br><img src=cid:' ||  _secuencia2 || '_' || cast(_adjunto as char(1)) || '.jpg width=850 height=1100>';
			Update parmailsend
			   set html_body	= _html_body,
			   	   adjunto		= _adjunto
			 where secuencia	= _secuencia2;
	  else
				let _html_body = "<html><img src=cid:" ||  _secuencia2 || ".jpg width=850 height=1100>" || "<br><img src=cid:" || _secuencia2 || "_1.jpg width=850 height=1100>";
			Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
			Values (a_cod_tipo, _email_corr, 0, _adjunto, _html_body, _secuencia2);
	  end if

			Select max(secuencia) + 1
			  into _secuencia1
			  from parmailcomp;

			insert into parmailcomp (secuencia,no_remesa,renglon,mail_secuencia)
			values(_secuencia1,a_cod_avican,_renglon,_secuencia2);

	end foreach
end foreach

RETURN _error, _error_desc  WITH RESUME;

END

END PROCEDURE