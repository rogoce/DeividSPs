-- Procedimiento que cambia la comision para los traspasos de cartera
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par188;		

CREATE PROCEDURE "informix".sp_par188(
a_cod_cober_reas	char(3),
a_tipo_contrato		smallint,
a_porc_comision		dec(16,2),
a_porc_impuesto		dec(16,2)
)

define _cod_contrato	char(5);

foreach
 select cod_contrato
   into _cod_contrato
   from reacomae
  where tipo_contrato = a_tipo_contrato

	update reacocob
	   set porc_comision  = a_porc_comision,
	       porc_impuesto  = a_porc_impuesto
	 where cod_contrato   = _cod_contrato
	   and cod_cober_reas = a_cod_cober_reas;
	

end foreach

end procedure
