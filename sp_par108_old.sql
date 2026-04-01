	select sum(prima_suscrita),
	       sum(prima_retenida),
		   sum(prima),
		   sum(descuento),
		   sum(recargo),
		   sum(prima_neta),
		   sum(impuesto),
		   sum(prima_bruta)
	  into _prima_suscrita_unidad,
	       _prima_retenida_u,
		   _prima_u,
		   _descuento_u,
		   _recargo_u,
		   _prima_neta_u,
		   _impuesto_u,
		   _prima_bruta_u
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select count(*)
	  into _cantidad
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	let _error    = 0;

	if abs(_prima_suscrita_endoso - _prima_suscrita_unidad) > 0.05 then

		let _error    = 1;

		return _no_factura,
		       _prima_suscrita_endoso,
			   _prima_suscrita_unidad,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   1,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc	
			   with resume;

	end if



	if abs(_prima_retenida - _prima_retenida_u) > 0.05 then

{
		foreach
		 select no_unidad
		   into _no_unidad
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			select sum(prima)
			  into _prima_emifacon
			  from emifacon f, reacomae c
			 where f.cod_contrato  = c.cod_contrato
			   and f.no_poliza     = _no_poliza
			   and f.no_endoso     = _no_endoso
			   and f.no_unidad     = _no_unidad
			   and c.tipo_contrato = 1;
				
			if _prima_emifacon is null then
				let _prima_emifacon = 0;
			end if

			update endeduni
			   set prima_retenida = _prima_emifacon							
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso
			   and no_unidad      = _no_unidad;
			
		end foreach
--}

		let _error    = 1;

		return _no_factura,
		       _prima_retenida,
			   _prima_retenida_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   2,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_prima - _prima_u) > 0.05 then

{
		if _cantidad = 1 then

			update endeduni
			   set prima     = _prima
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;

		else

			let _monto = _prima - _prima_u;
			
			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endeduni
				   set prima     = prima + _centavo
			     where no_poliza = _no_poliza
			       and no_endoso = _no_endoso
			       and no_unidad = _no_unidad;

			end foreach

		end if
--}
		let _error    = 1;

		return _no_factura,
		       _prima,
			   _prima_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   3,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_descuento - _descuento_u) > 0.05 then

{
		if _cantidad = 1 then

			update endeduni
			   set descuento = _descuento
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;

		end if
}
		let _error    = 1;

		return _no_factura,
		       _descuento,
			   _descuento_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   4,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_recargo - _recargo_u) > 0.05 then

		let _error    = 1;
{
		if _cantidad = 1 then

		else

			let _monto = _recargo - _recargo_u;
			
			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endeduni
				   set recargo   = recargo + _centavo
			     where no_poliza = _no_poliza
			       and no_endoso = _no_endoso
			       and no_unidad = _no_unidad;

			end foreach

		end if
--}
		return _no_factura,
		       _recargo,
			   _recargo_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   5,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_prima_neta - _prima_neta_u) > 0.05 then

		let _error    = 1;
{
		if _cantidad = 1 then

		else

			let _monto = _prima_neta - _prima_neta_u;
			
			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endeduni
				   set prima_neta = prima_neta + _centavo
			     where no_poliza  = _no_poliza
			       and no_endoso  = _no_endoso
			       and no_unidad  = _no_unidad;

			end foreach

		end if
--}
		return _no_factura,
		       _prima_neta,
			   _prima_neta_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   6,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_impuesto - _impuesto_u) > 0.05 then

{
		if _cantidad = 1 then

			update endeduni
			   set impuesto  = _impuesto
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;

		else

			let _monto = _impuesto - _impuesto_u;
			
			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endeduni
				   set impuesto  = impuesto + _centavo
			     where no_poliza = _no_poliza
			       and no_endoso = _no_endoso
			       and no_unidad = _no_unidad;

			end foreach

		end if
--}
		let _error    = 1;

		return _no_factura,
		       _impuesto,
			   _impuesto_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   7,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_prima_bruta - _prima_bruta_u) > 0.05 then

		let _error    = 1;
{
		if _cantidad = 1 then

			update endeduni
			   set prima_bruta = _prima_bruta
		     where no_poliza   = _no_poliza
		       and no_endoso   = _no_endoso;

		else

			let _monto = _prima_bruta - _prima_bruta_u;
			
			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endeduni
				   set prima_bruta = prima_bruta + _centavo
			     where no_poliza   = _no_poliza
			       and no_endoso   = _no_endoso
			       and no_unidad   = _no_unidad;

			end foreach

		end if
--}
		return _no_factura,
		       _prima_bruta,
			   _prima_bruta_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   8,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_prima - _descuento + _recargo - _prima_neta) > 0.05 then

		let _error    = 1;

{
		 select sum(prima),
				sum(prima_neta)
		   into _prima_uni_1,
				_prima_uni_2
		   from endedcob
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso;

		if _prima_uni_1 = _prima_uni_2 then

			update endedmae
			   set prima     = prima_neta
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;

			update endedhis
			   set prima     = prima_neta
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;

			update endeduni
			   set prima     = prima_neta
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;

		else
		
			select count(*)
			  into _cant_desc
			  from endunide
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;

			if _cant_desc <> 0 then

				update endedmae
				   set descuento = prima - prima_neta
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				update endedhis
				   set descuento = prima - prima_neta
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				update endeduni
				   set descuento = prima - prima_neta
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				update endedcob
				   set descuento = prima - prima_neta
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

			else

 				foreach
				 select no_unidad,
				        prima,
						prima_neta
				   into _no_unidad,
				        _prima_uni_1,
						_prima_uni_2
				   from endeduni
				  where no_poliza = _no_poliza
				    and no_endoso = _no_endoso

					if _prima_uni_1 = 0.00 then
						continue foreach;
					end if

					let _porc_descuento = 100 - (_prima_uni_2 / _prima_uni_1 * 100);

						insert into endunide
						values(
						_no_poliza,
						_no_endoso,
						_no_unidad,
						"001",
						_porc_descuento
						);
						
						select count(*)
						  into _cant_desc
						  from emiunide
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
						
						if _cant_desc = 0 then

							select count(*)
							  into _cant_desc
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = _no_unidad;
						
							if _cant_desc <> 0 then

								insert into emiunide
								values(
								_no_poliza,
								_no_unidad,
								"001",
								_porc_descuento
								);

							end if
	
						end if

				end foreach

			end if

		end if
--}

		return _no_factura,
		       (_prima - _descuento + _recargo),
			   _prima_neta,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   9,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if
