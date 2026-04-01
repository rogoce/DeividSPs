-- Procedure que Verifica las Primas en Suspenso

-- Creado    : 13/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob164;

create procedure sp_cob164() 
returning char(30),
		  dec(16,2),
		  date,
		  char(50),
		  char(50);
		  
define _doc_suspenso	char(30);
define _monto			dec(16,2);
define _fecha			date;
define _asegurado		char(50);
define _poliza			char(50);
define _cantidad		smallint;

foreach
 select	doc_suspenso,
		monto,
		fecha,
		asegurado,
		poliza
   into	_doc_suspenso,
		_monto,
		_fecha,
		_asegurado,
		_poliza
   from	cobsuspe
  where	actualizado = 0
 order by fecha

	select count(*)
	  into _cantidad
	  from cobredet
	 where doc_remesa = _doc_suspenso;

	if _cantidad = 0 then

		return _doc_suspenso,
			   _monto,
			   _fecha,
			   _asegurado,
			   _poliza
			   with resume;

	end if

end foreach

return "0",
	   0.00,
	   today,
	   "",
	   ""
	   with resume;

end procedure