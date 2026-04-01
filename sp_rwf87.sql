-- Buscando Polizas emitidas que aun tienen incidentes activos

-- Creado    : 12/09/2011 - Autor: Amado Perez

drop procedure sp_rwf87;

create procedure sp_rwf87()
 returning integer,
		   nchar(512),
		   nchar(256),
		   nvarchar(128,0),
		   nchar(512);

define _cant            smallint;

define _incident	    integer;
define _taskuser		nchar(512);
define _processname		nchar(256);
define _steplabel		nvarchar(128,0);
define _nrocotizacion	decimal(10,0);
define _cotizacion	    char(10);
define _initiator       nchar(512);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf87.trc";
--TRACE ON;

foreach
  SELECT incident,   
         taskuser,   
         processname,   
         steplabel,
		 assignedtouser
    INTO _incident,
         _taskuser,
         _processname,
         _steplabel,
		 _initiator
    FROM wf_emi_aprob

  FOREACH
	  SELECT nrocotizacion
	    INTO _nrocotizacion
		FROM wf_db_autos
	   WHERE incident = _incident
      EXIT FOREACH;
  END FOREACH
   
  LET _cotizacion = _nrocotizacion;
  LET _cant = 0;
  
  SELECT count(*)
    INTO _cant
    FROM emipomae
   WHERE emipomae.cotizacion = _cotizacion  
     AND emipomae.actualizado = 1; 
     
  IF _cant = 0 THEN
  	continue foreach;
  END IF     

	return _incident,
		   _taskuser,
		   _processname,
		   _steplabel,
		   _initiator
		   with resume;

end foreach
end procedure
