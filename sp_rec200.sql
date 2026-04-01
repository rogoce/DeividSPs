-- Reclamos sin Reserva - Luego Pagados
-- 
-- Creado    : 28/11/2012 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec200;		

create procedure "informix".sp_rec200()
returning char(20),
          date,
          dec(16,2),
		  date,
		  date,
          char(50),
          char(50);

define _numrecla	char(20);
define _no_reclamo	char(10);
define _no_poliza	char(10);

define _cod_ramo	char(3);
define _nombre_ramo	char(50);

define _cod_agente	char(5);
define _nombre_agt	char(50);

define _monto		dec(16,2);

define _fecha_pago	date;
define _fecha_prima	date;
define _fecha_siniestro	date;

foreach 
 select numrecla,
        no_reclamo,
		no_poliza,
		fecha_siniestro
   into _numrecla,
        _no_reclamo,
		_no_poliza,
		_fecha_siniestro
   from recrcmae
  where actualizado           = 1
    and year(fecha_siniestro) = 2012
--    and month(fecha_siniestro) = 11
--    and numrecla[1,2]         = 20
  order by numrecla

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select min(cod_agente)
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza;
	 
	 select nombre
	   into _nombre_agt
	   from agtagent
	  where cod_agente = _cod_agente;  	

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select sum(monto),
	       min(fecha)
	  into _monto,
	       _fecha_pago
	  from rectrmae
	 where actualizado  = 1
	   and no_reclamo   = _no_reclamo
	   and cod_tipotran = "004"
	   and periodo[1,4] = 2012;

	select min(fecha)
	  into _fecha_prima
	  from cobredet
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and tipo_mov    = "P";

	if _monto is null then
		let _monto = 0;
	end if
	
	if _monto <> 0 then

		return _numrecla,
		       _fecha_siniestro,
			   _monto,
			   _fecha_pago,
			   _fecha_prima,
		       _nombre_ramo,
		       _nombre_agt
			   with resume;

	end if

end foreach

end procedure