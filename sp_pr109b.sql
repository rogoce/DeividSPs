-- Reporte de Total de Produccion de Reaseguro por Grupo
-- 
-- Creado    : 09/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 09/08/2000 - Autor: Lic. Armando Moreno
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pr109b;

CREATE PROCEDURE "informix".sp_pr109b(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 
RETURNING CHAR(10),
            DECIMAL(16,2), 
            DECIMAL(16,2), 
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2);

define _no_factura			char(10);
DEFINE v_total_prima_sus	DECIMAL(16,2);
DEFINE v_total_prima_ced 	DECIMAL(16,2);
DEFINE v_total_prima_ret 	DECIMAL(16,2);
DEFINE v_comision  		 	DECIMAL(16,2);
DEFINE _impuesto 			DECIMAL(16,2);
DEFINE _comision_rea_ced	DECIMAL(16,2);

define v_filtros			char(255);
define _comision			dec(16,2);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET v_filtros = sp_pro109(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

let _comision = 0.00;

FOREACH 
 SELECT no_factura,
		sum(total_pri_sus),
		sum(total_pri_ced),
		sum(total_pri_ret),
		sum(comision_corredor),
		sum(impuesto),
		sum(comision_rea_ced)
   INTO _no_factura,
		v_total_prima_sus,
		v_total_prima_ced,
		v_total_prima_ret,
		v_comision,
		_impuesto,
		_comision_rea_ced
   FROM tmp_prod
  WHERE seleccionado = 1
  group by no_factura
  order by no_factura

	select sum(monto_comision)
	  into _comision
	  from comision2
	 where no_factura = _no_factura;

	if _comision is null then
		let _comision = 0.00;
	end if

	let _impuesto = _comision;

	if _comision <> _comision_rea_ced then

	  RETURN  _no_factura,
	   		  v_total_prima_sus,
			  v_total_prima_ced,
			  v_total_prima_ret,
			  v_comision,
			  _impuesto,
			  _comision_rea_ced
			  WITH RESUME;

	end if

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
