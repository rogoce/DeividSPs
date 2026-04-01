-- Procedure que guarda la poliza que se envio a imprimir
-- desde el pool de impresion.


-- Creado    : 30/11/2009 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro999;

create procedure sp_pro999(a_no_poliza char(10),a_usuario char(8),a_documento char(20))
RETURNING smallint;


insert into emirenhis(
no_poliza,		  
no_documento,
fecha_renovo,
user_renovo
)
VALUES (
a_no_poliza,
a_documento,
current,
a_usuario);

return 0;
end procedure