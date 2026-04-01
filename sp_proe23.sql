-- Procedimiento para buscar si existe el numero de motor 
-- en otra poliza
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 28/05/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe23;
CREATE PROCEDURE sp_proe23(
a_poliza  CHAR(10), 
a_motor   CHAR(30), 
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

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe23.trc";      
--TRACE ON;                                                                     

LET _error = 0;

--if a_motor = '1HZ0569629' then
--	RETURN _error, "", TODAY, "";
--end if

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
      AND emiauto.no_motor     = a_motor
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

IF _error = 1 THEN
	RETURN _error, ls_documento, ldt_vig_final, ls_unidad;
ELSE
	RETURN _error, "", TODAY, "";
END IF
END

END PROCEDURE;