-- Carta Oirta

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro202d;

CREATE PROCEDURE "informix".sp_pro202d(a_no_eval char(10))
returning varchar(100),date,smallint,char(20),date,dec(16,2),varchar(50);


define _nombre			 varchar(100);
define _fecha_nacimiento date;
define _identidad		 smallint;
define _identidad_otro	 char(20);
define _user_scan		 char(8);
define _suma_asegurada   dec(16,2);
define _fecha_eval       date;
define _claves           varchar(50);
define _cod_asegurado    char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202d.trc";
--trace on;

BEGIN

select nombre,
       fecha_nacimiento,
	   identidad,
	   identidad_otro,
	   suma_asegurada,
	   fecha_eval,
	   claves,
	   cod_asegurado
  into _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _suma_asegurada,
	   _fecha_eval,
	   _claves,
	   _cod_asegurado
  from emievalu
 where no_evaluacion = a_no_eval;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

return _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _fecha_eval,
	   _suma_asegurada,
	   _claves;

END
END PROCEDURE
