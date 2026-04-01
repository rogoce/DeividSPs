-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

--drop procedure sp_rec95bk2;

create procedure "informix".sp_rec95bk2(_no_requis char(10))
returning integer;

define _transaccion		char(10);
define _anular_nt		char(10);
define _periodo			char(7);
define _monto			dec(16,2);
define _pagado			smallint;
define _cantidad		smallint;
define _no_cheque		integer;
define _anulado			smallint;
define _control_flujo   smallint;
define _error			integer;
define _cod_banco       char(3);
define _cod_chequera    char(3);

set debug file to "sp_rec95.trc";
trace on;
set isolation to dirty read;

-- Borrar todo en cascada (requisicion)

		update rectrmae
		   set no_requis = null
		 where no_requis = _no_requis;

		delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

		delete from chqchdes
		 where no_requis = _no_requis;

		delete from chqchrec
		 where no_requis = _no_requis;

		delete from chqchcta
		 where no_requis = _no_requis;

		delete from chqchmae
		 where no_requis = _no_requis;

return 0;
end procedure
