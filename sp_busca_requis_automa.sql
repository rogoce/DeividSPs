-- Borrar Requisiciones con seis meses que no han sido impresas

-- Creado: 16/06/2011 - Autor: Armando Moreno M.

drop procedure sp_busca_requis_automa;

create procedure "informix".sp_busca_requis_automa()
returning integer,char(10);

define _no_requis		char(10);
define _incidente       integer;

SET ISOLATION TO DIRTY READ;

begin

foreach
	select no_requis,
	       incidente
	  into _no_requis,
	       _incidente
	  from chqchmae
	 where no_cheque  = 0
	   and autorizado = 0
	   and pagado     = 0
	   and anulado    = 0
	   and (today - fecha_impresion) > 180

	return _incidente,_no_requis with resume;

end foreach

end

end procedure
