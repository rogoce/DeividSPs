-- Procedimiento correos de envio del carta de bienvenida - renovacion 	
-- Creado    : 27/04/2017 - Autor: Henry Giron
-- execute procedure sp_par360('0216-00182-02')

drop procedure sp_par360;
create procedure sp_par360(a_no_documento char(20))
returning	char(5),
			char(200),
			char(200);

define _secuencia		integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _secuencia_orig	integer;
define _carta_bienvenida	smallint;
define _adjunto			smallint;
define _existe			smallint;
define _tipo_tran		smallint;
define _email_cc		char(200);
define _error_desc		char(100);
define _email_to		char(200);
define _email_send		char(200);
define _email_cli		char(50);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _cod_grupo		char(5);
define _email_cartas	char(50);
define _email_agtmail	char(50);
define _email_cliclien	char(20);
define _no_tarjeta		char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _cod_contratante		char(10);
define _cod_ramo        char(3);
define _sucursal        char(3);
define _cantidad        smallint;


on exception set _error, _error_isam, _error_desc
	--rollback work;   
	return _error,_error_isam,_error_desc;
end exception

set isolation to dirty read; 
--set debug file to "sp_par360.trc"; 
--trace on; 

let _email_cc = '';
let _email_to = '';
let _cod_agente = '';

call sp_sis21(a_no_documento) returning _no_poliza;

select cod_contratante, cod_ramo, sucursal_origen,cod_grupo
  into _cod_contratante, _cod_ramo, _sucursal,_cod_grupo
  from emipomae
 where no_poliza = _no_poliza;
 
{
 -- Se envia copia solo si es sucursal 006-LOS PUEBLOS. ASTANCIO: 170504, hasta segundo aviso.
 select count(*)
  into _cantidad
  from insagen
 where sucursal_promotoria <> '001'
   and centro_costo = '006'
   and codigo_agencia  = _sucursal ;  

   if _cantidad <> 0 then
		return _cod_agente,_email_to,_email_cc;   
   end if
 }
 
if _cod_ramo <> "002" then
	return _cod_agente,_email_to,_email_cc;
end if 



Select e_mail
  into _email_cli
  from cliclien
 where cod_cliente = _cod_contratante;
	
if _email_cli is null or _email_cli = '' then
else
	let _email_to 	=	trim(_email_cli) || ';';
end if

foreach
	Select email
	  into _email_cli
	  from climail
	 where cod_cliente = _cod_contratante
	
	if trim(_email_cli) = '' or _email_cli is null then
		continue foreach;
	end if
 	if _email_cli = _email_to then
 		continue foreach;
 	else
		let _email_to = trim(_email_to) || trim(_email_cli) || ';';
	end if
end foreach 


if _cod_grupo in ('1122','77850','77870','77857','77960') then  -- Añadir correos de Banisi para las pólizas del Colectivo Banisi Ducruet
	let _email_cc = 'segurosbanisi@banisipanama.com;trackingbanisi@unityducruet.com;';  -- SD#3010 77960  11/04/2022 10:00
	
	return '00035',_email_to,_email_cc;
	
end if

foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza
	 order by porc_partic_agt desc
--	exit foreach;

	Select e_mail,
		    carta_bienvenida
	  into _email_cartas,
		    _carta_bienvenida
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _carta_bienvenida  = 0 then
		continue foreach;
	end if
		
	if _email_cartas is null or _email_cartas = '' then
	else
		if _email_cc is null or _email_cartas = '' then
			let _email_cc 	=	trim(_email_cartas) || ';';
		else
			let _email_cc 	=	trim(_email_cc)|| trim(_email_cartas) || ';';
		end if
	end if

	foreach
		Select distinct email
		  into _email_agtmail
		  from agtmail
		 where cod_agente = _cod_agente
		   and tipo_correo = 'COM'
		
		if trim(_email_agtmail) = '' or _email_agtmail is null then
			continue foreach;
		end if
		if _email_agtmail = _email_cartas then
			continue foreach;
		else
			let _email_cc = trim(_email_cc) || trim(_email_agtmail) || ';';
		end if
	end foreach 

end foreach

return _cod_agente,_email_to,_email_cc;
end procedure



