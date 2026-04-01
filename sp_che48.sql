-- Procedimiento que Genera el Proceso Intermedio de Seleccion
-- de a cuales corredores se generaran los cheques  

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che48;

CREATE PROCEDURE sp_che48(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE
) RETURNING INTEGER,
			CHAR(50);
			

SET ISOLATION TO DIRTY READ;

-- Genera los registros de las comisiones

--drop table tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
0
);

-- Genera el archivo para las comisiones de Ducruet

execute procedure sp_che28(a_fecha_desde, a_fecha_hasta);

drop table tmp_agente;
 
return 0, "Actualizacion Exitosa";

end procedure