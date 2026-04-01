-- Retorna Nombre del Plan

-- Creado    : 29/10/2010 - Autor: Armando Moreno
-- Modificado: 29/10/2010 - Autor: Armando Moreno


DROP PROCEDURE sp_pro197;

CREATE PROCEDURE sp_pro197(a_cod_ramo char(3))
RETURNING CHAR(5),   
          VARCHAR(50),
		  DEC(16,2),
		  VARCHAR(50),
		  CHAR(3);

DEFINE _cod_producto     CHAR(5);
DEFINE _n_plan           VARCHAR(50);
DEFINE _maximo_vitalicio dec(16,2);
DEFINE _cod_subramo		 CHAR(3);
DEFINE _n_subramo        VARCHAR(50);

SET ISOLATION TO DIRTY READ;

let _maximo_vitalicio = 0.00;

FOREACH

	SELECT cod_producto,
	       nombre,
		   cod_subramo
	  INTO _cod_producto,
		   _n_plan,
		   _cod_subramo
	  FROM prdprod
	 WHERE cod_ramo = a_cod_ramo
	   AND activo = 1
  ORDER BY nombre

   let _maximo_vitalicio = 0.00;

   select nombre
     into _n_subramo
	 from prdsubra
	where cod_ramo    = a_cod_ramo
	  and cod_subramo = _cod_subramo;

   foreach

	select maximo_vitalicio
	  into _maximo_vitalicio
	  from prdbemax
	 where cod_producto = _cod_producto

	exit foreach;

   end foreach

   if _maximo_vitalicio is null then
		let _maximo_vitalicio = 0.00;
   end if
   	
   RETURN _cod_producto, _n_plan, _maximo_vitalicio,_n_subramo,_cod_subramo WITH RESUME;
	
END FOREACH

END PROCEDURE;


