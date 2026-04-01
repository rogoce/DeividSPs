-- Procedimiento que Genera el Cheque para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che32;

CREATE PROCEDURE sp_che32(a_no_requis char(10)
) RETURNING INTEGER; 

DEFINE _no_requis	CHAR(10);
DEFINE _monto_banco	DEC(16,2);
DEFINE _banco_ach   CHAR(3);
DEFINE _comision	DEC(16,2);

define _renglon		smallint;
DEFINE _cuenta      CHAR(25);
define _origen_banc	char(3);
define _tipo_agente char(1);
define _cod_agente	char(5);
define _cod_subramo	char(3);
define _cod_ramo	char(3);
define _cod_origen	char(3);
define _origen_cheq	char(1);
define _error       integer;
define _error_desc  char(50);


--SET DEBUG FILE TO "sp_che32.trc"; 
--TRACE ON;                                                                

--BEGIN WORK;

let _cod_origen = "001";

foreach
 select	no_requis,
        cod_banco,
		monto,
		cod_agente,
		origen_cheque
   into _no_requis,
		_banco_ach,
		_monto_banco,
		_cod_agente,
		_origen_cheq
   From chqchmae
  where no_requis = a_no_requis

	if _origen_cheq = "2" or
	   _origen_cheq = "7" then
	else
		return 0;
	end if
	
	-- Registros Contables de Cheques de Comisiones

	call sp_par205(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if
	
END FOREACH

RETURN 0;

END PROCEDURE;