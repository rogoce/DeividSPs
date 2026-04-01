-- Procedimiento que valida acreedor
-- Creado : 20/03/2021- Autor: Henry Giron 
-- manejo especial para marcar Acreedor
Drop procedure sp_cob776; 
create procedure "informix".sp_cob776(a_no_poliza char(10),a_renglon integer,a_no_aviso char(10))
returning char(1);

define _email_cli	varchar(100);
define _error		integer;
define _clase		char(1);
define _estatus		char(1);

set lock mode to wait;
{
	MODULO DE COBROS		RESULTADO DESPUES DEL DIARIO		MODULO DE LOGISTICA			
	Correo Electronico	PROCESO DIARIO DE ENVÍO DE CORREO			Correo Certificado		Acreedor	
M			Validacion = 3	No baja a LOG				
C					log	Validacion = 3		
A			Validacion = EstatusProv (2)	Si Baja a LOG			log	Validacion = 3
I					log	Validacion = EstatusProv (1)	log	Validacion = 3
E	SE ENVIA POR CORREO EL AVISO AL CLIENTE Y A ACREEDOR.							
B	Correo Certificado para cliente y @ al acreedor							
								
	Clase			Estatus 				
	0	Aviso Generado			M	Envio por correo @, sin o con acreedor 		
	1	Email		Nuevo	A	Envio por correo @, con acreedor 		
	2	Apartado (Correo Certificado)						
	3	Otros			I	Impresión de Avisos a Clientes y Acreedores		
				Nuevo	C	impresión de Aviso a Clientes		
								

}
begin
on exception set _error
	return _error;
end exception
	let _clase = '2';

	select trim(email_cli)
	  into _email_cli
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

	if _email_cli is null then 
		let _email_cli = '';
	end if	

if _email_cli <> '' then  -- se valida el correo
 --     para validar el email del cliente vs email de corredor    -- HG01112019
	call sp_cob425(a_no_poliza, _email_cli) returning _error;
	if _error <> 0 then
		let _clase = '2';
	else
		let _clase = '1';
	end if

else			
	let _clase = '2';
end if

return _estatus;
end
end procedure 
                                                                                                                                                                                                                       
