--***************************************************************--
-- Buscar vigencia del año que se esta pagando el Incentivo de Fidelidad--
--***************************************************************--

-- Creado    : 05/01/2009 - Autor: Armando Moreno M.
-- Modificado: 05/01/2009 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis382;

CREATE PROCEDURE sp_sis382(a_no_documento CHAR(20),a_periodo CHAR(7))
RETURNING CHAR(10);

define _ano        smallint;
define _no_poliza  char(10);
define _serie      smallint;
define _flag       smallint;

let _ano       = a_periodo[1,4];
let _no_poliza = "";
let _flag = 0;

--SET DEBUG FILE TO "sp_sis381.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

foreach

	SELECT no_poliza,
	       serie
	  INTO _no_poliza,
	       _serie
	  FROM emipomae
	 WHERE actualizado  = 1
	   AND no_documento = a_no_documento

	if _serie = _ano then
		let _flag = 1;
		exit foreach;		
	end if

end foreach

if _flag = 0 then
	let _no_poliza = "";
end if

return _no_poliza;

END PROCEDURE;