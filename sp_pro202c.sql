-- Aceptacion endoso de exclusion y/o recargo

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro202c;

CREATE PROCEDURE "informix".sp_pro202c(a_no_eval char(10))
returning varchar(100),char(10),char(8),varchar(30);


define _nombre	 	 	varchar(100);
define _user_eval	 	char(8);
define _n_evaluadora    varchar(30);
define _cod_asegurado   char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202.trc";
--trace on;

BEGIN

select nombre,
	   usuario_eval,
	   cod_asegurado
  into _nombre,
	   _user_eval,
	   _cod_asegurado
  from emievalu
 where no_evaluacion = a_no_eval;

select descripcion
  into _n_evaluadora
  from insuser
 where usuario = _user_eval;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

if _user_eval is null then
	let _user_eval    = "";
	let _n_evaluadora = "";
end if

return _nombre,
	   a_no_eval,
	   _user_eval,
	   _n_evaluadora;
	   

END
END PROCEDURE
