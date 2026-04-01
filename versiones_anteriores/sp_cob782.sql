-- Procedimiento que valida acreedor
-- Creado : 20/03/2021- Autor: Henry Giron 
-- manejo especial para marcar Acreedor
Drop procedure sp_cob782; 
create procedure "informix".sp_cob782(a_no_poliza char(10),a_renglon integer,a_no_aviso char(10),a_opcion char(1))
returning char(1);

define _email_cli		varchar(100);
define _error			integer;
define _clase			char(1);
define _estatus			char(1);
define _valido      	integer;
define _cod_acreedor 	CHAR(10);
define _imp_aviso_log 	smallint;
define _enviado      	integer;
define _email_acreedor	varchar(100);
define _reporte_certifica 	CHAR(10);
define _clase2			char(1);



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

let a_no_poliza = a_no_poliza;
let a_renglon = a_renglon ;
let a_no_aviso = a_no_aviso ;

	let _clase = '2';
	let _estatus = 'I';
	let _enviado = 0;		
	let _email_acreedor = '';	
	let _reporte_certifica = '';			
	
 call sp_cob776(a_no_poliza,a_renglon,a_no_aviso) returning _clase;

--     para validar el email del cliente vs email de corredor    -- HG01112019
select trim(nvl(cod_acreedor,'')),clase, estatus, imp_aviso_log, reporte_certifica
  into _cod_acreedor,_clase2,_estatus,_imp_aviso_log,_reporte_certifica
  from avisocanc
 where no_aviso = a_no_aviso
   and renglon = a_renglon
   and no_poliza = a_no_poliza;
   
   if _clase = 1 then 
       let _enviado = 1;
	 else
	     let _enviado = 2;
   end if

if a_opcion = 'L' then 
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
end if
-- Verifica el email del acreedor por poliza
select email 
  into _email_acreedor
  from emiacre 
 where cod_acreedor = _cod_acreedor;

if _email_acreedor is null then 
	let _email_acreedor = '';
end if	
if _reporte_certifica is null then 
	let _reporte_certifica = '';
end if

if _enviado in ( 2,3) then   -- se Proceso mas no se ha ejecutado el diario de envio
    let  _clase = 2;
 else
    let  _clase = 1;
end if

if a_opcion = 'C' then
	 if _clase = 1 then  -- se valida el correo  -- clase 1
		 
	-- MODULO DE COBROS
	--  Estatus = 'M'		 
		if trim(_cod_acreedor) = ''  and _email_acreedor = ''  then   -- and _reporte_certifica = '' and _estatus  = 'I' then
			let _estatus = 'M';
		end if
		--  Estatus = 'E'	
		if trim(_cod_acreedor) <> '' and _email_acreedor <> ''  then   --and _reporte_certifica = '' and _estatus  = 'I' then
			let _estatus = 'E';
		end if
		--  Estatus = 'A'	
		if trim(_cod_acreedor) <> ''  and _email_acreedor = ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'A';
		end if


	else	--clase 2		

		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _email_acreedor <> ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'B';
		end if		
		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _email_acreedor = ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'I';
		end if
	--  impresión de Aviso a Clientes
		if trim(_cod_acreedor) = ''  and _email_acreedor = ''  then   --and _reporte_certifica = '' and  _estatus  = 'I' then
			let _estatus = 'C';
		end if	
		
		
	end if
end if



	

if a_opcion = 'L' then 
	--MODULO DE LOGISTICA  
	 if _clase = 1 then  -- se valida el correo  -- clase 1
		 
	-- MODULO DE COBROS
	--  Estatus = 'M'		 
		if trim(_cod_acreedor) = ''  and _email_acreedor = ''  then   -- and _reporte_certifica = '' and _estatus  = 'I' then
			let _estatus = 'M';
		end if
		--  Estatus = 'E'	
		if trim(_cod_acreedor) <> '' and _email_acreedor <> ''  then   --and _reporte_certifica = '' and _estatus  = 'I' then
			let _estatus = 'E';
		end if
		--  Estatus = 'A'	
		if trim(_cod_acreedor) <> ''  and _email_acreedor = ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'A';
		end if


	else	--clase 2		

		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _email_acreedor <> ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'B';
		end if		
		--  Impresión de Avisos a Clientes y Acreedores
		if trim(_cod_acreedor) <> '' and _email_acreedor = ''  then   --and _reporte_certifica <> '' and  _estatus  = 'I' then
			let _estatus = 'I';
		end if
	--  impresión de Aviso a Clientes
		if trim(_cod_acreedor) = ''  and _email_acreedor = ''  then   --and _reporte_certifica = '' and  _estatus  = 'I' then
			let _estatus = 'C';
		end if	
		
		
	end if	
end if

return _estatus;
end
end procedure 
                                                                                                                                                                                                                       
