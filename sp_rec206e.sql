-- Procedimiento que carga el check list de los documentos al momento de abrir los reclamos
-- creado 16/07/2019 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec206e;		
create procedure "informix".sp_rec206e()
returning	integer;
			
define _fecha_hoy	    date;
define _no_reclamo    	varchar(10);
define _no_poliza    	varchar(10);
define _cod_ramo        char(3);
define _user_added      varchar(8);
define _cod_docra       varchar(3);

set isolation to dirty read;

--set debug file to "sp_rec206c.trc"; 
--trace on;

let _fecha_hoy	= today;

foreach
	select no_reclamo,
		   user_added,
		   no_poliza
      into _no_reclamo,
           _user_added,
		   _no_poliza
	  from recrcmae 
	 where fecha_reclamo = _fecha_hoy
       and user_added    = 'informix'
  
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
		 SELECT cod_docra
		   into _cod_docra
           FROM recdocra
          where cod_ramo  = _cod_ramo
            and default   = 1
            and asegurado = 1
	
		insert into recrcdoc(no_reclamo, cod_docra, entregado, date_added, user_added, date_entrega, cod_compania, cod_agencia) values(_no_reclamo, _cod_docra, 1, current, 'informix', current, '001','001');
	end foreach
	
	update recrcmae
	   set doc_completa = 1,
		   date_doc_comp = current
	 where no_reclamo = _no_reclamo;
	
end foreach
  
return	0;

end procedure