-- Busca proxima libreta disponible

-- Creado    : 31/07/2003 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob121c;

CREATE PROCEDURE "informix".sp_cob121c(a_sucursal CHAR(3), as_libreta char(5), a_cobrador char(3)) RETURNING integer;

DEFINE _cnt  smallint;

SET ISOLATION TO DIRTY READ;

 SELECT	count(*)
   INTO	_cnt
   FROM	coblibre c, cobcobra h
  WHERE c.cod_libreta = h.cod_libreta
    and c.asignado_para  = a_sucursal
	AND c.origen_libreta = 1
	AND c.tipo_libreta   = 1
    and c.usada          = 0
	and h.cod_cobrador   = a_cobrador;


RETURN _cnt;

END PROCEDURE;