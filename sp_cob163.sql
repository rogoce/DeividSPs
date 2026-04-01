--Procedimiento que borra una Remesa

--Creado    : 09/09/2004 - Autor: Armando Moreno
--Modificado: 09/09/2004 - Autor: Armando Moreno

--SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob163;

CREATE PROCEDURE sp_cob163(a_remesa CHAR(10))
RETURNING smallint,char(80);

define _doc_remesa char(30);
define _no_recibo  char(10);
define _cant       integer;
define _monto_det  dec(16,2);
define _tipo_mov   char(1);
define _no_poliza  char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

SET LOCK MODE TO WAIT;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach

	select doc_remesa,
		   no_recibo,
		   monto,
		   tipo_mov,
		   no_poliza
	  into _doc_remesa,
		   _no_recibo,
		   _monto_det,
		   _tipo_mov,
		   _no_poliza
	  from cobredet
	 where no_remesa   = a_remesa
	   and actualizado = 0

if _tipo_mov = "E" then

	update cobsuspe
	   set monto = monto - _monto_det
	 where doc_suspenso = _doc_remesa;

elif _tipo_mov = "P" then
	update emipomae
	   set saldo = saldo + _monto_det
	 where no_poliza = _no_poliza;
end if

end foreach

delete from cobreagt
where no_remesa = a_remesa;

delete from cobredet
where no_remesa = a_remesa
and actualizado = 0;

delete from cobremae
where no_remesa = a_remesa
and actualizado = 0;

delete from cobrepag
where no_remesa = a_remesa;

delete from cobasiau
where no_remesa = a_remesa;

delete from cobasien
where no_remesa = a_remesa;

end
return 0,"";

END PROCEDURE;
