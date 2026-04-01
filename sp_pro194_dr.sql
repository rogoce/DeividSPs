-- Busqueda del caso mas viejo cuando le dan nuevo programa de consulta de solicitudes.

-- Creado    : 28/10/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro194;
CREATE PROCEDURE sp_pro194(a_user char(8), a_flag smallint)
returning integer,varchar(100),char(10),datetime year to fraction(5),char(10),date,dec(16,2),char(10),char(5);


define _n_contratante    varchar(100);
define _no_evaluacion	 char(10);
define _fecha			 datetime year to fraction(5);
define _no_recibo		 char(10);
define _fecha_recibo	 date;
define _monto			 decimal(16,2);
define _cantidad	     integer;
define _cod_asegurado    char(10);
define _cod_producto     char(5);
define _es_medico        smallint;
define _fecha_eval       date;
define _fecha_hora       datetime hour to fraction(5);
define _codigo_per       char(3);

--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro194.trc";
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

let _cantidad   = 0;
let _fecha_eval = CURRENT;
let _fecha_hora = CURRENT;
let _codigo_per = '052';

select es_medico,
       codigo_perfil
  into _es_medico,
       _codigo_per
  from insuser
 where usuario = a_user;

if a_flag = 1 then	--le dieron insertar
	if _es_medico = 1 or _codigo_per = '052' then --in('073','052') then --_codigo_per = '052' then --perfil de evaluador -- or _codigo_per = '073' perfil de supervisor suscripcion personas Amado 1-7-2013 al 15-7-2013
	else
		return -2,"","","2010-10-26 15:09:00.00000","","01/01/1900",0,"","";
	end if
end if

if _es_medico = 1 then
	--busca si hay uno pendiente para el medico.

	SELECT count(*)
	  INTO _cantidad
	  FROM emievalu
	 WHERE escaneado   = 1
	   AND completado  = 0
	   AND decicion    = 6 	--Evaluacion medica
	   AND suspenso    = 0
	   AND usuario_med = a_user
	   AND ((no_recibo is null and aprobado = 1)
 	    OR no_recibo is NOT null);

	if _cantidad > 0 then   --Si hay, se busca el mas viejo de ese usuario y se devuelve.
		foreach					  
			SELECT nombre,
				   no_evaluacion,
				   fecha,
				   no_recibo,
				   fecha_recibo,
				   monto,
				   cod_asegurado,
				   plan
			  INTO _n_contratante,
			       _no_evaluacion,
				   _fecha,
				   _no_recibo,
				   _fecha_recibo,
				   _monto,
				   _cod_asegurado,
				   _cod_producto
			  FROM emievalu
			 WHERE escaneado    = 1
			   AND completado   = 0
			   AND decicion     = 6
			   AND suspenso     = 0
			   AND usuario_med  = a_user
			   AND ((no_recibo is null and aprobado = 1)
 	            OR no_recibo is NOT null)
			 ORDER BY fecha

			exit foreach;

		end foreach

		if _cod_asegurado is null then
			let _cod_asegurado = "";
		end if

		if _cod_producto is null then
			let _cod_producto = "";
		end if

		Return 0,
		_n_contratante,
		_no_evaluacion,
		_fecha,
		_no_recibo,
		_fecha_recibo,
		_monto,
		_cod_asegurado,
		_cod_producto;

	end if

	if a_flag = 0 then
		return 0,"","","2010-10-26 15:09:00.00000","","01/01/1900",0,"","";
	end if

	--Le dieron insertar, busca el mas viejo que este escaneado y no completado y se asigna al usuario que inserto.
	foreach					  
		SELECT nombre,
			   no_evaluacion,
			   fecha,
			   no_recibo,
			   fecha_recibo,
			   monto,
			   cod_asegurado,
			   plan
		  INTO _n_contratante,
		       _no_evaluacion,
			   _fecha,
			   _no_recibo,
			   _fecha_recibo,
			   _monto,
			   _cod_asegurado,
			   _cod_producto
		  FROM emievalu
		 WHERE escaneado   = 1
		   AND completado  = 0
		   AND decicion    = 6
		   AND suspenso    = 0
		   AND usuario_med is null
	   	   AND ((no_recibo is null and aprobado = 1)
 	        OR no_recibo is NOT null)
		 ORDER BY fecha

		exit foreach;

	end foreach

	update emievalu
	   set usuario_med   = a_user,
           fecha_obs_med = _fecha_eval,
		   hora_obs_med  = _fecha_hora
	 where no_evaluacion = _no_evaluacion;

	if _cod_asegurado is null then
		let _cod_asegurado = "";
	end if

	if _cod_producto is null then
		let _cod_producto = "";
	end if

	Return 0,
	_n_contratante,
	_no_evaluacion,
	_fecha,
	_no_recibo,
	_fecha_recibo,
	_monto,
	_cod_asegurado,
	_cod_producto;
end if	--fin es medico

SELECT count(*)			--busca si hay uno pendiente para el usuario que entra.
  INTO _cantidad
  FROM emievalu
 WHERE escaneado    = 1
   AND completado   = 0
   AND decicion     <> 6
   AND suspenso     = 0
   AND usuario_eval = a_user
   AND ((no_recibo is null and aprobado = 1)
    OR no_recibo is NOT null);

if _cantidad > 0 then

	SELECT count(*)			--busca si hay uno que priorizaron
	  INTO _cantidad
	  FROM emievalu
	 WHERE escaneado       = 1
	   AND completado      = 0
	   AND decicion        <> 6
	   AND suspenso        = 0
	   AND usuario_eval    = a_user
	   AND fecha_eval is not null
   	   AND ((no_recibo is null and aprobado = 1)
 	    OR no_recibo is NOT null);

	if _cantidad > 0 then  --Si hay, Priorizaron una evaluacion, esa es la que sale.

		foreach					  
			SELECT nombre,
				   no_evaluacion,
				   fecha,
				   no_recibo,
				   fecha_recibo,
				   monto,
				   cod_asegurado,
				   plan
			  INTO _n_contratante,
			       _no_evaluacion,
				   _fecha,
				   _no_recibo,
				   _fecha_recibo,
				   _monto,
				   _cod_asegurado,
				   _cod_producto
			  FROM emievalu
			 WHERE escaneado    = 1
			   AND completado   = 0
			   AND decicion     <> 6
			   AND suspenso     = 0
			   AND usuario_eval = a_user
			   AND ((no_recibo is null and aprobado = 1)
 	            OR no_recibo is NOT null)
			 ORDER BY fecha_eval

			exit foreach;
		end foreach
	else			 --sale la mas vieja
		foreach					  
			SELECT nombre,
				   no_evaluacion,
				   fecha,
				   no_recibo,
				   fecha_recibo,
				   monto,
				   cod_asegurado,
				   plan
			  INTO _n_contratante,
			       _no_evaluacion,
				   _fecha,
				   _no_recibo,
				   _fecha_recibo,
				   _monto,
				   _cod_asegurado,
				   _cod_producto
			  FROM emievalu
			 WHERE escaneado    = 1
			   AND completado   = 0
			   AND decicion     <> 6
			   AND suspenso     = 0
			   AND usuario_eval = a_user
			   AND ((no_recibo is null and aprobado = 1)
				OR no_recibo is NOT null)			   
			 ORDER BY fecha

			exit foreach;
		end foreach
	end if
	if _cod_asegurado is null then
		let _cod_asegurado = "";
	end if

	if _cod_producto is null then
		let _cod_producto = "";
	end if

	Return 0,
	_n_contratante,
	_no_evaluacion,
	_fecha,
	_no_recibo,
	_fecha_recibo,
	_monto,
	_cod_asegurado,
	_cod_producto;

end if
if a_flag = 0 then
	return 0,"","","2010-10-26 15:09:00.00000","","01/01/1900",0,"","";
end if
--Le dieron insertar, busca el mas viejo que este escaneado y no completado y se asigna al usuario que inserto.
foreach					  
	SELECT nombre,
		   no_evaluacion,
		   fecha,
		   no_recibo,
		   fecha_recibo,
		   monto,
		   cod_asegurado,
		   plan
	  INTO _n_contratante,
	       _no_evaluacion,
		   _fecha,
		   _no_recibo,
		   _fecha_recibo,
		   _monto,
		   _cod_asegurado,
		   _cod_producto
	  FROM emievalu
	 WHERE escaneado    = 1
	   AND completado   = 0
	   AND decicion     <> 6
	   AND suspenso     = 0
	   AND usuario_eval is null
   	   AND ((no_recibo is null and aprobado = 1)
 	    OR no_recibo is NOT null)
	 ORDER BY fecha

	exit foreach;
end foreach

update emievalu
   set usuario_eval   = a_user,
       fecha_obs_eval = _fecha_eval,
	   hora_obs_eval  = _fecha_hora,
	   fecha_eval     = _fecha_eval,
	   eval_original  = a_user
 where no_evaluacion  = _no_evaluacion;

if _cod_asegurado is null then
	let _cod_asegurado = "";
end if
if _cod_producto is null then
	let _cod_producto = "";
end if

Return 0,
_n_contratante,
_no_evaluacion,
_fecha,
_no_recibo,
_fecha_recibo,
_monto,
_cod_asegurado,
_cod_producto;

END
END PROCEDURE