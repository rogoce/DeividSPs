-- Renovacion automatica, dw de tabla emideren(detalle de excepciones de la poliza)

-- Creado    : 15/04/2009 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro850;

CREATE PROCEDURE sp_pro850(a_no_poliza char(10))
returning integer,					   --error
		  integer,					   --renglon
		  char(10),					   --no_poliza
		  char(50),                    --descripcion
		  char(1),					   --tipo ramo
		  smallint;		   

define _no_aprobacion	    char(10);
define _n_descripcion		char(50);
define _renglon		    	integer;
define _tipo_ramo    		char(1);
define _color,_activo       smallint;

let _color = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro850.trc";
--trace on;

   foreach
		SELECT renglon,
			   activo
		  INTO _renglon,
			   _activo
		  FROM emideren
		 WHERE no_poliza = a_no_poliza
		   AND renglon is not null

		SELECT descripcion,
		       tipo_ramo
		  INTO _n_descripcion,
		       _tipo_ramo
		  FROM emiusuex
		 WHERE renglon = _renglon;

	   return _color,
	   		  _renglon,
			  a_no_poliza,
			  _n_descripcion,
			  _tipo_ramo,
			  _activo
			  with resume;
	   if _color = 0 then
		let _color = 1;
	   else
		let _color = 0;
	   end if
   end foreach

END PROCEDURE
