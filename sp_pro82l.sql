-- Retorna las notas de reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro82l;

create procedure sp_pro82l(a_no_documento char(20))
returning datetime year to fraction(5),
          char(8),
		  varchar(250),
          char(18);

define _no_reclamo		char(10);
define _fecha_nota		datetime year to fraction(5);
define _fecha_aviso		date;
define _desc_nota       varchar(250);
define _user_added		char(8);
define _numrecla		char(18);

foreach
 select no_reclamo,
		numrecla
   into	_no_reclamo,
		_numrecla
   from recrcmae
  where	actualizado  = 1
	and no_documento matches a_no_documento

	foreach
		 select fecha_nota,
				desc_nota,
				user_added
		   into	_fecha_nota,
				_desc_nota,
				_user_added
		   from recnotas
		  where	no_reclamo = _no_reclamo
		  order by fecha_nota desc

		return _fecha_nota,
			   _user_added,
		       _desc_nota,
			   _numrecla
			   with resume;

	end foreach
end foreach

end procedure
