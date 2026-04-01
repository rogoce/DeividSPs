-- Filtro de Ramos para los Estados de Cuentas de Clientes y Grupo de Clientes
-- Creado por :     Roman Gordon	25/01/2011
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_co27;

CREATE PROCEDURE "informix".sp_co27(a_cod_cliente	  CHAR(10))
RETURNING	CHAR(3),	-- codig de ramo
			CHAR(50);	-- nombre del ramo
			
DEFINE _cod_ramo	CHAR(3);
DEFINE _nom_ramo	CHAR(50);


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_co51c.trc";
--trace on;

let _cod_ramo = '';
let _nom_ramo = '';

foreach
	Select distinct cod_ramo
  	  into _cod_ramo
  	  from emipomae
 	 where cod_pagador = a_cod_cliente

	Select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _cod_ramo,
		   _nom_ramo 
		   with resume;
end foreach
end Procedure;	