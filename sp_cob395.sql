-- Procedimiento que valida que no ha sido generada la remesa de cierre 
-- Creado    : 08/06/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

-- Drop procedure sp_cob395;
create procedure 'informix'.sp_cob395(a_no_remesa char(10)) 
returning	smallint,char(100);

define _error_desc			varchar(100);
define _error_code			integer;
define _error_isam			integer;
define _cod_agt		 		char(10);
define _no_remesa           char(10);
define _cnt_pago            integer;

set isolation to dirty read;
--set debug file to 'sp_cob395.trc';
--trace on ;
begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc;
end exception

let _cnt_pago = 0;

select cod_agente
  into _cod_agt
  from cobpaex0
 where no_remesa = a_no_remesa ;
 
 if _cod_agt <> '00035' then 
	return 1,'Agente NO es 00035 - Ducruet.';
else
	return 0,'Realizar remesa de cierre - Ducruet.';
 end if
 
 {select distinct no_remesa 
   into _no_remesa
   from deivid_cob:duc_cob 
  where no_remesa_agt = a_no_remesa
     and procesado = 1;
	 
	 if _no_remesa is null then
		return 1,"No se encontro la Remesa."
	end if
 
	select count(*) 
	  into _cnt_pago
	  from cobremae
	 where no_remesa = _no_remesa
	   and actualizado = 1;	   
	   
	   if _cnt_pago = 0 then
			return 1,"La Remesa ya fue Actualiada."
	   end if	   
 
	return 0,'Pagos Procesado para cierre de Remesa.';
	}
end
end procedure;