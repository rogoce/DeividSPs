-- Procedimiento que Retorna la Informacion de Cobros de los Clientes

-- Creado    : 30/04/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas082;

create procedure sp_cas082(a_cod_contratante CHAR(10))
returning char(100);	--_nombre,

define _nombre	          char(100);

set isolation to dirty read;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_contratante;


return _nombre;

end procedure