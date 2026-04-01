-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36bk2;

CREATE PROCEDURE "informix".sp_sis36bk2() 
RETURNING varchar(50);

DEFINE _cod_vendedor char(3);
DEFINE _nombre varchar(50);

-- Descomponer los periodos en fechas

foreach

select cod_vendedor,nombre
  into _cod_vendedor,_nombre
  from agtvende
  
update milan08
   set nombre_vendedor = _nombre
 where cod_vendedor = _cod_vendedor; 
 
return _nombre with resume;  
end foreach


END PROCEDURE;