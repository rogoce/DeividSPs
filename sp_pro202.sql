-- Carta Oirta

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro202;

CREATE PROCEDURE "informix".sp_pro202(a_no_eval char(10))
returning varchar(100),date,smallint,char(20),char(8),varchar(30);


define _nombre			 varchar(100);
define _fecha_nacimiento date;
define _identidad		 smallint;
define _identidad_otro	 char(20);
define _user_scan		 char(8);
define _n_asistente      varchar(30);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202.trc";
--trace on;

BEGIN

select nombre,
       fecha_nacimiento,
	   identidad,
	   identidad_otro,
	   user_escan
  into _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _user_scan
  from emievalu
 where no_evaluacion = a_no_eval;

select descripcion
  into _n_asistente
  from insuser
 where usuario = _user_scan;


if _user_scan is null then
	let _user_scan = "";
	let _n_asistente = "";
end if

return _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _user_scan,
	   _n_asistente;

END
END PROCEDURE
