-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento -- Deivid Gestion

drop procedure sp_rec313;

create procedure sp_rec313(a_periodo1 char(7), a_periodo2 char(7))
returning char(20) as reclamo,
          varchar(100) as asegurado,
		  varchar(100) as reclamante,
          date as fecha_siniestro,
          date as fecha_documento,
          date as fecha_apertura,
		  varchar(50) as diagnostico,
		  varchar(50) as cobertura,
		  char(8) as usuario,
		  dec(16,2) as reserva;

define _fecha_reclamo	date;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _user_added      char(8);

define _no_tranrec      char(10);
define _fecha_factura   date;
define _fecha_notificacion date;
define _cod_asegurado   char(10);
define _cod_reclamante  char(10);
define _cod_icd         char(10);
define _cod_cobertura   char(5);

define _asegurado       varchar(100);
define _reclamante      varchar(100);
define _diagnostico     varchar(50);
define _cobertura       varchar(50);

set isolation to dirty read;

foreach
	select no_tranrec,
	       no_reclamo,
	       monto
	  into _no_tranrec,
	       _no_reclamo,
	       _reserva
	  from rectrmae
	 where periodo >= a_periodo1
	   and periodo <= a_periodo2
	   and cod_tipotran = '011'
	   and user_added = 'informix'	
       and actualizado = 1	   
	   and numrecla[1,2] = '18'

	 select	numrecla,
	        fecha_reclamo,
	        fecha_documento,
			fecha_siniestro,
			cod_asegurado,
			cod_reclamante,
			cod_icd,
			user_added
	   into	_numrecla,
	        _fecha_reclamo,
	        _fecha_notificacion,
			_fecha_factura,
			_cod_asegurado,
			_cod_reclamante,
			_cod_icd,
			_user_added
	   from recrcmae
	  where no_reclamo  = _no_reclamo;

	select cod_cobertura
	  into _cod_cobertura
	  from rectrcob
	 where no_tranrec = _no_tranrec;
		   
	select nombre
      into _asegurado
      from cliclien
     where cod_cliente = _cod_asegurado;

    select nombre
      into _reclamante
      from cliclien
     where cod_cliente = _cod_reclamante;	  
	 
	select nombre
	  into _diagnostico
	  from recicd
	 where cod_icd = _cod_icd;
	 
	select nombre 
	  into _cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	return _numrecla,
	       _asegurado,
		   _reclamante,
		   _fecha_factura,
		   _fecha_notificacion,
	       _fecha_reclamo,
		   _diagnostico,
		   _cobertura,
		   _user_added,
		   _reserva
		   with resume;

end foreach



end procedure