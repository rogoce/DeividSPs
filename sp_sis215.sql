-- Validacion del no_requis antes de imprimir, para evitar duplicidad.
--
-- Creado    : 07/09/2007 - Autor: Lic. Armando Moreno 
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_sis215;

CREATE PROCEDURE "informix".sp_sis215(
a_no_requis 	CHAR(10) 
) RETURNING INTEGER;


DEFINE _flag    INTEGER;
DEFINE _transaccion CHAR(10);
define _pagado      smallint;

--SET DEBUG FILE TO "sp_sis215.trc";
--TRACE ON;

let _flag = 0;
let _pagado = 0;
foreach

	 SELECT transaccion
	   into _transaccion
	   FROM chqchrec
	  WHERE no_requis = a_no_requis
	  
	 select count(*)
	   into _pagado
	   from rectrmae
	  where transaccion = _transaccion
	    and pagado      = 1;
		
    let _flag = 0;
	
    if _pagado > 0 then
	    let _flag = 1;
		exit foreach;
	end if	
	  
end foreach

RETURN _flag;

END PROCEDURE;
