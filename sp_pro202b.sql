-- No Aprobacion de de uno de los aspirantes

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro202b;

CREATE PROCEDURE "informix".sp_pro202b(a_no_eval char(10))
returning varchar(100),char(10),varchar(255),char(8),varchar(30);


define _nombre	 	 	varchar(100);
define _user_eval	 	char(8);
define _declinacion_obs	varchar(255);
define _n_evaluacion    varchar(30);
define _declina_aseg    smallint;
define _cod_asegurado   char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202b.trc";
--trace on;

BEGIN

let _declina_aseg = 0;

select nombre,
	   declinacion_obs,
	   usuario_eval,
	   declina_asegurado,
	   cod_asegurado
  into _nombre,
	   _declinacion_obs,
	   _user_eval,
	   _declina_aseg,
	   _cod_asegurado
  from emievalu
 where no_evaluacion = a_no_eval;

select descripcion
  into _n_evaluacion
  from insuser
 where usuario = _user_eval;

if _user_eval is null then
	let _user_eval = "";
	let _n_evaluacion = "";
end if
if _declina_aseg = 0 then
	let _declinacion_obs = "";
end if

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

return _nombre,
	   a_no_eval,
	   trim(_declinacion_obs),
	   _user_eval,
	   _n_evaluacion;

END
END PROCEDURE
