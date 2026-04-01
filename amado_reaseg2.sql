-- Buscar la prima anual de la poliza

-- Creado    : 09/06/2010 - Autor: Amado Perez M. 

drop procedure amado_reaseg2;

create procedure "informix".amado_reaseg2(a_poliza char(10), a_endoso char(5), a_unidad char(5), a_cober_reas char(3), a_cod_contrato char(5),a_porc_partic_sum dec(9,6), a_porc_partic_prim dec(9,6), a_suma dec(16,2), a_prima dec(16,2))
returning integer;

define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_unidad	char(5);
define _cod_contrato char(5);
define _cod_cober_reas char(3);
define _porc_partic_suma dec(9,6); 
define _porc_partic_prima dec(9,6);
define _no_documento char(20); 
define _no_factura char(10); 

define _suma_asegurada dec(16,2); 
define _prima dec(16,2); 

SET ISOLATION TO DIRTY READ;


foreach
	select porc_partic_suma, porc_partic_prima, suma_asegurada, prima
	  into _porc_partic_suma, _porc_partic_prima, _suma_asegurada, _prima
	  from emifacon
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad
	   and cod_cober_reas = a_cober_reas
	   and cod_contrato = a_cod_contrato

     If _porc_partic_suma <> a_porc_partic_sum or _porc_partic_prima <> a_porc_partic_prim or _suma_asegurada <> a_suma or _prima <> a_prima then
		insert into tmp_reaseg (
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cober_reas,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima,
			suma,
			prima)
		values (
			a_poliza,
			a_endoso,
			a_unidad,
			a_cober_reas,
			a_cod_contrato,
			a_porc_partic_sum,
			a_porc_partic_prim,
			a_suma,
			a_prima);
	   End If
end foreach

return 0;
end procedure 
