-- Informe Anual para INUSE
-- Creado    : 18/04/2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.
-- DROP PROCEDURE sp_cob207a;

CREATE PROCEDURE "informix".sp_cob207a(a_fecha date, a_fechaf date, a_cob char(3)) 
       RETURNING   		 CHAR(50),	-- 1. -Nombre del Cobrador de Calle
						 CHAR(3),	-- 2. -Codigo del Cobrador 
       					 CHAR(30),  -- 3. -P¢liza
						 DEC(12,2),	-- 4. -Monto cobTotal
						 DATE,		-- 5. -Fecha de inicio
						 CHAR(50),	-- 6. -Nombre del Cliente
			     		 CHAR(10),  -- 7. -Codigo del Cliente
						 smallint,	-- 8. -Anulado
						 DATE;		-- 9. -Fecha de Programaci¢n 

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
	   
SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT nombre,
	       cod_cobrador
	  INTO v_nombre_cobrador,
		   v_cod_cobrador 
	  FROM cobcobra
   	 WHERE tipo_cobrador = "3"	
       AND activo        =  1
	   AND cod_cobrador  = a_cob
 
FOREACH
     	SELECT id_turno,
		       id_cliente,
			   id_transaccion,
			   nombre_cliente,
			   total,
			   fecha_inicio,
			   id_motivo_abandono
		  INTO v_turno,
			   v_id_cliente,
			   v_id_transaccion,
			   v_nombre_cliente,
			   v_total,
			   v_fecha,
			   _id_motivo
		  FROM cdmtransaccionesbk
		 WHERE id_usuario         = v_cod_cobrador 
		   AND (date(fecha_inicio) >= a_fecha) AND (date(fecha_inicio) <= a_fechaf )
   	     ORDER BY fecha_inicio

		let _anulado = 0;

		if v_total = 0 and _id_motivo is null then --cobro anulado
			let _anulado = 1;
		end if

		if v_total = 0 and _id_motivo is not null then --no cobrado por motivo
			let _anulado = 2;
		end if

		   FOREACH
			    SELECT cuenta,
					   monto	
			      INTO v_poliza,
				       v_total_det
				  FROM cdmtrandetallebk
			 	 WHERE id_transaccion = v_id_transaccion and
				       id_usuario     = v_cod_cobrador   and
				       id_turno       = v_turno
				   
			    RETURN v_nombre_cobrador,--  1. Nombre del Cobrador de la calle
					   v_cod_cobrador,	 --  2. Numero de usuario del Cobrador de Calle
					   v_poliza,		 --  3. P¢liza
					   v_total_det,      --  4. Monto a pagar en detalle
					   a_fecha,          --  5. Fecha de Inicio
					   v_nombre_cliente, --  6. Nombre del Cliente
					   v_id_cliente,  	 --	 7. Codigo del Cliente 
					   _anulado,         --  8. Anulado 
					   v_fecha			 --  9.	Fecha de Programaci¢n 
				  WITH RESUME;

		   END FOREACH;

       END FOREACH;

    END FOREACH;

END PROCEDURE;



						
