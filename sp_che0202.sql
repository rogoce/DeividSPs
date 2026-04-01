-- Procedimiento que Crea el Maestro Conciliador

-- Creado    : 02/11/2009 - Autor: Juan Plata
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che0202;

CREATE PROCEDURE sp_che0202(a_compania char(3),a_cod_banco char(3),a_cod_ctabanco char(4),a_tipo_proceso char(2),a_nodocmto char(10),a_ano_transac char(4),a_mes_transac char(2),a_estado char(2),a_monto decimal(15,2))
returning integer,char(50);

Define _registro        Integer;
define _fechamax	char(3);
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

 
 IF a_estado = "X" THEN 
  UPDATE  bcocirc 
	 SET estado    = "C",
	     ano_transac    = a_ano_transac,
         mes_transac    = a_mes_transac
    WHERE compania      = a_compania
      AND cod_banco     = a_cod_banco
      AND cod_ctabanco  = a_cod_ctabanco
      AND tipo_proceso  = a_tipo_proceso
      AND nodocmto      = a_nodocmto
	  AND monto         = a_monto;
 ELSE 
  UPDATE  bcocirc 
	 SET estado    = "R",
	     ano_transac    = a_ano_transac,
         mes_transac    = a_mes_transac
    WHERE compania      = a_compania
      AND cod_banco     = a_cod_banco
      AND cod_ctabanco  = a_cod_ctabanco
      AND tipo_proceso  = a_tipo_proceso
      AND nodocmto      = a_nodocmto
	  AND monto         = a_monto;
  END IF

 end

return 0, "Actualizacion Exitosa";

end procedure 
  