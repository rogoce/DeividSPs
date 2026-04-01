-- Cargar Porcentajes de Gasto de Administracion, Adquisicion y Contrato XLS
-- 
-- Creado    : 08/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_sis50;

CREATE PROCEDURE "informix".sp_sis50()

define _cod_ramo	char(3);
define _cod_enlace	char(3);

foreach with hold
 select cod_ramo
   into _cod_ramo
   from prdramo

	if _cod_ramo = "001" or	   -- Inc
	   _cod_ramo = "003" then  -- Multi

		let _cod_enlace = "002";

	elif _cod_ramo = "002" then	-- Auto

		let _cod_enlace = "003";

	elif _cod_ramo = "004" or   -- AP
	     _cod_ramo = "016" then -- CV

		let _cod_enlace = "001";

	elif _cod_ramo = "005" or
	     _cod_ramo = "006" or
	     _cod_ramo = "007" or
	     _cod_ramo = "015" or
	     _cod_ramo = "017" then	 -- Varios

		let _cod_enlace = "005";

	elif _cod_ramo = "008" or
	     _cod_ramo = "080" then	-- Fianzas

		let _cod_enlace = "007";

	elif _cod_ramo = "009" then	-- Carga

		let _cod_enlace = "004";

	elif _cod_ramo = "010" or
	     _cod_ramo = "011" or
	     _cod_ramo = "012" or
	     _cod_ramo = "013" or
	     _cod_ramo = "014" then -- Tecnicos

		let _cod_enlace = "006";

	elif _cod_ramo = "018" then	-- Salud

		let _cod_enlace = "008";

	elif _cod_ramo = "019" then -- VI

		let _cod_enlace = "009";

	end if
	
	update prdramo
	   set cod_enlace = _cod_enlace
	 where cod_ramo   = _cod_ramo;

end foreach

end procedure
