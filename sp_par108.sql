drop procedure sp_par108;

create procedure sp_par108()
returning char(10),
          dec(16,2),
		  dec(16,2),
		  integer,
		  char(10),
		  char(5),
		  smallint,
		  char(7),
		  char(3),
		  char(3);

define _no_factura				char(10);
define _no_poliza					char(10);
define _periodo					char(7);
define _cod_cobertura				char(5);
define _cod_producto				char(5);
define _cod_contrato				char(5);
define _cod_endomov				char(3);
define _no_endoso					char(5);
define _no_unidad					char(5);
define _cod_ruta					char(5);
define _cod_cober_reas			char(3);
define _cod_tipocalc				char(3);
define _cod_ramo					char(3);
define _porc_partic_prima 		dec(9,6);
define _porc_partic_suma  		dec(9,6);
define _prima_suscrita_endoso	dec(16,2);
define _prima_suscrita_unidad	dec(16,2);
define _prima_retenida_u			dec(16,2);
define _prima_emifacon			dec(16,2);
define _prima_emifafac			dec(16,2);
define _prima_retenida			dec(16,2);
define _porc_impuesto				dec(16,2);
define _prima_bruta_u				dec(16,2);
define _prima_neta_u				dec(16,2);
define _prima_uni_1				dec(16,2);
define _prima_uni_2				dec(16,2);
define _prima_bruta				dec(16,2);
define _descuento_u				dec(16,2);
define _prima_neta				dec(16,2);
define _impuesto_u				dec(16,2);
define _descuento					dec(16,2);
define _recargo_u					dec(16,2);
define _impuesto					dec(16,2);
define _recargo					dec(16,2);
define _prima_u					dec(16,2);
define _centavo					dec(16,2);
define _prima						dec(16,2);
define _monto						dec(16,2);
define _porc_partic_coas			dec(16,4);
define _porc_descuento			dec(16,4);
define _repeticion				smallint;
define _ano						smallint;
define _serie						smallint;
define _orden						smallint;
define _cont_endhisfa				integer;
define _cant_desc					integer;
define _cantidad					integer;
define _error						integer;
define _vigencia_inic				date;

--set debug file to "sp_par108.trc";

set isolation to dirty read;

let _repeticion	= 0;

{
create table endhisfa(
no_factura char(10)
);
}

let _ano = year(today) - 2;
 
foreach
	select prima_suscrita,
		   no_poliza,
		   no_endoso,
		   no_factura,
		   prima,
		   descuento,
		   recargo,
		   prima_neta,
		   impuesto,
		   prima_bruta,
		   prima_retenida,
		   periodo,
		   cod_endomov,
		   cod_tipocalc,
		   vigencia_inic
	  into _prima_suscrita_endoso,
		   _no_poliza,
		   _no_endoso,
		   _no_factura,
		   _prima,
		   _descuento,
		   _recargo,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _prima_retenida,
		   _periodo,
		   _cod_endomov,
		   _cod_tipocalc,
		   _vigencia_inic
	  from endedhis
	 where actualizado   = 1
	   and periodo[1,4] >= _ano
--	and no_factura in("01-1298279")         --in ("07-07261")
-- 	and no_factura   = "01-613185"
--	and no_poliza    = "251599"
--	and periodo      >= "2007-01"
--	and user_added   = "GERENCIA"
--	and no_factura   in ("01-509227", "01-510885", "01-511023", "01-509227")
--	and cod_endomov  = "011"
--	and cod_tipocan  = "013"
--	and no_factura   in (select no_factura from endhisfa)
--	and no_factura   in (select no_factura from cobinc0601)
--	and periodo      = "2005-12"

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

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

	if _prima_suscrita_unidad is null then
		let _prima_suscrita_unidad = 0.00;
	end if
	
	if _prima_retenida_u is null then
		let _prima_retenida_u = 0.00;
	end if

	if _prima_u is null then
		let _prima_u = 0.00;
	end if

	if _descuento_u is null then
		let _descuento_u = 0.00;
	end if

	if _recargo_u is null then
		let _recargo_u = 0.00;
	end if

	if _prima_neta_u is null then
		let _prima_neta_u = 0.00;
	end if

	if _impuesto_u is null then
		let _impuesto_u = 0.00;
	end if

	if _prima_bruta_u is null then
		let _prima_bruta_u = 0.00;
	end if

	select count(*)
	  into _cantidad
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	let _error    = 0;

	if abs(_prima_suscrita_endoso - _prima_suscrita_unidad) > 0.50 then

		let _error    = 1;

		if _cantidad = 1 then
			update endeduni
			   set prima_suscrita = _prima_suscrita_endoso
		     where no_poliza      = _no_poliza
		       and no_endoso      = _no_endoso;
		end if
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

	continue foreach;

	if abs(_prima_retenida - _prima_retenida_u) > 0.05 then
{
		 update endedmae
			set prima_retenida = _prima_retenida_u
		  where no_poliza      = _no_poliza
	        and no_endoso      = _no_endoso;

		 update endedhis
			set prima_retenida = _prima_retenida_u
		  where no_poliza      = _no_poliza
	        and no_endoso      = _no_endoso;

--}

		if _cantidad = 1 then
			update endeduni
			   set prima_retenida = _prima_retenida
		     where no_poliza      = _no_poliza
		       and no_endoso      = _no_endoso;
		else
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
			}

		end if


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
		if _cantidad = 1 then
			update endeduni
			   set prima     = _prima
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;
		end if
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

			while _monto != 0.00

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
			end while
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
		if _cantidad = 1 then
			update endeduni
			   set descuento = _descuento 
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;
		else
			let _monto = _descuento - _descuento_u;
			
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
				   set descuento = descuento + _centavo
			     where no_poliza = _no_poliza
			       and no_endoso = _no_endoso
			       and no_unidad = _no_unidad;
			end foreach
		end if
		
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

			update endeduni
			   set recargo   = _recargo 
		     where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;

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

		if _cantidad = 1 then
			update endeduni
			   set prima_neta = _prima_neta
		     where no_poliza  = _no_poliza
		       and no_endoso  = _no_endoso;
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
			
			while _monto != 0.00

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

			end while

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

		let _error    = 1;{
		if _cantidad = 1 then

			update endeduni
			   set prima_bruta = _prima_bruta
		     where no_poliza   = _no_poliza
		       and no_endoso   = _no_endoso;

		else

			let _monto = _prima_bruta - _prima_bruta_u;
			
			while _monto != 0.00

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
			end while
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
		
		if _prima_neta < 0.00 and _descuento  > 0.00 then
				
			update endedmae
			   set descuento  = descuento * -1
			 where no_factura = _no_factura;

			update endedhis
			   set descuento  = descuento * -1
			 where no_factura = _no_factura;

		else
			update endedmae
			   set prima      = _prima_neta + _descuento - _recargo
			 where no_factura = _no_factura;

			update endedhis
			   set prima      = _prima_neta + _descuento - _recargo
			 where no_factura = _no_factura;

		end if

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

	if abs(_prima - _descuento + _recargo - _prima_neta) > 0.05 then

		let _error    = 1;
{
		if _cantidad = 1 then

			update endedmae
			   set prima      = _prima_neta + _descuento - _recargo
			 where no_factura = _no_factura;

			update endedhis
			   set prima      = _prima_neta + _descuento - _recargo
			 where no_factura = _no_factura;

			update endeduni
			   set prima       = _prima_neta + _descuento - _recargo
		     where no_poliza   = _no_poliza
		       and no_endoso   = _no_endoso;

		else

			let _monto = _prima - _descuento + _recargo - _prima_neta;
			
			while _monto != 0.00

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
					   set prima       = prima + _centavo
				     where no_poliza   = _no_poliza
				       and no_endoso   = _no_endoso
				       and no_unidad   = _no_unidad;

				end foreach

			end while

		end if
--}

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
			   10,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;
	end if

	select sum(prima)
	  into _prima_emifacon
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if abs(_prima_suscrita_endoso - _prima_emifacon) > 0.05 then
{
		if _cod_endomov = "018" then

			 update endedmae
				set prima_suscrita = _prima_emifacon
			  where no_poliza      = _no_poliza
			    and no_endoso      = _no_endoso;

			 update endedhis
				set prima_suscrita = _prima_emifacon
			  where no_poliza      = _no_poliza
			    and no_endoso      = _no_endoso;

		end if}

		foreach
			select no_unidad,
				   prima_suscrita
			  into _no_unidad,
				   _prima_suscrita_unidad
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			-- No Existe Emifacon

			select count(*)
			  into _cantidad
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad;

			if _cantidad = 0 then

				select sum(prima)
				  into _prima_emifacon
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;

--{
				let _serie    = year(_vigencia_inic);
				let _cod_ruta = null;

				foreach
					select cod_ruta
					  into _cod_ruta
					  from rearumae
					 where cod_ramo = _cod_ramo
					   and serie    = _serie
					 order by cod_ruta	desc
					exit foreach;
				end foreach

				foreach
					select cod_cober_reas
					  into _cod_cober_reas
					  from reacobre
					 where cod_ramo = _cod_ramo
					 order by cod_cober_reas
					exit foreach;
				end foreach

				foreach
					select orden,
						   cod_contrato,
						   porc_partic_prima,
						   porc_partic_suma
					  into _orden,
						   _cod_contrato,
						   _porc_partic_prima,
						   _porc_partic_suma
					  from rearucon
					 where cod_ruta  = _cod_ruta
					 order by orden

					insert into emifacon(
				    no_poliza,
				    no_endoso,
					no_unidad,
					cod_cober_reas,
				    orden,
				    cod_contrato,
				    porc_partic_prima,
				    porc_partic_suma,
				    suma_asegurada,
				    prima)
					values(	_no_poliza,
							_no_endoso,
							_no_unidad,
							_cod_cober_reas,
							_orden,
							_cod_contrato,
							_porc_partic_prima,
							_porc_partic_suma,
							0,
							0);
				end foreach 	

				delete from emifacon
				 where no_poliza         = _no_poliza
				   and no_endoso         = _no_endoso
				   and no_unidad         = _no_unidad
				   and porc_partic_prima = 0
				   and porc_partic_suma  = 0;

--}
				let _error    = 1;
				let _cantidad = _no_unidad;

				return _no_factura,
				       _prima_suscrita_unidad,
					   _prima_emifacon,
					   _cantidad,
					   _no_poliza,
					   _no_endoso,
					   11,
					   _periodo,
					   _cod_endomov,
					   _cod_tipocalc	
					   with resume;
		   end if

			select sum(prima)
			  into _prima_emifacon
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad;

			let _cantidad = _no_unidad;

			if _prima_suscrita_unidad is null then
				let _prima_suscrita_unidad = 0.00;
			end if

			if abs(_prima_suscrita_unidad - _prima_emifacon) > 0.01 then
				if _cod_endomov <> "018" then
					if _cod_ramo not in ("001", "003") then

						update emifacon
						   set prima     = _prima_suscrita_unidad * porc_partic_prima / 100 
						 where no_poliza = _no_poliza
						   and no_endoso = _no_endoso
						   and no_unidad = _no_unidad;
					end if
				else
					update endeduni
					   set prima_suscrita = _prima_emifacon
					 where no_poliza      = _no_poliza
					   and no_endoso      = _no_endoso
					   and no_unidad      = _no_unidad;
				end if
				
				let _error    = 1;

				return _no_factura,
					   _prima_suscrita_unidad,
				       _prima_emifacon,
					   _cantidad,
					   _no_poliza,
					   _no_endoso,
					   12,
					   _periodo,
					   _cod_endomov,
					   _cod_tipocalc	
					   with resume;
			end if
		end foreach
	end if

	select sum(prima)
	  into _prima_emifacon
	  from emifacon f, reacomae c
	 where f.no_poliza     = _no_poliza
	   and f.no_endoso     = _no_endoso
	   and f.cod_contrato  = c.cod_contrato
	   and c.tipo_contrato = 1;

	if abs(_prima_retenida - _prima_emifacon) > 0.05 then
{
		 update endedmae
			set prima_retenida = _prima_emifacon
		  where no_poliza      = _no_poliza
	        and no_endoso      = _no_endoso;

		 update endedhis
			set prima_retenida = _prima_emifacon
		  where no_poliza      = _no_poliza
	        and no_endoso      = _no_endoso;

--}

		foreach
			select no_unidad,
				   prima_retenida
			  into _no_unidad,
				   _prima_retenida_u
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			let _cantidad = _no_unidad;

			select sum(prima)
			  into _prima_emifacon
			  from emifacon f, reacomae c
			 where f.no_poliza     = _no_poliza
			   and f.no_endoso     = _no_endoso
			   and f.no_unidad     = _no_unidad
			   and f.cod_contrato  = c.cod_contrato
	   		   and c.tipo_contrato = 1;

			if _prima_emifacon is null then
				let _prima_emifacon = 0.00;
			end if

			if _prima_emifacon <> _prima_retenida_u then				
				
				update endeduni
				   set prima_retenida = _prima_emifacon
				 where no_poliza      = _no_poliza
				   and no_endoso      = _no_endoso
				   and no_unidad      = _no_unidad;

				let _error    = 1;

				return _no_factura,
				       _prima_retenida_u,
					   _prima_emifacon,
					   _cantidad,
					   _no_poliza,
					   _no_endoso,
					   13,
					   _periodo,
					   _cod_endomov,
					   _cod_tipocalc	
					   with resume;
			end if
		end foreach
	end if

	-- Primas de Facultativos
	select sum(prima)
	  into _prima_emifacon
	  from emifacon f, reacomae c
	 where f.no_poliza     = _no_poliza
	   and f.no_endoso     = _no_endoso
	   and f.cod_contrato  = c.cod_contrato
	   and c.tipo_contrato = 3;

	select sum(prima)
	  into _prima_emifafac
	  from emifafac f
	 where f.no_poliza     = _no_poliza
	   and f.no_endoso     = _no_endoso;

	if abs(_prima_emifacon - _prima_emifafac) > 0.05 then
		if _prima_emifacon = 0 then
			update emifafac
			   set prima     = 0 
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
		end if 

		let _error = 1;

		return _no_factura,
		       _prima_emifacon,
			   _prima_emifafac,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   14,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc	
			   with resume;
	end if


	if _cod_endomov <> "018" then -- Cambio de Coaseguro
	 
		select porc_partic_coas
		  into _porc_partic_coas
		  from endcoama
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso
		   and cod_coasegur = "036";

		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let _prima_suscrita_unidad = _prima_neta * _porc_partic_coas / 100;

		if abs(_prima_suscrita_unidad - _prima_suscrita_endoso) > 0.05 then

{
				update endedmae
				   set prima_suscrita = _prima_suscrita_unidad
				 where no_factura     = _no_factura;

				update endedhis
				   set prima_suscrita = _prima_suscrita_unidad
				 where no_factura     = _no_factura;
--}

			return _no_factura,
			       _prima_suscrita_endoso,
				   _prima_suscrita_unidad,
				   _cantidad,
				   _no_poliza,
				   _no_endoso,
				   15,
				   _periodo,
				   _cod_endomov,
				   _cod_tipocalc	
				   with resume;

		end if
	end if

	-- Existe Emifacon y No Existe Endeduni
	foreach
		select no_unidad
		  into _no_unidad
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		 group by no_unidad
		 order by no_unidad

		select prima_suscrita
		  into _prima_suscrita_unidad
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _prima_suscrita_unidad is null then

	    delete from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

			let _cantidad = _no_unidad;

			return _no_factura,
			       _prima_suscrita_endoso,
				   _prima_suscrita_unidad,
				   _cantidad,
				   _no_poliza,
				   _no_endoso,
				   16,
				   _periodo,
				   _cod_endomov,
				   _cod_tipocalc	
				   with resume;

		end if
	end foreach
continue foreach;
{
if _error = 1 then

	select count(*)
	  into _cont_endhisfa
	  from endhisfa
	 where no_factura = _no_factura;

	if _cont_endhisfa = 0 then

		insert into endhisfa
		values (_no_factura);

	end if
	
end if

continue foreach;
}
-------------------------------------------------------------------------------
--                              Coberturas
-------------------------------------------------------------------------------


	select sum(prima),
		   sum(descuento),
		   sum(recargo),
		   sum(prima_neta),
		   count(*)
	  into _prima_u,
		   _descuento_u,
		   _recargo_u,
		   _prima_neta_u,
		   _cantidad
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_u is null then
		let _prima_u = 0.00;
	end if

	if _descuento_u is null then
		let _descuento_u = 0.00;
	end if

	if _recargo_u is null then
		let _recargo_u = 0.00;
	end if

	if _prima_neta_u is null then
		let _prima_neta_u = 0.00;
	end if

	if abs(_prima - _prima_u) > 0.05 then

{
		update endedcob
		   set prima      = 0.00,
		       descuento  = 0.00,
			   recargo    = 0.00,
			   prima_neta = 0.00
   	     where no_poliza  = _no_poliza
		   and no_endoso  = _no_endoso;

		foreach
		 select no_unidad,
		        prima,
		   		descuento,
		   		recargo,
		   		prima_neta
		   into _no_unidad,
				_prima_u,
		   		_descuento_u,
		   		_recargo_u,
		   		_prima_neta_u
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			foreach
			 select cod_cobertura,
			        orden
			   into _cod_cobertura,
			        _orden
			   from endedcob
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
				and no_unidad = _no_unidad
			  order by orden, cod_cobertura

				update endedcob
				   set prima     	 = _prima_u,
				       descuento     = _descuento_u,
					   recargo       = _recargo_u,
			   		   prima_neta    = _prima_neta_u
			     where no_poliza     = _no_poliza
			       and no_endoso     = _no_endoso
			       and no_unidad     = _no_unidad
			       and cod_cobertura = _cod_cobertura;

				exit foreach;

			end foreach
	
		end foreach

--}

{
		let _monto = _prima - _prima_u;
			
		while _monto != 0.00

			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad,
			        cod_cobertura
			   into _no_unidad,
			        _cod_cobertura
			   from endedcob
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endedcob
				   set prima     	 = prima + _centavo
			     where no_poliza     = _no_poliza
			       and no_endoso     = _no_endoso
			       and no_unidad     = _no_unidad
			       and cod_cobertura = _cod_cobertura;

			end foreach

		end while
--}
		let _error    = 1;

		return _no_factura,
		       _prima,
			   _prima_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   20,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_descuento - _descuento_u) > 0.05 then

		let _error = 1;

{
		let _porc_descuento = _descuento / _prima;

		update endedcob
		   set descuento     = prima * _porc_descuento
	     where no_poliza     = _no_poliza
	       and no_endoso     = _no_endoso;
--}
{
		let _monto = _descuento - _descuento_u;
		
		while _monto != 0.00

			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad,
			        cod_cobertura
			   into _no_unidad,
			        _cod_cobertura
			   from endedcob
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
				and descuento <> 0.00

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endedcob
				   set descuento     = descuento + _centavo
			     where no_poliza     = _no_poliza
			       and no_endoso     = _no_endoso
			       and no_unidad     = _no_unidad
			       and cod_cobertura = _cod_cobertura;

			end foreach

		end while
--}

		return _no_factura,
		       _descuento,
			   _descuento_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   21,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

--	continue foreach;

	if abs(_recargo - _recargo_u) > 0.05 then

		let _error    = 1;
{
		let _monto = _recargo - _recargo_u;
		
		if _monto > 0.00 then
			let _centavo = +0.01;
		else
			let _centavo = -0.01;
		end if				

		foreach
		 select no_unidad,
		        cod_cobertura
		   into _no_unidad,
		        _cod_cobertura
		   from endedcob
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			if _monto = 0.00 then
				exit foreach;
			end if

			let _monto = _monto - _centavo;
			
			update endedcob
			   set recargo       = recargo + _centavo
		     where no_poliza     = _no_poliza
		       and no_endoso     = _no_endoso
		       and no_unidad     = _no_unidad
		       and cod_cobertura = _cod_cobertura;

		end foreach

--}
		return _no_factura,
		       _recargo,
			   _recargo_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   22,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if abs(_prima_neta - _prima_neta_u) > 0.05 then

		let _error    = 1;

{
		let _monto = _prima_neta - _prima_neta_u;
		
		while _monto != 0.00

			if _monto > 0.00 then
				let _centavo = +0.01;
			else
				let _centavo = -0.01;
			end if				

			foreach
			 select no_unidad,
			        cod_cobertura
			   into _no_unidad,
			        _cod_cobertura
			   from endedcob
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				if _monto = 0.00 then
					exit foreach;
				end if

				let _monto = _monto - _centavo;
				
				update endedcob
				   set prima_neta    = prima_neta + _centavo
			     where no_poliza     = _no_poliza
			       and no_endoso     = _no_endoso
			       and no_unidad     = _no_unidad
			       and cod_cobertura = _cod_cobertura;

			end foreach
		
		end while

--}

		return _no_factura,
		       _prima_neta,
			   _prima_neta_u,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   23,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;

	end if

	if _prima_neta_u = 0 and _prima_suscrita_endoso <> 0.00 and _cod_endomov <> "018" then
{
		if _cantidad = 1 then

			update endedcob
			   set prima_neta = _prima_suscrita_endoso
		     where no_poliza  = _no_poliza
		       and no_endoso  = _no_endoso;

		end if


		foreach
		 select no_unidad,
		        prima,
		   		descuento,
		   		recargo,
		   		prima_neta,
				cod_producto
		   into _no_unidad,
				_prima_u,
		   		_descuento_u,
		   		_recargo_u,
		   		_prima_neta_u,
				_cod_producto
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
	
			let _cod_cobertura = null;
			 
			foreach
			 select cod_cobertura
			   into _cod_cobertura
			   from prdcobpd
			  where cod_producto = _cod_producto
  		   order by cod_cobertura
				exit foreach;
			end foreach		

			if _cod_cobertura is not null then

				insert into endedcob(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cobertura,
				orden,
				tarifa,
				deducible,
				limite_1,
				limite_2,
				prima_anual,
				prima,
				descuento,
				recargo,
				prima_neta,
				date_added,
				date_changed,
				desc_limite1
				)
				values(
				_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cobertura,
				1,
				1,
				"",
				0.00,
				0.00,
				_prima_u,
				_prima_u,
				_descuento_u,
				_recargo_u,
				_prima_neta_u,
				today,
				today,
				""
				);

			end if

		end foreach		
}
		return _no_factura,
		       _prima_suscrita_endoso,
			   0.00,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   24,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;
	end if

	if _cod_endomov = "018" and _cantidad <> 1 and _prima_suscrita_endoso <> 0.00 then 
{
		foreach
		 select no_unidad,
		        prima,
		   		descuento,
		   		recargo,
		   		prima_neta,
				cod_producto
		   into _no_unidad,
				_prima_u,
		   		_descuento_u,
		   		_recargo_u,
		   		_prima_neta_u,
				_cod_producto
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
	
			let _cod_cobertura = null;
			 
			foreach
			 select cod_cobertura
			   into _cod_cobertura
			   from prdcobpd
			  where cod_producto = _cod_producto
  		   order by cod_cobertura
				exit foreach;
			end foreach		

			if _cod_cobertura is not null then

				insert into endedcob(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cobertura,
				orden,
				tarifa,
				deducible,
				limite_1,
				limite_2,
				prima_anual,
				prima,
				descuento,
				recargo,
				prima_neta,
				date_added,
				date_changed,
				desc_limite1
				)
				values(
				_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cobertura,
				1,
				1,
				"",
				0.00,
				0.00,
				_prima_u,
				_prima_u,
				_descuento_u,
				_recargo_u,
				_prima_neta_u,
				today,
				today,
				""
				);

				exit foreach;

			end if

		end foreach		
--}
		return _no_factura,
		       _prima_suscrita_endoso,
			   0.00,
			   _cantidad,
			   _no_poliza,
			   _no_endoso,
			   25,
			   _periodo,
			   _cod_endomov,
			   _cod_tipocalc
			   with resume;
	end if

	if _error = 1 then

		select count(*)
		  into _cont_endhisfa
		  from endhisfa
		 where no_factura = _no_factura;

		if _cont_endhisfa = 0 then
			insert into endhisfa
			values (_no_factura);
		end if		
	end if
end foreach

return "0",
       0.00,
	   0.00,
	   0,
	   null,
	   null,
	   0,
	   null,
	   null,
	   "0"
	   with resume;
end procedure

