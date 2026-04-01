-- Reclamos sin Reserva - Luego Pagados
-- 
-- Creado    : 28/11/2012 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec199;		

create procedure "informix".sp_rec199()
returning char(20),
          char(50),
          dec(16,2);

define _numrecla	char(20);
define _no_reclamo	char(10);
define _no_poliza	char(10);
define _cod_ramo	char(3);
define _nombre_ramo	char(50);

define _variacion	dec(16,2);
define _monto		dec(16,2);

define _periodo1	char(7);
define _periodo2	char(7);

let _periodo1 = "2012-10";
let _periodo2 = "2012-11";

foreach 
 select numrecla,
        no_reclamo,
		no_poliza
   into _numrecla,
        _no_reclamo,
		_no_poliza
   from recrcmae
  where actualizado   = 1
    and fecha_reclamo <= "31/10/2012"
  order by numrecla

	select sum(variacion)
	  into _variacion
	  from rectrmae 
	 where cod_compania = "001"
	   and no_reclamo   = _no_reclamo
	   and periodo     <= _periodo1 
	   and actualizado  = 1;

	if _variacion is null then
		let _variacion = 0;
	end if
	
	if _variacion <> 0 then
		continue foreach;
	end if

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select sum(monto)
	  into _monto
	  from rectrmae
	 where actualizado  = 1
	   and no_reclamo   = _no_reclamo
	   and cod_tipotran = "004"
	   and periodo      = _periodo2;

	if _monto is null then
		let _monto = 0;
	end if
	
	if _monto = 0 then
		continue foreach;
	end if

	return _numrecla,
	       _nombre_ramo,
		   _monto
		   with resume;


end foreach

return "",
       "", 
	   0;


end procedure