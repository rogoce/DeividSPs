-- Procedimiento para buscar si existe el numero de placa
-- en otra poliza
-- Creado    : 24/06/2022 - Autor: Federico Coronado.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web70;

CREATE PROCEDURE "informix".sp_web70(
a_placa   CHAR(30), 
a_vig_ini DATE)
RETURNING   INTEGER,			 -- _error
			CHAR(20),			 -- ld_descuento
            DATE,				 -- ldt_vig_final
			CHAR(10)			 -- ls_unidad

DEFINE ldt_ff_unidad, ldt_ff_poliza		DATE;
DEFINE ldt_vig_final					DATE;
DEFINE ls_documento						CHAR(20);
DEFINE ls_unidad						CHAR(10);
DEFINE li_estatus, _error				INTEGER;
DEFINE v_motor                          varchar(30);

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe23.trc";      
--TRACE ON;                                                                     

LET _error = 0;

FOREACH
	SELECT no_motor
	  into v_motor
	  from emivehic
	 where placa = a_placa
	FOREACH
	   SELECT emipomae.no_documento, 
			  emipomae.estatus_poliza, 
			  emipouni.vigencia_final, 
			  emipomae.vigencia_final, 
			  emiauto.no_unidad
		 INTO ls_documento, 
			  li_estatus, 
			  ldt_ff_unidad, 
			  ldt_ff_poliza, 
			  ls_unidad
		 FROM emiauto, emipouni, emipomae
		WHERE emiauto.no_poliza    = emipouni.no_poliza
		  AND emiauto.no_unidad    = emipouni.no_unidad
		  AND emiauto.no_poliza    = emipomae.no_poliza
		  AND emiauto.no_motor     = v_motor
		  AND emipomae.actualizado = 1
		  AND emipouni.vigencia_inic <> emipouni.vigencia_final
		ORDER BY emipomae.vigencia_final DESC

	   LET _error = 0;

	   LET ldt_vig_final = ldt_ff_poliza;

	   IF ldt_vig_final > a_vig_ini AND li_estatus not in(2,3,4) THEN
		  LET _error = 1;
		  EXIT FOREACH;
	   END IF
	END FOREACH
END FOREACH

IF _error = 1 THEN
	RETURN _error, ls_documento, ldt_vig_final, ls_unidad;
ELSE
	RETURN _error, "", TODAY, "";
END IF
END

END PROCEDURE;