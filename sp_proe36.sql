-- Procedimiento para buscar el valor del descuento
-- f_emision_busca_descuento
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe21 pero para tablas de endoso.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_proe36;
CREATE PROCEDURE "informix".sp_proe36(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5), a_prima DEC(16,2))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return, li_orden  INTEGER;
DEFINE ld_porc, ld_porc_desc		DECIMAL(10,4);
DEFINE ld_descuento, ld_descuen_tot	DECIMAL(16,2);

DEFINE ls_cod_descuen		CHAR(3);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

LET ld_descuento = 0.00;
LET ld_descuen_tot = 0.00;
FOREACH
  SELECT emidescu.orden, endunide.cod_descuen,endunide.porc_descuento
    INTO li_orden, ls_cod_descuen, ld_porc_desc
    FROM emidescu, endunide  
   WHERE endunide.no_poliza = a_poliza
     AND endunide.no_endoso = a_endoso
     AND endunide.no_unidad = a_unidad 
     AND endunide.cod_descuen = emidescu.cod_descuen
  ORDER BY emidescu.orden

  LET ld_porc = ld_porc_desc / 100;
  LET ld_descuento = a_prima * ld_porc;
  LET a_prima = a_prima - ld_descuento;
  LET ld_descuen_tot = ld_descuen_tot + ld_descuento;

END FOREACH
--  LET ld_descuento = ld_descuento + (a_prima * ld_porc);

RETURN ld_descuen_tot;
END
END PROCEDURE;