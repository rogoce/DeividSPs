-- Buscando Polizas emitidas que aun tienen incidentes activos

-- Creado    : 12/09/2011 - Autor: Amado Perez

drop procedure sp_rwf89;

create procedure sp_rwf89()
 returning integer,
		   nchar(512),
		   nchar(256),
		   nvarchar(128,0),
		   nchar(512),
		   smallint,
		   smallint;

define _cant            smallint;

define _incident	    integer;
define _taskuser		nchar(512);
define _processname		nchar(256);
define _steplabel		nvarchar(128,0);
define _nrocotizacion	decimal(10,0);
define _cotizacion	    char(10);
define _initiator       nchar(512);
define _starttime		datetime year to fraction(5);
define _meses           integer;
define _hoy       		date;
define _fecha           date;

SET ISOLATION TO DIRTY READ;
foreach
  SELECT incident,   
         taskuser,   
         processname,   
         steplabel,
		 initiator,
		 starttime
    INTO _incident,
         _taskuser,
         _processname,
         _steplabel,
		 _initiator,
		 _starttime
    FROM wf_emi_aprob
  ORDER BY incident

  LET _cant = 0;

  FOREACH
	  SELECT a.nrocotizacion
	    INTO _nrocotizacion
		FROM wf_db_autos a, wf_cotizacion b
	   WHERE a.nrocotizacion = b.nrocotizacion
	     AND a.incident = _incident
	  EXIT FOREACH;
  END FOREACH

  LET _cotizacion = _nrocotizacion;

  SELECT count(*)
    INTO _cant
    FROM emipomae
   WHERE emipomae.cotizacion = _cotizacion;  


--     AND b.actualizado = "1"
--     AND b.emitirpolizajefepr in ("1","2");

  LET _hoy = current;
  LET _fecha = _starttime;
   
  LET _meses = (_hoy  - _fecha );
     
  IF _meses < 30 or _cant > 0 THEN --   	
  	continue foreach;
  END IF     

	return _incident,
		   _taskuser,
		   _processname,
		   _steplabel,
		   _initiator,
		   _meses,
		   _cant
		   with resume;

end foreach
end procedure
