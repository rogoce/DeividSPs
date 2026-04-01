-- Procedimiento que valida acreedor
-- Creado : 20/03/2021- Autor: Henry Giron 
-- manejo especial para marcar Acreedor
Drop procedure sp_cob782; 
create procedure "informix".sp_cob782(a_no_poliza char(10),a_renglon integer,a_no_aviso char(10))
returning char(1);

define _email_cli		varchar(100);
define _error			integer;
define _clase			char(1);
define _estatus			char(1);
define _valido      	integer;
define _cod_acreedor 	CHAR(10);
define _imp_aviso_log 	smallint;
define _enviado      	integer;

set lock mode to wait;
{  -- se coloca en cobros en sp_cob388
E -	SE ENVIA POR CORREO EL AVISO AL CLIENTE Y A ACREEDOR.	
B -	Correo Certificado para cliente y @ al acreedor	
}
begin
on exception set _error
	return _error;
end exception

set debug file to 'sp_cob782.trc';
trace on ;

	let _clase = '2';
	let _estatus = 'I';
	let _enviado = 0;

select count(*)
  into _valido
  from avisocanc
 where no_aviso = a_no_aviso
   and renglon = a_renglon
   and no_poliza = a_no_poliza
   and email_cli is not null
   and email_cli not like '%/%'
   and email_cli <> ''
   and email_cli like '%@%'
   and email_cli not like '@%'
   and email_cli not like '% %'
   and email_cli not like '%,%'
   and trim(email_cli) not like '%[^a-z,0-9,@,.]%'
   and trim(email_cli) like '%_@_%_.__%'
   and lower(trim(email_cli))not like '%asegurancon%'
   and lower(trim(email_cli))not like '%no%tiene%' ;

if _valido is null then 
	let _valido = 0;
end if			

--     para validar el email del cliente vs email de corredor    -- HG01112019
select trim(nvl(cod_acreedor,'')),clase, estatus,imp_aviso_log
  into _cod_acreedor,_clase,_estatus,_imp_aviso_log
  from avisocanc
 where no_aviso = a_no_aviso
   and renglon = a_renglon
   and no_poliza = a_no_poliza;

-- RESULTADO DESPUES DEL DIARIO
select enviado	
  into _enviado	   
  from parmailcomp t, parmailsend p
 where t.mail_secuencia = p.secuencia                
   and p.cod_tipo = '00010'
 --  and p.enviado = 1
   and t.no_remesa = a_no_aviso
   and t.renglon = a_renglon;
   
if _enviado is null then 
	let _enviado = 0;
end if	

if _enviado = 1 then
 --   let _estatus = 'M';
 
	 if _valido <> 0 then  -- se valida el correo
		 
	-- MODULO DE COBROS
	--  Envio por correo @, sin acreedor 
		 
		if trim(_cod_acreedor) = '' and _clase = 1 and _estatus  = 'I' then
			let _estatus = 'M';
		end if
	--  Envio por correo @, con acreedor 	
		if trim(_cod_acreedor) <> '' and _clase = 1 and _estatus  = 'I' then
			let _estatus = 'A';
		end if


	else			
		
		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _clase = 2 and _estatus  = 'I' then
			let _estatus = 'I';
		end if
	--  impresión de Aviso a Clientes
		if trim(_cod_acreedor) = '' and _clase = 2 and _estatus  = 'I' then
			let _estatus = 'C';
		end if	
		
		
	end if


end if

if _enviado = 2 then
 --   let _estatus = 'I';
 
 	 if _valido <> 0 then  -- se valida el correo
		 
	-- MODULO DE COBROS
	--  Envio por correo @, sin acreedor 
		 
		if trim(_cod_acreedor) = '' and _clase = 1 and _estatus  = 'I' then
			let _estatus = 'C';
		end if
	--  Envio por correo @, con acreedor 	
		if trim(_cod_acreedor) <> '' and _clase = 1 and _estatus  = 'I' then
			let _estatus = 'I';
		end if


	else			
		
		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _clase = 2 and _estatus  = 'I' then
			let _estatus = 'I';
		end if
	--  impresión de Aviso a Clientes
		if trim(_cod_acreedor) = '' and _clase = 2 and _estatus  = 'I' then
			let _estatus = 'C';
		end if	
		
		
	end if
	
	
end if
	


--MODULO DE LOGISTICA

    if  _clase = 1 and _imp_aviso_log <> 3  then	   	 
	  let _estatus = 'I';
	end if
	
	if trim(_cod_acreedor) = '' and _clase = 1 and _estatus  = 'I' and _imp_aviso_log <> 3  then   	 
	  let _estatus = 'M';
	end if	
	
	if trim(_cod_acreedor) not in ( '' ) and _clase = 1 and _estatus  = 'I' and _imp_aviso_log <> 3  then   	 
	  let _estatus = 'A';
	end if	

	if trim(_cod_acreedor) = '' and _clase = 2 and _estatus  = 'I' and _imp_aviso_log <> 3  then   	 
	    let _estatus = 'M';
	end if	
	  
	if trim(_cod_acreedor) not in ( '' ) and _clase = 2 and _estatus  = 'I' and _imp_aviso_log <> 3  then   	 
	    let _estatus = 'I';
	end if	
	
	if  _clase = 2 and _estatus  = 'I' and _imp_aviso_log =  3 and trim(_cod_acreedor) = '' then   	 
	    let _estatus = 'C';
	end if		


return _estatus;
end
end procedure 
                                                                                                                                                                                                                       
