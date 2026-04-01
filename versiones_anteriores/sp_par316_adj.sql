-- Procedimiento: Genera el html body y la secuencia del envio de Avisos 
-- Creado       : 15/11/2010 - Autor: Henry Giron 
-- execute procedure sp_par316('00010','hgiron@hotmail.com','00003',1) 

DROP PROCEDURE sp_par316_adj;
CREATE PROCEDURE "informix".sp_par316_adj(
a_cod_tipo	   CHAR(5),
a_email		   CHAR(384),
a_cod_avican   CHAR(10),
a_renglon      SMALLINT)
RETURNING      SMALLINT,
               CHAR(30);

Define _secuencia1		integer;
Define _secuencia2		integer;
Define _secuencia3      integer;
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
Define _longitud		integer; 
define _no_documento	char(20); 
define _cod_agente      char(50);
Define _enviado			integer;
Define _user_proceso    char(15);
Define _email_jefe      char(50);
define _cnt             integer;
define li_flag          integer;
define _max_adjunto     integer;


let li_flag = 0;
let _max_adjunto = 0;

BEGIN
ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc; 
END EXCEPTION

SET ISOLATION TO DIRTY READ; 
-- return 0,"Realizado Exitosamente. En Base de prueba de Sistema."; 

 set debug file to "sp_par316.trc"; 
 trace on;
LET _error       = 0; 
LET _enviado     = 0;
LET _error_desc = 'Actualizacion Exitosa ...'; 

if a_email is null then
	return 0,'';
end if

if a_cod_tipo = '00014' then --Se Inactiva en espera de respuesta por parte de Cobros
	return 0,'';
end if
{
00010	Aviso de Cancelacion - Cliente 
00011	Aviso de cancelacion - Corredor 
00012	Aviso de cancelacion - Ultima Gestion : Aviso al cumplir las 48 horas
00013	Aviso de cancelacion - Cancelacion - Corredor 
00014	Aviso de cancelacion - Cancelacion - Archivo 

   LET _enviado = 4;		-- Caso de Avisarle al cumplir 48 horas.
   LET _enviado = 5;		-- Caso de Pagar morosidad en proceso diario realizado en la noche.

}
--if a_cod_tipo = "00011" then	 -- Henry: ver sp_par316_0011
--	RETURN _error, _error_desc;
--end if
let _anexar = 0;

if a_cod_tipo = "00010" then
   let _anexar = 1;			-- Mensaje texto dinamico + Carta de Aviso 
end if
if a_cod_tipo = "00011" then
   let _anexar = 1;			-- Mensaje texto dinamico + Carta de Aviso 
end if
if a_cod_tipo = "00012" then   -- TO gestor seleccionado 
   let _anexar = 1;			-- Mensaje texto dinamico + Estado Cta cliente 
   LET _enviado = 4;		-- Caso de Avisarl al cumplir 48 horas.
end if
if a_cod_tipo = "00013" then   -- TO cliente CC corredor   NO VA SE ASIGNARA AL SR: BERROCAL
   let _anexar = 3;			-- Mensaje texto + Carta de Aviso + Gestion x Vigencia + Endoso 
end if

{if a_cod_tipo = "00014" then   -- TO archivo 055 parcocue
   let _anexar = 3;			-- Mensaje texto + Carta de Aviso + Gestion x Vigencia + Endoso 
   --  cambiar el a_email por el email depto archivo
   let _email_archivo = "";
   foreach
	 select trim(email)
	   into _email_055
	   from parcocue
	  where cod_correo = "055"
		let _lenght = 0;
	    let _lenght = length(_email_archivo) + length(_email_055);
		 if _lenght < 100 then
			let _email_archivo = trim(_email_archivo) || trim(_email_055) || ";";
		else
			exit foreach;
	    end if
   end foreach
   if trim(_email_archivo) <> "" then
	  let a_email = _email_archivo ;
  end if
  let a_email = 'hgiron@asegurancon.com;' ;
end if}

let _secuencia1 = 0;
let _secuencia2 = 0;
let _adjunto    = 0;
let _html_body  = "";
let _ciclo      = 1;

--datos de html_body
Select max(secuencia) + 1
  into _secuencia2
  from parmailsend;

if a_cod_tipo = "00013" then
	select firma_end_canc
	  into _user_proceso
	  from parparam
	 where cod_compania = "001";

    select e_mail
	  into _email_jefe
      from insuser 
	 where usuario = _user_proceso;

        if _email_jefe is null then
	       let a_email = "cobros@asegurancon.com;" ;
	   else
	       let a_email = trim(_email_jefe)||"; cobros@asegurancon.com;" ;
	   end if
end if

if a_cod_tipo in ('00010','00011') then
          let li_flag = 0;
		  let _max_adjunto = 0;
	Select max(secuencia)
	  into _secuencia3
	  from parmailsend
	 where cod_tipo  = a_cod_tipo
	   and email	 = a_email
	   and enviado	 = 0
	   and nvl(adjunto,0) <= 70; 

	{Select max(adjunto)
	  into _max_adjunto
	  from parmailsend
	 where cod_tipo  = a_cod_tipo
	   and email	 = a_email
	   and enviado	 = 0 
	   and secuencia = _secuencia3 and adjunto > 0;	   -- control de envio que no acepta mas de 70 adjunto

	if _max_adjunto is null then 
		let _max_adjunto = 0;
	end if		   
	   
	   if _max_adjunto > 70 then
	     let li_flag = 0;
		 else 
		 let li_flag = 1;
	   end if
	   
	 if li_flag = 0 then}
	 
		Select max(secuencia) + 1
		  into _secuencia2
		  from parmailsend;
	--end if
	if _secuencia3 <> 0 and _secuencia3 is not null then
		let _longitud = 0;	 -- validar maximo html body

		Select length(html_body)
		  into _longitud
		  from parmailsend
		 where cod_tipo  = a_cod_tipo
		   and email	 = a_email
		   and enviado	 = 0 
		   and secuencia = _secuencia3 ;

		if _longitud is null then
			let _longitud = 0;
		end if

		if _longitud < 400 then
			let _secuencia2 = _secuencia3;
		end if
		 let li_flag = 1;
	end if
end if


for _ciclo = 1 to _anexar

		Select html_body,
			   adjunto
		  into _html_body,
			   _adjunto
		  from parmailsend
		 where cod_tipo  = a_cod_tipo
		   and email	 = a_email
		   and secuencia = _secuencia2
		   and enviado	 = 0;

		select count(*)
		  into _cnt
		  from parmailcomp
	     where no_remesa      = a_cod_avican
	       and renglon        =	a_renglon
	       and mail_secuencia = _secuencia2;

		if _cnt is null then
			let _cnt = 0;
		end if

	    if _cnt = 0 then

			if _adjunto is null then
				let	_adjunto = 0;
	        end if

			if _html_body is null then
				let	_html_body = "";
		    end if

		    let _adjunto = _adjunto + 1;

			if _adjunto > 4 then
				let _html_body = "<html><img src=cid:" ||  _secuencia2 || ".jpg width=850 height=1100>";
		    else
				if _adjunto = 1 then
					let _html_body = "<html><img src=cid:" ||  _secuencia2 || ".jpg width=850 height=1100>" || "<br><img src=cid:" || _secuencia2 || "_1.jpg width=850 height=1100>";

					Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
					Values (a_cod_tipo, a_email, _enviado, _adjunto, _html_body, _secuencia2);

				else
					let _html_body = trim(_html_body) || '<br><img src=cid:' ||  _secuencia2 || '_' || cast(_adjunto as char(1)) || '.jpg width=850 height=1100>';
				end if
		    end if

			Update parmailsend
			   set html_body	= _html_body,
			   	   adjunto		= _adjunto
			 where secuencia	= _secuencia2;

			--  Datos Adjuntos
			Select max(secuencia) + 1
			  into _secuencia1
			  from parmailcomp;

			Select trim(no_documento),trim(cod_agente)
			  into _no_documento,_cod_agente
			  from avisocanc
			 where no_aviso = a_cod_avican
			   and renglon  = a_renglon;

			insert into parmailcomp (secuencia,no_remesa,renglon,mail_secuencia,no_documento,asegurado)
			values(_secuencia1,a_cod_avican,a_renglon,_secuencia2,_no_documento,_cod_agente);
		end if

end for

return _error, _error_desc;

end

end procedure

 