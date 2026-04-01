--Carta Declinacion para el cliente

-- Creado    : 24/01/2011 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro202f;

CREATE PROCEDURE "informix".sp_pro202f(a_no_eval char(10))
returning varchar(100),char(10),varchar(255),char(8),varchar(30),smallint;


define _nombre	 	 	varchar(100);
define _user_eval	 	char(8);
define _declinacion_obs	varchar(255);
define _n_evaluacion    varchar(30);
define _declina_aseg    smallint;
define _tipo_ramo       smallint;
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
	   tipo_ramo,
	   cod_asegurado
  into _nombre,
	   _declinacion_obs,
	   _user_eval,
	   _declina_aseg,
	   _tipo_ramo,
	   _cod_asegurado
  from emievalu
 where no_evaluacion = a_no_eval;

select descripcion
  into _n_evaluacion
  from insuser
 where usuario = _user_eval;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

if _user_eval is null then
	let _user_eval = "";
	let _n_evaluacion = "";
end if

if _declina_aseg = 0 then
	let _declinacion_obs = "";
end if

return _nombre,
	   a_no_eval,
	   _declinacion_obs,
	   _user_eval,
	   _n_evaluacion,
	   _tipo_ramo;

END
END PROCEDURE
