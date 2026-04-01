-- Procedure que actualiza estado de impresion de aviso de cancelación.
-- Creado    : 22/2/2016 - Autor: Henry Girón.
-- SIS v.2.0 - DEIVID, S.A.
-- set debug file to 'sp_cob317.trc';  -- execute procedure sp_log009()
-- trace on;

Drop procedure sp_log009;
Create procedure sp_log009(a_no_aviso char(10))
RETURNING integer, 
          varchar(50);

define _flag         smallint;
define _error        integer;

set lock mode to wait; 
	
BEGIN 
	ON EXCEPTION SET _error 
	 	RETURN _error, "Verificacion estado 3 en AvisoCanc";  
	END EXCEPTION 
	
  select count(*)
	into _flag
	from avisocanc 
   where estatus in ('I') 
     and no_aviso  = (a_no_aviso) 
     and saldo > 0 and exigible > 0 -- and exigible > corriente
     and ( dias_60 + dias_90 + dias_120 + dias_150 + dias_180 ) <> 0
     and ( imp_aviso_log <> 3 or imp_aviso_log is null );
	 
	  if _flag is null then 
	     let _flag = 0; 
	 end if 

	if _flag > 0 then 		
		let _flag = 1; 
	end if 
				
end

set isolation to dirty read;

--SOLICTUD: ROMAN, 21/12/2017
--if trim(a_no_aviso) in ('01242i','01243i','01234y','01256y','01227','01252','01251','01235','01256','01234') then
--  return 1,"especial";
--end if

return _flag, "Verificación Exitosa";
end procedure  