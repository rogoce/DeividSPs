-- Verificacion de Descuentos por Unidad

DROP PROCEDURE sp_par32;

CREATE PROCEDURE "informix".sp_par32() 
returning char(20),
          char(10),
          date,
          date,
          date,
          char(100),
          dec(16,2),
          dec(16,2);

define _no_documento	char(20);
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_emision	date;
define _cant_uni		integer;
define _porcentaje		dec(16,2);
define _prima			dec(16,2);
define _prima_neta		dec(16,2);
define _error			integer;
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_endoso0		char(5);
define _cod_descuen		char(3);

--set debug file to "sp_par32.trc";
--trace on;

let _no_endoso0 = "00000";

FOREACH
 SELECT no_documento,
		no_poliza,
		vigencia_inic,
		vigencia_final,
		fecha_suscripcion,
		prima,
		prima_neta
   INTO _no_documento,
		_no_poliza,
		_vigencia_inic,
		_vigencia_final,
		_fecha_emision,
		_prima,
		_prima_neta
   FROM emipomae
  where actualizado = 1
    and descuento   = 0
	and recargo     = 0
	and prima_neta  <> prima
--	and no_poliza   = "67525"
    and cod_ramo    = "002"
  order by 5 desc

	select count(*)
	  into _cant_uni
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cant_uni is null or _cant_uni = 0 then

	   insert into endeduni(
	   		  no_poliza, 
	   		  no_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_cliente, 
	          suma_asegurada, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida)
	   select no_poliza, 
	   		  v_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_asegurado, 
	          suma_asegurada, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida
	   from emipouni
	  where no_poliza = v_poliza
	    and no_unidad = v_unidad;


		return _no_documento,
		       _no_poliza,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_emision,
			   "01 - Poliza sin Unidades",
			   _prima,
			   _prima_neta
			   with resume;

	elif _cant_uni = 1 then

		select sum(porc_descuento)
		  into _porcentaje
		  from emiunide
		 where no_poliza = _no_poliza;

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 0 then
			--{
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza;

			let _error = sp_proe01(_no_poliza, _no_unidad, "001"); -- Este procedure llama al proe02
			let _error = sp_proe03(_no_poliza, "001");
			--}

			return _no_documento,
			       _no_poliza,
				   _vigencia_inic,
				   _vigencia_final,
				   _fecha_emision,
				   "02 - Una Unidad Con Descuento",
				   _prima,
				   _porcentaje
				   with resume;
		else
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza;

			select sum(porc_descuento)
			  into _porcentaje
			  from endunide
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso0
			   and no_unidad = _no_unidad;

			if _porcentaje is null then
				let _porcentaje = 0;
			end if

			if _porcentaje <> 0 then

				begin 
				on exception in(-691)
				end exception
					{
					insert into emiunide
					select no_poliza,
					       no_unidad,
						   cod_descuen,
						   porc_descuento
					  from endunide
					 where no_poliza = _no_poliza
					   and no_endoso = _no_endoso0
					   and no_unidad = _no_unidad;
					--}
				end 
				return _no_documento,
				       _no_poliza,
					   _vigencia_inic,
					   _vigencia_final,
					   _fecha_emision,
					   "03 - Una unidad Con Descuento en Endoso 0",
					   _prima,
					   _prima_neta
					   with resume;
			else

				select min(no_endoso)
				  into _no_endoso
				  from endunide
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and porc_descuento <> 0;

				if _no_endoso is not null then
					{
					begin 
					on exception in(-268)
						foreach
						 select cod_descuen,
						        porc_descuento
						   into _cod_descuen,
						        _porcentaje
						   from endunide
						  where no_poliza = _no_poliza
						    and no_endoso = _no_endoso
						    and no_unidad = _no_unidad
								update emiunide
								   set porc_descuento = _porcentaje
								 where no_poliza      = _no_poliza
						           and no_unidad      = _no_unidad
								   and cod_descuen    = _cod_descuen;
						end foreach
					end exception
						insert into emiunide
						select no_poliza,
						       no_unidad,
							   cod_descuen,
							   porc_descuento
						  from endunide
						 where no_poliza = _no_poliza
						   and no_endoso = _no_endoso
						   and no_unidad = _no_unidad;
					end
					--}
					return _no_documento,
					       _no_poliza,
						   _vigencia_inic,
						   _vigencia_final,
						   _fecha_emision,
						   "04 - Una Unidad Con Descuento en Algun Endoso",
						   _prima,
						   _prima_neta
						   with resume;
				else
					 select sum(porc_descuento)
					   into _porcentaje
					   from emicobde
					  where no_poliza = _no_poliza;
					    
					if _porcentaje <> 0 then
						{
						foreach
						 select porc_descuento
						   into _porcentaje
						   from emicobde
						  where no_poliza = _no_poliza
								exit foreach;
						end foreach
						insert into emiunide
						values(_no_poliza,
						       _no_unidad,
							   "001",
							   _porcentaje);
						--}
						return _no_documento,
						       _no_poliza,
							   _vigencia_inic,
							   _vigencia_final,
							   _fecha_emision,
							   "05 - Una Unidad Con Descuento en Coberturas",
							   _prima,
							   _porcentaje
							   with resume;
					else
						if _prima = 0 then
							let _porcentaje = 100;
						else
							let _porcentaje = 100 * ((_prima - _prima_neta)/_prima);
						end if
						if _porcentaje >= 5 and _porcentaje <= 50 then
							{
							let _error = sp_proe02(_no_poliza, _no_unidad, "001"); 
							let _error = sp_proe03(_no_poliza, "001");
							--}
							{
							insert into emiunide
							values(_no_poliza,
							       _no_unidad,
								   "001",
								   _porcentaje);
							return _no_documento,
							       _no_poliza,
								   _vigencia_inic,
								   _vigencia_final,
								   _fecha_emision,
								   "06 - Porcentaje entre 5 y 50",
								   _prima,
								   _porcentaje
								   with resume;
							--}
						elif _porcentaje < 0 then
							{
							let _error = sp_proe02(_no_poliza, _no_unidad, "001"); 
							let _error = sp_proe03(_no_poliza, "001");
							--}
							return _no_documento,
							       _no_poliza,
								   _vigencia_inic,
								   _vigencia_final,
								   _fecha_emision,
								   "07 - Porcentaje Menor Que Cero",
								   _prima,
								   _porcentaje
								   with resume;
						else
							{
							let _error = sp_proe02(_no_poliza, _no_unidad, "001"); 
							let _error = sp_proe03(_no_poliza, "001");
							--}
							return _no_documento,
							       _no_poliza,
								   _vigencia_inic,
								   _vigencia_final,
								   _fecha_emision,
								   "08 - Una Unidad Sin Descuento en Endoso 0",
								   _prima,
								   _porcentaje
								   with resume;
						end if
					end if
				end if
			end if
		end if

	else

		{
		foreach 
		 select no_unidad
		   into _no_unidad
		   from emipouni
		  where no_poliza = _no_poliza

			 select sum(porc_descuento)
			   into _porcentaje
			   from emicobde
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad;

			if _porcentaje <> 0 then
				foreach
				 select porc_descuento
				   into _porcentaje
				   from emicobde
				  where no_poliza = _no_poliza
				    and no_unidad = _no_unidad
						exit foreach;
				end foreach
				insert into emiunide
				values(_no_poliza,
				       _no_unidad,
					   "001",
					   _porcentaje);
			end if
--			let _error = sp_proe02(_no_poliza, _no_unidad, "001"); 
		end foreach
--		let _error = sp_proe03(_no_poliza, "001");
		--}

		return _no_documento,
		       _no_poliza,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_emision,
			   "20 - Mas de una unidad",
			   _prima,
			   _prima_neta
			   with resume;
	end if

end foreach

END PROCEDURE 

