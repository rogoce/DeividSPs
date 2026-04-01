-- Procedimiento que determina el ultimo contrato despues de los traspasos de cartera

-- Creado     : 02/08/2007 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par251;		

CREATE PROCEDURE "informix".sp_par251(a_cod_contrato char(5))
RETURNING CHAR(5);

define _traspaso		smallint;
define _cod_traspaso	char(5);
define _cod_contrato	char(5);

let _traspaso     = 1;
let _cod_contrato = a_cod_contrato;

while _traspaso = 1

	select traspaso,
	       cod_traspaso
	  into _traspaso,
	       _cod_traspaso
	  from reacomae
	 where cod_contrato = _cod_contrato;

	if _traspaso = 1 then
		let _cod_contrato = _cod_traspaso;
	end if

end while

return _cod_contrato;

end procedure
