-- Procedimiento reversa comisiones


{
drop procedure sp_demetrio;

create procedure "informix".sp_demetrio(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10))
--}

--{
drop procedure comisaldo;

create procedure "informix".comisaldo()
returning smallint, char(50);
--}

define _cod_agente      char(5);
define _cod_ramo        char(3);
define _saldo           dec(16,2);
define _monto           dec(16,2);
DEFINE _error   			SMALLINT;

--- Actualizacion de Polizas

				
--SET DEBUG FILE TO "revercomi.trc"; 
--trace on;
begin work;

BEGIN

--SET isolation to dirty read;

ON EXCEPTION SET _error 
	rollback work;
 	RETURN _error, "Error al Actualizar Saldos";         
END EXCEPTION 


{FOREACH
	SELECT cod_agente,
	       saldo
	  INTO _cod_agente,
	       _saldo
	  FROM tmp_comi1

   UPDATE agtagent
      SET saldo = _saldo
	WHERE cod_agente = _cod_agente;
   
END FOREACH
}
FOREACH
	SELECT cod_agente,
	       cod_ramo,
	       expr1002
	  INTO _cod_agente,
	       _cod_ramo,
		   _monto
	  FROM tmp_comi2

   LET _monto = _monto * (-1);

   UPDATE agtsalra
      SET monto = monto + _monto
	WHERE cod_agente = _cod_agente
	  AND cod_ramo = _cod_ramo;
   
END FOREACH


end

commit work;

RETURN 0, "Actualizacion Exitosa";         
 
end procedure;