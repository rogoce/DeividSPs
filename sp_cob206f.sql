-- Creado    : 08/06/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.
--
DROP PROCEDURE sp_cob206f;

CREATE PROCEDURE "informix".sp_cob206f(a_fecha date, a_fechaf date) 						 
       RETURNING   		 CHAR(50),	-- 1. -Nombre del Cobrador de Calle						  
						 CHAR(3),	-- 2. -Codigo del Cobrador 								 
       					 CHAR(20),  -- 3. -P¢liza											 
						 DEC(16,2),	-- 4. -Monto cobTotal									 
						 date,      --5. -Fecha de Programaci¢n			                     
						 CHAR(50),	-- 6. -Nombre del Cliente								  
			     		 CHAR(10),  -- 7. -Codigo del Cliente								 
						 char(1),	-- 8. -Anulado											 
						 char(10),	-- 9. -Fecha de Programaci¢n 							 
						 VARCHAR(20),	--10  -Tipo de pago
						 char(10);

DEFINE v_poliza  	     CHAR(20);
DEFINE v_nombre_cliente  CHAR(50);
DEFINE v_nombre_cobrador CHAR(50);
DEFINE v_id_usuario 	 INTEGER;
DEFINE v_id_transaccion  INTEGER;
DEFINE v_no_poliza       CHAR(10);
DEFINE v_id_cliente      CHAR(10);
DEFINE v_total  	 	 DEC(16,2);
DEFINE v_total_det	 	 DEC(16,2);
DEFINE v_cod_cobrador    CHAR(3);
DEFINE v_fecha_inicio    datetime year to fraction(5);
DEFINE v_fecha           DATE;
DEFINE v_usuario         INTEGER;
DEFINE _id_motivo    	 INTEGER;
DEFINE v_turno           INTEGER;
DEFINE v_trans           INTEGER;
DEFINE _anulado          SMALLINT;
DEFINE _secuencia        INTEGER;
DEFINE _id_tipo_cobro    integer;
DEFINE _tipo_pago        VARCHAR(20);
DEFINE v_recibo          char(10);
define _tipo_mov         char(1);
define _renglon          integer;
define _no_remesa        char(10);
define _no_poliza        char(10);

	   
SET ISOLATION TO DIRTY READ;

FOREACH

    SELECT nombre,
	       cod_cobrador
	  INTO v_nombre_cobrador,
		   v_cod_cobrador 
	  FROM cobcobra
   	 WHERE tipo_cobrador = "3"	--rutero
       AND activo        =  1
	   AND cod_sucursal  = "001"
 
	FOREACH

		select no_remesa
		  into _no_remesa
		  from cobremae
		 where cod_cobrador = v_cod_cobrador
		   and fecha between  a_fecha AND a_fechaf 

		foreach

	     	SELECT no_recibo,
				   doc_remesa,
				   tipo_mov,
				   monto,
				   fecha,
				   renglon,
				   no_remesa,
				   desc_remesa,
				   no_poliza
			  INTO v_recibo,
				   v_poliza,
				   _tipo_mov,
				   v_total,
				   v_fecha,
				   _renglon,
				   _no_remesa,
				   v_nombre_cliente,
				   _no_poliza
			  FROM cobredet
			 WHERE no_remesa  = _no_remesa
	   	     ORDER BY fecha

			 select cod_pagador
			   into v_id_cliente
			   from emipomae
			  where no_poliza = _no_poliza;

			 select nombre
			   into v_nombre_cliente
			   from cliclien
			  where cod_cliente = v_id_cliente;
			 

			 let _tipo_pago = '';

			   FOREACH
				    SELECT tipo_pago
				      INTO _id_tipo_cobro
					  FROM cobrepag
				 	 WHERE no_remesa  = _no_remesa
				 	   and renglon    = _renglon

						                 
						if _id_tipo_cobro = 1 then
							let _tipo_pago = _tipo_pago || '-E-';
						elif _id_tipo_cobro = 2 then
							let _tipo_pago = _tipo_pago || '-CH-';
						elif _id_tipo_cobro = 3 then
							let _tipo_pago = _tipo_pago || '-CLV-';
					   	elif _id_tipo_cobro = 4 then
							let _tipo_pago = _tipo_pago || '-TC-';
						end if

			   END FOREACH

				    RETURN v_nombre_cobrador, --  1. Nombre del Cobrador de la calle
						   v_cod_cobrador,	  --  2. Numero de usuario del Cobrador de Calle
						   v_poliza,		  --  3. P¢liza
						   v_total,           --  4. Monto a pagar en detalle
						   v_fecha,           --  5. Fecha de Inicio
						   v_nombre_cliente,  --  6. Nombre del Cliente
						   v_id_cliente,  	  --	 7. Codigo del Cliente 
						   _tipo_mov,          --  8. tipo movimiento
						   v_recibo,		  --	 9
						   _tipo_pago,
						   _no_remesa       
					  WITH RESUME;

		end foreach

	END FOREACH;
END FOREACH;

END PROCEDURE;



						
