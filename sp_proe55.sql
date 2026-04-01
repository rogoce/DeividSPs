-- Procedimiento para buscar el valor del Recargo del dependiente
-- f_emision_busca_recargo
--
-- Creado    : 25/10/2010 - Autor: Amado Perez M.
-- Modificado: 25/10/2010 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe55;
CREATE PROCEDURE "informix".sp_proe55(a_poliza CHAR(10), a_unidad CHAR(5))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);
DEFINE _cod_cliente             CHAR(10);
DEFINE ld_recargo_tot	   		DECIMAL(16,2);
DEFINE _prima 					DECIMAL(16,2);
DEFINE _meses                   SMALLINT;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\sp_pro44.trc";
-- TRACE ON;                                                                     

LET ld_recargo = 0.00;
LET ld_recargo_tot = 0.00;


FOREACH	WITH HOLD
	SELECT prima, cod_cliente
	  INTO _prima, _cod_cliente
	  FROM emidepen  
	 WHERE emidepen.no_poliza = a_poliza  
	   AND emidepen.no_unidad = a_unidad
	   AND emidepen.activo = 1

	IF _prima IS NULL THEN
		LET _prima = 0.00;
	END IF

	SELECT por_recargo
	  INTO ld_porc_recargo
	  FROM emiderec
	 WHERE no_poliza = a_poliza  
	   AND no_unidad = a_unidad
	   AND cod_cliente = _cod_cliente;

	IF ld_porc_recargo IS NULL THEN
		LET ld_porc_recargo = 0.00;
	END IF

    --LET _prima = _prima * _meses;

    LET ld_recargo = _prima * ld_porc_recargo / 100;

	IF ld_recargo IS NULL THEN
		LET ld_recargo = 0.00;
	END IF

    LET ld_recargo_tot = ld_recargo_tot + ld_recargo;

END FOREACH

IF ld_recargo_tot IS NULL THEN
	LET ld_recargo_tot = 0.00;
END IF

RETURN ld_recargo_tot;
END
END PROCEDURE;