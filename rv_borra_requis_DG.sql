-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure rv_borra_requis_DG;

create procedure "informix".rv_borra_requis_DG()
returning integer,char(80);

define _no_requis		char(10);
define _transaccion     char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _cont            integer;

--SET LOCK MODE TO WAIT;

--set debug file to "aa.trc";
--trace on;

begin work;
begin
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc || " " || _no_requis;
end exception

let _cont = 0;

foreach
	select no_requis
	  into _no_requis 
	  from chqchmae
	 where no_requis NOT IN (  SELECT rectrmae.no_requis
    FROM recrcmae,   
         rectrmae  
   WHERE ( rectrmae.no_reclamo = recrcmae.no_reclamo ) and  
         ( ( recrcmae.no_documento = '1819-99900-01' ) AND  
         ( rectrmae.no_requis is not null ) AND  
         ( rectrmae.anular_nt is null ) AND 
		 ( rectrmae.fecha < '01/04/2019') ))
    	
		update rectrmae
		   set no_requis      = null
		 where no_requis      = _no_requis;
      
	    DELETE FROM chqchpoa WHERE no_requis = _no_requis;
	    DELETE FROM chqchpol WHERE no_requis = _no_requis;
	    DELETE FROM recunino WHERE no_requis = _no_requis;
	    DELETE FROM chqchdes WHERE no_requis = _no_requis;
	    DELETE FROM chqchagt WHERE no_requis = _no_requis;
	    DELETE FROM chqctaux WHERE no_requis = _no_requis;
	    DELETE FROM chqchcta WHERE no_requis = _no_requis;
	    DELETE FROM chqchrec WHERE no_requis = _no_requis;
	    DELETE FROM chqchmae WHERE no_requis = _no_requis;
		
	let _cont = _cont + 1;
	
	if _cont > 50000 then
		exit foreach;
    end if
end foreach


end
commit work;
return 0,"";

end procedure
