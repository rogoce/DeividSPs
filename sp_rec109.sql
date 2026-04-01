-- Reclamos con saldo a 90 Dias

-- Creado: 31/10/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec109;

create procedure "informix".sp_rec109()
returning char(20),
          char(7),
          char(20),
          dec(16,2),
          dec(16,2),
          char(50);

define _numrecla		char(20);
define _no_documento	char(20);
define _periodo			char(7);
define _saldo			dec(16,2);
define _dias_90			dec(16,2);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _no_poliza		char(10);

foreach
 select numrecla,
        no_documento,
		periodo,
		no_poliza
   into _numrecla,
        _no_documento,
		_periodo,
		_no_poliza
   from recrcmae
  where periodo    >= "2003-01"
    and actualizado = 1

	select saldo,
	       dias_90
	  into _saldo,
	       _dias_90
	  from cobmoros
	 where no_documento = _no_documento
	   and periodo      = _periodo;

	if _dias_90 is null then
		continue foreach;
	end if  

	if _dias_90 <= 0 then
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

	return _numrecla,
	       _periodo,
		   _no_documento,
		   _saldo,
		   _dias_90,
		   _nombre_ramo
		   with resume;

end foreach
 
end procedure