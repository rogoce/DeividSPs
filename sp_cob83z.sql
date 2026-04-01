-- Procedimiento que Genera la Remesa de los ACH

-- ref. sp_cob50;   : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Creado: 29/01/2002 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob83z;

CREATE PROCEDURE "informix".sp_cob83z() RETURNING SMALLINT,CHAR(100);

DEFINE _error_code,_no_tran      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(20); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(100);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_cliente   	CHAR(10);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _no_cuenta		CHAR(17);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(100);
DEFINE _monto_pol		DEC(16,2);
DEFINE _cargo_pol		DEC(16,2);
DEFINE _cod_pagador   	CHAR(10);
DEFINE _nombre_pagador 	CHAR(100);
DEFINE _cargo			DEC(16,2);
DEFINE _monto_rem		DEC(16,2);
define _cnt             integer;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Ach';
END EXCEPTION           

FOREACH

	SELECT no_documento
	  INTO _no_documento
	  FROM cobcutmp
	 WHERE rechazado = 0
	 order by 1

	--Leer las transacciones
	 SELECT count(*)
	   INTO	_cnt
	   FROM cobcutas
	  WHERE no_documento = _no_documento;	--transacciones aprobados

	if _cnt = 0 then
		RETURN 0, 'Actualizacion Exitosa, Remesa # ' || _no_documento with resume;
	end if

end foreach

RETURN 0, 'Actualizacion Exitosa, Remesa #'; 

END 

END PROCEDURE;
