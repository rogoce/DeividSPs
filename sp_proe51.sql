-- Procedimiento para buscar el valor del Recargo del dependiente
-- f_emision_busca_recargo
--
-- Creado    : 25/10/2010 - Autor: Amado Perez M.
-- Modificado: 25/10/2010 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe51;
CREATE PROCEDURE "informix".sp_proe51(a_poliza CHAR(10), a_unidad CHAR(5), a_cliente CHAR(10), a_prima DEC(16,2))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\sp_pro44.trc";
-- TRACE ON;                                                                     

LET ld_recargo = 0.00;
SELECT SUM(emiderec.por_recargo)
  INTO ld_porc_recargo
  FROM emiderec, emirecar  
 WHERE emiderec.no_poliza = a_poliza  
   AND emiderec.no_unidad = a_unidad
   AND emiderec.cod_cliente = a_cliente
   AND emirecar.cod_recargo = emiderec.cod_recargo;


If ld_porc_recargo IS NULL Then
   LET ld_porc_recargo = 0.00;
End If

LET ld_porc = ld_porc_recargo / 100;
LET ld_recargo = a_prima * ld_porc;


RETURN ld_recargo;
END
END PROCEDURE;