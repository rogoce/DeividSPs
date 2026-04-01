-- Informaci¢n: para Panam  Presentar los datos en el Grid
-- Creado     : 11/09/2007 - Autor: Ruben Arnaez 

 DROP PROCEDURE sp_sispoliza;

create procedure "informix".sp_sispoliza(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user			char(8))
 returning integer,
           char(100);

{
define _tiempo	datetime year to fraction(5);
define _error	integer;
let _tiempo = current;
}


-- Para cargar la tabla temporal de CASPOLIZA

DEFINE pno_documento         char(20);
DEFINE pcod_cliente          char(10);
DEFINE pdia_cobros1          smallint;
DEFINE pdia_cobros2          smallint;
DEFINE pa_pagar              decimal(16,2);
DEFINE ptipo_mov             char(1);

SET ISOLATION TO DIRTY READ;

			CREATE TEMP TABLE temp_caspoliza(
			no_documento         char(20),
			cod_cliente          char(10),
			dia_cobros1          smallint,
			dia_cobros2          smallint,
			a_pagar              decimal(16,2),
			tipo_mov             char(1) 
			--PRIMARY KEY		(cod_cliente)
				) WITH NO LOG;


-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	  
	  	select 
			no_documento,         
			cod_cliente,          
			dia_cobros1,          
			dia_cobros2,          
			a_pagar,              
			tipo_mov             
			
		into 
		   pno_documento,        
		   pcod_cliente,         
		   pdia_cobros1,         
		   pdia_cobros2,         
		   pa_pagar,             
		   ptipo_mov            
		  
		  from caspoliza 
		  where cod_cliente = a_cod_errado
	  	
		INSERT INTO temp_caspoliza(
		   no_documento,        
		   cod_cliente,         
		   dia_cobros1,         
		   dia_cobros2,         
		   a_pagar,             
		   tipo_mov                 
		  )
   VALUES(
		   pno_documento,        
		   pcod_cliente,         
		   pdia_cobros1,         
		   pdia_cobros2,         
		   pa_pagar,             
		   ptipo_mov   
		   );
end foreach;
return 0, "Actualizacion Exitosa";
				--execute procedure sp_sisra("1234567890","1234567890","12345678") 
			   	{return  _usuario,	   		-- 1. Usuario 
			   			_descripcion,	   	-- 2. Nombre completo del usuario
						_e_mail,     		-- 3. Correo del usuario 
						_status,	   	    -- 4. Estado del usuario 
						_windows_user,		-- 5. Usuario de windows
						_fvac_out,			-- 6. Fecha inicial de vacaciones 
						_fvac_duein	     	-- 7. fecha de regreso de Vacaciones 
				 }		
	 -- with resume;

end procedure;
