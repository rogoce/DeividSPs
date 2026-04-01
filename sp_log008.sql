-- Procedure que actualiza estado de impresion de aviso de cancelación.
-- Creado    : 22/2/2016 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- 
Drop procedure sp_log008;
Create procedure sp_log008(a_no_aviso char(10), a_no_poliza char(10), a_opcion char(1), a_usuario char(15), a_fecha date )
RETURNING integer, 
          varchar(50);

define _flag_orig	 smallint;
define _flag         smallint;
define _cod_acreedor char(5);
define _error        integer;

set lock mode to wait; 
	
BEGIN 
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al actualizar tabla AvisoCanc";  
	END EXCEPTION 
	
 select  d.imp_aviso_log, 
		 d.cod_acreedor 
	into _flag_orig, 
		 _cod_acreedor 
	from avicanpar a, avisocanc d 
   where d.estatus in ('I') 
     and a.cod_avican = d.no_aviso 
	 and a.cod_avican = (a_no_aviso) 
	 and d.no_poliza  = (a_no_poliza) ; 
	 
	  if _flag_orig is null then 
	     let _flag_orig = 0; 
	 end if 

     if a_opcion = 'C' then 
		if _cod_acreedor = '' or _cod_acreedor is null then 
			let _flag = 3;  
		else 
			if _flag_orig = 2 then
                let _flag = 3; 			
			else
			    let _flag = 1; 
			end if			
		end if 
	end if 
	
	 if a_opcion = 'A' then 
		if _flag_orig = 0  then 
		   let _flag = 2; 
        else
			if _flag_orig = 1 then 
				let _flag = 3; 
			end if									 
		end if									 			
	end if		
		 
 Update avisocanc
	set user_imp_aviso_log = (a_usuario), 
	    date_imp_aviso_log = (a_fecha), 
	    imp_aviso_log = _flag 
  Where no_poliza = (a_no_poliza) 
    and no_aviso = (a_no_aviso) ; 
				
end

set isolation to dirty read;

return 0, "Actualizaciion Exitosa";

end procedure  