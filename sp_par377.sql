-- Procedimiento para buscar clientes con mala referencia para auto
--
-- creado: 10/08/2009 - Autor: Amado Perez M.

DROP PROCEDURE sp_par377;
CREATE PROCEDURE sp_par377(a_cod_cliente CHAR(10))
	RETURNING 	  SMALLINT;  --Incurrido bruto

DEFINE _cod_mala_refe        CHAR(3);
DEFINE _mala_referencia      SMALLINT;
DEFINE _bloqemirenaut      SMALLINT;

SET ISOLATION TO DIRTY READ;

let _cod_mala_refe = NULL;
let _bloqemirenaut = 0;

  select mala_referencia,
         cod_mala_refe  
	into _mala_referencia,
	     _cod_mala_refe
	from cliclien
   where cod_cliente = a_cod_cliente;

  if _mala_referencia = 1 then
	select bloqemirenaut
      into _bloqemirenaut
      from climalare
     where cod_mala_refe = _cod_mala_refe;	 
	 
    if _bloqemirenaut is null then
		let _bloqemirenaut = 0;
	end if
  end if  
        
  RETURN _bloqemirenaut;
END PROCEDURE
