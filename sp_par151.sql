-- Depuracion de la tabla de Clientes

-- Creado    : 06/04/2005 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_par151;

create procedure "informix".sp_par151(a_nombre char(100))


foreach
 select cod_cliente,   
        nombre,   
        cedula,   
        direccion_1,   
        telefono1
   from cliclien  
  where cliclien.nombre like :a_nombre
  order by nombre


end foreach


end procedure



