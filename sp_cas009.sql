-- Retorna los Reclamos de un Pagador o de Una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas009;

create procedure sp_cas009(a_cod_pagador char(10), a_no_documento char(20))
returning char(20),
          char(20),
		  date,
		  date,
		  date,
		  char(1),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50);

define _no_reclamo		char(10);
define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_doc		date;
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _estatus_rec		char(1);

define _rec_pagado		dec(16,2);
define _rec_reserva		dec(16,2);
define _rec_salvamento	dec(16,2);
define _rec_recupero	dec(16,2);
define _rec_deducible	dec(16,2);

define _cod_ajustador	char(3);
define _nombre_ajust	char(50);

foreach
 select r.no_reclamo,
        r.numrecla,
		p.no_documento,
		r.fecha_documento,
		r.fecha_siniestro,
		r.fecha_reclamo,
		r.estatus_reclamo,
		r.ajust_interno
   into	_no_reclamo,
        _numrecla,
		_no_documento,
		_fecha_doc,
		_fecha_siniestro,
		_fecha_reclamo,
		_estatus_rec,
		_cod_ajustador
   from recrcmae r, caspoliza p
  where	r.no_documento = p.no_documento
	and r.actualizado  = 1
	and p.cod_cliente  matches a_cod_pagador
	and p.no_documento matches a_no_documento
  order by p.no_documento, r.fecha_siniestro desc

	select nombre
	  into _nombre_ajust
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select sum(monto)
	  into _rec_pagado
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran = "004";

	if _rec_pagado is null then
		let _rec_pagado		= 0;
	end if

	select sum(variacion)
	  into _rec_reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _rec_reserva is null then
		let _rec_reserva	= 0;
	end if

	select sum(monto)
	  into _rec_salvamento
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran = "005";

	if _rec_salvamento is null then
		let _rec_salvamento	= 0;
	end if

	select sum(monto)
	  into _rec_recupero
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran = "006";

	if _rec_recupero is null then
		let _rec_recupero	= 0;
	end if

	select sum(monto)
	  into _rec_deducible
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran = "007";

	if _rec_deducible is null then
		let _rec_deducible	= 0;
	end if

	return _no_documento,
	       _numrecla,
		   _fecha_doc,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _estatus_rec,
		   _rec_pagado,
		   _rec_reserva,
		   _rec_salvamento,
		   _rec_recupero,
		   _rec_deducible,
		   _nombre_ajust
		   with resume;

end foreach

end procedure
