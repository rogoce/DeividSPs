-- Busca proxima libreta disponible

-- Creado    : 31/07/2003 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob121bk;

CREATE PROCEDURE "informix".sp_cob121bk(a_sucursal CHAR(3), a_cod_cobrador char(3)) RETURNING CHAR(5);

DEFINE _cod_libreta    CHAR(5);
define _cod_libreta_c  char(5);
define _cod_chequera_c char(3);
define _cod_chequera   char(3);
define _cod_cobrador   char(3);
define _cnt            smallint;


SET ISOLATION TO DIRTY READ;

select cod_chequera,cod_libreta
  into _cod_chequera_c,_cod_libreta_c
  from cobcobra
 where cod_cobrador = a_cod_cobrador;

FOREACH

 SELECT	cod_libreta
   INTO	_cod_libreta
   FROM	coblibre
  WHERE usada          = 0
	AND origen_libreta = 1			   	   
	AND tipo_libreta   = 1
	AND asignado_para  = a_sucursal
	AND cod_libreta    <> _cod_libreta_c
  ORDER BY cod_libreta ASC

	let _cod_cobrador = null;
	let _cod_chequera = null;

	 select count(*)
	   into _cnt
	   from cobcobra
	  where cod_sucursal = a_sucursal
	    and cod_libreta  = _cod_libreta
	    and cod_cobrador <> a_cod_cobrador;

	 if _cnt = 0 then
	 	RETURN _cod_libreta;
	 end if

	foreach

		 select cod_cobrador,cod_chequera
		   into _cod_cobrador,_cod_chequera
		   from cobcobra
		  where cod_sucursal = a_sucursal
		    and cod_libreta  = _cod_libreta
		    and cod_cobrador <> a_cod_cobrador

		 if _cod_chequera <> _cod_chequera_c then
			continue foreach;
		 else
			RETURN _cod_libreta;
		 end if

	end foreach

END FOREACH

RETURN _cod_libreta;

END PROCEDURE;
