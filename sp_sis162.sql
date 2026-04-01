-- Numero Interno de Poliza de la ultima Vigencia
-- dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis162;

create procedure "informix".sp_sis162(a_no_documento char(30)) returning char(10), char(20);

define _no_poliza      char(10);
define _no_documento   char(20);
define _vigencia_final date;

set isolation to dirty read;

let _no_poliza    = null;
let _no_documento = null;

foreach
 select	no_poliza,
	    vigencia_final,
		no_documento
   into	_no_poliza,
	    _vigencia_final,
		_no_documento
   from	emipomae
  where no_poliza_coaseg   = a_no_documento
	and actualizado        = 1
  order by vigencia_final desc
	exit foreach;
end foreach

return _no_poliza, _no_documento;

end procedure;