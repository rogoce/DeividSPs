-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf59;
CREATE PROCEDURE "informix".sp_rwf59(a_incidente int)
returning char(10),
		  smallint,
		  char(3),
		  varchar(50),
		  smallint,
		  dec(16,2),
		  char(10);

define _no_tranrec	   	char(10);
define v_no_orden	   	char(10);
define v_no_reclamo	   	char(10);
define v_cod_ajustador 	char(3);	
define v_cod_proveedor 	char(10);
define v_nombre_cliente varchar(100);
define v_fecha_orden   	date;
define v_tipo_ord_comp 	char(1);
define v_actualizado   	smallint;
define v_monto		   	dec(16,2);
define v_transaccion   	char(10);
define v_user_added	   	char(8);
define v_no_tranrec	   	char(10);
define v_deducible	   	dec(16,2);
define v_renglon	   	smallint;
define v_no_parte	   	char(3);
define v_desc_orden	   	varchar(50);
define v_cantidad	   	smallint;
define v_valor		   	dec(16,2);

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;

FOREACH
	SELECT no_tranrec
	  INTO _no_tranrec
	  FROM rectrmae
	 WHERE wf_incidente = a_incidente

	FOREACH
		SELECT no_orden,
		       transaccion
		  INTO v_no_orden,
		       v_transaccion
		  FROM recordma
		 WHERE no_tranrec = _no_tranrec
		   AND actualizado = 1
		   AND tipo_ord_comp = "C"

         FOREACH 
         	SELECT renglon,
				   no_parte,
				   desc_orden,
				   cantidad,
				   valor
	          INTO v_renglon,
				   v_no_parte,
				   v_desc_orden,
				   v_cantidad,
				   v_valor
			  FROM recordde
			 WHERE no_orden = v_no_orden
			  
			RETURN v_no_orden,
			       v_renglon,
				   v_no_parte,
				   v_desc_orden,
				   v_cantidad,
				   v_valor,
				   v_transaccion WITH RESUME;
		 END FOREACH
	END FOREACH
END FOREACH
end procedure