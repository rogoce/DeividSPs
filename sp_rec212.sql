-- Actualizacion de las Causas de Siniestros en las coberturas

-- Creado    : 17/07/2013 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_rec212;

create procedure "informix".sp_rec212() 
returning smallint,
          char(50);

define _cod_cobertura	char(5);
define _tipo_causa		smallint;

-- Causas del Siniestro

--  1. Gastos Medicos (P)
--  2. Legal (P)
--  3. Perdida Total - Robo
--  4. Perdida Total - Colision
--  5. Perdida Total - Incendio
--  6. Perdida Parcial
--  7. Danos a Terceros - Lesiones Corporales
--  8. Danos a Terceros - Danos a Cosas

--  9. Perdida Total sin Cobertura

-- 10. Perdida Total - Caida de Objetos
-- 11. Perdida Total - Inundacion

set isolation to dirty read;

foreach
 select cod_cobertura
   into _cod_cobertura
   from prdcober
  where cod_ramo in ("002", "020")

	if _cod_cobertura in ("00107", "00108", "00109", "00117", "00123", "01028", "01073", "01074", "01075", "01191") then -- Gastos Medicos

		let _tipo_causa = 1;

	elif _cod_cobertura in ("00103", "00118", "00606", "00900", "00901", "01146") then -- Robo

		let _tipo_causa = 3;

	elif _cod_cobertura in ("00104", "00119", "00121", "00122", "00907", "01030", "01120", "01141", "01154", "01155", "01222") then -- Colision

		let _tipo_causa = 4;

	elif _cod_cobertura in ("00120", "00902") then -- Incendio

		let _tipo_causa = 5;

	elif _cod_cobertura in ("00102", "00106", "01021") then -- Danos a Terceros - Lesiones Corporales

		let _tipo_causa = 7;

	elif _cod_cobertura in ("00113", "01119", "01142", "01145", "01022") then -- Danos a Terceros - Danos a Terceros

		let _tipo_causa = 8;

	elif _cod_cobertura in ("00903", "00904") then -- Caida de Objetos

		let _tipo_causa = 10;

	elif _cod_cobertura in ("01233") then -- Inundacion

		let _tipo_causa = 11;

	else -- Perdida Parcial

		let _tipo_causa = 0;

	end if

	update prdcober
	   set causa_siniestro = _tipo_causa
 	 where cod_cobertura   = _cod_cobertura;
	
end foreach

return 0, "Actualizacion Exitosa";

end procedure