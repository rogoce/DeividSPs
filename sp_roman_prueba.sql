-- procso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- creado    : 08/08/2012 - autor: roman gordon 

-- sis v.2.0 - deivid, s.a.

drop procedure sp_roman_prueba;

create procedure "informix".sp_roman_prueba(a_no_poliza char(10))
returning dec(16,2),
		  dec(16,2),
		  dec(16,2),
          dec(16,2);

define _monto_impuesto	dec(16,2);
DEFINE _prima_certif	dec(16,2);
define _prima_neta		dec(16,2);
define _prima_vida		dec(16,2); 
define _factor_imp_tot	dec(5,2);
define _factor_impuesto	dec(5,2);
define _porc_descuento	dec(5,2);
define _porc_recargo	dec(5,2); 
define _tiene_impuesto	smallint;
define _no_unidad		char(5);
define _cod_impuesto	char(3);
define _pagado_por		char(1);
define _impuesto		dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
	

begin
	LET _porc_descuento   = 0;
	LET _no_unidad      = NULL;
	FOREACH	
		SELECT no_unidad
		  INTO _no_unidad
		  FROM emiunide
		 WHERE no_poliza = a_no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN		  

		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF

	END IF

	-- Se Determina el Porcentaje de Recargo
	LET _no_unidad      = NULL;
	LET _porc_recargo   = 0;

   FOREACH	
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emiunire
	 WHERE no_poliza = a_no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN		  

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF

	END IF


select sum(prima_total),
	   sum(prima_vida)
  into _prima_certif,
	   _prima_vida
  from emipouni
 where no_poliza = a_no_poliza
   and activo    = 1;

let _descuento   = _prima_certif / 100 * _porc_descuento;
let _recargo     = (_prima_certif - _descuento) / 100 * _porc_recargo;
let _prima_neta  = _prima_certif - _descuento + _recargo;



let _monto_impuesto = 0;
let _tiene_impuesto = 0;
let _factor_imp_tot = 0;

foreach
 select	cod_impuesto
   into	_cod_impuesto
   from	emipolim
  where	no_poliza = a_no_poliza

	select factor_impuesto,
	       pagado_por
	  into _factor_impuesto,
		   _pagado_por	
	  from prdimpue
	 where cod_impuesto = _cod_impuesto;

	let _impuesto = (_prima_neta - _prima_vida) / 100 * _factor_impuesto;

--		if _pagado_por = 'a' then
		let _tiene_impuesto = 1;
		let _monto_impuesto = _monto_impuesto + _impuesto;		
		let _factor_imp_tot = _factor_imp_tot + _factor_impuesto;
end foreach

return _prima_neta,
	   _prima_vida,
	   _impuesto,
	   _monto_impuesto;
end
end procedure