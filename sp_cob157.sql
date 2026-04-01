-- Verificacion de Primas en Suspenso

DROP PROCEDURE sp_cob157;

CREATE PROCEDURE "informix".sp_cob157() 
RETURNING char(30),
		  date,
		  dec(16,2),
		  dec(16,2);

define _doc_suspenso	char(30);
define _monto_suspenso	dec(16,2);
define _monto_remesa	dec(16,2);
define _fecha			date;

foreach
 select doc_suspenso,
        monto,
		fecha
   into _doc_suspenso,
        _monto_suspenso,
		_fecha
   from cobsuspe
  where actualizado = 1
  order by fecha

	select sum(monto)
	  into _monto_remesa
	  from cobredet
	 where doc_remesa  = _doc_suspenso
	   and actualizado = 1;

	if _monto_suspenso <> _monto_remesa then
		
		return _doc_suspenso,
		       _fecha,
			   _monto_suspenso,
			   _monto_remesa
			   with resume;

	end if

end foreach

end procedure