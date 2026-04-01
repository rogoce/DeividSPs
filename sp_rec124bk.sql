-- Busqueda del caso mas viejo cuando le dan nuevo programa de consulta de reclamos.

-- Creado    : 01/08/2006 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec124bk;

CREATE PROCEDURE "informix".sp_rec124bk(a_user char(8), a_flag smallint)
returning integer,char(10),char(20),char(10),char(10),char(10),char(100),char(100),char(50),char(10),char(10);

define _cod_asignacion	 char(10);
define _date_added       datetime year to fraction(5);
define _fecha_time       datetime year to fraction(5);
define _cod_ajustador    char(3);
define _cantidad	     integer;
define _no_documento	 char(20);
define _no_unidad		 char(10);
define _cod_asegurado	 char(10);
define _cod_reclamante	 char(10);
define _cod_producto     char(5);
define _asegurado	     char(100);
define _reclamante	     char(100);
define _producto         char(50);
define _no_poliza		 char(10);
define _cod_entrada		 char(10);
define _cod_tipo         char(3);
define _error            smallint;

--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec124.trc";
--trace on;


SET LOCK MODE TO WAIT;

BEGIN

let _fecha_time = CURRENT;
let _cantidad   = 0;
LET _cod_asignacion = null;
let _error          = 0;

if a_flag = 1 then		--Le dieron insertar, verifico si es apto para hacerlo.

	select cod_ajustador
	  into _cod_ajustador
	  from recajust
	 where usuario = a_user
	   and activo             = 1
	   and inserta_asignacion = 1;

	if _cod_ajustador is null or _cod_ajustador = "" then

		return -3,"2","3","4","5","6","7","8","9","10","11";

	end if

end if

select cod_ajustador	--busca el codigo de ajustador del usuario que entro.
  into _cod_ajustador
  from recajust
 where usuario = a_user
   and activo  = 1
   and inserta_asignacion = 1;

if _cod_ajustador is null or _cod_ajustador = "" then

	return -2,"","","","","","","","","","";

end if

SELECT count(*)			--busca si hay uno pendiente.
  INTO _cantidad
  FROM atcdocde
 WHERE cod_ajustador      = _cod_ajustador
   AND ajustador_asignado = 1
   AND completado         = 0
   AND suspenso           <> 1
   AND en_mora            <> 1;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   foreach
	SELECT cod_asignacion,
		   date_added,
		   no_documento,
		   no_unidad,
		   cod_asegurado,
		   cod_reclamante
	  INTO _cod_asignacion,
	       _date_added,
		   _no_documento,
		   _no_unidad,
		   _cod_asegurado,
		   _cod_reclamante
	  FROM atcdocde
	 WHERE cod_ajustador      = _cod_ajustador
	   AND ajustador_asignado = 1
	   AND completado         = 0
       AND suspenso           <> 1
	   AND en_mora            <> 1
	   --AND no_documento       in("1812-00077-01","1812-00088-01")   --Poliza Embajada USA
	 ORDER BY prioridad desc, date_added

	exit foreach;
   end foreach

   if _cod_asignacion is not null or _cod_asignacion <> "" then
   else
	   foreach
		SELECT cod_asignacion,
			   date_added,
			   no_documento,
			   no_unidad,
			   cod_asegurado,
			   cod_reclamante
		  INTO _cod_asignacion,
		       _date_added,
			   _no_documento,
			   _no_unidad,
			   _cod_asegurado,
			   _cod_reclamante
		  FROM atcdocde
		 WHERE cod_ajustador      = _cod_ajustador
		   AND ajustador_asignado = 1
		   AND completado         = 0
	       AND suspenso           <> 1
		   AND en_mora            <> 1
		 ORDER BY date_added

		exit foreach;
	   end foreach
   end if

   foreach

	SELECT cod_entrada
	  INTO _cod_entrada
	  FROM atcdocde
	 WHERE cod_asignacion = _cod_asignacion

	exit foreach;
   end foreach

	let _no_poliza = sp_sis21(_no_documento);

	SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	SELECT nombre
	  INTO _reclamante
	  FROM cliclien
	 WHERE cod_cliente = _cod_reclamante;

	SELECT cod_producto
	  INTO _cod_producto
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;

	SELECT nombre
	  INTO _producto
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;

   return 1,
   		  _cod_asignacion,
   		  _no_documento,
		  _no_unidad,
		  _cod_asegurado,
		  _cod_reclamante,
		  _asegurado,
		  _reclamante,
		  _producto,
		  _no_poliza,
		  _cod_entrada;

end if

if a_flag = 0 then
	return 0,"","","","","","","","","","";
end if

--Buscar tipo
call sp_sis180(_cod_ajustador) returning _error, _cod_tipo;

if _error <> -4 then
else
	return -1,"","","","","","","","","","";
end if

foreach					  --no hay pendientes, entonces se busca el mas viejo y se devuelve.

		SELECT cod_asignacion,
			   date_added,
			   no_documento,
			   no_unidad,
			   cod_asegurado,
			   cod_reclamante
		  INTO _cod_asignacion,
		       _date_added,
			   _no_documento,
			   _no_unidad,
			   _cod_asegurado,
			   _cod_reclamante
		  FROM atcdocde
		 WHERE ajustador_asignado = 0
		   AND completado         = 0
		   AND ajustador_asignar  = 1
	       AND suspenso           <> 1
		   AND en_mora            <> 1
		   AND titulo is not null
		   AND cod_tipo           = _cod_tipo
		 ORDER BY prioridad desc, date_added

		exit foreach;

end foreach
	
if _cod_asignacion is not null or _cod_asignacion <> "" then

	update atcdocde
	   set ajustador_asignado = 1,
		   cod_ajustador      = _cod_ajustador,
		   ajustador_fecha    = _fecha_time
	 where cod_asignacion 	  = _cod_asignacion;

else
		return -1,"","","","","","","","","","";
end if 

foreach

	SELECT cod_entrada
	  INTO _cod_entrada
	  FROM atcdocde
	 WHERE cod_asignacion = _cod_asignacion

	exit foreach;
end foreach

let _no_poliza = sp_sis21(_no_documento);

SELECT nombre
  INTO _asegurado
  FROM cliclien
 WHERE cod_cliente = _cod_asegurado;

SELECT nombre
  INTO _reclamante
  FROM cliclien
 WHERE cod_cliente = _cod_reclamante;

SELECT cod_producto
  INTO _cod_producto
  FROM emipouni
 WHERE no_poliza = _no_poliza
   AND no_unidad = _no_unidad;

SELECT nombre
  INTO _producto
  FROM prdprod
 WHERE cod_producto = _cod_producto;

Return 0,
_cod_asignacion,
_no_documento,
_no_unidad,
_cod_asegurado,
_cod_reclamante,
_asegurado,
_reclamante,
_producto,
_no_poliza,
_cod_entrada;

END
END PROCEDURE
