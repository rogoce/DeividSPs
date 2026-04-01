-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 19/12/2006 - Autor: Armando Moreno

drop procedure sp_rwf82;

create procedure sp_rwf82()
 returning   integer,
             varchar(255);

define _no_cheque       char(20);
define _incident        integer;
define _initiator		varchar(255);

SET ISOLATION TO DIRTY READ;

foreach
	SELECT a.no_cheque,
	       b.incident,
	       b.initiator   
	  INTO _no_cheque,
	       _incident,
		   _initiator
      FROM chqchmae a, wf_db_atencion b  
	 WHERE (a.no_cheque = b.doc_atencion AND incidente is not null AND incidente <> 0 AND (anulado = 1 OR wf_entregado = 1)) --  No son electronicos
	    OR (a.no_cheque = b.doc_atencion AND en_firma = 2 AND (anulado = 1 OR wf_entregado = 1))						     --  Electronico
	    OR (a.no_cheque = b.doc_atencion AND a.a_nombre_de = b.a_nombre_de AND en_firma = 0)
	 --  AND no_cheque = a_no_cheque 

	{foreach with hold   
		SELECT incident,
		       initiator
		  INTO _incident,
		       _initiator  
		  FROM wf_db_atencion
		 WHERE doc_atencion = _no_cheque 
  }
		 RETURN _incident,
		       	TRIM(REPLACE(TRIM(_initiator),"ancon.com/",""))
		   with resume;
  --	end foreach
end foreach


end procedure
