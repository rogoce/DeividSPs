-- Procedimiento para buscar el valor del Recargo
-- f_emision_busca_recargo
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe22;
CREATE PROCEDURE sp_proe22(a_poliza CHAR(10), a_unidad CHAR(5), a_prima DEC(16,2))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo,_ld_prima_au  DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\sp_pro44.trc";
-- TRACE ON;                                                                     

LET ld_recargo = 0.00;
let _ld_prima_au = a_prima;
foreach
	SELECT emiunire.porc_recargo
	  INTO ld_porc_recargo
	  FROM emiunire, emirecar  
	 WHERE emiunire.no_poliza = a_poliza  
	   AND emiunire.no_unidad = a_unidad
	   AND emirecar.cod_recargo = emiunire.cod_recargo

	If ld_porc_recargo IS NULL Then
	   LET ld_porc_recargo = 0.00;
	End If

	LET ld_porc = ld_porc_recargo / 100;
	LET ld_recargo = ld_recargo + _ld_prima_au * ld_porc;
    let _ld_prima_au = _ld_prima_au + ld_recargo;
end foreach


RETURN ld_recargo;
END
END PROCEDURE;