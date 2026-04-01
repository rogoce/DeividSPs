--DROP procedure sp_amm14d;
--cuentas de Ach mal creadas
CREATE procedure "informix".sp_amm14d(a_cuenta char(17))
RETURNING   integer;

SET ISOLATION TO DIRTY READ;

DELETE FROM cobcutas WHERE no_cuenta = a_cuenta;
DELETE FROM cobcuhab WHERE no_cuenta = a_cuenta;

return 0;		   	
END PROCEDURE