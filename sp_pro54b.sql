-- Procedimiento para los calcular los descuentos de la poliza
--
-- Creado    : 15/12/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 15/12/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro54b;
create procedure sp_pro54b(a_poliza char(10), a_unidad char(5),a_general int, a_endoso char(5))
returning   char(50),			 --	v_nombre
			dec(16,2);			 --	v_recargo
	
define v_nombre  	   char(50);
define _no_poliza      char(10);
define _cod_cobertura  char(5);
define _cod_producto   char(5);
define _no_unidad      char(5);
define _no_endoso      char(5);
define _cod_descuen    char(3);
define _cod_recargo    char(3);
define _cod_ramo       char(3);
define _descuento_cob  dec(16,2);
define _descuent_temp  dec(16,2);
define v_descuen_sal   dec(16,2);
define v_recargo_sal   dec(16,2);
define v_porcentaje    dec(16,4);
define _recargo_cob    dec(16,2);
define v_descuento	   dec(16,2);
define v_prima_uni     dec(16,2);
define v_recargo       dec(16,2);
define v_prima         dec(16,2);
define _prima          dec(16,2); 
define _prima_0          dec(16,2); 
define v_orden         int;
define _contador       int;
define _txt_retorno    char(1);

set isolation to dirty read;

let _contador = 1;
let _descuento_cob = 0;
let v_descuen_sal = 0;
let v_recargo_sal = 0;
let _recargo_cob = 0;
let v_descuento = 0;
let v_recargo = 0;
let v_nombre = '';
let _txt_retorno = '0';
let _prima_0 = 0;

create temp table temp_unicob(
no_poliza		char(10),
no_endoso		char(5),
no_unidad		char(5),
cod_cobertura	char(5),
prima			dec(16,2),
prima_0			dec(16,2)) with no log;	  

--set debug file to "sp_pro54b.trc";      
--trace on;                                                                     


if a_general = 1 then
	select sum(prima) 
	  into v_prima
	  from endeduni
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso;
	   
    foreach
		select y.prima,
			   y.no_poliza,
			   y.no_endoso,
			   y.no_unidad,
			   y.cod_cobertura 
		  into _prima,
			   _no_poliza,
			   _no_endoso,
			   _no_unidad,
			   _cod_cobertura
		  from endeduni x, endedcob y, prdcobpd z
		 where y.no_poliza = a_poliza
		   and y.no_endoso = a_endoso
		   and x.no_poliza = y.no_poliza
		   and x.no_endoso = y.no_endoso
		   and x.no_unidad = y.no_unidad
		   and z.cod_producto = x.cod_producto  
		   and z.cod_cobertura = y.cod_cobertura
		   and z.acepta_desc = 1

		insert into temp_unicob(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cobertura,
				prima,
				prima_0)
		values(	_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cobertura,
				_prima,
				_prima);
	end foreach

	foreach
		select x.cod_descuen,
			   y.nombre,
			   y.orden
		  into _cod_descuen,
			   v_nombre,
			   v_orden
		  from endunide x, emidescu y
		 where x.no_poliza = a_poliza
		   and x.no_endoso = a_endoso
		   and y.cod_descuen = x.cod_descuen
		 group by x.cod_descuen, y.nombre, y.orden
		 order by y.orden

 		let v_descuento = 0;

		foreach
			select x.porc_descuento,
				   z.prima,
				   z.cod_producto,
				   z.no_unidad
			  into v_porcentaje,
				   v_prima_uni,
				   _cod_producto,
				   _no_unidad
			  from endunide x, endeduni z
			 where z.no_poliza = x.no_poliza
			   and z.no_endoso = x.no_endoso
			   and z.no_unidad = x.no_unidad
			   and x.no_poliza = a_poliza
			   and x.no_endoso = a_endoso
			   and x.cod_descuen = _cod_descuen

				foreach
					select prima,
						   cod_cobertura
					  into _prima,
						   _cod_cobertura
					  from temp_unicob
					 where no_poliza = a_poliza
					   and no_endoso = a_endoso
					   and no_unidad = _no_unidad

					let _descuento_cob = _prima * v_porcentaje / 100;
					let _prima = _prima -_descuento_cob;
					let v_descuento = v_descuento + _descuento_cob;

					update temp_unicob
					   set prima = _prima
					 where no_poliza = a_poliza
					   and no_endoso = a_endoso
					   and no_unidad = _no_unidad
					   and cod_cobertura = _cod_cobertura;
				end foreach;			
		end foreach;

		let v_prima = v_prima - v_descuento;
 		let v_descuen_sal = v_descuento * -1; 
  --		return
  --		    v_nombre,
  --			v_descuento	with resume;
	end foreach

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = a_poliza;

	if _cod_ramo = "018" then
		select recargo
		  into v_recargo_sal
		  from endedmae
		 where no_poliza = a_poliza
		   and no_endoso = a_endoso;
		   
		if v_recargo_sal = 0 then
			select recargo
			  into v_recargo_sal
			  from emipomae
			 where no_poliza = a_poliza;
		end if
				 
		--se agrego el porcentaje de recargo aplicado a la poliza 24/10/2012
		foreach
			select nombre||porc_recargo||"%" 
			  into v_nombre
			  from emiunire inner join emirecar on  emirecar.cod_recargo = emiunire.cod_recargo
			 where emiunire.no_poliza = a_poliza
			   and emiunire.no_unidad = a_unidad
					
			return v_nombre, v_recargo_sal with resume;
		end foreach	
	else
		foreach					
			select x.cod_recargo
			  into _cod_recargo
			  from endunire x, emirecar y
			 where x.no_poliza = a_poliza
			   and x.no_endoso = a_endoso
			   and y.cod_recargo = x.cod_recargo
			group by x.cod_recargo, y.nombre, x.porc_recargo
					  --select cod_recargo
					  --into _cod_recargo
					  --from emiunire
					 --where no_poliza = a_poliza

			let v_recargo = 0;

			foreach
				select x.porc_recargo,
					   z.prima,
					   z.cod_producto,
					   z.no_unidad
				  into v_porcentaje,
					   v_prima_uni,
					   _cod_producto,
					   _no_unidad
				  from endunire x, endeduni z
				 where z.no_poliza = x.no_poliza
				   and z.no_endoso = x.no_endoso
				   and z.no_unidad = x.no_unidad
				   and x.no_poliza = a_poliza
				   and x.no_endoso = a_endoso
				   and x.cod_recargo = _cod_recargo
{
				foreach
					select prima, cod_cobertura   -- box de sistema ya prima tiene el recargo actuallizado vuelve y recalcula
}
				foreach
					select prima, prima_0, cod_cobertura
					  into _prima, _prima_0, _cod_cobertura
					  from temp_unicob
					 where no_poliza = a_poliza
					   and no_endoso = a_endoso
					   and no_unidad = _no_unidad
					   
					   if trim(a_poliza) in ('1676959','1676920') then -- validar
					      let _prima = _prima_0;					   
					   end if

					let _recargo_cob = _prima * v_porcentaje / 100;
					let _prima       = _prima + _recargo_cob;
					let v_recargo    = v_recargo + _recargo_cob;

					update temp_unicob
					   set prima = _prima
					 where no_poliza = a_poliza
					   and no_endoso = a_endoso
					   and no_unidad = _no_unidad
					   and cod_cobertura = _cod_cobertura;
				end foreach;
			end foreach;

			let v_prima = v_prima + v_recargo;
			let v_recargo_sal = v_recargo; 

			if v_recargo_sal = 0 then
				continue foreach;
			end if

				 /*   select cod_ramo
					  into _cod_ramo
					  from emipomae
					 where no_poliza = a_poliza;

						if _cod_ramo = "018" then
							select recargo
							  into v_recargo_sal
							  from emipomae
							 where no_poliza = a_poliza;
							 
					--se agrego el porcentaje de recargo aplicado a la poliza 24/10/2012
							select nombre||porc_recargo||"%" 
							into   v_nombre
							from emiunire inner join emirecar on  emirecar.cod_recargo = emiunire.cod_recargo
							where emiunire.no_poliza = a_poliza
							  and emiunire.no_unidad = a_unidad;
							
							if v_recargo_sal = 0 then
								continue foreach;
							end if
						end if
				*/
			let _txt_retorno = '1';
			return	v_nombre,
					v_recargo_sal with resume;

		end foreach
	end if	
	
else
	select sum(prima)
	  into v_prima
	  from endeduni
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad;

    select cod_ramo 
	  into _cod_ramo
	  from emipomae
	 where no_poliza = a_poliza;

    if _cod_ramo <> "020" then
		if _cod_ramo = '018' then
		    foreach
				select y.prima,
					   y.no_poliza,
					   y.no_unidad,
					   y.cod_cobertura 
				  into _prima,
					   _no_poliza,
					   _no_unidad,
					   _cod_cobertura
				  from emipouni x, emipocob y, prdcobpd z
				 where y.no_poliza = a_poliza
				   and y.no_unidad = a_unidad
				   and x.no_poliza = y.no_poliza
				   and x.no_unidad = y.no_unidad
				   and z.cod_producto = x.cod_producto  
				   and z.cod_cobertura = y.cod_cobertura
				   and z.acepta_desc = 1

				insert into temp_unicob(
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cobertura,
						prima)
			  values(	_no_poliza,
						a_endoso,
						_no_unidad,
						_cod_cobertura,
						_prima);
			end foreach
		else
			foreach
				select y.prima,
					   y.no_poliza,
					   y.no_endoso,
					   y.no_unidad,
					   y.cod_cobertura 
				  into _prima,
					   _no_poliza,
					   _no_endoso,
					   _no_unidad,
					   _cod_cobertura
				  from endeduni x, endedcob y, prdcobpd z
				 where y.no_poliza = a_poliza
				   and y.no_endoso = a_endoso
				   and y.no_unidad = a_unidad
				   and x.no_poliza = y.no_poliza
				   and x.no_endoso = y.no_endoso
				   and x.no_unidad = y.no_unidad
				   and z.cod_producto = x.cod_producto  
				   and z.cod_cobertura = y.cod_cobertura
				   and z.acepta_desc = 1

				insert into temp_unicob(
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cobertura,
						prima)
				values(	_no_poliza,
						_no_endoso,
						_no_unidad,
						_cod_cobertura,
						_prima);
			end foreach
		end if

		foreach	
			select y.orden,
				   y.nombre,
				   x.porc_descuento
			  into v_orden,
				   v_nombre,
				   v_porcentaje
			  from endunide x, emidescu y
			 where y.cod_descuen = x.cod_descuen
			   and x.no_poliza = a_poliza
			   and x.no_unidad = a_unidad
			   and x.no_endoso = a_endoso
			 order by y.orden

            if v_porcentaje is null then
				continue foreach;
			end if

			let v_descuento = 0;

			foreach
				select prima,
					   cod_cobertura
				  into _prima,
					   _cod_cobertura
				  from temp_unicob
				 where no_poliza = a_poliza
				   and no_endoso = a_endoso
				   and no_unidad = a_unidad
				   and prima <> 0

				let _descuento_cob = _prima * v_porcentaje / 100;
				let _prima = _prima -_descuento_cob;
				let v_descuento = v_descuento + _descuento_cob;

				update temp_unicob
				   set prima = _prima
				 where no_poliza = a_poliza
				   and no_endoso = a_endoso
				   and no_unidad = a_unidad
				   and cod_cobertura = _cod_cobertura;
			end foreach;

			let v_prima = v_prima - v_descuento;
			let v_descuen_sal = v_descuento * -1; 			
		end foreach;

		foreach	
			select x.porc_recargo
			  into v_porcentaje
			  from endunire x, emirecar y
			 where y.cod_recargo = x.cod_recargo
			   and x.no_poliza = a_poliza
			   and x.no_unidad = a_unidad
			   and x.no_endoso = a_endoso

			let v_recargo = 0;

			foreach
				select prima,
					   cod_cobertura
				  into _prima,
					   _cod_cobertura
				  from temp_unicob
				 where no_poliza = a_poliza
				   and no_endoso = a_endoso
				   and no_unidad = a_unidad
				   and prima <> 0

				let _recargo_cob = _prima * v_porcentaje / 100;
				let _prima       = _prima + _recargo_cob;
				let v_recargo    = v_recargo + _recargo_cob;

				update temp_unicob
				   set prima = _prima
				 where no_poliza = a_poliza
				   and no_endoso = a_endoso
				   and no_unidad = a_unidad
				   and cod_cobertura = _cod_cobertura;
			end foreach;

	 		let v_prima = v_prima + v_recargo;
	 		let v_recargo_sal = v_recargo;			
		end foreach;

		if _cod_ramo = "018" then
		    select recargo
			  into v_recargo_sal
			  from emipomae
			 where no_poliza = a_poliza;
		end if

		--se agrego el porcentaje de recargo aplicado a la poliza 24/10/2012
		foreach
			select nombre||porc_recargo||"%" 
			  into v_nombre
			  from emiunire inner join emirecar on  emirecar.cod_recargo = emiunire.cod_recargo
			 where emiunire.no_poliza = a_poliza
			   and emiunire.no_unidad = a_unidad
				 

			if v_recargo_sal = 0 then
			else
				let _txt_retorno = '2';
				return v_nombre, v_recargo_sal	with resume;
			end if
		end foreach	
	else
		foreach
			select sum(recargo)
			  into v_recargo_sal
			  from endedcob
		     where no_poliza = a_poliza
		       and no_endoso = a_endoso
		       and no_unidad = a_unidad

	        if v_recargo_sal = 0 then
				continue foreach;
			end if

	        let v_nombre = "";
            let _txt_retorno = '3';
			return v_nombre, v_recargo_sal	with resume;
		end foreach		
	end if
end if

drop table temp_unicob;

end procedure;