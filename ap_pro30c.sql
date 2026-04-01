-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

drop procedure ap_pro30c;

create procedure ap_pro30c(a_no_poliza char(10))
returning smallint,
          char(50);

define _fecha_nac		date;
define _edad			smallint;
define _anos			smallint;
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _producto_nuevo	char(5);
define _prima_total		dec(16,2);
define _prima_plan		dec(16,2);
define _prima_vida		dec(16,2);
define _cantidad		smallint;

define _porc_descuento  dec(5,2);
define _porc_recargo    dec(5,2);
define _porc_impuesto   dec(5,2);
define _porc_coas       dec(7,4);

define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipoprod	char(3);

define _cod_perpago		char(3);
define _meses			smallint;

define _no_unidad		char(5);
define _prima			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _cambiar_tarifas	smallint;
define _no_documento	char(20);

define _error			smallint;
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);

DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
define _tar_salud       smallint;
define _cod_depend      CHAR(10);
define _prima_plan_dep	dec(16,2);
define _prima_vida_dep	dec(16,2);
define _tarifa_dep	    dec(16,2);
define _tarifa_dep_tot 	dec(16,2);
DEFINE _fecha_aniversario 	DATE;

--set debug file to "sp_pro30c.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Cambiar Tarifas...";
end exception

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

{select count(*)
  into _cantidad
  from prdsalno
 where no_documento = _no_documento;

if _cantidad >= 1 then
	return 0, "Actualizacion Exitosa...";
end if

select count(*)
  into _cantidad
  from emipouni
 where no_poliza = a_no_poliza;

if _cantidad > 1 then
	return 0, "Actualizacion Exitosa...";
end if
}
LET _ano_contable = YEAR(today);

IF MONTH(today) < 10 THEN
	LET _mes_contable = '0' || MONTH(today);
ELSE
	LET _mes_contable = MONTH(today);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;
--let _periodo = '2010-06';
foreach
 select cod_asegurado,
        cod_producto,
		prima_asegurado,
		no_unidad,
		cambiar_tarifas
   into _cod_cliente,
        _cod_producto,
		_prima_total,
		_no_unidad,
		_cambiar_tarifas
   from emipouni
  where no_poliza = a_no_poliza

{
	if _cambiar_tarifas = 0 then
		continue foreach;
	end if
}

	select vigencia_inic,
	       vigencia_final,
		   cod_perpago,
		   cod_tipoprod,
		   no_documento,
		   cod_subramo
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_perpago,
		   _cod_tipoprod,
		   _no_documento,
		   _cod_subramo
	  from emipomae
	 where no_poliza = a_no_poliza; 

	-- Verificacion si es Coaseguro Mayoritario

	IF _cod_tipoprod = "001" THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	let _edad = sp_sis78(_fecha_nac, today);

 {	if _edad is null then
		insert into prdsalex
		VALUES(_no_documento, _periodo, "EDAD DEL CLIENTE EN BLANCO");
		continue foreach;
	end if
 }
	let _anos = (_vigencia_final - _vigencia_inic) / 365;

 {	if _anos = 0 then
		insert into prdsalex
		VALUES(_no_documento, _periodo, "POLIZA AUN NO CUMPLE ANIVERSARIO");
		continue foreach;
	end if
 }
--	if month(_vigencia_inic) <> month(_vigencia_final) then	-- Para que?
--		continue foreach;
--	end if

	let _prima_plan   = 0;
	let _prima_vida   = 0;

	--let _cod_producto = sp_pro30d(a_no_poliza, _cod_producto);   Se quito porque era solo en 2006 -- Amado Perez M. 1/06/2008
	let _cod_producto = sp_pro30g(a_no_poliza, _cod_producto, _periodo); --  Se agrega para el cambio de tarifa 2010 -- Amado Perez M. 29/09/2010

    select tar_salud
	  into _tar_salud
	  from prdprod
	 where cod_producto = _cod_producto;

	select prima,
           prima_vida
	  into _prima_plan,
           _prima_vida
	  from prdtaeda
	 where cod_producto = _cod_producto
	   and edad_desde   <= _edad
	   and edad_hasta   >= _edad;


	if _prima_plan is null then
		insert into prdsalex
		VALUES(_no_documento, _periodo, "NO SE ENCONTRO PRIMA PARA EDAD");
		continue foreach;
	end if
	
    let _tarifa_dep_tot	= 0;  

    if _tar_salud = 5 then	--> Tarifas por edad (Aseg + Dep)

      FOREACH
		SELECT cod_cliente
		  INTO _cod_depend
		  FROM emidepen
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1

		SELECT fecha_aniversario
		  INTO _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_depend;

        LET _edad = sp_sis78(_fecha_aniversario);
        let _tarifa_dep = 0;
        let _prima_plan_dep = 0;
        let _prima_vida_dep = 0;
         
		select prima, _prima_vida
		  into _prima_plan_dep, _prima_vida_dep
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		if _prima_plan_dep is null then
			let _prima_plan_dep = 0;
		end if

		if _prima_vida_dep is null then
			let _prima_vida_dep = 0;
		end if

        let _tarifa_dep = _prima_plan_dep + _prima_vida_dep;

        UPDATE emidepen 
		   SET prima = _tarifa_dep
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1;

		let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;

	  END FOREACH
	  
	  let _prima_plan = _prima_plan + _tarifa_dep_tot; 

    end if

	{if _prima_total >= (_prima_plan + _prima_vida) then
		insert into prdsalex
		VALUES(_no_documento, _periodo, "PRIMA A COBRAR ES MENOR");
		continue foreach;
	end if
	}
-- Hasta Aqui las evaluaciones.

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		let _meses = 1;
	end if

	-- Porcentaje de Impuesto
	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_no_poliza;

	IF _porc_impuesto IS NULL THEN
		LET _porc_impuesto = 0;
	END IF

	let _porc_impuesto = _porc_impuesto / 100;

	-- Porcentaje de Descuento

	LET _porc_descuento = 0;

	SELECT SUM(porc_descuento)
	  INTO _porc_descuento
	  FROM emiunide
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_descuento IS NULL THEN
		LET _porc_descuento = 0;
	END IF

	-- Porcentaje de Recargo

	LET _porc_recargo   = 0;

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiunire
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_recargo IS NULL THEN
		LET _porc_recargo = 0;
	END IF

	-- Calculos

{	let _prima  		= _prima_plan * _meses;
	let _descuento 		= 0.00;
--		let _descuento  	= _prima / 100 * _porc_descuento;
	let _recargo		= 0.00;
--		let _recargo    	= (_prima - _descuento) / 100 * _porc_recargo;
	let _prima_neta 	= _prima - _descuento + _recargo;
	let _impuesto   	= _prima_neta * _porc_impuesto;
	let _prima_bruta	= _prima_neta + _impuesto;
	let _prima_suscrita = _prima_neta / 100 * _porc_coas;}
			
	let _prima  		= (_prima_plan + _prima_vida) * _meses;
	let _descuento 		= 0.00;
--		let _descuento  	= _prima / 100 * _porc_descuento;
	let _recargo		= 0.00;
--		let _recargo    	= (_prima - _descuento) / 100 * _porc_recargo;
	let _prima_neta 	= _prima - _descuento + _recargo;
	let _impuesto   	= (_prima_neta - _prima_vida) * _porc_impuesto;
	let _prima_bruta	= _prima_neta + _impuesto;
	let _prima_suscrita = _prima_neta / 100 * _porc_coas;

	set lock mode to wait; --> para que espere y no tranque la BD Amado 4/10/2010

	update emipouni
	   set cod_producto 	= _cod_producto,
	       prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   impuesto			= _impuesto,
		   prima_bruta 		= _prima_bruta,
		   prima_asegurado	= _prima_plan + _prima_vida,
		   prima_total		= _prima,
		   prima_suscrita   = _prima_suscrita
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad;

	update emipocob
	   set prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   prima_anual		= _prima
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad
	   and prima_anual      <> 0.00;

	-- Realiza el cambio automatico de la nueva prima

	-- En caso de que sean Tarjetas de Credito 

	update cobtacre
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;      	

	-- En caso de que sean ACH 

	update cobcutas
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;
	 
	set isolation to dirty read; --> cambiamos a dirty read para que no tranque Amado 4/10/2010      	

end foreach

end

return 0, "Actualizacion Exitosa...";

end procedure