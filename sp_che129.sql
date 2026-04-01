-- Procedimiento que Arreglas el no_poliza en chqchcta de las devoluciones de primas anuladas
-- 
-- Creado    : 25/05/2011 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che129;

CREATE PROCEDURE "informix".sp_che129()
RETURNING CHAR(10),
          smallint,
          smallint;

define _no_requis	char(10);
define _no_poliza	char(10);
define _cantidad	smallint;
define _cantidad2	smallint;

foreach
 select no_requis
   into _no_requis
   from chqchmae
  where origen_cheque       = "6"
    and pagado              = 1
    and anulado             = 1
--  and year(fecha_anulado) = 2011
--	and no_requis           = "381024"

	select count(*)
	  into _cantidad
	  from chqchpol
	 where no_requis = _no_requis;

	select count(*)
	  into _cantidad2
	  from chqchcta
	 where no_requis = _no_requis
	   and no_poliza is null;

	if _cantidad = 1 then

		select no_poliza
		  into _no_poliza
	      from chqchpol
	     where no_requis = _no_requis;

--		update chqchcta
--		   set no_poliza = _no_poliza
--	     where no_requis = _no_requis
--	       and no_poliza is null;

	end if

	if _cantidad2 <> 0 then
	
		return _no_requis,
		       _cantidad,
			   _cantidad2
			   with resume;

	end if

end foreach

return "", 
       0,
	   0;

end procedure