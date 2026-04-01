-- Actualizacion de los registros de morosidad y cobros para BO

-- Creado    : 28/08/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par237; 

create procedure "informix".sp_par237(a_periodo char(7)) 
returning char(20),
          dec(6,2),
          dec(6,2);

define _no_documento	char(20);
define _renglon			integer;
define _diferencia1		dec(16,2);
define _diferencia2		dec(16,2);

set isolation to dirty read;

foreach
 select p.no_documento,
        (p.monto - p.prima_neta)
   into _no_documento,
        _diferencia1
   from chqchmae m, chqchpol p
  where m.no_requis = p.no_requis
    and m.periodo   = a_periodo
    and m.pagado    = 1

	select diferencia
	  into _diferencia2
	  from chqdif131
	 where no_documento = _no_documento;

--	if _diferencia1 <> _diferencia2 then

		return _no_documento,
		       _diferencia1,
			   _diferencia2
		       with resume;

--	end if

end foreach

end procedure
