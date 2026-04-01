-- Informe de Cobros Rutero por Fecha
-- Creado    : 26/04/2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_cob206a;

CREATE PROCEDURE "informix".sp_cob206a(a_fecha date) 
       RETURNING CHAR(50),	-- 1. -Nombre del Cobrador de Calle
				 INTEGER,	-- 2. -Codigo del Cobrador
       			 DEC(12,2),	-- 3. -Monto cobTotal
				 DATE,		-- 4. -Fecha de inicio
				 CHAR(50),	-- 5. -Nombre del Cliente
			     CHAR(10),  -- 6. -Codigo del Cliente
				 CHAR(50),	-- 7. -Nombre de Motivo del No Cobro
				 CHAR(3);   -- 8. -Codigo del motivo

DEFINE v_poliza  	     CHAR(20);
DEFINE v_nombre_cliente  CHAR(50);
DEFINE v_nombre_cobrador CHAR(50);
DEFINE v_id_usuario 	 INTEGER;
DEFINE v_id_transaccion  INTEGER;
DEFINE v_no_poliza       CHAR(30);
DEFINE v_id_cliente      CHAR(30);
DEFINE v_total  	 	 DEC(12,2);
DEFINE v_total_det	 	 DEC(12,2);
DEFINE v_cod_cobrador    CHAR(3);
DEFINE v_fecha_inicio    datetime year to fraction(5);
DEFINE v_fecha           DATE;
DEFINE v_usuario         INTEGER;
DEFINE _id_motivo    	 INTEGER;
DEFINE v_turno           INTEGER;
DEFINE v_trans           INTEGER;
DEFINE _anulado          SMALLINT;
DEFINE _cod_motiv        CHAR(3);
DEFINE _nombre_motiv	 CHAR(50);
DEFINE _cod_cobrador     CHAR(3);
DEFINE _fecha_inicio     datetime year to fraction(5);
DEFINE _dia              DATE;
DEFINE _a_pagar          DEC(16,2);
DEFINE _cod_pagador      CHAR(50);
DEFINE v_cod_motiv       CHAR(3);
	   							 
SET ISOLATION TO DIRTY READ;
FOREACH																							 
    SELECT nombre,
	       cod_cobrador
	  INTO v_nombre_cobrador,
		   v_cod_cobrador 
	  FROM cobcobra
	 WHERE tipo_cobrador = "3"	-- rutero
	   AND activo        =  1

  	FOREACH
	    SELECT cod_motiv,
	           nombre 
	      INTO v_cod_motiv,
	           _nombre_motiv		   
	      FROM cobmotiv
	 
	-- Seleccionar los cobros por dia  --

		FOREACH
		    SELECT cod_cobrador,
		           dia_cobros1,
		           cod_motiv,
			       fecha,
				   a_pagar,
				   cod_pagador
			  INTO _cod_cobrador,
			       _dia,
			       _cod_motiv,
			       _fecha_inicio,
				   v_total_det,
				   _cod_pagador
			  FROM cobruhis
		     WHERE cod_cobrador = v_cod_cobrador  
			   AND date(fecha)  = a_fecha 
			   AND cod_motiv    = v_cod_motiv

		-- Seleccionar el Nombre del Cliente y Codigo de Pagador

			FOREACH
			   SELECT id_turno,
			          id_cliente,
			   	      id_transaccion,
			 		  nombre_cliente,
			     	  total,
			    	  id_motivo_abandono
			 	 INTO v_turno,
			 	      v_id_cliente,
			 	      v_id_transaccion,
			 	      v_nombre_cliente,
			 	      v_total,
			 	      _id_motivo
				 FROM cdmtransaccionesbk
			    WHERE id_cliente         = _cod_pagador
				  AND id_usuario         = v_cod_cobrador
				  AND id_motivo_abandono = _cod_motiv
		     	  AND date(fecha_inicio) = a_fecha   
		   	   
		     RETURN v_nombre_cobrador,--  1. Nombre del Cobrador de la calle
				   v_cod_cobrador,	  --  2. N£mero de usuario del Cobrador de Calle
				   v_total_det,       --  3. Monto a pagar en detalle
				   a_fecha,           --  4. Fecha de Inicio
				   v_nombre_cliente,  --  5. Nombre del Cliente
				   v_id_cliente,  	  --  6. Codigo del Cliente
				   _nombre_motiv,     --  7. Nombre del Motivo
				   _cod_motiv         --  8. Codigo del Motivo
			   
		     WITH RESUME;
	     END FOREACH;		
	    END FOREACH;	
	   END FOREACH;
	  END FOREACH;	   
     END PROCEDURE;



						
