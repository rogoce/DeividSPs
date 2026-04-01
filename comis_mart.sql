-- Consulta de Transacciones por requisicion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE comis_mart;

CREATE PROCEDURE comis_mart()
RETURNING INTEGER,
          char(100);

define v_no_requis     	   char(10);
define _error			integer;
define _error_desc		char(50);
define _cod_agente		char(5);
define _monto_his		dec(16,2);
define _cuenta 			char(25);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH	WITH HOLD
	SELECT no_requis,
	       cod_agente
	  INTO v_no_requis,
	       _cod_agente
	  FROM chqchmae 		  
	 WHERE origen_cheque IN ('2')
  --	   AND tipo_requis = "C"
	   AND fecha_captura >= '03/07/2006'

	call sp_par205(v_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error, v_no_requis;
	end if

	select sum(monto)
	  into _monto_his
	  from agtsalhi
	 where cod_agente = _cod_agente
	   and fecha_al = "30/06/2006";

	If _monto_his is null Then
		let _monto_his = 0;	
	end if

    If _monto_his <> 0 Then
   		LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);
		update chqchcta
		   set debito    = debito  + _monto_his
		 where no_requis = v_no_requis
		   and cuenta    = _cuenta;
	End if


END FOREACH

	RETURN 0, "listo";

END PROCEDURE;