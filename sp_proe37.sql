-- Procedimiento para buscar el valor del Recargo
-- f_emision_busca_recargo
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe22 pero para tablas de endoso.
-- 
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_proe37;
CREATE PROCEDURE "informix".sp_proe37(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5), a_prima DEC(16,2))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

LET ld_recargo = 0.00;
SELECT SUM(endunire.porc_recargo)
  INTO ld_porc_recargo
  FROM endunire, emirecar  
 WHERE endunire.no_poliza = a_poliza 
   AND endunire.no_endoso = a_endoso
   AND endunire.no_unidad = a_unidad
   AND emirecar.cod_recargo = endunire.cod_recargo;


If ld_porc_recargo IS NULL Then
   LET ld_porc_recargo = 0.00;
End If

LET ld_porc = ld_porc_recargo / 100;
LET ld_recargo = a_prima * ld_porc;


RETURN ld_recargo;
END
END PROCEDURE;