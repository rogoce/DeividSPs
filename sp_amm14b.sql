--DROP procedure sp_amm14b;

CREATE procedure "informix".sp_amm14b()

DEFINE _cod_cliente    CHAR(10);
DEFINE _nombre         CHAR(50);


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT cod_cliente
   INTO _cod_cliente
   FROM emibenef

 select nombre
   into _nombre
   from cliclien
  where cod_cliente = _cod_cliente; 	

   UPDATE emibenef
     SET nombre = _nombre
   WHERE cod_cliente = _cod_cliente;

END FOREACH

FOREACH
 SELECT cod_cliente
   INTO _cod_cliente
   FROM endbenef

 select nombre
   into _nombre
   from cliclien
  where cod_cliente = _cod_cliente; 	

   UPDATE endbenef
     SET nombre = _nombre
   WHERE cod_cliente = _cod_cliente;

END FOREACH
END PROCEDURE