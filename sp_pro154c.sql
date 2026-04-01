-- Procedure para el cambio de tarifas por el cambio de edad

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro154_dw1 - DEIVID, S.A.

drop procedure sp_pro154c;

create procedure sp_pro154c(
a_compania	char(3),
a_sucursal	char(3),
a_fecha		date,
a_periodo 	char(7)
)
returning char(20),
          date,
		  date,
		  char(10),
		  smallint,
		  dec(16,2),
		  char(5),
		  dec(16,2),
		  dec(16,2),
		  char(100),
		  smallint,
		  char(50);

define _cantidad		smallint;
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _prima_total		dec(16,2);
define _fecha_nac	  	date;
define _edad		  	smallint;
define _prima_plan	  	dec(16,2);
define _prima_vida	  	dec(16,2);
define _vigencia_inic 	dec(16,2);
define _vigencia_final	dec(16,2);
define _no_documento  	char(20);
define _producto_nuevo	char(5);
define _nombre_cliente	char(100);
define _anos			smallint;
define _tipo			char(50);

set isolation to dirty read;

foreach
 SELECT no_poliza,
		vigencia_inic,
		vigencia_final,
		no_documento
   INTO _no_poliza,
		_vigencia_inic,
		_vigencia_final,
		_no_documento
   FROM emipomae
  WHERE cod_ramo              = "018"
    AND estatus_poliza        = 1 -- Vigentes
    AND actualizado           = 1 -- Actualizado
	and cod_tipoprod          in ("001", "005")
	and month(vigencia_final) = a_periodo[6,7]
	and year(vigencia_final)  = a_periodo[1,4]

--	and cod_subramo in ("007", "008")
--    AND vigencia_final >= "01/08/2005"
--    AND vigencia_final <= "31/08/2005"

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select cod_asegurado,
	        cod_producto,
			prima_asegurado
	   into _cod_cliente,
	        _cod_producto,
			_prima_total
	   from emipouni
	  where no_poliza = _no_poliza

		let _tipo = null;

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _edad = sp_sis78(_fecha_nac, today);
		let _anos = (_vigencia_final - _vigencia_inic) / 365;

		if _edad is null then
			let _tipo = "98 - Sin Edad";
		end if

		let _prima_plan = 0;
		let _prima_vida = 0;

		if _anos <> 0 then

			if month(_vigencia_inic) = a_periodo[6,7] and
			   year(_vigencia_final)  = a_periodo[1,4] then

				select producto_nuevo
				  into _producto_nuevo
				  from prdnewpro
				 where cod_producto = _cod_producto;

{
				if _producto_nuevo is not null and
				   _edad           is null then

					select edad_hasta
					  into _edad
					  from prdtaeda
					 where cod_producto = _cod_producto
					   and prima        = _prima_total;
					
					if _edad is not null then
						let _tipo = "02 - Tarifas Nuevas por Siniestrealidad - Estimando la Edad";
					end if

				end if
}

				if _producto_nuevo is not null then
					let _cod_producto = _producto_nuevo;
				end if

				select prima,
			           prima_vida
				  into _prima_plan,
			           _prima_vida
				  from prdtaeda
				 where cod_producto = _cod_producto
				   and edad_desde   <= _edad
				   and edad_hasta   >= _edad;

				if _prima_plan is null then
					if _tipo is null then
						let _tipo = "50 - No Encontro Primas para las Tarifas Nuevas";
					end if
				else
					if _prima_total > (_prima_plan + _prima_vida) then
						if _tipo is null then
							let _tipo = "51 - Prima Menor con el Cambio de Tarifa";
						end if
					else
						let _tipo = "01 - Tarifas Nuevas por Siniestrealidad";
					end if
				end if
			
			end if

		end if

		if _prima_total < (_prima_plan + _prima_vida) then
			if _tipo is null then
				let _tipo = "05 - Cambio de Prima por Cambio de Edad";
			end if
		end if

		if _prima_plan is null then
--			continue foreach;
		end if
		
		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
	
		if _anos = 0 then
--			continue foreach;
		end if


		if _tipo is null then
			let _tipo = "99 - Sin Cambios";
		end if

		if _tipo[1,2] in ("50", "98", "99") then
			let _prima_plan = _prima_total;
			let _prima_vida = 0;
		end if

		if _tipo[1,2] in ("50", "51") then

			return _no_documento,
				       _vigencia_inic,
				       _vigencia_final,
				       _cod_cliente,
					   _edad,
					   _prima_total,
				       _cod_producto,
					   _prima_plan,
					   _prima_vida,
					   _nombre_cliente,
					   _anos,
					   _tipo
					   with resume;

		end if


	end foreach

end foreach

end procedure




















