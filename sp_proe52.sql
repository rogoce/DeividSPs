-- Procedimiento para buscar el valor del Recargo
-- f_emision_busca_recargo
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe52;
CREATE PROCEDURE "informix".sp_proe52(a_poliza CHAR(10), a_unidad CHAR(5), a_cliente CHAR(10), a_tarifa DEC(16,2))
			RETURNING   integer, char(50);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);
DEFINE _error             		INTEGER;

-- SET DEBUG FILE TO "\\sp_pro44.trc";
-- TRACE ON;            
                                                         
SET ISOLATION TO DIRTY READ;

BEGIN
	 ON EXCEPTION SET _error 
	 	rollback work;
		RETURN _error, "Error al actualizar la prima en emidepen";         
	 END EXCEPTION 



UPDATE emidepen 
   SET prima = a_tarifa
 WHERE no_poliza = a_poliza
   AND no_unidad = a_unidad
   AND cod_cliente = a_cliente
   AND activo = 1
   AND calcula_prima = 1;


RETURN 0, "Actualizacion Exitosa";
END
END PROCEDURE;