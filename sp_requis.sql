-- Creado    : 22/01/2010 - Autor: Armando Moreno
-- pasar a imprmimir requis nuevas que se crearon a partir de anulaciones para que no se tengan que firmar nuevamente
drop procedure sp_requis;

create procedure sp_requis()
 returning char(17),
		   char(20);

define _no_requis		 char(10);
define _firma1			 char(20);
define _firma2			 char(20);
define _autorizado_por   char(8);
define _no_cheque		 integer;
define _fecha_firma1     datetime year to fraction(5);
define _fecha_firma2     datetime year to fraction(5);
define _fecha_paso_firma datetime year to fraction(5);
define _no_documento     char(20);
define _no_cuenta        char(17);

SET ISOLATION TO DIRTY READ;

foreach

	select no_documento
	  into _no_documento
	  from a

	 select	no_cuenta
	   into	_no_cuenta
	   from	cobcutmp
	  where no_documento = _no_documento;

	 if _no_cuenta is not null then

		update cobcutmp
		   set rechazado = 0
		 where no_cuenta = _no_cuenta;

		update cobcutas
		   set rechazada    = 0
		 where no_cuenta    = _no_cuenta
		   and no_documento = _no_documento;

		update cobcuhab
		   set rechazada    = 0
		 where no_cuenta    = _no_cuenta;
     
		return _no_cuenta,
			   _no_documento
			   with resume;

	 end if	

end foreach


{foreach

	select firma1,
	       firma2,
		   fecha_firma1,
		   fecha_firma2,
		   fecha_paso_firma,
		   no_cheque,
		   autorizado_por
	  into _firma1,
	       _firma2,
		   _fecha_firma1,    
		   _fecha_firma2,    
		   _fecha_paso_firma,
		   _no_cheque,
		   _autorizado_por
	 from chqchmae
	where fecha_impresion = '22/01/2010'
	  and cod_chequera    = '006'
	  and (no_cheque      = 43152
	   or no_cheque       = 43182)
	order by no_cheque

	 select	no_requis
	   into	_no_requis
	   from	chqchmae
	  where fecha_impresion = '22/01/2010'
	    and cod_chequera    = '006'
	    and anulado         = 0
	    and pagado          = 0
	    and no_cheque_ant   = _no_cheque;

	update chqchmae		    
	   set firma1			= _firma1,
		   firma2			= _firma2,
		   fecha_firma1		= _fecha_firma1,
		   fecha_firma2		= _fecha_firma2,   
		   fecha_paso_firma	= _fecha_paso_firma,
		   en_firma         = 2,
		   autorizado_por   = _autorizado_por
	 where no_requis = _no_requis;

	return _no_requis,
		   _no_cheque
		   with resume;
   
end foreach	}

end procedure
