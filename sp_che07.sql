-- Procedimiento que Actualiza los Datos Finales
-- usada en las comisiones de corredores 

-- Creado    : 27/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 27/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 21/08/2019 - Autor: Amado Perez Mendoza
--                                 Se dropea la tabla tmp_arrastre

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che07;

CREATE PROCEDURE sp_che07(
a_compania       CHAR(3),
a_sucursal       CHAR(3),
a_fecha_hasta	 DATE
) 

UPDATE parparam
   SET agt_fecha_comis = a_fecha_hasta
 WHERE cod_compania    = a_compania;

UPDATE chqpagco
   SET generado    = 1,
       fecha_fin   = current
 WHERE fecha_hasta = a_fecha_hasta;
   			
DROP TABLE tmp_ramo;
--DROP TABLE tmp_arrastre;

END PROCEDURE;