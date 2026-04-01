-- Retorna los Reclamos de Una Poliza
-- 
-- Creado    : 27/06/2008 - Autor: Armando Moreno M.
-- Modificado: 27/06/2008 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_atc08;

create procedure sp_atc08(a_no_documento char(20), a_no_unidad char(5))
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
		  char(10),
		  char(10),
		  varchar(100);

define _no_reclamo		char(10);
define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_doc		date;
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _estatus_rec		char(1);
define _no_tramite		char(10);

define _rec_pagado		dec(16,2);
define _rec_reserva		dec(16,2);
define _rec_salvamento	dec(16,2);
define _rec_recupero	dec(16,2);
define _rec_deducible	dec(16,2);

define _cod_ajustador	char(3);
define _nombre_ajust	char(50);
define _parte           char(10);

define _fecha_suspension date;
define _mensaje          varchar(100);
define _estatus          smallint;


SET ISOLATION TO DIRTY READ;

foreach
 select no_reclamo,
        numrecla,
		no_documento,
		fecha_documento,
		fecha_siniestro,
		fecha_reclamo,
		estatus_reclamo,
		ajust_interno,
		no_tramite,
		parte_policivo
   into	_no_reclamo,
        _numrecla,
		_no_documento,
		_fecha_doc,
		_fecha_siniestro,
		_fecha_reclamo,
		_estatus_rec,
		_cod_ajustador,
		_no_tramite,
		_parte
   from recrcmae
  where	actualizado  = 1
	and no_documento matches a_no_documento
	and no_unidad    = a_no_unidad
  order by no_documento, fecha_siniestro desc

	if _no_tramite is null then
		let _no_tramite = "";
	end if

	if _parte is null then
		let _parte = "";
	end if

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
		let _rec_pagado	= 0;
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
	
	call sp_ley001(_no_documento, _fecha_siniestro) returning _estatus, _mensaje, _fecha_suspension;

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
		   _nombre_ajust,
		   _no_tramite,
		   _parte,
		   _mensaje
		   with resume;

end foreach

end procedure                                                                                                                                                                                                                              
