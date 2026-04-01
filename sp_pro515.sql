-- Analisis de las Renovaciones de SODA para cambiara el esquema a Persistencia

-- Creado    : 20/09/2012 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_pro515;

create procedure "informix".sp_pro515()
returning char(20),
          char(20);

define _no_documento		char(20);
define _reemplaza_poliza	char(20);

foreach
 select no_documento,
 		reemplaza_poliza
   into _no_documento,
        _reemplaza_poliza
   from emipomae
  where actualizado = 1
    and cod_ramo    = "020"
	and periodo     = "2012-09"

	return _no_documento,
	       _poliza_maestra
	       with resume;
	

end foreach

end procedure