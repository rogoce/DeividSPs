-- Registra excel envio de parmailsend y parmailcomp
-- Creado    : 21/08/2020 -- Henry Girón
-- Execute procedure sp_log033('01708_20200819')

drop procedure sp_log033e_email;
create procedure sp_log033e_email(
a_cod_tipo		    char(5),
a_cod_acreedor		char(5),
a_email       	    varchar(50)
)
returning integer, varchar(30);

define _error				smallint;
define _error_isam			smallint;
define _secuencia			integer;
define _secuencia2			integer;
define _descripcion			varchar(30);
define _fecha_hoy		    date;
define _renglon				smallint;
define _cnt                 smallint;
define _cod_cliente         char(10);
define _n_cliente       	varchar(100);
define _no_documento		char(20); 


set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception

  
--set debug file to "sp_log033e_fail.trc";  
--trace on;
let _cnt = 0;
let _error = 0;
let _renglon = 0;
let _descripcion = 'Actualizacion Exitosa ...';
call sp_sis40() returning _fecha_hoy;

foreach
	select secuencia
	  into _secuencia 
	  from parmailsend 
	 where cod_tipo = a_cod_tipo
	   and date_added = fecha_hoy
	   and email = a_email
	   and enviado = 0 	   

	select count(*)
	  into _cnt
	  from parmailcomp
	 where mail_secuencia = _secuencia;
	 
	    if _cnt is null then
		   let _cnt = 0;
	   end if
	   
	   if _cnt = 0 then

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
			
			foreach				 
				select no_documento,
				       cod_cliente
                  into _no_documento,   
		               _cod_cliente				 
				  from endpool0
				 where cod_acreedor = a_cod_acreedor
				   and fecha_imprimio = _fecha_hoy
				   and estado_pro     = 2
				   and estado_log     = 2 
				   
				select nombre
				  into _n_cliente
				  from cliclien
				 where cod_cliente = _cod_cliente;				   
		
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
						
			end foreach	
			
			else
				select max(secuencia)
				  into _secuencia2
				  from parmailcomp
	             where mail_secuencia = _secuencia;		
					
		end if						
	  
end foreach	

return _error, _descripcion;
	--return  _secuencia2,a_cod_acreedor	with resume;	
end
end procedure;