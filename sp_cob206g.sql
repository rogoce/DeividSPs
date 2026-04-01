-- Creado    : 09/06/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.
--
--DROP PROCEDURE sp_cob206g;

CREATE PROCEDURE "informix".sp_cob206g(a_fecha date, a_fechaf date) 						 
       RETURNING   		 CHAR(10),							  
						 SMALLINT,						 
       					 CHAR(50),  					 
						 smallint,
						 CHAR(3),
						 integer,
						 CHAR(100),						  
						 DEC(16,2);											

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
define _no_remesa        char(10);
define _no_poliza        char(10);
define _renglon			 SMALLINT;
define _cod_banco		 char(3);
define _no_cheque		 integer;
define _girado_por		 char(100);
define _importe			 DEC(16,2);

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


			   FOREACH
				    SELECT tipo_pago,
					       renglon,
						   cod_banco,
						   no_cheque,
						   girado_por,
						   importe
				      INTO _id_tipo_cobro,
					       _renglon,
						   _cod_banco,
						   _no_cheque,
						   _girado_por,
						   _importe
					  FROM cobrepag
				 	 WHERE no_remesa  = _no_remesa

				    RETURN _no_remesa,
						   _renglon,
						   v_nombre_cobrador,
						   _id_tipo_cobro,
						   _cod_banco,
						   _no_cheque,
						   _girado_por,
						   _importe
					  WITH RESUME;

			   END FOREACH

	END FOREACH;
END FOREACH;

END PROCEDURE;



						
