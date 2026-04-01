-- Buscando Polizas emitidas que aun tienen incidentes activos

-- Creado    : 12/09/2011 - Autor: Amado Perez

drop procedure sp_rwf88;

create procedure sp_rwf88()
 returning char(10),
		   varchar(1),
		   varchar(1);

define _cant            smallint;

define _incident	    integer;
define _taskuser		nchar(512);
define _processname		nchar(256);
define _steplabel		nvarchar(128,0);
define _nrocotizacion	decimal(10,0);
define _cotizacion	    char(10);
define _initiator       nchar(512);

define _actualizado, _emitirpolizajefepr varchar(1);


SET ISOLATION TO DIRTY READ;
foreach
--  SELECT nrocotizacion, actualizado, emitirpolizajefepr
--    INTO _nrocotizacion, _actualizado, _emitirpolizajefepr
--	FROM wf_cotizacion
--   WHERE (actualizado = "1" OR actualizado = "7") AND emitirpolizajefepr <> "1"
    
 --  WHERE (actualizado <> "1" AND actualizado <> "7")
 --     OR actualizado IS NULL
  SELECT incident,   
         taskuser,   
         processname,   
         steplabel,
		 initiator
    INTO _incident,
         _taskuser,
         _processname,
         _steplabel,
		 _initiator
    FROM wf_emi_aprob

  SELECT a.nrocotizacion, b.actualizado, b.emitirpolizajefepr
    INTO _nrocotizacion, _actualizado, _emitirpolizajefepr
	FROM wf_db_autos a, wf_cotizacion b
   WHERE a.nrocotizacion = b.nrocotizacion
     AND a.incident = _incident
  group by 1,2,3;
   
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

	return _cotizacion, _actualizado, _emitirpolizajefepr
		   with resume;

end foreach
end procedure
