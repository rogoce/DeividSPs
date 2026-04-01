-- Busca proxima libreta disponible

-- Creado    : 31/07/2003 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob121b;

CREATE PROCEDURE "informix".sp_cob121b(a_sucursal CHAR(3), as_libreta char(5), a_cobrador char(3)) RETURNING integer;

DEFINE _cnt          smallint;
DEFINE _cod_cobrador char(3);
DEFINE _cod_libreta  char(5);

SET ISOLATION TO DIRTY READ;

foreach
 SELECT	cod_libreta
   INTO	_cod_libreta
   FROM	coblibre c
  WHERE c.asignado_para  = a_sucursal
	AND c.origen_libreta = 1
	AND c.tipo_libreta   = 1
    and c.usada          = 0
    and c.cod_libreta    <> as_libreta
exit foreach;
end foreach

foreach
select cod_cobrador
  into _cod_cobrador
  from cobcobra
 where cod_libreta = _cod_libreta
exit foreach;
end foreach

if a_cobrador <> _cod_cobrador then
	let _cnt = 0;
else
	let _cnt = 1;
end if

RETURN _cnt;

END PROCEDURE;
