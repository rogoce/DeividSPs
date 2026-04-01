-- Procedimiento que extrae los datos del Rutero (Cobruter1)
-- 
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 20/11/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob108;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_cob108(a_cobrador CHAR(3), a_dia INT) 
       RETURNING	    INT,  	  	-- Dia Uno
						INT,	  	-- Dia Dos
						CHAR(3),    -- cod_motiv
						CHAR(100),	-- Asegurado
						DEC(16,2),	-- Saldo
						DEC(16,2),	-- Por vencer
						DEC(16,2),	-- Exigible
						DEC(16,2),	-- Corriente
						DEC(16,2),	-- Monto 30
						DEC(16,2),	-- Monto 60
						DEC(16,2),	-- Monto 90
						DEC(16,2),	-- A_pagar
						DATETIME YEAR TO FRACTION(5), -- fecha
						CHAR(5),
						INT,  	  	-- Dia Uno otro
						CHAR(10),
						SMALLINT,
						CHAR(10),
						SMALLINT,
						CHAR(3);

DEFINE v_orden2,v_orden1,_pago_fijo  SMALLINT;
DEFINE _tipo_labor		 SMALLINT;
DEFINE v_dia1			 INT;
DEFINE v_dia2            INT;
DEFINE v_motiv  		 CHAR(3);
DEFINE _cia		         CHAR(3);
DEFINE _suc		         CHAR(3);
DEFINE v_asegurado       CHAR(100);
DEFINE v_prima_orig      DEC(16,2);
DEFINE v_saldo           DEC(16,2);
DEFINE v_por_vencer      DEC(16,2);	 
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente		 DEC(16,2);
DEFINE v_monto_30		 DEC(16,2);
DEFINE v_monto_60		 DEC(16,2);
DEFINE v_monto_90		 DEC(16,2);
DEFINE v_apagar          DEC(16,2);
DEFINE _code_agente      CHAR(5);				  
DEFINE _cod_pagador      CHAR(10);
DEFINE _cod_cobrador     CHAR(3);
DEFINE _fecha_dt         DATETIME YEAR TO FRACTION(5);
DEFINE _periodo          CHAR(7);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
define _user_added		 char(8);

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

LET v_por_vencer = 0;
LET v_exigible   = 0;
LET v_corriente  = 0; 
LET v_monto_30   = 0;  
LET v_monto_60   = 0;  
LET v_monto_90   = 0;
LET v_saldo	     = 0;
LET _cod_pagador = null;
LET _code_agente = null;
LET v_dia1       = null;
LET _fecha_dt    = null;
LET v_apagar     = null;
LET v_motiv		 = null;
LET v_dia2		 = null;
LET _tipo_labor  = 0;
let _pago_fijo	 = 0;
FOREACH
 -- Lectura de Cobruter1	
		SELECT cod_cobrador,
			   cod_motiv,
			   a_pagar,      
			   saldo,       
			   por_vencer,  
			   exigible,    
			   corriente,   
			   monto_30,    
			   monto_60,    
			   monto_90,    
			   dia_cobros1,	
			   dia_cobros2,
			   fecha,
			   orden_1,
			   orden_2,
			   cod_agente,
			   cod_pagador,
			   user_added,
			   tipo_labor
		  INTO _cod_cobrador,
		       v_motiv,
			   v_apagar,
			   v_saldo,     
			   v_por_vencer,
			   v_exigible,  
			   v_corriente,	
			   v_monto_30,	
			   v_monto_60,	
			   v_monto_90,	
			   v_dia1,
			   v_dia2,
			   _fecha_dt,
			   v_orden1,
			   v_orden2,
			   _code_agente,
			   _cod_pagador,
			   _user_added,
			   _tipo_labor
		  FROM cobruter1
		 WHERE cod_cobrador  = a_cobrador
		   AND (dia_cobros1  = a_dia
		    OR  dia_cobros2  = a_dia)
	     ORDER BY orden_2,orden_1

--Lectura de Corredor si la poliza es null
 IF _cod_pagador IS NULL THEN
   let _cod_pagador = " ";
   SELECT nombre
     INTO v_asegurado
     FROM agtagent
    WHERE cod_agente = _code_agente;
 ELSE
 --if _cod_pagador = "32598" or _cod_pagador = "46799" or _cod_pagador = "58672"	then
 -- continue foreach;
 --end if
	--Lectura de Asegurado
   let _code_agente = " ";
	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;

 END IF		 
   foreach
		SELECT pago_fijo
		  INTO _pago_fijo
		  FROM cascliente
		 WHERE cod_cliente = _cod_pagador

		if _pago_fijo = 1 then
		else
			let _pago_fijo = 0;
		end if
   end foreach;

	RETURN v_dia1,	   
		   v_dia2,      
		   v_motiv,
		   v_asegurado, 
		   v_saldo,     
		   v_por_vencer,
		   v_exigible,  
		   v_corriente,	
		   v_monto_30,	
		   v_monto_60,	
		   v_monto_90,	
		   v_apagar,
		   _fecha_dt,
		   _code_agente,
		   v_dia1,
		   _cod_pagador,
		   _pago_fijo,
		   _user_added,
		   _tipo_labor,
		   _cod_cobrador
		   WITH RESUME;

END FOREACH;
END PROCEDURE