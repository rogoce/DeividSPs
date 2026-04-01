-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro82bb;

create procedure sp_pro82bb(a_no_documento char(20))
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
		  char(50),
		  smallint,
		  char(5),
		  varchar(50),
		  smallint,
		  date,
		  char(10);

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
define _estatus_audiencia smallint;
define _cod_ajustador	char(3);
define _nombre_ajust	char(50);
define _no_unidad       char(5);
define _cod_evento      char(3);
define _tiene_audiencia smallint;
define _fecha_audiencia date;
define _nombre_evento   varchar(50);

foreach
 select no_reclamo,
        numrecla,
		fecha_documento,
		fecha_siniestro,
		fecha_reclamo,
		estatus_reclamo,
		ajust_interno,
		estatus_audiencia,
		no_unidad,
		cod_evento,
		tiene_audiencia,
		fecha_audiencia
   into	_no_reclamo,
        _numrecla,
		_fecha_doc,
		_fecha_siniestro,
		_fecha_reclamo,
		_estatus_rec,
		_cod_ajustador,
		_estatus_audiencia,
		_no_unidad,
		_cod_evento,
		_tiene_audiencia,
		_fecha_audiencia
   from recrcmae
  where	actualizado  = 1
	and no_documento matches a_no_documento
  order by fecha_siniestro desc

	select nombre
	  into _nombre_ajust
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select nombre
	  into _nombre_evento
	  from recevent
	 where cod_evento = _cod_evento;

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

	return a_no_documento,
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
		   _nombre_ajust,
		   _estatus_audiencia,
		   _no_unidad,
		   _nombre_evento,
		   _tiene_audiencia,
		   _fecha_audiencia,
		   _no_reclamo
		   with resume;

end foreach

end procedure
